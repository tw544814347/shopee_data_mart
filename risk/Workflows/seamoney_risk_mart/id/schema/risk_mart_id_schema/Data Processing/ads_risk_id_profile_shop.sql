drop table if exists ${SCHEMA}.ads_risk_id_profile_shop;
create external table if not exists ${SCHEMA}.ads_risk_id_profile_shop
(
    shop_id	bigint
    ,shopee_registration_timestamp bigint
)
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_id_profile_shop';
msck repair table ${SCHEMA}.ads_risk_id_profile_shop;