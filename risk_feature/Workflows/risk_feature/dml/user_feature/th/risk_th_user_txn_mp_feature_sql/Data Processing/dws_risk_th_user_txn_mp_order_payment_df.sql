--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-10-30
-- Theme Domain：       feature station 迁移
-- Description:         feature station 迁移
-- Data Granularity:    https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit?gid=1104704143#gid=1104704143
-- 变更历史
--********************************************************************--

--drop table if exists ${SCHEMA}.dws_risk_th_user_txn_mp_order_payment_df;
create external table if not exists ${SCHEMA}.dws_risk_th_user_txn_mp_order_payment_df (
    shopee_user_id                                    string     comment 'shopee user id',
    platform_user_id                                  string     comment 'platform user id',
    uw_repayment_channel_flag                         bigint     comment 'uw_repayment_channel_flag',
    uw_payment_channel                                string     comment 'uw_payment_channel',
    uw_payment_channel_code                           bigint     comment 'uw_payment_channel_code'
)
partitioned by (
    grass_date                                        string     comment "Partition, YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_aio_user_txn_mp_order_payment_df/grass_region=TH';
--msck repair table ${SCHEMA}.dws_risk_th_user_txn_mp_order_payment_df;

create or replace temporary view uw_payment_channel_feature as
select 
t1.platform_user_id
,case when t1.airpay_sum + t1.ibanking_sum>=1 then 1 else 0  end as uw_repayment_channel_flag
,case when t1.airpay_sum>=1 then 'shopeepay_channel'
      when t1.ibanking_sum>=1 then 'ibanking_channel'
      else 'other_channel' end as uw_payment_channel
,t1.uw_payment_channel_code 
from (
    select 
    platform_user_id
    ,sum(case when payment_be_channel in ('label_airpay_giro','label_airpay_wallet') then 1 else 0 end) as airpay_sum
    ,sum(case when payment_be_channel='label_ibanking'then 1 else 0 end) as ibanking_sum
    ,min(case when payment_method_id = 30 then 1 
              when payment_method_id = 28 then 2
              when payment_method_id = 4 then 3
              when payment_method_id in(18,23) then 4
              when payment_method_id = 50 then 5
              when payment_method_id = 2 and payment_be_channel_id <> 71000 then 6
              when payment_method_id = 2 and payment_be_channel_id = 71000 then 7
              when payment_method_id = 6 then 8
              else 9 end) as uw_payment_channel_code
    from ${SCHEMA}.dwd_risk_th_user_txn_mp_order_complete_df
    where grass_date ='${grass_date}'
    and order_be_status_id in (4, 11, 12, 13, 14, 15)
    and is_bi_excluded = 0
    and has_return_item = 0
    and is_net_order = 1 
    group by platform_user_id
) t1
;

insert overwrite table ${SCHEMA}.dws_risk_th_user_txn_mp_order_payment_df partition(grass_date ='${grass_date}')
select
    t1.platform_user_id as shopee_user_id
    ,t1.platform_user_id
    ,t2.uw_repayment_channel_flag
    ,t2.uw_payment_channel
    ,t2.uw_payment_channel_code
from
(
    select
        user_id as platform_user_id
    from mp_user.dim_user__reg_s0_live
    where
        tz_type = 'local'
        and grass_region = '${grass_region}'
        and grass_date = '${grass_date}'
) t1
left join uw_payment_channel_feature t2
on t1.platform_user_id = t2.platform_user_id
;