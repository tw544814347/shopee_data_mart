drop table if exists ${SCHEMA}.dim_risk_tongdun_device_mapping_history_df;
create external table if not exists ${SCHEMA}.dim_risk_tongdun_device_mapping_history_df
(
    shopee_df string comment 'shopee original df'
    ,shopee_device_id string comment 'shopee device id'
    ,hash_shopee_df string comment 'hashed shopee device fingerprint'
    ,tongdun_device_id string comment 'bought from the third part, to be the unique mark'
    ,app_type int comment 'application type'
)
comment 'Tongdun device id is bought from the third part, to be the unique mark '
partitioned by
(
    tz_type        string          comment         'timezone type'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dim/dim_risk_tongdun_device_mapping_history_df';
msck repair table ${SCHEMA}.dim_risk_tongdun_device_mapping_history_df;