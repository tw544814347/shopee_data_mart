drop table if exists risk.ads_risk_af_phone_register_nd;
CREATE TABLE risk.ads_risk_af_phone_register_nd  (
   register_phone                        string comment 'user register phone'
   ,register_fraud_tag_user_3d           string comment 'last 3 days login fraud_tag user_id'
   ,register_fraud_tag_user_7d           string comment 'last 6 days login fraud_tag user_id'
   ,register_fraud_tag_user_30d          string comment 'last 30 days login fraud_tag user_id'
   ,register_fraud_tag_user_60d          string comment 'last 60 days login fraud_tag user_id'
   ,register_fraud_tag_user_90d          string comment 'last 90 days login fraud_tag user_id'
   ,register_fraud_tag_user_120d         string comment 'last 120 days login fraud_tag user_id'
   ,register_fraud_tag_user_150d         string comment 'last 150 days login fraud_tag user_id'
   ,register_fraud_tag_user_180d         string comment 'last 180 days login fraud_tag user_id'
   )
PARTITIONED BY ( 
   grass_region string comment 'region',
   grass_date string comment 'grass_dates'
   )
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_feature/ads/ads_risk_af_phone_register_nd'
;
