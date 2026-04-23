drop table if exists ${SCHEMA}.ads_risk_user_device_login_language_channel_info_df;
create external table if not exists ${SCHEMA}.ads_risk_user_device_login_language_channel_info_df 
(
    rowkey string
    ,qf_1d string
    ,qf_3d string
    ,qf_7d string
    ,qf_14d string
) 
partitioned by 
(
    grass_region string comment 'partition key'
    ,type string comment 'partition key'
) 
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
) 
location '${HDFS_PATH}/risk_mart/ads/ads_risk_user_device_login_language_channel_info_df'
;
msck repair table ${SCHEMA}.ads_risk_user_device_login_language_channel_info_df;


