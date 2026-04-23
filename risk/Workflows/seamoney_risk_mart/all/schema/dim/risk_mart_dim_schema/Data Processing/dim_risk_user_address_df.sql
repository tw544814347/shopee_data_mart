drop table if exists ${SCHEMA}.dim_risk_user_address_df;
create external table if not exists ${SCHEMA}.dim_risk_user_address_df
(
    user_id	bigint comment 'shopee user id'
    ,config_address string comment 'user config address, came from the upstream table.'
    ,modified_time bigint comment 'record modified time'
    ,status int comment 'raw status code, came from the upstream table'
    ,is_valid string comment 'Y : valid, N : invalid'
)
comment 'the address user configured'
partitioned by
(
     tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dim/dim_risk_user_address_df';
msck repair table ${SCHEMA}.dim_risk_user_address_df;