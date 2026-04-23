drop table if exists ${SCHEMA}.ads_risk_user_login_cnt_in_spp_df;
create external table if not exists ${SCHEMA}.ads_risk_user_login_cnt_in_spp_df 
(
    rowkey         string
    ,qf            string
    ,is_auto_login string
) 
partitioned by 
(
    grass_region    string         comment         'partition key'
    ,grass_date     string         comment         'partition key, yyyy-MM-dd'
) 
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
) 
location '${HDFS_PATH}/risk_mart/ads/ads_risk_user_login_cnt_in_spp_df'
;
msck repair table ${SCHEMA}.ads_risk_user_login_cnt_in_spp_df;


drop table if exists ${SCHEMA}.ads_risk_user_login_country_city_in_spp_df;
create external table if not exists ${SCHEMA}.ads_risk_user_login_country_city_in_spp_df 
(
    rowkey         string
    ,qf            string
    ,is_auto_login string
) 
partitioned by 
(
    grass_region    string         comment         'partition key'
    ,grass_date     string         comment         'partition key, yyyy-MM-dd'
) 
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
) 
location '${HDFS_PATH}/risk_mart/ads/ads_risk_user_login_country_city_in_spp_df'
;
msck repair table ${SCHEMA}.ads_risk_user_login_country_city_in_spp_df;


drop table if exists ${SCHEMA}.ads_risk_user_device_latest_login_in_spp_df;
create external table if not exists ${SCHEMA}.ads_risk_user_device_latest_login_in_spp_df 
(
    rowkey         string
    ,qf            string
    ,version       bigint
) 
partitioned by 
(
    grass_region    string         comment         'partition key'
) 
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
) 
location '${HDFS_PATH}/risk_mart/ads/ads_risk_user_device_latest_login_in_spp_df'
;
msck repair table ${SCHEMA}.ads_risk_user_device_latest_login_in_spp_df;