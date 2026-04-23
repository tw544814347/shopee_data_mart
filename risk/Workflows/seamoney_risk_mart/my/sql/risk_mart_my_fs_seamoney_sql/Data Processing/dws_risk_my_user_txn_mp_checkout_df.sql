--drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_checkout_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_checkout_df (
    platform_user_id                        string     comment 'platform user id',
    webcheckout_escrow_paid_order_cnt_30d   bigint     comment 'Escrow paid order cnt in 30 days',
    webcheckout_escrow_paid_order_cnt_60d   bigint     comment 'Escrow paid order cnt in 60 days',
    webcheckout_escrow_paid_order_cnt_90d   bigint     comment 'Escrow paid order cnt in 90 days',
    webcheckout_escrow_paid_order_cnt_120d  bigint     comment 'Escrow paid order cnt in 120 days',
    webcheckout_escrow_paid_order_cnt_150d  bigint     comment 'Escrow paid order cnt in 150 days',
    webcheckout_escrow_paid_order_cnt_180d  bigint     comment 'Escrow paid order cnt in 180 days',
    user_webcheckout_frequency_180d         bigint     comment 'cnt_buyer_webcheckout_frequency'
)
partitioned by (
    grass_date                              string     comment "Partition, YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_aio_user_txn_mp_checkout_df/grass_region=${region_uppercase}';

--msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_mp_checkout_df;

--6个月内在shopee 里escrow paid 的所有订单
--与“过去xx 天”有关，看过去180天，所以取180+2天
with base as (
    select
         buyer_id                                   as platform_user_id
        ,order_id
        ,checkout_channel_id
        ,date(from_unixtime(create_timestamp))      as order_create_day
        ,date(from_unixtime(escrow_paid_timestamp)) as escrow_paid_day
    from mp_order.dwd_order_all_ent_df__reg_s0_live
    where tz_type = 'local'
      and grass_region = '${region_uppercase}'
      and grass_date > current_date - interval 182 day
      and grass_date < current_date
      and to_date(from_unixtime(create_timestamp))  > current_date - interval 182 day
      and order_be_status = 'ESCROW_PAID'
)

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_mp_checkout_df partition (grass_date = '${ds}')
select
     a.platform_user_id                                                                                         as platform_user_id
    ,nvl(webcheckout_escrow_paid_order_cnt_30d, 0)                                                              as webcheckout_escrow_paid_order_cnt_30d
    ,nvl(webcheckout_escrow_paid_order_cnt_60d, 0)                                                              as webcheckout_escrow_paid_order_cnt_60d
    ,nvl(webcheckout_escrow_paid_order_cnt_90d, 0)                                                              as webcheckout_escrow_paid_order_cnt_90d
    ,nvl(webcheckout_escrow_paid_order_cnt_120d, 0)                                                             as webcheckout_escrow_paid_order_cnt_120d
    ,nvl(webcheckout_escrow_paid_order_cnt_150d, 0)                                                             as webcheckout_escrow_paid_order_cnt_150d
    ,nvl(webcheckout_escrow_paid_order_cnt_180d, 0)                                                             as webcheckout_escrow_paid_order_cnt_180d
    ,is_pc_order_0_1m + is_pc_order_1_2m + is_pc_order_2_3m + is_pc_order_3_4m 
    + is_pc_order_4_5m + is_pc_order_5_6m                                                                       as user_webcheckout_frequency_180d
from
    (select platform_user_id from ${SCHEMA}.dim_risk_${region}_user_info_df where grass_date = '${ds}') a
left join
    (select
         platform_user_id
        ,sum(case when checkout_channel_id = 2 and datediff(current_date, escrow_paid_day) <= 30 then 1 else 0 end)  as webcheckout_escrow_paid_order_cnt_30d
        ,sum(case when checkout_channel_id = 2 and datediff(current_date, escrow_paid_day) <= 60 then 1 else 0 end)  as webcheckout_escrow_paid_order_cnt_60d
        ,sum(case when checkout_channel_id = 2 and datediff(current_date, escrow_paid_day) <= 90 then 1 else 0 end)  as webcheckout_escrow_paid_order_cnt_90d
        ,sum(case when checkout_channel_id = 2 and datediff(current_date, escrow_paid_day) <= 120 then 1 else 0 end) as webcheckout_escrow_paid_order_cnt_120d
        ,sum(case when checkout_channel_id = 2 and datediff(current_date, escrow_paid_day) <= 150 then 1 else 0 end) as webcheckout_escrow_paid_order_cnt_150d
        ,sum(case when checkout_channel_id = 2 and datediff(current_date, escrow_paid_day) <= 180 then 1 else 0 end) as webcheckout_escrow_paid_order_cnt_180d
        ,max(case when checkout_channel_id = 2 and datediff(current_date, escrow_paid_day) <= 30 then 1 else 0 end)                                                    as is_pc_order_0_1m
        ,max(case when checkout_channel_id = 2 and datediff(current_date, escrow_paid_day) <= 60 and datediff(current_date, escrow_paid_day) > 30 then 1 else 0 end)   as is_pc_order_1_2m
        ,max(case when checkout_channel_id = 2 and datediff(current_date, escrow_paid_day) <= 90 and datediff(current_date, escrow_paid_day) > 60 then 1 else 0 end)   as is_pc_order_2_3m
        ,max(case when checkout_channel_id = 2 and datediff(current_date, escrow_paid_day) <= 120 and datediff(current_date, escrow_paid_day) > 90 then 1 else 0 end)  as is_pc_order_3_4m
        ,max(case when checkout_channel_id = 2 and datediff(current_date, escrow_paid_day) <= 150 and datediff(current_date, escrow_paid_day) > 120 then 1 else 0 end) as is_pc_order_4_5m
        ,max(case when checkout_channel_id = 2 and datediff(current_date, escrow_paid_day) <= 180 and datediff(current_date, escrow_paid_day) > 150 then 1 else 0 end) as is_pc_order_5_6m
    from base
    group by 1
    ) b
on a.platform_user_id = b.platform_user_id
;