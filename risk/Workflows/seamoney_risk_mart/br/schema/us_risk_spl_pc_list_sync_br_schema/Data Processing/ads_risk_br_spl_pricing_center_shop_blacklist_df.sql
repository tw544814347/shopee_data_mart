drop  table if exists risk.ads_risk_br_spl_pricing_center_shop_blacklist_df;
create external table if not exists risk.ads_risk_br_spl_pricing_center_shop_blacklist_df
(
shop_id                   string          comment 'blacklist shopid'
,status                   int             comment '1-blacklist'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
comment 'Tag:risk summary table'
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_risk_br_spl_pricing_center_shop_blacklist_df'
;