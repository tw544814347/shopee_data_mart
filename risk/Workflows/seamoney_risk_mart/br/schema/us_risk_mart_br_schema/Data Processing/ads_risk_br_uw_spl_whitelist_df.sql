drop  table if exists risk.ads_risk_br_uw_spl_whitelist_df;
create external table if not exists risk.ads_risk_br_uw_spl_whitelist_df
(
platform_user_id         string          comment 'available shopid'
,status                   int             comment '1-available'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="536870912")
LOCATION '${HDFS_PATH}/risk_mart/ads/ads_risk_br_uw_spl_whitelist_df'
;