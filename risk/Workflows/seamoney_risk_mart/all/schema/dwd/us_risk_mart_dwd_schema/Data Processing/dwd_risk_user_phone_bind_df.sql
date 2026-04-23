drop table if exists ${SCHEMA}.dwd_risk_user_phone_bind_df;
create external table if not exists ${SCHEMA}.dwd_risk_user_phone_bind_df
(
    user_id bigint comment 'shopee user id'
    ,bind_phone string comment 'user bind phone'
    ,bind_timestamp bigint comment 'user bind phone time'
)
comment 'user login record'
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_user_phone_bind_df';
msck repair table ${SCHEMA}.dwd_risk_user_phone_bind_df;
