drop  table if exists risk.ads_risk_tw_seller_kyc_info_df;
create external table if not exists risk.ads_risk_tw_seller_kyc_info_df
(
store_id            string comment 'store_id'
,user_id            string comment 'platform_user_id'
,brand_name         string comment 'store_brand_name'
,resp_name          string comment 'resp_name'
,resp_id            string comment 'resp_id'
,vendor_name        string comment 'vendor_name'
,vendor_no          string comment 'vendor_no'
)
partitioned by 
(
      grass_date string comment "partition date yyyy-MM-dd"
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/ads/ads_risk_seller_kyc_info_df/grass_region=TW'
;