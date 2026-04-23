-- ========================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-11-11
-- Description:         Antifraud Buyer Feature
-- Data Granularity:    platform_user_id
-- PRD:           
-- Version:
--          v1:2025-08-08，跟业务确认，下线smcdrisk_antifraud.seller_loan_blacklist_fs_last表相关特征   
-- ========================================================================

--drop table if exists ${SCHEMA}.ads_risk_my_fs_seamoney_antifraud_buyer_df;
create external table if not exists ${SCHEMA}.ads_risk_my_fs_seamoney_antifraud_buyer_df (
    platform_user_id string comment 'platform_user_id'
    ,config_addr_list_td string
    ,frequency_city_name_list_6m string
    ,fst_lvl_network_user_id_list_sz_dfp_td string
    ,frequency_hex_hash_shopee_df_list_1y string
    ,frequency_sz_dfp_device_id_list_1y string
    ,frequency_phone_list_td string
    ,frequency_shopee_df_list_seller_1y string
    ,silent_days_cnt bigint
    ,cnt_phone_mp_dpt_linked_user_dpd1 bigint
    ,cnt_phone_ec_ec_linked_user_dpd1 bigint
    ,cnt_shopeedf_90days_linked_user_dpd1 bigint
    ,cnt_phone_mp_mp_linked_user_dpd1 bigint
    ,cnt_phone_mp_ec_linked_user_dpd1 bigint
    ,cnt_phone_ec_mp_linked_user_dpd1 bigint
    ,cnt_phone_reg_ec_linked_user_dpd1 bigint
    ,cnt_phone_dpt_mp_linked_user_dpd1 bigint
    ,cnt_phone_reg_mp_linked_user_dpd1 bigint
    ,cnt_phone_reg_reg_linked_user_dpd1 bigint
    ,cnt_phone_dpt_reg_linked_user_dpd1 bigint
    ,cnt_tongdundf_linked_user_dpd1 bigint
    ,cnt_phone_dpt_ec_linked_user_dpd1 bigint
    ,cnt_tongdundf_90days_linked_user_dpd1 bigint
    ,cnt_shopeedf_linked_user_dpd1 bigint
    ,cnt_phone_reg_dpt_linked_user_dpd1 bigint
    ,cnt_facebook_linked_user_dpd1 bigint
    ,cnt_phone_ec_dpt_linked_user_dpd1 bigint
    ,cnt_phone_dpt_dpt_linked_user_dpd1 bigint
    ,cnt_phone_ec_reg_linked_user_dpd1 bigint
    ,cnt_bankaccount_linked_user_dpd1 bigint
    ,cnt_creditcard_linked_user_dpd1 bigint
    ,cnt_phone_mp_reg_linked_user_dpd1 bigint
    ,cnt_email_linked_user_dpd1 bigint
    ,cnt_bankaccountsuccess_linked_user_dpd1 bigint
    ,cnt_address_linked_user_dpd1 bigint
    ,cnt_creditcardmask_linked_user_dpd1 bigint
    ,cnt_address_phone_linked_user_dpd1 bigint
    ,cnt_phone_mp_dpt_linked_user_dpd15 bigint
    ,cnt_phone_ec_ec_linked_user_dpd15 bigint
    ,cnt_shopeedf_90days_linked_user_dpd15 bigint
    ,cnt_phone_mp_mp_linked_user_dpd15 bigint
    ,cnt_phone_mp_ec_linked_user_dpd15 bigint
    ,cnt_phone_ec_mp_linked_user_dpd15 bigint
    ,cnt_phone_reg_ec_linked_user_dpd15 bigint
    ,cnt_phone_dpt_mp_linked_user_dpd15 bigint
    ,cnt_phone_reg_mp_linked_user_dpd15 bigint
    ,cnt_phone_reg_reg_linked_user_dpd15 bigint
    ,cnt_phone_dpt_reg_linked_user_dpd15 bigint
    ,cnt_tongdundf_linked_user_dpd15 bigint
    ,cnt_phone_dpt_ec_linked_user_dpd15 bigint
    ,cnt_tongdundf_90days_linked_user_dpd15 bigint
    ,cnt_shopeedf_linked_user_dpd15 bigint
    ,cnt_phone_reg_dpt_linked_user_dpd15 bigint
    ,cnt_facebook_linked_user_dpd15 bigint
    ,cnt_phone_ec_dpt_linked_user_dpd15 bigint
    ,cnt_phone_dpt_dpt_linked_user_dpd15 bigint
    ,cnt_phone_ec_reg_linked_user_dpd15 bigint
    ,cnt_bankaccount_linked_user_dpd15 bigint
    ,cnt_creditcard_linked_user_dpd15 bigint
    ,cnt_phone_mp_reg_linked_user_dpd15 bigint
    ,cnt_email_linked_user_dpd15 bigint
    ,cnt_bankaccountsuccess_linked_user_dpd15 bigint
    ,cnt_address_linked_user_dpd15 bigint
    ,cnt_creditcardmask_linked_user_dpd15 bigint
    ,cnt_address_phone_linked_user_dpd15 bigint
    ,cnt_phone_mp_dpt_linked_user_dpd30 bigint
    ,cnt_phone_ec_ec_linked_user_dpd30 bigint
    ,cnt_shopeedf_90days_linked_user_dpd30 bigint
    ,cnt_phone_mp_mp_linked_user_dpd30 bigint
    ,cnt_phone_mp_ec_linked_user_dpd30 bigint
    ,cnt_phone_ec_mp_linked_user_dpd30 bigint
    ,cnt_phone_reg_ec_linked_user_dpd30 bigint
    ,cnt_phone_dpt_mp_linked_user_dpd30 bigint
    ,cnt_phone_reg_mp_linked_user_dpd30 bigint
    ,cnt_phone_reg_reg_linked_user_dpd30 bigint
    ,cnt_phone_dpt_reg_linked_user_dpd30 bigint
    ,cnt_tongdundf_linked_user_dpd30 bigint
    ,cnt_phone_dpt_ec_linked_user_dpd30 bigint
    ,cnt_tongdundf_90days_linked_user_dpd30 bigint
    ,cnt_shopeedf_linked_user_dpd30 bigint
    ,cnt_phone_reg_dpt_linked_user_dpd30 bigint
    ,cnt_facebook_linked_user_dpd30 bigint
    ,cnt_phone_ec_dpt_linked_user_dpd30 bigint
    ,cnt_phone_dpt_dpt_linked_user_dpd30 bigint
    ,cnt_phone_ec_reg_linked_user_dpd30 bigint
    ,cnt_bankaccount_linked_user_dpd30 bigint
    ,cnt_creditcard_linked_user_dpd30 bigint
    ,cnt_phone_mp_reg_linked_user_dpd30 bigint
    ,cnt_email_linked_user_dpd30 bigint
    ,cnt_bankaccountsuccess_linked_user_dpd30 bigint
    ,cnt_address_linked_user_dpd30 bigint
    ,cnt_creditcardmask_linked_user_dpd30 bigint
    ,cnt_address_phone_linked_user_dpd30 bigint
    ,user_bcard_v3_score double comment 'user_level_bcard_v3_score'
    ,user_bcard_v3_user_overdue_tag bigint comment 'user_bcard_v3_user_overdue_tag'
    ,is_bad_user bigint comment 'is_bad_user'
    ,last_spl_increment_control_live_days_from_now bigint comment 'last_spl_increment_control_live_days_from_now'
    ,is_low_limit_users bigint comment 'is_low_limit_users'
    ,is_recoverd_users bigint comment 'is_recoverd_users'
    ,ctos_model_v2 double comment 'ctos_model_v2'
    ,ctos_credit_card_max_limit double comment 'ctos_credit_card_max_limit'
    ,repayment_channel_flag bigint
    ,cnt_network_linked_spldpd30 bigint
    ,cnt_network_linked_frozen bigint
    ,cnt_network_linked_banned bigint
    ,spp_bcl_whitelist_uid_test bigint
    ,hit_rule_bad_user_in_cluster bigint
    ,hit_rule_bad_user_in_cluster_v2 bigint
    ,user_webcheckout_frequency_180d bigint
)
partitioned by
    (grass_date string comment "YYYY-MM-DD") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/ads/ads_risk_reg_fs_seamoney_antifraud_buyer_df/grass_region=${grass_region}'
;
--msck repair table ${SCHEMA}.ads_risk_my_fs_seamoney_antifraud_buyer_df;

insert overwrite table
    ${SCHEMA}.ads_risk_my_fs_seamoney_antifraud_buyer_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t2.config_addr_list_td
    ,t2.frequency_city_name_list_6m
    ,t2.fst_lvl_network_user_id_list_sz_dfp_td
    ,t2.frequency_hex_hash_shopee_df_list_1y
    ,t2.frequency_sz_dfp_device_id_list_1y
    ,t2.frequency_phone_list_td
    ,t2.frequency_shopee_df_list_seller_1y
    ,t3.silent_days_cnt
    ,t4.cnt_phone_mp_dpt_linked_user_dpd1
    ,t4.cnt_phone_ec_ec_linked_user_dpd1
    ,t4.cnt_shopeedf_90days_linked_user_dpd1
    ,t4.cnt_phone_mp_mp_linked_user_dpd1
    ,t4.cnt_phone_mp_ec_linked_user_dpd1
    ,t4.cnt_phone_ec_mp_linked_user_dpd1
    ,t4.cnt_phone_reg_ec_linked_user_dpd1
    ,t4.cnt_phone_dpt_mp_linked_user_dpd1
    ,t4.cnt_phone_reg_mp_linked_user_dpd1
    ,t4.cnt_phone_reg_reg_linked_user_dpd1
    ,t4.cnt_phone_dpt_reg_linked_user_dpd1
    ,t4.cnt_tongdundf_linked_user_dpd1
    ,t4.cnt_phone_dpt_ec_linked_user_dpd1
    ,t4.cnt_tongdundf_90days_linked_user_dpd1
    ,t4.cnt_shopeedf_linked_user_dpd1
    ,t4.cnt_phone_reg_dpt_linked_user_dpd1
    ,t4.cnt_facebook_linked_user_dpd1
    ,t4.cnt_phone_ec_dpt_linked_user_dpd1
    ,t4.cnt_phone_dpt_dpt_linked_user_dpd1
    ,t4.cnt_phone_ec_reg_linked_user_dpd1
    ,t4.cnt_bankaccount_linked_user_dpd1
    ,t4.cnt_creditcard_linked_user_dpd1
    ,t4.cnt_phone_mp_reg_linked_user_dpd1
    ,t4.cnt_email_linked_user_dpd1
    ,t4.cnt_bankaccountsuccess_linked_user_dpd1
    ,t4.cnt_address_linked_user_dpd1
    ,t4.cnt_creditcardmask_linked_user_dpd1
    ,t4.cnt_address_phone_linked_user_dpd1
    ,t4.cnt_phone_mp_dpt_linked_user_dpd15
    ,t4.cnt_phone_ec_ec_linked_user_dpd15
    ,t4.cnt_shopeedf_90days_linked_user_dpd15
    ,t4.cnt_phone_mp_mp_linked_user_dpd15
    ,t4.cnt_phone_mp_ec_linked_user_dpd15
    ,t4.cnt_phone_ec_mp_linked_user_dpd15
    ,t4.cnt_phone_reg_ec_linked_user_dpd15
    ,t4.cnt_phone_dpt_mp_linked_user_dpd15
    ,t4.cnt_phone_reg_mp_linked_user_dpd15
    ,t4.cnt_phone_reg_reg_linked_user_dpd15
    ,t4.cnt_phone_dpt_reg_linked_user_dpd15
    ,t4.cnt_tongdundf_linked_user_dpd15
    ,t4.cnt_phone_dpt_ec_linked_user_dpd15
    ,t4.cnt_tongdundf_90days_linked_user_dpd15
    ,t4.cnt_shopeedf_linked_user_dpd15
    ,t4.cnt_phone_reg_dpt_linked_user_dpd15
    ,t4.cnt_facebook_linked_user_dpd15
    ,t4.cnt_phone_ec_dpt_linked_user_dpd15
    ,t4.cnt_phone_dpt_dpt_linked_user_dpd15
    ,t4.cnt_phone_ec_reg_linked_user_dpd15
    ,t4.cnt_bankaccount_linked_user_dpd15
    ,t4.cnt_creditcard_linked_user_dpd15
    ,t4.cnt_phone_mp_reg_linked_user_dpd15
    ,t4.cnt_email_linked_user_dpd15
    ,t4.cnt_bankaccountsuccess_linked_user_dpd15
    ,t4.cnt_address_linked_user_dpd15
    ,t4.cnt_creditcardmask_linked_user_dpd15
    ,t4.cnt_address_phone_linked_user_dpd15
    ,t4.cnt_phone_mp_dpt_linked_user_dpd30
    ,t4.cnt_phone_ec_ec_linked_user_dpd30
    ,t4.cnt_shopeedf_90days_linked_user_dpd30
    ,t4.cnt_phone_mp_mp_linked_user_dpd30
    ,t4.cnt_phone_mp_ec_linked_user_dpd30
    ,t4.cnt_phone_ec_mp_linked_user_dpd30
    ,t4.cnt_phone_reg_ec_linked_user_dpd30
    ,t4.cnt_phone_dpt_mp_linked_user_dpd30
    ,t4.cnt_phone_reg_mp_linked_user_dpd30
    ,t4.cnt_phone_reg_reg_linked_user_dpd30
    ,t4.cnt_phone_dpt_reg_linked_user_dpd30
    ,t4.cnt_tongdundf_linked_user_dpd30
    ,t4.cnt_phone_dpt_ec_linked_user_dpd30
    ,t4.cnt_tongdundf_90days_linked_user_dpd30
    ,t4.cnt_shopeedf_linked_user_dpd30
    ,t4.cnt_phone_reg_dpt_linked_user_dpd30
    ,t4.cnt_facebook_linked_user_dpd30
    ,t4.cnt_phone_ec_dpt_linked_user_dpd30
    ,t4.cnt_phone_dpt_dpt_linked_user_dpd30
    ,t4.cnt_phone_ec_reg_linked_user_dpd30
    ,t4.cnt_bankaccount_linked_user_dpd30
    ,t4.cnt_creditcard_linked_user_dpd30
    ,t4.cnt_phone_mp_reg_linked_user_dpd30
    ,t4.cnt_email_linked_user_dpd30
    ,t4.cnt_bankaccountsuccess_linked_user_dpd30
    ,t4.cnt_address_linked_user_dpd30
    ,t4.cnt_creditcardmask_linked_user_dpd30
    ,t4.cnt_address_phone_linked_user_dpd30
    ,t5.user_bcard_v3_score
    ,t5.user_bcard_v3_user_overdue_tag
    ,t5.is_bad_user
    ,t5.last_spl_increment_control_live_days_from_now
    ,t5.is_low_limit_users
    ,t5.is_recoverd_users
    ,t5.ctos_model_v2
    ,t5.ctos_credit_card_max_limit
    ,t5.repayment_channel_flag
    ,t5.cnt_network_linked_spldpd30
    ,t5.cnt_network_linked_frozen
    ,t5.cnt_network_linked_banned
    ,t5.spp_bcl_whitelist_uid_test
    ,t5.hit_rule_bad_user_in_cluster
    ,t5.hit_rule_bad_user_in_cluster_v2
    ,t6.user_webcheckout_frequency_180d
from
    (
        select
            platform_user_id
        from ${SCHEMA}.dim_risk_my_user_info_df
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
            ,frequency_shopee_df_list_seller_1y
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
            ,cnt_phone_mp_dpt_linked_user_dpd1
            ,cnt_phone_ec_ec_linked_user_dpd1
            ,cnt_shopeedf_90days_linked_user_dpd1
            ,cnt_phone_mp_mp_linked_user_dpd1
            ,cnt_phone_mp_ec_linked_user_dpd1
            ,cnt_phone_ec_mp_linked_user_dpd1
            ,cnt_phone_reg_ec_linked_user_dpd1
            ,cnt_phone_dpt_mp_linked_user_dpd1
            ,cnt_phone_reg_mp_linked_user_dpd1
            ,cnt_phone_reg_reg_linked_user_dpd1
            ,cnt_phone_dpt_reg_linked_user_dpd1
            ,cnt_tongdundf_linked_user_dpd1
            ,cnt_phone_dpt_ec_linked_user_dpd1
            ,cnt_tongdundf_90days_linked_user_dpd1
            ,cnt_shopeedf_linked_user_dpd1
            ,cnt_phone_reg_dpt_linked_user_dpd1
            ,cnt_facebook_linked_user_dpd1
            ,cnt_phone_ec_dpt_linked_user_dpd1
            ,cnt_phone_dpt_dpt_linked_user_dpd1
            ,cnt_phone_ec_reg_linked_user_dpd1
            ,cnt_bankaccount_linked_user_dpd1
            ,cnt_creditcard_linked_user_dpd1
            ,cnt_phone_mp_reg_linked_user_dpd1
            ,cnt_email_linked_user_dpd1
            ,cnt_bankaccountsuccess_linked_user_dpd1
            ,cnt_address_linked_user_dpd1
            ,cnt_creditcardmask_linked_user_dpd1
            ,cnt_address_phone_linked_user_dpd1
            ,cnt_phone_mp_dpt_linked_user_dpd15
            ,cnt_phone_ec_ec_linked_user_dpd15
            ,cnt_shopeedf_90days_linked_user_dpd15
            ,cnt_phone_mp_mp_linked_user_dpd15
            ,cnt_phone_mp_ec_linked_user_dpd15
            ,cnt_phone_ec_mp_linked_user_dpd15
            ,cnt_phone_reg_ec_linked_user_dpd15
            ,cnt_phone_dpt_mp_linked_user_dpd15
            ,cnt_phone_reg_mp_linked_user_dpd15
            ,cnt_phone_reg_reg_linked_user_dpd15
            ,cnt_phone_dpt_reg_linked_user_dpd15
            ,cnt_tongdundf_linked_user_dpd15
            ,cnt_phone_dpt_ec_linked_user_dpd15
            ,cnt_tongdundf_90days_linked_user_dpd15
            ,cnt_shopeedf_linked_user_dpd15
            ,cnt_phone_reg_dpt_linked_user_dpd15
            ,cnt_facebook_linked_user_dpd15
            ,cnt_phone_ec_dpt_linked_user_dpd15
            ,cnt_phone_dpt_dpt_linked_user_dpd15
            ,cnt_phone_ec_reg_linked_user_dpd15
            ,cnt_bankaccount_linked_user_dpd15
            ,cnt_creditcard_linked_user_dpd15
            ,cnt_phone_mp_reg_linked_user_dpd15
            ,cnt_email_linked_user_dpd15
            ,cnt_bankaccountsuccess_linked_user_dpd15
            ,cnt_address_linked_user_dpd15
            ,cnt_creditcardmask_linked_user_dpd15
            ,cnt_address_phone_linked_user_dpd15
            ,cnt_phone_mp_dpt_linked_user_dpd30
            ,cnt_phone_ec_ec_linked_user_dpd30
            ,cnt_shopeedf_90days_linked_user_dpd30
            ,cnt_phone_mp_mp_linked_user_dpd30
            ,cnt_phone_mp_ec_linked_user_dpd30
            ,cnt_phone_ec_mp_linked_user_dpd30
            ,cnt_phone_reg_ec_linked_user_dpd30
            ,cnt_phone_dpt_mp_linked_user_dpd30
            ,cnt_phone_reg_mp_linked_user_dpd30
            ,cnt_phone_reg_reg_linked_user_dpd30
            ,cnt_phone_dpt_reg_linked_user_dpd30
            ,cnt_tongdundf_linked_user_dpd30
            ,cnt_phone_dpt_ec_linked_user_dpd30
            ,cnt_tongdundf_90days_linked_user_dpd30
            ,cnt_shopeedf_linked_user_dpd30
            ,cnt_phone_reg_dpt_linked_user_dpd30
            ,cnt_facebook_linked_user_dpd30
            ,cnt_phone_ec_dpt_linked_user_dpd30
            ,cnt_phone_dpt_dpt_linked_user_dpd30
            ,cnt_phone_ec_reg_linked_user_dpd30
            ,cnt_bankaccount_linked_user_dpd30
            ,cnt_creditcard_linked_user_dpd30
            ,cnt_phone_mp_reg_linked_user_dpd30
            ,cnt_email_linked_user_dpd30
            ,cnt_bankaccountsuccess_linked_user_dpd30
            ,cnt_address_linked_user_dpd30
            ,cnt_creditcardmask_linked_user_dpd30
            ,cnt_address_phone_linked_user_dpd30
        from ${SCHEMA}.dws_risk_${region}_user_af_graph_dpd_df
        where grass_date = '${grass_date}'
    ) t4 on t1.platform_user_id = t4.platform_user_id
    left join (
        select
            platform_user_id
            ,user_bcard_v3_score
            ,user_bcard_v3_user_overdue_tag
            ,is_bad_user
            ,last_spl_increment_control_live_days_from_now
            ,is_low_limit_users
            ,is_recoverd_users
            ,ctos_model_v2
            ,ctos_credit_card_max_limit
            ,repayment_channel_flag
            ,cnt_network_linked_spldpd30
            ,cnt_network_linked_frozen
            ,cnt_network_linked_banned
            ,spp_bcl_whitelist_uid_test
            ,hit_rule_bad_user_in_cluster
            ,hit_rule_bad_user_in_cluster_v2
        from ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df
        where grass_date = '${grass_date}'
    ) t5 on t1.platform_user_id = t5.platform_user_id
    left join (
        select
            platform_user_id
            ,user_webcheckout_frequency_180d
        from ${SCHEMA}.dws_risk_${region}_user_txn_mp_checkout_df
        where grass_date = '${grass_date}'
    ) t6 on t1.platform_user_id = t6.platform_user_id
;