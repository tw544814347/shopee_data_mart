drop table if exists ${SCHEMA}.ads_risk_user_device_auto_login_cnt_df;
create external table if not exists ${SCHEMA}.ads_risk_user_device_auto_login_cnt_df 
(
    user_id string
    ,is_success string
    ,login_time string
    ,login_channel string
    ,is_auto_login string
    ,grass_date string
) 
partitioned by 
(
    grass_region string comment 'partition key'
) 
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
) 
location '${HDFS_PATH}/risk_mart/ads/ads_risk_user_device_auto_login_cnt_df'
;
msck repair table ${SCHEMA}.ads_risk_user_device_auto_login_cnt_df;


drop table if exists ${SCHEMA}.ads_risk_user_device_latest_login_time_df;
create external table if not exists ${SCHEMA}.ads_risk_user_device_latest_login_time_df 
(
    user_id string
    ,is_success string
    ,login_time string
    ,login_channel string
    ,is_auto_login string
) 
partitioned by 
(
    grass_region string comment 'partition key'
    ,grass_date  string comment 'partition key'
) 
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
) 
location '${HDFS_PATH}/risk_mart/ads/ads_risk_user_device_latest_login_time_df'
;
msck repair table ${SCHEMA}.ads_risk_user_device_latest_login_time_df;