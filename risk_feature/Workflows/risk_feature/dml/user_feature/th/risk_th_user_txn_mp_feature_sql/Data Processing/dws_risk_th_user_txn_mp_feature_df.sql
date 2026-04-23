-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-11-18
-- Theme Domain:        User Txn MP Feature
-- Data Granularity:    shopee_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-03-11 - chengguo.liu - 初始化
-- =============================================================================

drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_feature_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_feature_df
(
    shopee_user_id string comment 'shopee user id'
    ,uw_cod_percent_360d double comment 'COD confirmed order ratio in last 360 days (cod_order_cnt / total_confirmed_order_cnt)'
    ,uw_cod_percent_90d double comment 'COD confirmed order ratio in last 90 days (cod_order_cnt / total_confirmed_order_cnt)'
    ,uw_abs_usd_360d double comment 'average basket size in USD in last 360 days (confirmed_gmv_usd / confirmed_order_cnt)'
    ,uw_cod_percent_180d double comment 'COD confirmed order ratio in last 180 days (cod_order_cnt / total_confirmed_order_cnt)'
    ,uw_confirmed_gmv_usd_90d_spl_exclude double comment 'confirmed GMV in USD in last 90 days, excluding SPL (payment_channel=others only)'
    ,completed_order_avg_duration_1m bigint comment 'average completed order duration in last 1 month (30 days)'
    ,completed_order_avg_duration_3m bigint comment 'average completed order duration in last 3 months (90 days)'
    ,completed_order_avg_duration_6m bigint comment 'average completed order duration in last 6 months (180 days)'
    ,last3_completed_order_avg_duration_3m bigint comment 'average completed order duration in last 3 months (90 days) for the last 3 completed orders'
    ,cnt_buyer_pccheckout_frequency bigint comment 'checkout frequency in last 90 days'
    ,uw_repayment_channel_flag bigint comment 'repayment channel flag'
    ,uw_payment_channel string comment 'payment channel'
    ,uw_payment_channel_code bigint comment 'payment channel code'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_txn_mp_feature_df/grass_region=${grass_region}';
msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_mp_feature_df;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_mp_feature_df partition (grass_date = '${grass_date}')
select
    t1.shopee_user_id
    ,t2.uw_cod_percent_360d
    ,t2.uw_cod_percent_90d
    ,t2.uw_abs_usd_360d
    ,t2.uw_cod_percent_180d
    ,t2.uw_confirmed_gmv_usd_90d_spl_exclude
    ,t2.completed_order_avg_duration_1m
    ,t2.completed_order_avg_duration_3m
    ,t2.completed_order_avg_duration_6m
    ,t2.last3_completed_order_avg_duration_3m
    ,t3.cnt_buyer_pccheckout_frequency
    ,t4.uw_repayment_channel_flag
    ,t4.uw_payment_channel
    ,t4.uw_payment_channel_code
from (
    select  user_id as shopee_user_id
    from mp_user.dim_user__reg_s0_live
    where   tz_type = 'local'
    and grass_region = '${grass_region}'
    and grass_date = '${grass_date}'
) t1
left join
(
    select
        shopee_user_id
        ,uw_cod_percent_360d
        ,uw_cod_percent_90d
        ,uw_abs_usd_360d
        ,uw_cod_percent_180d
        ,uw_confirmed_gmv_usd_90d_spl_exclude
        ,completed_order_avg_duration_1m
        ,completed_order_avg_duration_3m
        ,completed_order_avg_duration_6m
        ,last3_completed_order_avg_duration_3m
    from ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df
    where grass_date = '${grass_date}'
) t2
on t1.shopee_user_id = t2.shopee_user_id
left join
(
    select
        shopee_user_id
        ,cnt_buyer_pccheckout_frequency
    from ${SCHEMA}.dws_risk_${region}_user_txn_mp_checkout_df
    where grass_date = '${grass_date}'
) t3
on t1.shopee_user_id = t3.shopee_user_id
left join
(
    select
        shopee_user_id
        ,uw_repayment_channel_flag
        ,uw_payment_channel
        ,uw_payment_channel_code
    from ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_payment_df
    where grass_date = '${grass_date}'
) t4
on t1.shopee_user_id = t4.shopee_user_id
;