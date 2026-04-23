drop table if exists ${SCHEMA}.dwd_risk_checkout_df;
create external table if not exists ${SCHEMA}.dwd_risk_checkout_df
(
    buyer_id bigint comment 'shopee buyer id'
    ,checkout_id string comment 'checkout id'
    ,checkout_ip string comment 'checkout ip'
    ,shopee_device_id string comment 'shopee device id'
    ,checkout_timestamp bigint comment 'checkout time stamp'
)
comment 'store checkout full data of not finish, will be removed when over 1 year or complete'
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_checkout_df';
msck repair table ${SCHEMA}.dwd_risk_checkout_df;
