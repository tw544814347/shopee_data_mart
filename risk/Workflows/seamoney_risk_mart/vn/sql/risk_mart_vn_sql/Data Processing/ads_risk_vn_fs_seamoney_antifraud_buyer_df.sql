------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-03-11
-- Description:         Feature Station迁移，antifraud_buyer宽表
-- Data Granularity:    platform_user_id
-- PRD:                 
------------------------------------------------------------------------
insert overwrite table ${SCHEMA}.ads_risk_${region}_fs_seamoney_antifraud_buyer_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t2.config_addr_list_td
    ,t2.frequency_city_name_list_6m
    ,t2.fst_lvl_network_user_id_list_sz_dfp_td
    ,t2.frequency_hex_hash_shopee_df_list_1y
    ,t2.frequency_sz_dfp_device_id_list_1y
    ,t2.frequency_phone_list_td
    ,t3.silent_days_cnt
    ,t4.user_webcheckout_frequency_180d
    ,t5.hit_rule_bad_user_in_cluster_v2
from
    (
        select
            platform_user_id
        from ${SCHEMA}.dim_risk_${region}_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join (
        select
            user_id as platform_user_id
            ,config_addr_list_td
            ,frequency_city_name_list_6m
            ,fst_lvl_network_user_id_list_sz_dfp_td
            ,frequency_hex_hash_shopee_df_list_1y
            ,frequency_sz_dfp_device_id_list_1y
            ,frequency_phone_list_td
        from ${SCHEMA}.ads_risk_profile_user_df
        where
            grass_region = '${grass_region}'
            and grass_date = '${grass_date}'
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select
            platform_user_id
            ,silent_days_cnt
        from ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df
        where grass_date = '${grass_date}'
    ) t3 on t1.platform_user_id = t3.platform_user_id
    left join (
        select
            platform_user_id
            ,user_webcheckout_frequency_180d
        from ${SCHEMA}.dws_risk_${region}_user_txn_mp_checkout_df
        where grass_date = '${grass_date}'
    ) t4 on t1.platform_user_id = t4.platform_user_id
    left join (
        select
            platform_user_id
            ,hit_rule_bad_user_in_cluster_v2
        from ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df
        where grass_date = '${grass_date}'
    ) t5 on t1.platform_user_id = t5.platform_user_id
;