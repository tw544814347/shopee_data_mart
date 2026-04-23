------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-05-21
-- Description:         Antifaud Buyer ADS Feature
-- Data Granularity:    platform_user_id
-- PRD:                 
-- 变更历史：
    --delete dp_abtesting_user_tag column
    --2025.7.31 新增 spl_cpd30_cnt_in_cluster 字段，jira: https://jira.shopee.io/browse/SPFDT-54075
    --2025.8.8  跟业务确认下线 ph_spl_blacklist_hit 字段
------------------------------------------------------------------------

--drop table if exists ${SCHEMA}.ads_risk_${region}_fs_seamoney_antifraud_buyer_df;
create external table if not exists ${SCHEMA}.ads_risk_${region}_fs_seamoney_antifraud_buyer_df (
    platform_user_id string comment 'platform_user_id'
    ,lending_cnt bigint comment 'lending_cnt'
    ,lending_high_cnt bigint comment 'lending_high_cnt'
    ,casino_cnt bigint comment 'casino_cnt'
    ,suspicious_cnt bigint comment 'suspicious_cnt'
    ,spl_wifi_shared_dpd60_ind int comment 'spl_wifi_shared_dpd60_ind'
    ,spl_wifi_graph_risk_ind int comment 'spl_wifi_graph_risk_ind'
    ,bcl_wifi_shared_dpd60_ind int comment 'bcl_wifi_shared_dpd60_ind'
    ,phone_ec_mp_cur_dpd15 int comment 'phone_ec_mp_cur_dpd15'
    ,phone_ec_mp_cur_dpd30 int comment 'phone_ec_mp_cur_dpd30'
    ,user_webcheckout_frequency_180d bigint comment 'cnt_buyer_webcheckout_frequency'
    ,month_due_spl_cnt bigint comment 'count the month of SPL dued'
    ,linked_dpd60_sellerbankaccount int comment 'linked_dpd60_sellerbankaccount'
    ,linked_sellbankaccount_user_count int comment 'linked_sellbankaccount_user_count'
    ,spl_cpd30_cnt_in_cluster bigint comment 'spl_cpd30_cnt_in_cluster'
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/ads/ads_risk_reg_fs_seamoney_antifraud_buyer_df/garss_region=${upper_region}'
;
--msck repair table ${SCHEMA}.ads_risk_${region}_fs_seamoney_antifraud_buyer_df;

insert overwrite table
    ${SCHEMA}.ads_risk_${region}_fs_seamoney_antifraud_buyer_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t2.lending_cnt
    ,t2.lending_high_cnt
    ,t2.casino_cnt
    ,t2.suspicious_cnt
    ,t2.spl_wifi_shared_dpd60_ind
    ,t2.spl_wifi_graph_risk_ind
    ,t2.bcl_wifi_shared_dpd60_ind
    ,t2.phone_ec_mp_cur_dpd15
    ,t2.phone_ec_mp_cur_dpd30
    ,t3.user_webcheckout_frequency_180d
    ,coalesce(t4.month_due_spl_cnt,0) as month_due_spl_cnt
    ,t2.linked_dpd60_sellerbankaccount
    ,t2.linked_sellbankaccount_user_count
    ,t2.spl_cpd30_cnt_in_cluster
from
    (
        select
            platform_user_id
        from ${SCHEMA}.dim_risk_ph_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join (
        select
            *
        from ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df
        where grass_date = '${grass_date}'
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select
            *
        from ${SCHEMA}.dws_risk_${region}_user_txn_mp_checkout_df
        where grass_date = '${grass_date}'
    ) t3 on t1.platform_user_id = t3.platform_user_id
    left join (
        select
            *
        from ${SCHEMA}.dws_risk_${region}_platform_user_dpd_df
        where grass_date = '${grass_date}'
    ) t4 on t1.platform_user_id = t4.platform_user_id
;