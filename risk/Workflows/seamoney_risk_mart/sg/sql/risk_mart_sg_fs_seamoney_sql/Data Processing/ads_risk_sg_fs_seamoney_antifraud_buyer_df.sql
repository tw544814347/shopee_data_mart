--drop table if exists ${SCHEMA}.ads_risk_${region}_fs_seamoney_antifraud_buyer_df;
create external table if not exists ${SCHEMA}.ads_risk_${region}_fs_seamoney_antifraud_buyer_df (
    platform_user_id string comment 'platform_user_id'
    ,config_addr_list_td string
    ,frequency_city_name_list_6m string
    ,frequency_hex_hash_shopee_df_list_1y string
    ,frequency_sz_dfp_device_id_list_1y string
    ,frequency_phone_list_td string
    ,silent_days_cnt bigint
    ,is_only_have_non_sg_card bigint
    ,hit_rule_bad_user_in_cluster bigint
)
partitioned by
    (grass_date string comment "YYYY-MM-DD") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/ads/ads_risk_reg_fs_seamoney_antifraud_buyer_df/garss_region=${upper_region}'
;
--msck repair table ${SCHEMA}.ads_risk_${region}_fs_seamoney_antifraud_buyer_df;

insert overwrite table
    ${SCHEMA}.ads_risk_${region}_fs_seamoney_antifraud_buyer_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t2.config_addr_list_td
    ,t2.frequency_city_name_list_6m
    ,t2.frequency_hex_hash_shopee_df_list_1y
    ,t2.frequency_sz_dfp_device_id_list_1y
    ,t2.frequency_phone_list_td
    ,t3.silent_days_cnt
    ,t4.is_only_have_non_sg_card
    ,t6.hit_rule_bad_user_in_cluster
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
            ,frequency_hex_hash_shopee_df_list_1y
            ,frequency_sz_dfp_device_id_list_1y
            ,frequency_phone_list_td
        from risk.ads_risk_profile_user_df
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
            ,is_only_have_non_sg_card
        from ${SCHEMA}.dws_risk_${region}_user_txn_spp_bank_card_df
        where grass_date = '${grass_date}'
    ) t4 on t1.platform_user_id = t4.platform_user_id
    left join (
        select
            platform_user_id
            ,hit_rule_bad_user_in_cluster
        from regsm_riskmgmt.user_graph_community_risk_antifraud_v1
        where grass_region = '${grass_region}'
        and grass_date = (select max(grass_date) from regsm_riskmgmt.user_graph_community_risk_antifraud_v1 where grass_region = '${grass_region}')
    ) t6 on t1.platform_user_id = t6.platform_user_id
;