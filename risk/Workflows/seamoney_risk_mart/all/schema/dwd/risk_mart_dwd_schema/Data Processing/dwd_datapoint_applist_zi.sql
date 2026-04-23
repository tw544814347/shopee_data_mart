drop table if exists ${SCHEMA}.dwd_datapoint_applist_zi;
create external table if not exists ${SCHEMA}.dwd_datapoint_applist_zi
(
    advertisement_id string
    ,app_version string
    ,client_id string
    ,client_ip string
    ,country string
    ,device_fingerprint string
    ,device_id string
    ,env string
    ,event_timestamp bigint
    ,log_timestamp bigint
    ,platform string
    ,trigger_source string
    ,user_id string
    ,app_id string
    ,app_name string
    ,first_installed_time string
    ,last_updated_time string
    ,start_date string
    ,platform_id string
)
partitioned by
(
    grass_region string comment 'partition key'
    ,end_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties("orc.compress" = "zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_datapoint_applist_zi'
;

msck repair table ${SCHEMA}.dwd_datapoint_applist_zi;

