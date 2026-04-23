drop table if exists risk.ads_risk_id_user_address_level_df
;

create table risk.ads_risk_id_user_address_level_df (
    user_id string
    ,address_level1_value string comment 'Province'
    ,address_level2_value string comment 'City'
    ,address_level3_value string comment 'District'
    ,latest_modify_time   string comment ''
)
partitioned by
    (grass_date string) stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_feature/ads/ads_risk_id_user_address_level_df'
;

msck repair table risk.ads_risk_id_user_address_level_df
;