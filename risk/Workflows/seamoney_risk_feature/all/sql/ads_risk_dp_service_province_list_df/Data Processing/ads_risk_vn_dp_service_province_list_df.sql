-- =============================================================================
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-12-08
-- Theme Domain:        risk feature dev 
-- Data Granularity:    
-- Description:         基于 itemid（电费和教育品类）查询到对应的服务省份
-- Documents:           
-- =============================================================================
--  Version History:
--  wei.tao@shopee.com jira:https://jira.shopee.io/browse/SPFDT-56711
-- =============================================================================




DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_vn_dp_service_province_list_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_vn_dp_service_province_list_df
(
    item_id string comment ''
    ,item_name string comment 'item_name'
    ,category string comment 'category'
    ,level1_location_list string comment 'level1_location_list'
)
partitioned by
( 
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="ZSTD")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_vn_dp_service_province_list_df';

insert overwrite table ${SCHEMA}.ads_risk_vn_dp_service_province_list_df partition (grass_date = '${ds}')
select itemid as item_id, item_name, category,
    concat_ws(',', collect_set(level1_location)) as level1_location_list
from smcdrisk_antifraud.vn_dp_service_province_list
group by itemid, item_name, category
;