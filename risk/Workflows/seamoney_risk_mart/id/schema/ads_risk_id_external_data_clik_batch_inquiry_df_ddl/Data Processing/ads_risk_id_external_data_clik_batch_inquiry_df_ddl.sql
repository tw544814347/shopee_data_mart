--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2024-11-01
-- Theme Domain：      
-- Description:         [SPFDT-45650] 
-- Data Granularity:    
-- 变更历史：https://casement.scredit.io/project/78703/version?versionTab=task&versionId=7013&jiraKey=SPFDT-45650
--********************************************************************--

DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_id_external_data_clik_batch_inquiry_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_id_external_data_clik_batch_inquiry_df
(
     platform_user_id        string
    ,user_name              string
    ,birth_date             string   
    ,gender                 string 
    ,address                string
    ,sub_district           string
    ,district               string 
    ,country                string 
    ,id_card_no             string
    ,phone_number           string 
)
comment 'spl_copy_middle_table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="ZSTD")
location '${HDFS_PATH}/risk_mart/dwd/ads_risk_id_external_data_clik_batch_inquiry_df';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_id_external_data_clik_batch_inquiry_df;