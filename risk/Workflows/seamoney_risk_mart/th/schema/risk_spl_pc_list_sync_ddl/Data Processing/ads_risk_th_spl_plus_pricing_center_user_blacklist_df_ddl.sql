

DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_th_spl_plus_pricing_center_user_blacklist_df;
-- CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_th_spl_plus_pricing_center_user_blacklist_df
-- (
--     data      string 
--     ,datatype string 
-- )
-- comment 'spl_plus'
-- partitioned by
-- (
--     grass_date string comment 'partition key, yyyy-MM-dd'
-- )
-- stored as orc tblproperties ("orc.compress"="ZSTD")
-- location '${HDFS_PATH}/risk_mart/ads/ads_risk_th_spl_plus_pricing_center_user_blacklist_df';
-- MSCK REPAIR TABLE ${SCHEMA}.ads_risk_th_spl_plus_pricing_center_user_blacklist_df;