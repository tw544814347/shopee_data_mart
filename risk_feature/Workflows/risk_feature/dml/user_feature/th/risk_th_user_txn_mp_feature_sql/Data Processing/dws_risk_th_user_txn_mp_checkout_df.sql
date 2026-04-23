-- =============================================================================
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-10-30
-- Theme Domain:        User Txn MP Checkout Feature
-- Data Granularity:    shopee_user_id
-- Description:         MP用户交易 - 下单渠道特征表
-- Documents:           https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit?gid=198466448#gid=198466448
-- =============================================================================
--  Version History:
--  2024-10-30 - zongyi.lu - 初始化
--  2026-01-21 - chengguo.liu - 按主题规范开发
-- =============================================================================


--drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_checkout_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_checkout_df
(
    shopee_user_id                              string         comment 'shopee user id'
    ,platform_user_id                           string         comment 'shopeepay user id, 暂时保留兼容历史'
    ,cnt_buyer_pccheckout_frequency             int            comment '用户PC端下单频次(近180天内)'
    ,is_pc_order_0_1m                           int            comment '近1个月内是否有PC端订单'
    ,is_pc_order_1_2m                           int            comment '近1-2个月内是否有PC端订单'
    ,is_pc_order_2_3m                           int            comment '近2-3个月内是否有PC端订单'
    ,is_pc_order_3_4m                           int            comment '近3-4个月内是否有PC端订单'
    ,is_pc_order_4_5m                           int            comment '近4-5个月内是否有PC端订单'
    ,is_pc_order_5_6m                           int            comment '近5-6个月内是否有PC端订单'
)
comment 'risk feature summary table - user mp checkout feature'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_aio_user_txn_mp_checkout_df/grass_region=TH';
--msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_mp_checkout_df;


add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

create or replace temporary view tmp_user_pc_order_feature as
select 
    t1.buyer_id as shopee_user_id
    , max(case when t1.checkout_channel_id = 2 and t1.escrow_paid_day >= date_sub('${grass_date}',30) then 1 else 0 end) is_pc_order_0_1m
    , max(case when t1.checkout_channel_id = 2 and t1.escrow_paid_day >= date_sub('${grass_date}',60) and t1.escrow_paid_day < date_sub('${grass_date}',30) then 1 else 0 end) is_pc_order_1_2m
    , max(case when t1.checkout_channel_id = 2 and t1.escrow_paid_day >= date_sub('${grass_date}',90) and t1.escrow_paid_day < date_sub('${grass_date}',60) then 1 else 0 end) is_pc_order_2_3m
    , max(case when t1.checkout_channel_id = 2 and t1.escrow_paid_day >= date_sub('${grass_date}',120) and t1.escrow_paid_day < date_sub('${grass_date}',90) then 1 else 0 end) is_pc_order_3_4m
    , max(case when t1.checkout_channel_id = 2 and t1.escrow_paid_day >= date_sub('${grass_date}',150) and t1.escrow_paid_day < date_sub('${grass_date}',120) then 1 else 0 end) is_pc_order_4_5m
    , max(case when t1.checkout_channel_id = 2 and t1.escrow_paid_day >= date_sub('${grass_date}',180) and t1.escrow_paid_day < date_sub('${grass_date}',180) then 1 else 0 end) is_pc_order_5_6m
    from (
        select 
            buyer_id
            , order_id
            , checkout_channel_id 
            , to_date(format_time(create_timestamp,'TH'))      as  order_create_day
            , to_date(format_time(escrow_paid_timestamp,'TH')) as  escrow_paid_day
        from mp_order.dwd_order_all_ent_df__th_s0_live
        where grass_date >= date_sub('${grass_date}',182)
        and to_date(format_time(create_timestamp,'TH'))>=date_sub('${grass_date}',182)
        and grass_date <='${grass_date}'
        and tz_type='local'
        and order_be_status = 'ESCROW_PAID'
    ) t1 
    group by buyer_id
;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_mp_checkout_df partition (grass_date = '${grass_date}')
select
    t1.shopee_user_id
    ,t1.shopee_user_id as platform_user_id
    ,t2.is_pc_order_0_1m + t2.is_pc_order_1_2m + t2.is_pc_order_2_3m + t2.is_pc_order_3_4m + t2.is_pc_order_4_5m + t2.is_pc_order_5_6m as cnt_buyer_pccheckout_frequency
    ,t2.is_pc_order_0_1m
    ,t2.is_pc_order_1_2m
    ,t2.is_pc_order_2_3m
    ,t2.is_pc_order_3_4m
    ,t2.is_pc_order_4_5m
    ,t2.is_pc_order_5_6m
from 
(
    select
        user_id as shopee_user_id
    from mp_user.dim_user__reg_s0_live
    where
        tz_type = 'local'
        and grass_region = '${grass_region}'
        and grass_date = '${grass_date}'
) t1
left join tmp_user_pc_order_feature t2 on t1.shopee_user_id = t2.shopee_user_id
;
