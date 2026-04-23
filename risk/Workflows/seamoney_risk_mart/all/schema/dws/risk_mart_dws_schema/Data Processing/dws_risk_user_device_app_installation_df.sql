drop table if exists ${SCHEMA}.dws_risk_user_device_app_installation_df;
create external table if not exists ${SCHEMA}.dws_risk_user_device_app_installation_df
(
    platform_user_id string comment 'shopee platform user id'
    ,device_fingerprint string comment 'device fingerprint'
    ,device_id string comment 'device id'
    ,platform string comment 'platform'
    ,is_bpjs_installed tinyint comment 'whether install ID social security apps'
)
partitioned by
(
    grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_device_app_installation_df';
msck repair table ${SCHEMA}.dws_risk_user_device_app_installation_df;