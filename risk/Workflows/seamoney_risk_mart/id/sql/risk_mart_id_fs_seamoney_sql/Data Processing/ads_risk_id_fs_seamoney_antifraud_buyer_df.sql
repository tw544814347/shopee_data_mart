------------------------------------------------------------------------
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-03-15
-- Description:         业务维护的指标，对外提供ads表 
-- Data Granularity:    platform_user_id
-- PRD:                 
------------------------------------------------------------------------
--drop table if exists ${SCHEMA}.ads_risk_id_fs_seamoney_antifraud_buyer_df;
create table if not exists ${SCHEMA}.ads_risk_id_fs_seamoney_antifraud_buyer_df
(
    platform_user_id string comment 'platform_user_id'
    ,user_reg_after_days bigint
    ,config_addr_list_td string
    ,frequency_city_name_list_6m string
    ,fst_lvl_network_user_id_list_sz_dfp_td string
    ,fst_lvl_network_user_id_list_td string
    ,frequency_hex_hash_shopee_df_list_1y string
    ,frequency_sz_dfp_device_id_list_1y string
    ,frequency_phone_list_td string
    ,frequency_sz_dfp_device_id_list_seller_1y string
    ,frequency_shopee_df_list_seller_1y string
    ,frequency_tongdun_device_id_list_1y string
    ,frequency_tongdun_device_id_list_seller_1y string
    ,silent_days_cnt bigint
    ,current_days_after_activation_spl bigint
    ,cnt_szdf_90d_all_link_dpd30_all bigint
    ,bad_user_group_ds bigint
    ,phone_book_cluster_blacklist_1 bigint
    ,hit_ds_community_tag_l14d_v2 bigint
    ,hit_ds_community_tag_l7d_v2 bigint
    ,hit_ds_community_tag_l14d bigint
    ,hit_ds_community_tag_l7d bigint
    ,address_userid_cnt bigint
    ,cnt_order_l12m bigint
    ,cnt_ba_link_dpd30_all bigint
    ,cnt_email_link_dpd30_all bigint
    ,month_due_spl bigint
    ,flag_existing_credit_user bigint
    ,cash_out_tag bigint
    ,hit_rule_bad_user_in_cluster bigint
    ,hit_rule_bad_user_in_cluster_l7d bigint
    ,hit_rule_bad_user_in_cluster_l14d bigint
    ,abnormal_ratio_in_cluster double
) 
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/ads/ads_risk_fs_seamoney_antifraud_buyer_df/grass_region=ID';
--msck repair table ${SCHEMA}.ads_risk_id_fs_seamoney_antifraud_buyer_df;


insert overwrite table
    ${SCHEMA}.ads_risk_id_fs_seamoney_antifraud_buyer_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t2.user_reg_after_days
    ,t3.config_addr_list_td
    ,t3.frequency_city_name_list_6m
    ,t3.fst_lvl_network_user_id_list_sz_dfp_td
    ,t3.fst_lvl_network_user_id_list_td
    ,t3.frequency_hex_hash_shopee_df_list_1y
    ,t3.frequency_sz_dfp_device_id_list_1y
    ,t3.frequency_phone_list_td
    ,t3.frequency_sz_dfp_device_id_list_seller_1y
    ,t3.frequency_shopee_df_list_seller_1y
    ,t3.frequency_tongdun_device_id_list_1y
    ,t3.frequency_tongdun_device_id_list_seller_1y
    ,t4.silent_days_cnt
    ,t5.current_days_after_activation_spl
    ,t6.cnt_szdf_90d_all_link_dpd30_all
    ,t7.bad_user_group_ds
    ,t7.phone_book_cluster_blacklist_1
    ,t7.hit_ds_community_tag_l14d_v2
    ,t7.hit_ds_community_tag_l7d_v2
    ,t7.hit_ds_community_tag_l14d
    ,t7.hit_ds_community_tag_l7d
    ,t8.address_userid_cnt
    ,t8.cnt_order_l12m
    ,t9.cnt_ba_link_dpd30_all
    ,t9.cnt_email_link_dpd30_all
    ,t10.month_due_spl
    ,t10.flag_existing_credit_user
    ,t7.cash_out_tag
    ,t7.hit_rule_bad_user_in_cluster
    ,t7.hit_rule_bad_user_in_cluster_l7d
    ,t7.hit_rule_bad_user_in_cluster_l14d
    ,t7.abnormal_ratio_in_cluster
from
    (
        select
            *
        from ${SCHEMA}.dim_risk_id_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join
    (
        select 
            user_id as platform_user_id
            ,DATEDIFF('${smd_grass_date}', date(from_unixtime(registration_timestamp))) as user_reg_after_days
        from mp_user.dim_user__reg_s0_live
        where tz_type = 'local'
        and grass_region = 'ID'
        and grass_date = '${grass_date}'
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select
            user_id as platform_user_id
            ,config_addr_list_td
            ,frequency_city_name_list_6m
            ,fst_lvl_network_user_id_list_sz_dfp_td
            ,fst_lvl_network_user_id_list_td
            ,frequency_hex_hash_shopee_df_list_1y
            ,frequency_sz_dfp_device_id_list_1y
            ,frequency_phone_list_td
            ,frequency_sz_dfp_device_id_list_seller_1y
            ,frequency_shopee_df_list_seller_1y
            ,frequency_tongdun_device_id_list_1y
            ,frequency_tongdun_device_id_list_seller_1y
        from risk.ads_risk_profile_user_df
        where
            grass_region = 'ID'
            and grass_date = '${grass_date}'
    ) t3 on t1.platform_user_id = t3.platform_user_id
    left join
    (
        select
            platform_user_id
            ,silent_days_cnt
        from risk.dws_risk_id_user_behavior_mp_login_info_df
        where grass_date = '${grass_date}'
    ) t4 on t1.platform_user_id = t4.platform_user_id
    left join
    (
        select 
            platform_user_id
            ,first_activation_time
            ,DATEDIFF('${smd_grass_date}', date(first_activation_time)) as current_days_after_activation_spl
        from credit_uc.dws_spl_id_uc_user_df
        where grass_date = '${grass_date}'
    ) t5 on t1.platform_user_id = t5.platform_user_id
    left join
    (
        select
            platform_user_id
            ,cnt_szdf_90d_all_link_dpd30_all
        from risk.dws_risk_${region}_user_af_graph_dpd_df
        where grass_date = '${grass_date}'
    ) t6 on t1.platform_user_id = t6.platform_user_id
    left join
    (
        select
            platform_user_id
            ,bad_user_group_ds
            ,phone_book_cluster_blacklist_1
            ,hit_ds_community_tag_l14d_v2
            ,hit_ds_community_tag_l7d_v2
            ,hit_ds_community_tag_l14d
            ,hit_ds_community_tag_l7d
            ,cash_out_tag
            ,hit_rule_bad_user_in_cluster
            ,hit_rule_bad_user_in_cluster_l7d
            ,hit_rule_bad_user_in_cluster_l14d
            ,abnormal_ratio_in_cluster
        from risk.dws_risk_${region}_user_metrics_biz_manage_df
        where grass_date = '${grass_date}'
    ) t7 on t1.platform_user_id = t7.platform_user_id
    left join
    (
        select
            platform_user_id
            ,address_userid_cnt
            ,cnt_order_l12m
        from risk.dws_risk_${region}_user_txn_mp_order_complete_df
        where grass_date = '${grass_date}'
    ) t8 on t1.platform_user_id = t8.platform_user_id
    left join
    (
        select
            platform_user_id
            ,cnt_ba_link_dpd30_all
            ,cnt_email_link_dpd30_all
        from risk.dws_risk_${region}_user_af_graph_dpd_df
        where grass_date = '${grass_date}'
    ) t9 on t1.platform_user_id = t9.platform_user_id
    left join
    (
        select
            platform_user_id
            ,month_due_spl
            ,flag_existing_credit_user
        from risk.dws_risk_id_user_txn_fp_repayment_df
        where grass_date = '${grass_date}'
    ) t10 on t1.platform_user_id = t10.platform_user_id
;