drop table if exists ${SCHEMA}.dim_risk_device_df;
create external table if not exists ${SCHEMA}.dim_risk_device_df
(
    hash_shopee_df string,
    tongdun_device_id string,
    sz_dfp_device_id string
)
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key, region'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dim/dim_risk_device_df';
msck repair table ${SCHEMA}.dim_risk_device_df;

drop table if exists ${SCHEMA}.dim_risk_sz_dfp_device_mapping_df;
create external table if not exists ${SCHEMA}.dim_risk_sz_dfp_device_mapping_df
(
    device_type string
    ,device_id string
    ,sz_dfp_device_id string
)
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key, region'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dim/dim_risk_sz_dfp_device_mapping_df';
msck repair table ${SCHEMA}.dim_risk_sz_dfp_device_mapping_df;