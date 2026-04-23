drop table if exists ${SCHEMA}.dws_risk_ph_user_metrics_biz_manage_df;
create external table if not exists ${SCHEMA}.dws_risk_ph_user_metrics_biz_manage_df (
    platform_user_id string comment 'platform_user_id'
    ,lending_cnt bigint comment 'lending_cnt'
    ,lending_high_cnt bigint comment 'lending_high_cnt'
    ,casino_cnt bigint comment 'casino_cnt'
    ,suspicious_cnt bigint comment 'suspicious_cnt'
    ,dp_abtesting_user_tag string comment 'dp_abtesting_user_tag'
    ,ph_spl_blacklist_hit int comment 'ph_spl_blacklist_hit'
    ,spl_wifi_shared_dpd60_ind int comment 'spl_wifi_shared_dpd60_ind'
    ,spl_wifi_graph_risk_ind int comment 'spl_wifi_graph_risk_ind'
    ,bcl_wifi_shared_dpd60_ind int comment 'bcl_wifi_shared_dpd60_ind'
    ,linked_to_dpd_relationship_father_child int comment 'linked_to_dpd_relationship_father_child'
    ,linked_to_dpd_relationship_couple int comment 'linked_to_dpd_relationship_couple'
    ,linked_to_dpd_relationship_couple_suspect int comment 'linked_to_dpd_relationship_couple_suspect'
    ,linked_to_dpd_relationship_couple_infer int comment 'linked_to_dpd_relationship_couple_infer'
    ,linked_to_dpd_relationship_father_child_infer int comment 'linked_to_dpd_relationship_father_child_infer'
    ,linked_to_dpd_relationship_myself int comment 'linked_to_dpd_relationship_myself'
    ,linked_to_dpd_relationship_mother_child int comment 'linked_to_dpd_relationship_mother_child'
    ,linked_to_dpd_relationship_lover int comment 'linked_to_dpd_relationship_lover'
    ,linked_to_dpd_relationship_father_child_phone_infer int comment 'linked_to_dpd_relationship_father_child_phone_infer'
    ,phone_ec_mp_cur_dpd15 int comment 'phone_ec_mp_cur_dpd15'
    ,phone_ec_mp_cur_dpd30 int comment 'phone_ec_mp_cur_dpd30'
    ,linked_dpd60_sellerbankaccount int comment 'linked_dpd60_sellerbankaccount'
    ,linked_sellbankaccount_user_count int comment 'linked_sellbankaccount_user_count'
    ,is_af_blacklist int comment 'is_af_blacklist'
    ,is_spl_incre_control int comment 'is_spl_incre_control'
    ,is_plm_decre_control int comment 'is_plm_decre_control'
    ,is_plm_freeze_control int comment 'is_plm_freeze_control'
    ,is_af_blacklist_p30d int comment 'is_af_blacklist_p30d'
    ,lending_high_m6_cnt int comment 'lending_high_m6_cnt'
    ,spl_cpd30_cnt_in_cluster bigint comment 'spl_cpd30_cnt_in_cluster'
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_metrics_biz_manage_df/garss_region=PH'
;

msck repair table ${SCHEMA}.dws_risk_ph_user_metrics_biz_manage_df
;