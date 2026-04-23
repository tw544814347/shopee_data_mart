drop table if exists ${SCHEMA}.ads_risk_${region}_fs_seamoney_antifraud_buyer_df;

create table if not exists ${SCHEMA}.ads_risk_${region}_fs_seamoney_antifraud_buyer_df
(
    platform_user_id string comment 'platform_user_id'
    ,config_addr_list_td string comment 'list of shipping address used in history'
    ,frequency_city_name_list_6m string comment 'frequently located city'
    ,fst_lvl_network_user_id_list_sz_dfp_td string comment 'fst_lvl_network_user_id_list_sz_dfp_td'
    ,frequency_hex_hash_shopee_df_list_1y string comment 'frequency_hex_hash_shopee_df_list_1y'
    ,frequency_sz_dfp_device_id_list_1y string comment 'frequency_sz_dfp_device_id_list_1y'
    ,frequency_phone_list_td string comment 'frequently used phone number'
    ,silent_days_cnt bigint comment 'count of days for no-login period'
    ,user_webcheckout_frequency_180d bigint comment 'count the months which buyer has escrow paid web checkout in the past 6 months (0~6 variable)'
    ,hit_rule_bad_user_in_cluster_v2 bigint comment 'hit_rule_bad_user_in_cluster_v2'
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
location '${HDFS_PATH}/risk_mart/ads/ads_risk_fs_seamoney_antifraud_buyer_df/grass_region=${grass_region}';

msck repair table ${SCHEMA}.ads_risk_${region}_fs_seamoney_antifraud_buyer_df;

