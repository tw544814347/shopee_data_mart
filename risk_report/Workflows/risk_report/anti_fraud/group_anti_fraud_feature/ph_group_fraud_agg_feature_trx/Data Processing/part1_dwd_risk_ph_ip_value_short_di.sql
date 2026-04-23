--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-08-20
-- Theme Domain：       Anti-fraud 日志数据策略feature - dws 层
-- Description:         https://jira.shopee.io/browse/SPFDT-54753
-- Data Granularity:    
-- Change Log:
--********************************************************************--

DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_${reg}_ip_value_short_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_${reg}_ip_value_short_di
(
    flow_no                  STRING   COMMENT 'flow number'
   ,base_platform_user_id    STRING   COMMENT 'platform_user_id from base_data_today'
   ,base_req_time            BIGINT   COMMENT 'req_time from base_data_today'
   ,base_app_id              STRING   COMMENT 'app_id from base_data_today'
   ,base_scene_id            STRING   COMMENT 'scene_id from base_data_today'
   ,base_ip_value                 STRING   COMMENT 'ip_value from base_data_today'

   ,hist_platform_user_id    STRING   COMMENT 'platform_user_id from hist_data_15d'
   ,hist_req_time            BIGINT   COMMENT 'req_time from hist_data_15d'
   ,hist_end_result          STRING   COMMENT 'end_result from hist_data_15d'
   ,hist_is_batch_registration INT    COMMENT 'is_batch_registration from hist_data_15d'
   ,hist_is_reactivate       INT      COMMENT 'is_reactivate from hist_data_15d'

   ,time_diff_seconds        BIGINT   COMMENT '时间差（秒）= base.req_time - hist.req_time'
)
COMMENT ''
PARTITIONED BY (
   grass_date STRING
)
STORED AS parquet
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/dwd/dwd_risk_reg_ip_value_short_di/grass_region=${grass_region}';


CREATE OR REPLACE TEMP VIEW base_data_today AS (
    SELECT DISTINCT 
        flow_no, platform_user_id, req_time, app_id, scene_id, client_ip as ip_value, grass_date, szdf
    FROM risk_report.dwd_risk_${reg}_group_fraud_feature_trx_base_di 
    WHERE grass_date = '${ds}'
        AND szdf != ''
);
CREATE OR REPLACE TEMP VIEW hist_data_15d AS (
    SELECT DISTINCT 
        app_id, scene_id, ip_value, platform_user_id,
        req_time, end_result, is_batch_registration, is_reactivate
    FROM risk_report.dwd_risk_${reg}_group_fraud_ip_trx_di
    WHERE grass_date >= date('${ds}') - interval '15' day
        AND grass_date <= date('${ds}')  -- 不包含当天
        AND ((app_id IN ('kredit','spj', 'spjup') AND (is_reactivate = 0)) or 
            app_id NOT IN ('kredit', 'spj', 'spjup'))
);
CACHE TABLE hist_data_15d;


insert overwrite table risk_report.dwd_risk_${reg}_ip_value_short_di partition (grass_date = '${ds}')
SELECT /*+ BROADCAST(base) */
    base.flow_no,
    base.platform_user_id as base_platform_user_id,
    base.req_time as base_req_time,
    base.app_id as base_app_id,
    base.scene_id as base_scene_id,
    base.ip_value as base_ip_value,
    
    hist.platform_user_id as hist_platform_user_id,
    hist.req_time as hist_req_time,
    hist.end_result as hist_end_result,
    hist.is_batch_registration as hist_is_batch_registration,
    hist.is_reactivate as hist_is_reactivate,
    
    -- 预计算时间差（秒）
    base.req_time - hist.req_time as time_diff_seconds
    
FROM base_data_today base
LEFT JOIN hist_data_15d hist
    ON md5(base.ip_value) = md5(hist.ip_value)
    AND base.platform_user_id != hist.platform_user_id
    AND (if(base.app_id = 'kredit',base.app_id = hist.app_id,base.app_id = hist.app_id AND base.scene_id = hist.scene_id))
    -- AND base.app_id = hist.app_id AND base.scene_id = hist.scene_id
DISTRIBUTE BY md5(base.ip_value), md5(base.platform_user_id)
;

msck repair table risk_report.dwd_risk_${reg}_ip_value_short_di;
refresh table risk_report.dwd_risk_${reg}_ip_value_short_di;