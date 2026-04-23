------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-04-07
-- Description:         Feature Station迁移， antifraud_buyer 宽表
-- Data Granularity:    platform_user_id
-- PRD:                 
------------------------------------------------------------------------

drop table if exists ${SCHEMA}.ads_risk_br_fs_seamoney_antifraud_buyer_df;
create table if not exists ${SCHEMA}.ads_risk_br_fs_seamoney_antifraud_buyer_df (
    platform_user_id string comment 'platform_user_id'
    ,first_credit_act_succ_lc1 string comment 'first credit act succ lc1'
    ,frequency_city_name_list_6m string comment ''
    ,frequency_hex_hash_shopee_df_list_1y string comment ''
    ,frequency_sz_dfp_device_id_list_1y string comment ''
    ,frequency_shopee_df_list_seller_1y string comment ''
    ,frequency_sz_dfp_device_id_list_seller_1y string comment ''
    ,frequency_phone_list_td string comment 'frequency phone list'
    ,fst_lvl_network_user_id_list_td string comment 'fst lvl network user id list'
    ,config_addr_list_td string comment 'config addr list'
    ,silence_day_cnt_td bigint comment 'silence day cnt'
    ,community_id string comment 'community id'
    ,is_shopee_fraud_tag_fes bigint comment 'is shopee fraud tag fes'
    ,lending_count bigint comment 'lending count'
    ,uninstall_loan_last30 bigint comment 'uninstall loan last 30'
    ,credit_sp_device_v2 string comment 'credit sp device v2'
    ,credit_sz_device_v2 string comment 'credit sz device v2'
)
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/ads/ads_risk_fs_seamoney_antifraud_buyer_df/grass_region=BR'
;
msck repair table ${SCHEMA}.ads_risk_br_fs_seamoney_antifraud_buyer_df;

insert overwrite table risk.ads_risk_br_fs_seamoney_antifraud_buyer_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t1.first_credit_act_succ_lc1
    ,t2.frequency_city_name_list_6m as frequency_city_name_list_6m
    ,t2.frequency_hex_hash_shopee_df_list_1y as frequency_hex_hash_shopee_df_list_1y
    ,t2.frequency_sz_dfp_device_id_list_1y as frequency_sz_dfp_device_id_list_1y
    ,t2.frequency_shopee_df_list_seller_1y
    ,t2.frequency_sz_dfp_device_id_list_seller_1y
    ,t2.frequency_phone_list_td
    ,t2.fst_lvl_network_user_id_list_td
    ,t2.config_addr_list_td
    ,t2.silence_day_cnt_td
    ,t3.community_id
    ,t3.is_shopee_fraud_tag_fes
    ,t3.lending_count
    ,t3.uninstall_loan_last30
    ,t3.credit_sp_device_v2
    ,t3.credit_sz_device_v2
from
    (
        select
            platform_user_id
            ,is_seller
            ,shopee_age
            ,is_phone_verified
            ,first_credit_act_succ_lc1
        from ${SCHEMA}.dim_risk_br_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join (
        select
            user_id as platform_user_id
            ,frequency_city_name_list_6m as frequency_city_name_list_6m
            ,frequency_hex_hash_shopee_df_list_1y as frequency_hex_hash_shopee_df_list_1y
            ,frequency_sz_dfp_device_id_list_1y as frequency_sz_dfp_device_id_list_1y
            ,frequency_shopee_df_list_seller_1y
            ,frequency_sz_dfp_device_id_list_seller_1y
            ,frequency_phone_list_td
            ,fst_lvl_network_user_id_list_td
            ,config_addr_list_td
            ,silence_day_cnt_td
        from risk.ads_risk_profile_user_df
        where
            grass_region = 'BR'
            and grass_date = '${grass_date}'
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select  platform_user_id
                ,community_id
                ,is_shopee_fraud_tag_fes
                ,lending_count
                ,uninstall_loan_last30
                ,credit_sp_device_v2
                ,credit_sz_device_v2
        from ${SCHEMA}.dws_risk_br_user_metrics_biz_manage_df
        where grass_date = '${grass_date}'
    ) t3 on t1.platform_user_id = t3.platform_user_id
;