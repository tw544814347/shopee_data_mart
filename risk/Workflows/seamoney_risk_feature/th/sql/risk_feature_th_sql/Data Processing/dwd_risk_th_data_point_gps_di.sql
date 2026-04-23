--DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_data_point_gps_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_data_point_gps_di
(
    user_id bigint
    ,report_timestamp bigint
    ,device_fingerprint string
    ,longitude double
    ,latitude double
    ,base bigint
    ,location_timestamp bigint
)
partitioned by
(
     tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_data_point_gps_di';
--msck repair table ${SCHEMA}.dwd_risk_data_point_gps_di;


create or replace temporary function dps_decrypt as 'com.shopee.udf.AESDecryptUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';

INSERT OVERWRITE TABLE ${SCHEMA}.dwd_risk_data_point_gps_di PARTITION(tz_type='local', grass_region, grass_date)
select
    userid as user_id
    ,report_timestamp
    ,device_fingerprint
    ,cast(get_json_object(location,'$.longitude') as double) as longitude
    ,cast(get_json_object(location,'$.latitude') as double) as latitude
    ,cast(get_json_object(location,'$.base') as bigint) as base
    ,cast(get_json_object(location,'$.location_timestamp') as bigint) as location_timestamp
    ,upper('${region}') as grass_region
    ,grass_date
from
    (
        select
            cast(userid as bigint) as userid,
            cast(log_timestamp/1000 as bigint) as report_timestamp,
            cast(device_fingerprint as string) as device_fingerprint,
            dps_decrypt(data) as location,
            grass_date
        from tracking.shopee_tracking_ods_dps_merge_location_di__${region}_s1_live
        where grass_date = date'${grass_date}'
            and userid is not null
    ) t
;