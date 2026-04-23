-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-08-21
-- Theme Domain:        Anti-Fraud
-- Data Granularity:    store_id
-- Description:         业务侧透传表，落切片+DQC
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-08-21 - chengguo.liu - 初始化
-- =============================================================================

--drop table if exists ${SCHEMA}.dwd_risk_id_merchant_store_info_df;
create external table if not exists ${SCHEMA}.dwd_risk_id_merchant_store_info_df (
    store_id string
    ,gps_latitude double
    ,gps_longitude double
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_feature/dwd/dwd_risk_id_merchant_store_info_df'
;
--msck repair table ${SCHEMA}.dwd_risk_id_merchant_store_info_df;

insert overwrite table ${SCHEMA}.dwd_risk_id_merchant_store_info_df partition(grass_date = '${grass_date}')
select
    id as store_id
    ,latitude as gps_latitude
    ,longitude as gps_longitude
from merchantservice.mss_merchant_info_id_db__store_tab__reg_daily_s0_live
;