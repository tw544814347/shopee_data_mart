drop  table if exists risk.ads_risk_tw_uw_scl_whitelist_df;
create external table if not exists risk.ads_risk_tw_uw_scl_whitelist_df
(
platform_user_id         string          comment 'available shopid'
,status                   int             comment '1-available'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/ads/ads_risk_tw_uw_scl_whitelist_df'
;