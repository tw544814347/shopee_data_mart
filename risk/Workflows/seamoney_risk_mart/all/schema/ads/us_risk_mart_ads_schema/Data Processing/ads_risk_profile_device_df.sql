drop table if exists ${SCHEMA}.ads_risk_profile_device_df;
create external table if not exists ${SCHEMA}.ads_risk_profile_device_df
(
    shopee_df string comment 'shopee original device fingerprint'
    ,shopee_device_id	string comment 'shopee device id'
    ,hash_shopee_df	string comment 'hashed shopee device fingerprint'
    ,hex_hash_shopee_df	string comment 'hex hashed shopee device fingerprint'
    ,tongdun_device_id	string comment 'Tongdun device id, bought from the third-part would not change when users reset their phone.'
    ,login_user_id_list	string comment 'a list that can store all userid that have logged in on this device'
    ,spdf_fst_login_timestamp bigint comment 'shopee df first login in shopee timestamp'
    ,spdf_fst_req_credit_timestamp bigint comment 'shopee df first request in credit timestamp'
    ,sz_dfp_device_id string comment 'sz dfp device id'
)
comment 'shopee df dimension ads metrics'
partitioned by
(
     tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_profile_device_df';
msck repair table ${SCHEMA}.ads_risk_profile_device_df;