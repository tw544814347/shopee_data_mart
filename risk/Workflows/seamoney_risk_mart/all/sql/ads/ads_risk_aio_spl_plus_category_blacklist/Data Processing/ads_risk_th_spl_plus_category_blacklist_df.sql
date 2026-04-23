-- CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_th_spl_plus_category_blacklist_df
-- (
--     category_id_l1      string 
--     ,category_id_l2     string 
-- )
-- partitioned by
-- (
--     grass_date string comment 'partition key, yyyy-MM-dd'
-- )
-- stored as orc tblproperties ("orc.compress"="ZSTD")
-- location '${HDFS_PATH}/risk_mart/ads/ads_risk_th_spl_plus_category_blacklist_df';
-- MSCK REPAIR TABLE ${SCHEMA}.ads_risk_th_spl_plus_category_blacklist_df;

insert overwrite table risk.ads_risk_th_spl_plus_category_blacklist_df partition(grass_date='${grass_date}')
select 
category_id_l1 
,category_id_l2 
from smcdrisk_antifraud.th_spl_plus_category_blacklist
;