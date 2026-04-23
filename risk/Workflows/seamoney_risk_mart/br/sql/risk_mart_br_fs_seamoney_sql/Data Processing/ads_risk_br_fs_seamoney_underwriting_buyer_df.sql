-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-03-24
-- Theme Domain:        FS迁移,underwriting_buyer 宽表
-- Data Granularity:    platform_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-03-24 - chengguo.liu - 初始化
-- =============================================================================


drop table if exists ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_buyer_df;
create table if not exists ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_buyer_df (
    shopee_user_id string comment 'platform_user_id'
    ,platform_user_id string comment 'platform_user_id'
    ,is_phone_verified bigint comment 'is phone verified'
    ,shopee_age bigint comment 'shopee age'
    ,confirmed_gmv_usd_in_30d_br decimal(30, 10) comment 'Confirmed GMV USD in last 30 days'
    ,confirmed_gmv_usd_in_60d_br decimal(30, 10) comment 'Confirmed GMV USD in last 60 days'
    ,confirmed_gmv_usd_in_90d_br decimal(30, 10) comment 'Confirmed GMV USD in last 90 days'
    ,confirmed_gmv_usd_in_180d_br decimal(30, 10) comment 'Confirmed GMV USD in last 180 days'
    ,confirmed_gmv_usd_in_360d_br decimal(30, 10) comment 'Confirmed GMV USD in last 360 days'
    ,confirmed_gmv_usd_in_lifetime_br decimal(30, 10) comment 'Confirmed GMV USD in lifetime'
    ,confirmed_order_in_30d_br bigint comment 'Confirmed order in last 30 days'
    ,confirmed_order_in_60d_br bigint comment 'Confirmed order in last 60 days'
    ,confirmed_order_in_90d_br bigint comment 'Confirmed order in last 90 days'
    ,confirmed_order_in_180d_br bigint comment 'Confirmed order in last 180 days'
    ,confirmed_order_in_360d_br bigint comment 'Confirmed order in last 360 days'
    ,confirmed_order_in_lifetime_br bigint comment 'Confirmed order in lifetime'
    ,pctg_of_cc__order_in_30d_br double comment 'Percentage of cc installment orders in last 30 days'
    ,pctg_of_cc__order_in_90d_br double comment 'Percentage of cc installment orders in last 90 days'
    ,pctg_of_cc__order_in_180d_br double comment 'Percentage of cc installment orders in last 180 days'
    ,pctg_of_cc__order_in_360d_br double comment 'Percentage of cc installment orders in last 360 days'
    ,pctg_of_cc__order_in_lifetime_br double comment 'Percentage of cc installment orders in lifetime'
    ,pctg_of_cc__gmv_in_30d_br double comment 'Percentage of cc installment gmv in last 30 days'
    ,pctg_of_cc__gmv_in_90d_br double comment 'Percentage of cc installment gmv in last 90 days'
    ,pctg_of_cc__gmv_in_180d_br double comment 'Percentage of cc installment gmv in last 180 days'
    ,pctg_of_cc__gmv_in_360d_br double comment 'Percentage of cc installment gmv in last 360 days'
    ,pctg_of_cc__gmv_in_lifetime_br double comment 'Percentage of cc installment gmv in lifetime'
    ,abs_usd_in_30d_br decimal(30, 10) comment 'ABS of confirmed orders in last 30 days'
    ,abs_usd_in_90d_br decimal(30, 10) comment 'ABS of confirmed orders in last 90 days'
    ,abs_usd_in_180d_br decimal(30, 10) comment 'ABS of confirmed orders in last 180 days'
    ,abs_usd_in_360d_br decimal(30, 10) comment 'ABS of confirmed orders in last 360 days'
    ,abs_usd_in_lifetime_br decimal(30, 10) comment 'ABS of confirmed orders in lifetime'
    ,is_app_version_supported bigint comment 'is app version supported'
    ,login_days_in_180d bigint comment 'login days in last 180 days'
    ,region_tag_360d string comment 'region tag 360d'
    ,region_tier_360d bigint comment 'region tier 360d'
    ,user_total_fail_nums_180d bigint comment 'user total fail nums in last 180 days'
    ,user_recent_fail_day bigint comment 'user recent fail day'
    ,user_recent_fail_reason string comment 'user recent fail reason'
    ,high_risk_latest_day bigint comment 'high risk latest day'
    ,freq_card_number_180d string comment 'frequency of card number in last 180 days'
    ,freq_card_bin_180d string comment 'frequency of card bin in last 180 days'
    ,freq_card_brand_180d string comment 'frequency of card brand in last 180 days'
    ,freq_card_type_180d string comment 'frequency of card type in last 180 days'
    ,freq_bank_name_180d string comment 'frequency of bank name in last 180 days'
    ,freq_bank_id_180d string comment 'frequency of bank id in last 180 days'
    ,freq_order_number_of_ccard_180d string comment 'frequency of order number of ccard in last 180 days'
    ,freq_total_amount_of_ccard_180d string comment 'frequency of total amount of ccard in last 180 days'
    ,freq_max_amount_of_ccard_180d string comment 'frequency of max amount of ccard in last 180 days'
    ,freq_min_amount_of_ccard_180d string comment 'frequency of min amount of ccard in last 180 days'
    ,freq_avg_amount_of_ccard_180d string comment 'frequency of avg amount of ccard in last 180 days'
    ,active_card_nums_180d string comment 'active card number in last 180 days'
) 
comment 'risk feature summary table'
partitioned by (
    grass_date string comment 'grass_date, partition key'
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_feature/ads/ads_risk_reg_fs_seamoney_underwriting_buyer_df/grass_region=${grass_region}'
;
msck repair table ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_buyer_df;


insert overwrite table ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_buyer_df partition (grass_date = '${grass_date}')
select 
    t1.platform_user_id as shopee_user_id
    ,t1.platform_user_id
    ,t1.is_phone_verified
    ,t1.shopee_age
    ,t2.confirmed_gmv_usd_in_30d_br
    ,t2.confirmed_gmv_usd_in_60d_br
    ,t2.confirmed_gmv_usd_in_90d_br
    ,t2.confirmed_gmv_usd_in_180d_br
    ,t2.confirmed_gmv_usd_in_360d_br
    ,t2.confirmed_gmv_usd_in_lifetime_br
    ,t2.confirmed_order_in_30d_br
    ,t2.confirmed_order_in_60d_br
    ,t2.confirmed_order_in_90d_br
    ,t2.confirmed_order_in_180d_br
    ,t2.confirmed_order_in_360d_br
    ,t2.confirmed_order_in_lifetime_br
    ,t2.pctg_of_cc__order_in_30d_br
    ,t2.pctg_of_cc__order_in_90d_br
    ,t2.pctg_of_cc__order_in_180d_br
    ,t2.pctg_of_cc__order_in_360d_br
    ,t2.pctg_of_cc__order_in_lifetime_br
    ,t2.pctg_of_cc__gmv_in_30d_br
    ,t2.pctg_of_cc__gmv_in_90d_br
    ,t2.pctg_of_cc__gmv_in_180d_br
    ,t2.pctg_of_cc__gmv_in_360d_br
    ,t2.pctg_of_cc__gmv_in_lifetime_br
    ,t2.abs_usd_in_30d_br
    ,t2.abs_usd_in_90d_br
    ,t2.abs_usd_in_180d_br
    ,t2.abs_usd_in_360d_br
    ,t2.abs_usd_in_lifetime_br
    ,t3.is_app_version_supported
    ,t4.login_days_in_180d
    ,t5.region_tag_360d
    ,t5.region_tier_360d
    ,t6.user_total_fail_nums_180d
    ,t6.user_recent_fail_day
    ,t6.user_recent_fail_reason
    ,t6.high_risk_latest_day
    ,t7.freq_card_number_180d
    ,t7.freq_card_bin_180d
    ,t7.freq_card_brand_180d
    ,t7.freq_card_type_180d
    ,t7.freq_bank_name_180d
    ,t7.freq_bank_id_180d
    ,t7.freq_order_number_of_ccard_180d
    ,t7.freq_total_amount_of_ccard_180d
    ,t7.freq_max_amount_of_ccard_180d
    ,t7.freq_min_amount_of_ccard_180d
    ,t7.freq_avg_amount_of_ccard_180d
    ,t7.active_card_nums_180d
from (
    select
        platform_user_id
        ,is_phone_verified
        ,shopee_age
    from ${SCHEMA}.dim_risk_${region}_user_info_df
    where grass_date = '${grass_date}'
) t1  
left join (
    select 
        platform_user_id
        ,confirmed_gmv_usd_in_30d_br
        ,confirmed_gmv_usd_in_60d_br
        ,confirmed_gmv_usd_in_90d_br
        ,confirmed_gmv_usd_in_180d_br
        ,confirmed_gmv_usd_in_360d_br
        ,confirmed_gmv_usd_in_lifetime_br
        ,confirmed_order_in_30d_br
        ,confirmed_order_in_60d_br
        ,confirmed_order_in_90d_br
        ,confirmed_order_in_180d_br
        ,confirmed_order_in_360d_br
        ,confirmed_order_in_lifetime_br
        ,pctg_of_cc__order_in_30d_br
        ,pctg_of_cc__order_in_90d_br
        ,pctg_of_cc__order_in_180d_br
        ,pctg_of_cc__order_in_360d_br
        ,pctg_of_cc__order_in_lifetime_br
        ,pctg_of_cc__gmv_in_30d_br
        ,pctg_of_cc__gmv_in_90d_br
        ,pctg_of_cc__gmv_in_180d_br
        ,pctg_of_cc__gmv_in_360d_br
        ,pctg_of_cc__gmv_in_lifetime_br
        ,abs_usd_in_30d_br
        ,abs_usd_in_90d_br
        ,abs_usd_in_180d_br
        ,abs_usd_in_360d_br
        ,abs_usd_in_lifetime_br
    from ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df
    where grass_date = '${grass_date}'
) t2 on t1.platform_user_id = t2.platform_user_id
left join (
    select 
        platform_user_id
        ,is_app_version_supported
    from ${SCHEMA}.dws_risk_${region}_user_behavior_app_info_df
    where grass_date = '${grass_date}'
) t3 on t1.platform_user_id = t3.platform_user_id
left join (
    select 
        platform_user_id
        ,login_days_in_180d
    from ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df
    where grass_date = '${grass_date}'
) t4 on t1.platform_user_id = t4.platform_user_id
left join (
    select
        shopee_user_id
        ,region_tag_360d
        ,region_tier_360d
    from ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_region_tier_df
    where grass_date = '${grass_date}'
) t5 on t1.platform_user_id = t5.shopee_user_id
left join (
    select
        shopee_user_id
        ,user_total_fail_nums_180d
        ,user_recent_fail_day
        ,user_recent_fail_reason
        ,high_risk_latest_day
    from ${SCHEMA}.dws_risk_${region}_user_txn_spp_bank_card_df
    where grass_date = '${grass_date}'
) t6 on t1.platform_user_id = t6.shopee_user_id
left join (
    select
        platform_user_id
        ,freq_card_number_180d
        ,freq_card_bin_180d
        ,freq_card_brand_180d
        ,freq_card_type_180d
        ,freq_bank_name_180d
        ,freq_bank_id_180d
        ,freq_order_number_of_ccard_180d
        ,freq_total_amount_of_ccard_180d
        ,freq_max_amount_of_ccard_180d
        ,freq_min_amount_of_ccard_180d
        ,freq_avg_amount_of_ccard_180d
        ,active_card_nums_180d
    from ${SCHEMA}.dws_risk_${region}_user_txn_spp_bank_card_info_df
    where grass_date = '${grass_date}'
) t7 on t1.platform_user_id = t7.platform_user_id
;