use risk;
--********************************************************************--
-- Author:              dongbo.yu@shopee.com
-- Created Time:        2025-09-12T14:00:00
-- Description:         
--                      app_id+scene_id
-- Data Granularity:    grass_date+grass_region
-- PRD                  https://docs.google.com/spreadsheets/d/15_k8buzAcFh4YlYbsuXi3JvoPH70Xx791oEiRvUYWJs/edit?gid=356353349#gid=356353349
-- Jira                 
-- 
--********************************************************************--
-- drop table if exists ${SCHEMA}.`dwd_risk_${region}_strategy_wf_extend_info_di`;

create table if not exists ${SCHEMA}.`dwd_risk_${region}_strategy_wf_extend_info_di` (
  app_id               STRING  COMMENT 'app_id, such as kyc/voi/fm',
   scene_id             BIGINT COMMENT 'scene_id, such as 10012/10013/40003',
   flow_no              STRING COMMENT 'flow_no',
   req_time             BIGINT COMMENT 'request send time',
   handle_begin_time    BIGINT COMMENT 'handle_begin_time',
   handle_end_time      BIGINT COMMENT 'handle_end_time',
   fm_check_info        STRING COMMENT 'Rsp.RiskInsight.fmCheckInfo',
   process_date         STRING COMMENT 'data process date',
   rn                   BIGINT COMMENT 'row_number group by app_id,scene_id order by req_time desc,handle_end_time desc'
) partitioned by (
    grass_date string comment 'Date of refreshed data'
) stored as orc tblproperties (
    "orc.compress" = "ZSTD"
) location '${HDFS_PATH}/dwd/dwd_risk_reg_strategy_wf_extend_info_di/grass_region=${REGION}'
;

-- msck repair table ${SCHEMA}.dwd_risk_${region}_strategy_wf_extend_info_di;
refresh table ${SCHEMA}.dwd_risk_${region}_strategy_wf_extend_info_di;

ADD JAR hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

insert overwrite table ${SCHEMA}.dwd_risk_${region}_strategy_wf_extend_info_di  partition(grass_date='${grass_date}')
select 
    app_id,scene_id,flow_no,req_time,handle_begin_time,handle_end_time,fm_check_info,process_date,rn
from (
select 
    app_id,scene_id,flow_no,req_time,handle_begin_time,handle_end_time,fm_check_info,process_date
    --  按 app_id,scene_id 排序去重 
    ,row_number() over (partition by app_id,scene_id order by req_time desc,handle_end_time desc) as rn
from (
select 
    get_json_object(value, '$.Req.RiskReqHeader.AppID')                                     as app_id
    ,cast(get_json_object(value, '$.Req.RiskReqHeader.SceneID') as bigint)                   as scene_id
    ,get_json_object(value, '$.Req.RiskReqHeader.FlowNo')                                    as flow_no
    ,cast(get_json_object(value, '$.Req.RiskReqHeader.ReqTime') as bigint)                   as req_time
    ,cast(get_json_object(value, '$.Rsp.RiskInsight.HandleBeginTime') as bigint)             as handle_begin_time
    ,cast(get_json_object(value, '$.Rsp.RiskInsight.HandleEndTime') as bigint)               as handle_end_time
    ,get_json_object(value, '$.Rsp.RiskInsight.fmCheckInfo')                                 as fm_check_info
    ,dt                                                                                      as process_date
from    risk.ods_risk_live_kafka_gateway_req_rsp_di_v3 t1
where  t1.dt >= cast(date_sub('${grass_date}', 1) as string)
  and  t1.dt <= cast(date_add('${grass_date}', 1) as string)
  and  t1.grass_region = '${REGION}'
  and  get_json_object(t1.value, '$.Req.RiskReqHeader.AppID') is not null
  and  length(trim(get_json_object(t1.value, '$.ReqParams.CommonHeader.platform_user_id'))) between 1 and   14
  and to_date(format_time(cast(get_json_object(value, '$.Req.RiskReqHeader.ReqTime') as bigint),upper('${region}'))) ='${grass_date}'
  ) t2 
  --   筛选需要的app_id 和  scene_id
  where t2.app_id in('kyc','voi','fm') and t2.scene_id in (10012,40003)
) t3 
-- where t3.rn = 1 
;
