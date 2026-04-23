------------------------------------------------------------------------
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-10-29
-- Description:         Feature Station迁移， underwriting_buyer 宽表
-- Data Granularity:    platform_user_id
-- PRD:                 
------------------------------------------------------------------------

--drop table if exists ${SCHEMA}.ads_risk_th_fs_seamoney_underwriting_buyer_df;
create table if not exists ${SCHEMA}.ads_risk_th_fs_seamoney_underwriting_buyer_df (
    platform_user_id                         string comment 'platform_user_id'
    ,is_seller                               bigint comment 'is seller or not, 1: seller, 0: not seller'
    ,shopee_age                              bigint comment 'days count since shopee account created'
    ,is_phone_verified                       bigint comment 'is phone verified, 1: verified, 0: not verified'
    ,app_support_flag                        bigint comment 'app support flag, 1: supported, 0: not supported'
    ,uw_repayment_channel_flag               bigint comment 'user has used supported repayment channel in past 180 days or not, 1: yes, 0: no'
    ,uw_payment_channel                      string comment 'underwriting payment channel name'
    ,uw_payment_channel_code                 bigint comment 'underwriting payment channel code'
    ,uw_cod_percent_360d                     double comment 'COD (Cash on Delivery) percentage in 360 days'
    ,uw_cod_percent_90d                      double comment 'COD (Cash on Delivery) percentage in 90 days'
    ,uw_abs_usd_360d                         double comment 'absolute USD GMV in 360 days'
    ,uw_cod_percent_180d                     double comment 'COD (Cash on Delivery) percentage in 180 days'
    ,uw_confirmed_gmv_usd_90d_spl_exclude    double comment 'confirmed GMV in USD in 90 days (SPL excluded)'
    ,sl_max_dpd_l1m                          bigint comment 'max days past due in last 1 month'
    ,sl_max_dpd_l3m                          bigint comment 'max days past due in last 3 months'
    ,sl_max_dpd_l6m                          bigint comment 'max days past due in last 6 months'
    ,sl_max_dpd_l12m                         bigint comment 'max days past due in last 12 months'
    ,has_repaid_bcl_bills_flag               bigint comment 'has repaid BCL bills flag, 1: yes, 0: no'
    ,latest_spl_th_activation_till_now_days  bigint comment 'days from latest SPL TH activation till now, -9999: no activation'
    ,user_risk_level                         string comment 'user risk level'
    ,dp_abtesting_user_tag_th                string comment 'data platform AB testing user tag for TH'
    ,th_seller_order_cancel_rate_past15d     bigint comment 'TH seller order cancel rate in past 15 days'
    ,avg_spl_limit_utilization_in_360d       double comment 'average SPL limit utilization in 360 days, -9999: no data'
    ,max_spl_limit_utilization_in_360d       double comment 'max SPL limit utilization in 360 days, -9999: no data'
    ,currnet_spl_limit_utilization           double comment 'current SPL limit utilization, -9999: no data'
) 
comment 'risk feature summary table'
partitioned by (
    grass_date string comment 'grass_date, partition key'
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/ads/ads_risk_fs_seamoney_underwriting_buyer_df/grass_region=TH'
;
--msck repair table ${SCHEMA}.ads_risk_th_fs_seamoney_underwriting_buyer_df;

insert overwrite table risk.ads_risk_th_fs_seamoney_underwriting_buyer_df partition (grass_date = '${grass_date}')
select 
t1.platform_user_id
,t1.is_seller
,t1.shopee_age
,t1.is_phone_verified
,t2.app_support_flag
,t3.uw_repayment_channel_flag
,t3.uw_payment_channel
,t3.uw_payment_channel_code
,t3.uw_cod_percent_360d
,t3.uw_cod_percent_90d
,t3.uw_abs_usd_360d
,t3.uw_cod_percent_180d
,t3.uw_confirmed_gmv_usd_90d_spl_exclude
,t5.sl_max_dpd_l1m
,t5.sl_max_dpd_l3m
,t5.sl_max_dpd_l6m
,t5.sl_max_dpd_l12m
,t7.has_repaid_bcl_bills_flag
,coalesce(t6.latest_spl_th_activation_till_now_days,-9999) as latest_spl_th_activation_till_now_days
,t8.user_risk_level
,t8.dp_abtesting_user_tag_th
,t8.th_seller_order_cancel_rate_past15d
,t9.avg_spl_limit_utilization_in_360d
,t9.max_spl_limit_utilization_in_360d
,t9.currnet_spl_limit_utilization
from (
    select
        platform_user_id
        ,is_seller
        ,shopee_age
        ,is_phone_verified
    from ${SCHEMA}.dim_risk_th_user_info_df
    where grass_date = '${grass_date}'
) t1  
left join (
    select 
        platform_user_id
        ,app_support_flag
    from risk.dws_risk_th_user_behavior_app_info_df
    where grass_date = '${grass_date}'
) t2 on t1.platform_user_id = t2.platform_user_id
left join (
    select 
    shopee_user_id as platform_user_id
    ,uw_repayment_channel_flag
    ,uw_payment_channel
    ,uw_payment_channel_code
    ,uw_cod_percent_360d
    ,uw_cod_percent_90d
    ,uw_abs_usd_360d
    ,uw_cod_percent_180d
    ,uw_confirmed_gmv_usd_90d_spl_exclude
    from risk_feature.dws_risk_th_user_txn_mp_feature_df
    where grass_date ='${grass_date}'
)t3 on t1.platform_user_id = t3.platform_user_id
left join (
    select 
    platform_user_id
    ,sl_max_dpd_l1m
    ,sl_max_dpd_l3m
    ,sl_max_dpd_l6m
    ,sl_max_dpd_l12m
    from risk.dws_risk_th_shop_txn_fp_repayment_df
    where grass_date ='${grass_date}'
) t5 on t1.platform_user_id = t5.platform_user_id
left join (
    select 
    platform_user_id
    ,max(case when reactivate_time is not null then datediff('${grass_date}',to_date(reactivate_time))
          else datediff('${grass_date}',to_date(activation_time)) end)  as latest_spl_th_activation_till_now_days
    from credit_uc.dws_spl_th_uc_user_df
    where grass_date ='${grass_date}'
    group by platform_user_id
) t6 on t1.platform_user_id = t6.platform_user_id
left join (
    select 
    platform_user_id
    ,case when first_due_time_bcl<='${grass_date}' then 1 else 0 end has_repaid_bcl_bills_flag
    from (
    select
        platform_user_id
        ,min(first_instalment_due_time) as first_due_time_bcl
    from credit_mart.dws_bcl_th_loan_repayment_df
    where grass_date = '${grass_date}'
    and principal_repayable - principal_refund - principal_deduct> 0
    group by platform_user_id
    ) t 
) t7 on t1.platform_user_id = t7.platform_user_id
left join
(
    select
        platform_user_id
        ,user_risk_level
        ,dp_abtesting_user_tag_th
        ,th_seller_order_cancel_rate_past15d
    from ${SCHEMA}.dws_risk_th_user_metrics_biz_manage_df
    where grass_date = '${grass_date}'
) t8 on t1.platform_user_id = t8.platform_user_id
left join (
    select
        platform_user_id
        ,avg_spl_limit_utilization_in_360d
        ,max_spl_limit_utilization_in_360d
        ,currnet_spl_limit_utilization
    from risk.dws_risk_th_user_txn_fp_limit_df
    where grass_date = '${grass_date}'
) t9 on t1.platform_user_id = t9.platform_user_id
;