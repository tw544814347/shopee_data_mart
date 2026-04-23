--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2024-11-01
-- Theme Domain：       
-- Description:         [SPFDT-45651] 
-- Data Granularity:    
-- 变更历史：
--    
--********************************************************************--
DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_id_spl_xtra_ota_user_blacklist_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_id_spl_xtra_ota_user_blacklist_df
(
    user_id      string 
    ,status      string 
    ,add_date    string
)
comment 'spl_copy_middle_table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="ZSTD")
location '${HDFS_PATH}/risk_mart/dwd/ads_risk_id_spl_xtra_ota_user_blacklist_df';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_id_spl_xtra_ota_user_blacklist_df;