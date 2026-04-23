drop table if exists ${SCHEMA}.ads_risk_profile_sz_dfp_device_df;
create external table if not exists ${SCHEMA}.ads_risk_profile_sz_dfp_device_df
(
    sz_dfp_device_id string comment 'tongdun device fingerprint'
    ,szdf_fst_login_timestamp	string comment 'tongdun device first login shopee timestamp'
    ,szdf_fst_req_credit_timestamp	string comment 'tongdun device first req credit'
)
comment 'tongdun device dimension ads metrics'
partitioned by
(
     tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_profile_sz_dfp_device_df';
msck repair table ${SCHEMA}.ads_risk_profile_sz_dfp_device_df;