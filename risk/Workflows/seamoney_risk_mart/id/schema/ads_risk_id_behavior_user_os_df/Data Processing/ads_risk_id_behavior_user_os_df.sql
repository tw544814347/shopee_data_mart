--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2024-11-04
-- Theme Domain：       
-- Description:         [SPFDT-44654] 
-- Data Granularity:    
-- 变更历史：
--    
--********************************************************************--
DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_id_behavior_user_os_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_id_behavior_user_os_df
(   platform_user_id                                string
    ,spl_os                                         decimal(30,10) 
    ,spl_plus_offline_os                            decimal(30,10) 
    ,spl_plus_online_os                             decimal(30,10) 
    ,bcl_os                                         decimal(30,10) 
    ,tl_os                                          decimal(30,10)  
    ,total_internal_os                              decimal(30,10) 
    ,spl_os_dued_within_30d                         decimal(30,10) 
    ,spl_plus_offline_os_dued_within_30d            decimal(30,10) 
    ,spl_plus_online_os_dued_within_30d             decimal(30,10) 
    ,bcl_os_dued_within_30d                         decimal(30,10) 
    ,tl_os_dued_within_30d                          decimal(30,10) 
    ,total_internal_os_dued_within_30d              decimal(30,10) 
)
comment 'Tag: risk mart summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="ZSTD")
location '${HDFS_PATH}/risk_mart/dwd/ads_risk_id_behavior_user_os_df';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_id_behavior_user_os_df;