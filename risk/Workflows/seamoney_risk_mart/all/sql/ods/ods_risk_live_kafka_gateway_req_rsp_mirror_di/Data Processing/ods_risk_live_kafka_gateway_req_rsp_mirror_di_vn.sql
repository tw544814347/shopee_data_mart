--********************************************************************--
-- Author:             li.lill@shopee.com
-- Created Time:       2026-03-20
-- Description:        [TH/VN/BR]新增mirror的af数据
-- PRD:                https://jira.shopee.io/browse/SPFDT-61697
--********************************************************************--
-- drop table if exists risk.ods_risk_live_kafka_gateway_req_rsp_mirror_di;
create table if  not EXISTS risk.ods_risk_live_kafka_gateway_req_rsp_mirror_di(
  value            string comment 'msg body'
  ,biz_type        string comment '1=antifraud,2=underwriting'
  ,flow_no         string comment 'af flow_no' 
  ,app_id          string comment 'app_id- kredit' 
  ,req_time        string comment 'req_time' 
  ,scene_id        string comment 'scene_id'
  ,dispatch_time   string comment 'DispatchTime'
  ,grass_region    string comment 'region'
  ,tn              string comment 'topic name'
  ,grass_date      string comment 'req_date -- local' 
  ,dt              string comment 'kafka ingest date'
)partitioned by(grass_region,tn,grass_date,dt)
stored as parquet tblproperties ("orc.compress"="ZSTD")
location '${HDFS_PATH}/risk_kafka/ods/ods_risk_live_kafka_gateway_req_rsp_mirror_di';

-- msck repair table risk.ods_risk_live_kafka_gateway_req_rsp_mirror_di;


DROP TEMPORARY FUNCTION IF EXISTS get_msg_info;
create TEMPORARY function get_msg_info as 'com.shopee.udf.GetTopicInfoUDF' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-biz-udf-get-topic-msg-no-output-SNAPSHOT.jar';

insert overwrite table risk.ods_risk_live_kafka_gateway_req_rsp_mirror_di partition(grass_region='${region_upper}',tn,grass_date,dt)
select 
 get_json_object(get_msg_info(base64(value)),'$.body')                                                            as value 
,get_json_object(get_msg_info(base64(value)),'$.BizType')                                                         as biz_type   
,get_json_object(get_json_object(get_msg_info(base64(value)),'$.body') ,'$.Req.RiskReqHeader.FlowNo')             as flow_no   
,get_json_object(get_msg_info(base64(value)),'$.AppId')                                                           as app_id   
,get_json_object(get_json_object(get_msg_info(base64(value)),'$.body') ,'$.Req.RiskReqHeader.ReqTime')            as req_time   
,get_json_object(get_msg_info(base64(value)),'$.SceneId')                                                         as scene_id  
,get_json_object(get_msg_info(base64(value)),'$.DispatchTime')                                                    as dispatch_time
,case when get_json_object(get_msg_info(base64(value)),'$.BizType') ='1' 
      then lower(substr(get_json_object(get_msg_info(base64(value)),'$.OriginTopicName'),1,length(get_json_object(get_msg_info(base64(value)),'$.OriginTopicName'))-(length(get_json_object(get_msg_info(base64(value)),'$.SceneId'))+1)))
      else lower(get_json_object(get_msg_info(base64(value)),'$.OriginTopicName')) end                            as tn 
,to_date(from_unixtime(nvl(get_json_object(get_json_object(get_msg_info(base64(value)),'$.body') ,'$.Req.RiskReqHeader.ReqTime'),0) - ${time_zone}*3600)) as grass_date
,dt
from risk.mirror_risk_gateway_req_rsp_${region}_live__reg_continuous_s0_live
where dt >=date_sub('${grass_date}',0)
and dt <=date_add('${grass_date}',1)


