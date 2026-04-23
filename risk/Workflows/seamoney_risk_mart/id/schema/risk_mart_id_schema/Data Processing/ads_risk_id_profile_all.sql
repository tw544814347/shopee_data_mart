drop table if exists ${SCHEMA}.ads_risk_id_profile_all;
create external table if not exists ${SCHEMA}.ads_risk_id_profile_all
(
    user_id	bigint
    ,shopee_registration_timestamp bigint
    ,shopee_device_id string
    ,hex_hash_shopee_df string
    ,spdf_fst_login_timestamp bigint
    ,spdf_fst_req_credit_timestamp bigint
    ,tongdun_device_id string
    ,tddf_fst_login_timestamp string
    ,tddf_fst_req_credit_timestamp string
)
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
    ,bz_type string
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_id_profile_all';
msck repair table ${SCHEMA}.ads_risk_id_profile_all;