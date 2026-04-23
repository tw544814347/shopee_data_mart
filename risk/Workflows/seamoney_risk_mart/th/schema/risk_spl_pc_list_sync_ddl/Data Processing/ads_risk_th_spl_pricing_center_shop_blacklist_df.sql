drop  table if exists risk.ads_risk_th_spl_pricing_center_shop_blacklist_df;
create external table if not exists risk.ads_risk_th_spl_pricing_center_shop_blacklist_df
(
shop_id                   string          comment 'blacklist shopid'
,status                   int             comment '1-blacklist'
)
partitioned by (grass_date string comment "partition date yyyy-MM-dd")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ads/ads_risk_th_spl_pricing_center_shop_blacklist_df'
;

MSCK REPAIR TABLE ${SCHEMA}.ads_risk_th_spl_pricing_center_shop_blacklist_df
;