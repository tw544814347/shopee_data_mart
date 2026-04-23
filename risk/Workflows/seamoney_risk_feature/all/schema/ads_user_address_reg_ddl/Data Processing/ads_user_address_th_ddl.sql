drop table if exists risk.ads_user_address_th
;

create table risk.ads_user_address_th (
    row_key string
    ,latest_receiver_address string
    ,latitude double
    ,longitude double
    ,address_level1_value string
    ,address_level2_value string
    ,address_level3_value string
)
partitioned by
    (grass_date string) stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_feature/ads/ads_user_address_th'
;

msck repair table risk.ads_user_address_th
;