--drop table if exists ${SCHEMA}.dwd_datapoint_applist_zi_df;
create external table if not exists ${SCHEMA}.dwd_datapoint_applist_zi_df
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
    ,end_date string
)
partitioned by
(
    grass_region string comment 'partition key'
    ,grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties("orc.compress" = "zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_datapoint_applist_zi_df'
;

--msck repair table ${SCHEMA}.dwd_datapoint_applist_zi_df;


insert overwrite table risk.dwd_datapoint_applist_zi_df partition (grass_region, grass_date)
select
    advertisement_id
    ,app_version
    ,client_id
    ,client_ip
    ,country
    ,device_fingerprint
    ,device_id
    ,env
    ,event_timestamp
    ,log_timestamp
    ,platform
    ,trigger_source
    ,user_id
    ,app_id
    ,app_name
    ,first_installed_time
    ,last_updated_time
    ,start_date
    ,platform_id
    ,end_date
    ,grass_region
    ,'${grass_date}' as grass_date
from risk.dwd_datapoint_applist_zi
where end_date = '9999-12-31'
;