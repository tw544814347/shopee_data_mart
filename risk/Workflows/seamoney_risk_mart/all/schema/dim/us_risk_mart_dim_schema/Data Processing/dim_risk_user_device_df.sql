drop table if exists ${SCHEMA}.dim_risk_user_device_df;
create external table if not exists ${SCHEMA}.dim_risk_user_device_df
(
    user_id bigint comment 'shopee user id'
    ,shopee_df string comment 'shopee original device fingerprint'
    ,shopee_device_id string comment 'shopee device id'
    ,tongdun_device_id string comment 'bought from the third part, to be the unique mark'
    ,hash_shopee_df string comment 'hashed shopee device fingerprint'
    ,create_timestamp bigint comment 'create timestamp'
    ,sz_dfp_device_id string
)
comment 'this table record the user login device manually and automatically '
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dim/dim_risk_user_device_df';
msck repair table ${SCHEMA}.dim_risk_user_device_df;