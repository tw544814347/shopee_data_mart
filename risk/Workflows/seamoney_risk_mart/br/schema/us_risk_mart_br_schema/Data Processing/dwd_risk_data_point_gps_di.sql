DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_data_point_gps_di;
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
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_data_point_gps_di';
msck repair table ${SCHEMA}.dwd_risk_data_point_gps_di;