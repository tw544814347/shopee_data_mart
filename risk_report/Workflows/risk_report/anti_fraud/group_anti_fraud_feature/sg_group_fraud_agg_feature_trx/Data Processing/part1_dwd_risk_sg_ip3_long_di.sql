--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-08-20
-- Theme Domain：       Anti-fraud 日志数据策略feature - dws 层
-- Description:         https://jira.shopee.io/browse/SPFDT-54753
-- Data Granularity:    
-- Change Log: 
--********************************************************************--
drop table if exists ${SCHEMA}.dwd_risk_${reg}_ip3_long_di;
create external table if not exists ${SCHEMA}.dwd_risk_${reg}_ip3_long_di
(
    flow_no                    string  comment 'flow number'
   ,platform_user_id           string  comment 'platform user id'
   ,req_time                   bigint  comment 'request timestamp'
   ,app_id                     string  comment 'application id'
   ,scene_id                   string  comment 'scene id'
   ,ip3                        string  comment 'ip address'
   ,szdf                       string  comment 'szdf field'
   ,hist_all_platform_user_id  string  comment 'historical all platform user id'
   ,today_platform_user_id     string  comment 'today platform user id'
   ,hist_all_grass_date        string  comment 'historical all grass date'
   ,today_req_time             bigint  comment 'today request time'
   ,hist_end_result            string  comment 'historical end result'
   ,hist_is_batch_registration int     comment 'historical batch registration flag'
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
location '${HDFS_PATH}/dwd/dwd_risk_reg_ip3_long_di/grass_region=${grass_region}';

CREATE OR REPLACE TEMP VIEW 
ip3_hist_all_middle_day_agg_part as (
    SELECT DISTINCT 
        app_id, scene_id, ip3, platform_user_id,
        end_result, is_batch_registration, is_reactivate
        -- grass_date  -- 保留日期用于后续筛选
    FROM risk_report.dwd_risk_${reg}_group_fraud_ip_trx_di
    WHERE grass_date BETWEEN date('${ds}') - interval '29' day AND date('${ds}') - interval '1' day
        and ((app_id in ('kredit','spj','spjup') and is_reactivate = 0) or app_id not in ('kredit','spj','spjup'))
);

CACHE TABLE ip3_hist_all_middle_day_agg_part;   -- 把查询结果缓存到内存/磁盘
CREATE OR REPLACE TEMP VIEW 
ip3_hist_all_edge_day_agg_part as (
    SELECT DISTINCT 
        app_id, scene_id, ip3, platform_user_id,
        req_time, end_result, is_batch_registration, is_reactivate
    FROM risk_report.dwd_risk_${reg}_group_fraud_ip_trx_di
    WHERE grass_date in (date('${ds}'),date('${ds}') - interval '30' day)
        and ((app_id in ('kredit','spj','spjup') and is_reactivate = 0) or app_id not in ('kredit','spj','spjup'))
);


insert overwrite table risk_report.dwd_risk_${reg}_ip3_long_di partition (grass_date = '${ds}')
select /*+ BROADCAST(base) */
    base.flow_no,base.platform_user_id,base.req_time,base.app_id,base.scene_id,base.ip3,base.szdf
        ,hist_all.platform_user_id as hist_all_platform_user_id, null as today_platform_user_id,
        '1970-12-31' as hist_all_grass_date, null as today_req_time, hist_all.end_result as hist_end_result, hist_all.is_batch_registration as hist_is_batch_registration--, hist_all.is_reactivate
from 
(
    select distinct flow_no,platform_user_id,req_time, app_id, scene_id,ip3,grass_date,szdf
    from risk_report.dwd_risk_${reg}_group_fraud_feature_trx_base_di base
    where base.grass_date = '${ds}' 
) base
LEFT JOIN ip3_hist_all_middle_day_agg_part hist_all
    ON md5(base.ip3) = md5(hist_all.ip3)
    AND if(base.app_id = 'kredit', base.app_id = hist_all.app_id, base.app_id = hist_all.app_id AND base.scene_id = hist_all.scene_id)
    -- AND base.app_id = hist_all.app_id AND base.scene_id = hist_all.scene_id 
    AND base.szdf != ''
    AND base.platform_user_id != hist_all.platform_user_id
UNION ALL 
select /*+ BROADCAST(base) */
    base.flow_no,base.platform_user_id,base.req_time,base.app_id,base.scene_id,base.ip3,base.szdf
        ,null as hist_all_platform_user_id, today.platform_user_id as today_platform_user_id,
        null as hist_all_grass_date, today.req_time as today_req_time, today.end_result as hist_end_result, today.is_batch_registration as hist_is_batch_registration--, today.is_reactivate
from
(
    select distinct flow_no,platform_user_id,req_time, app_id, scene_id,ip3,grass_date,szdf
    from risk_report.dwd_risk_${reg}_group_fraud_feature_trx_base_di base
    where base.grass_date = '${ds}'
) base
LEFT JOIN ip3_hist_all_edge_day_agg_part today
    ON md5(base.ip3) = md5(today.ip3)
    AND if(base.app_id = 'kredit', base.app_id = today.app_id, base.app_id = today.app_id AND base.scene_id = today.scene_id) 
    -- AND base.app_id = today.app_id AND base.scene_id = today.scene_id  
    AND base.szdf != ''
    AND base.platform_user_id != today.platform_user_id
DISTRIBUTE BY md5(platform_user_id)
;

msck repair table risk_report.dwd_risk_${reg}_ip3_long_di;
refresh table risk_report.dwd_risk_${reg}_ip3_long_di;