--********************************************************************--
-- Author:              li.lill@shopee.com
-- Created Time:        2025-10-27
-- Description:         ods_risk_live_kafka_gateway_req_rsp_di_v3表的dwd缓冲层构建    
-- PRD:                 https://docs.google.com/spreadsheets/d/1MrTKjjiWKNcwMmQg8OB8mkgs3xbkdvxA0v1W8hgujkI/edit?gid=200904381#gid=200904381                  
--********************************************************************--

-- DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_${region}_live_kafka_gateway_aio_log_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_${region}_live_kafka_gateway_aio_log_di(
    -- RiskReqHeader 相关字段
    `risk_version` STRING COMMENT '<comment><description>Risk request version from RiskReqHeader</description><calculationLogic>get_json_object(value, "$.Req.RiskReqHeader.Version")</calculationLogic><enum>No enum</enum></comment>',
    `app_id` STRING COMMENT '<comment><description>Application ID from RiskReqHeader</description><calculationLogic>get_json_object(value, "$.Req.RiskReqHeader.AppID")</calculationLogic><enum>No enum</enum></comment>',
    `scene_id` STRING COMMENT '<comment><description>Scene ID from RiskReqHeader</description><calculationLogic>get_json_object(value, "$.Req.RiskReqHeader.SceneID")</calculationLogic><enum>No enum</enum></comment>',
    `flow_no` STRING COMMENT '<comment><description>Flow number from RiskReqHeader</description><calculationLogic>get_json_object(value, "$.Req.RiskReqHeader.FlowNo")</calculationLogic><enum>No enum</enum></comment>',
    `req_time` BIGINT COMMENT '<comment><description>Request timestamp from RiskReqHeader</description><calculationLogic>cast(get_json_object(value, "$.Req.RiskReqHeader.ReqTime") as bigint)</calculationLogic><enum>No enum</enum></comment>',
    `req_ip` STRING COMMENT '<comment><description>Request IP address from RiskReqHeader</description><calculationLogic>get_json_object(value, "$.Req.RiskReqHeader.ReqIp")</calculationLogic><enum>No enum</enum></comment>',
    `req_server` STRING COMMENT '<comment><description>Request server from RiskReqHeader</description><calculationLogic>get_json_object(value, "$.Req.RiskReqHeader.ReqServer")</calculationLogic><enum>No enum</enum></comment>',
    `req_memo` STRING COMMENT '<comment><description>Request memo from RiskReqHeader</description><calculationLogic>get_json_object(value, "$.Req.RiskReqHeader.ReqMemo")</calculationLogic><enum>No enum</enum></comment>',
    `req_no` STRING COMMENT '<comment><description>Request number from RiskReqHeader</description><calculationLogic>get_json_object(value, "$.Req.RiskReqHeader.ReqNo")</calculationLogic><enum>No enum</enum></comment>',
    `workflow_sceneid` STRING COMMENT '<comment><description>Workflow scene ID from RiskReqHeader</description><calculationLogic>get_json_object(value, "$.Req.RiskReqHeader.WorkflowSceneID")</calculationLogic><enum>No enum</enum></comment>',
    `req_type` STRING COMMENT '<comment><description>Request type from RiskReqHeader</description><calculationLogic>get_json_object(value, "$.Req.RiskReqHeader.ReqType")</calculationLogic><enum>No enum</enum></comment>',
    `req_async` STRING COMMENT '<comment><description>Request async flag from RiskReqHeader</description><calculationLogic>get_json_object(value, "$.Req.RiskReqHeader.ReqAsync")</calculationLogic><enum>No enum</enum></comment>',
    `workflow_flow_no` STRING COMMENT '<comment><description>Workflow flow number from RiskReqHeader</description><calculationLogic>get_json_object(value, "$.Req.RiskReqHeader.WorkflowFlowNo")</calculationLogic><enum>No enum</enum></comment>',

    -- ReqParams相关字段
    `encrypted_bank_account_no` STRING COMMENT '<comment><description>Encrypted bank account number from ReqParams</description><calculationLogic>get_json_object(value, "$.ReqParams.encrypted_bank_account_no")</calculationLogic><enum>No enum</enum></comment>',
    `encrypted_recipient_account` STRING COMMENT '<comment><description>Encrypted recipient account from ReqParams</description><calculationLogic>get_json_object(value, "$.ReqParams.encrypted_recipient_account")</calculationLogic><enum>No enum</enum></comment>',
    `email` STRING COMMENT '<comment><description>Email address from KYC info</description><calculationLogic>coalesce(get_json_object(value, "$.ReqParams.kyc_info.email"), get_json_object(value, "$.ReqParams.KYCInfo.email"))</calculationLogic><enum>No enum</enum></comment>',
    `user_name` STRING COMMENT '<comment><description>User name from KYC info</description><calculationLogic>coalesce(get_json_object(value, "$.ReqParams.KYCInfo.user_name"), get_json_object(value, "$.ReqParams.kyc_info.user_name"))</calculationLogic><enum>No enum</enum></comment>',
    `phone` STRING COMMENT '<comment><description>Phone number from KYC info</description><calculationLogic>coalesce(get_json_object(value, "$.ReqParams.kyc_info.phone"), get_json_object(value, "$.ReqParams.KYCInfo.phone"))</calculationLogic><enum>No enum</enum></comment>',
    `PhoneNo` STRING COMMENT '<comment><description>Phone number from ReqParams</description><calculationLogic>get_json_object(value, "$.ReqParams.PhoneNo")</calculationLogic><enum>No enum</enum></comment>',
    `emergency_contact_name1` STRING COMMENT '<comment><description>First emergency contact name from KYC info</description><calculationLogic>coalesce(get_json_object(value, "$.ReqParams.KYCInfo.emergency_contact_name1"), get_json_object(value, "$.ReqParams.kyc_info.emergency_contact_name1"))</calculationLogic><enum>No enum</enum></comment>',
    `emergency_contact_name2` STRING COMMENT '<comment><description>Second emergency contact name from KYC info</description><calculationLogic>coalesce(get_json_object(value, "$.ReqParams.kyc_info.emergency_contact_name2"), get_json_object(value, "$.ReqParams.KYCInfo.emergency_contact_name2"))</calculationLogic><enum>No enum</enum></comment>',
    `emergency_contact_phone1` STRING COMMENT '<comment><description>First emergency contact phone from KYC info</description><calculationLogic>coalesce(get_json_object(value, "$.ReqParams.kyc_info.emergency_contact_phone1"), get_json_object(value, "$.ReqParams.KYCInfo.emergency_contact_phone1"))</calculationLogic><enum>No enum</enum></comment>',
    `emergency_contact_phone2` STRING COMMENT '<comment><description>Second emergency contact phone from KYC info</description><calculationLogic>coalesce(get_json_object(value, "$.ReqParams.kyc_info.emergency_contact_phone2"), get_json_object(value, "$.ReqParams.KYCInfo.emergency_contact_phone2"))</calculationLogic><enum>No enum</enum></comment>',
    `user_name_by_user` STRING COMMENT '<comment><description>User name provided by user from OCR</description><calculationLogic>get_json_object(value, "$.ReqParams.user_name_by_ocr")</calculationLogic><enum>No enum</enum></comment>',
    `user_name_by_ocr` STRING COMMENT '<comment><description>User name extracted by OCR</description><calculationLogic>get_json_object(value, "$.ReqParams.id_card_no_by_ocr")</calculationLogic><enum>No enum</enum></comment>',
    `id_card_no_by_ocr` STRING COMMENT '<comment><description>ID card number extracted by OCR from KYC info</description><calculationLogic>coalesce(get_json_object(value, "$.ReqParams.KYCInfo.id_card_no_by_ocr"), get_json_object(value, "$.ReqParams.kyc_info.id_card_no_by_ocr"))</calculationLogic><enum>No enum</enum></comment>',
    `id_card_no` STRING COMMENT '<comment><description>ID card number from KYC info</description><calculationLogic>coalesce(get_json_object(value, "$.ReqParams.kyc_info.id_card_no"), get_json_object(value, "$.ReqParams.KYCInfo.id_card_no"))</calculationLogic><enum>No enum</enum></comment>',

    -- ReqParams.CommonHeader 相关字段
    `version` STRING COMMENT '<comment><description>Common header version</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.version")</calculationLogic><enum>No enum</enum></comment>',
    `seq_id` STRING COMMENT '<comment><description>Sequence ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.seq_id")</calculationLogic><enum>No enum</enum></comment>',
    `module` STRING COMMENT '<comment><description>Module name from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.module")</calculationLogic><enum>No enum</enum></comment>',
    `cmd` STRING COMMENT '<comment><description>Command from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.cmd")</calculationLogic><enum>No enum</enum></comment>',
    `client_ip` STRING COMMENT '<comment><description>Client IP address from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.client_ip")</calculationLogic><enum>No enum</enum></comment>',
    `device_type` STRING COMMENT '<comment><description>Device type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.device_type")</calculationLogic><enum>No enum</enum></comment>',
    `platform_type` STRING COMMENT '<comment><description>Platform type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.platform_type")</calculationLogic><enum>No enum</enum></comment>',
    `source_platform_type` STRING COMMENT '<comment><description>Original platform type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.original_platform_type")</calculationLogic><enum>No enum</enum></comment>',
    `traffic_platform_type` STRING COMMENT '<comment><description>traffic platform type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.traffic_platform_type")</calculationLogic><enum>No enum</enum></comment>',
    `platform_token` STRING COMMENT '<comment><description>Platform token from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.platform_token")</calculationLogic><enum>No enum</enum></comment>',
    `platform_user_id` STRING COMMENT '<comment><description>Platform user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.platform_user_id")</calculationLogic><enum>No enum</enum></comment>',
    `source_platform_user_id` STRING COMMENT '<comment><description>Original platform user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.original_platform_user_id")</calculationLogic><enum>No enum</enum></comment>',
    `traffic_platform_user_id` STRING COMMENT '<comment><description>traffic platform user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.traffic_platform_user_id")</calculationLogic><enum>No enum</enum></comment>',
    `credit_user_id` STRING COMMENT '<comment><description>Credit user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.credit_user_id")</calculationLogic><enum>No enum</enum></comment>',
    `region` STRING COMMENT '<comment><description>Region from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.region")</calculationLogic><enum>No enum</enum></comment>',
    `device_brand` STRING COMMENT '<comment><description>Device brand from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.device_brand")</calculationLogic><enum>No enum</enum></comment>',
    `device_id` STRING COMMENT '<comment><description>Device ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.device_id")</calculationLogic><enum>No enum</enum></comment>',
    `system_type` STRING COMMENT '<comment><description>System type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.system_type")</calculationLogic><enum>No enum</enum></comment>',
    `system_version` STRING COMMENT '<comment><description>System version from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.system_version")</calculationLogic><enum>No enum</enum></comment>',
    `app_version` STRING COMMENT '<comment><description>App version from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.app_version")</calculationLogic><enum>No enum</enum></comment>',
    `app_type` STRING COMMENT '<comment><description>App type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.app_type")</calculationLogic><enum>No enum</enum></comment>',
    `szdf_token` STRING COMMENT '<comment><description>SZDF token from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.szdf_token")</calculationLogic><enum>No enum</enum></comment>',
    `imei` STRING COMMENT '<comment><description>IMEI number from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.imei")</calculationLogic><enum>No enum</enum></comment>',
    `device_fingerprint` STRING COMMENT '<comment><description>Device fingerprint from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.device_fingerprint")</calculationLogic><enum>No enum</enum></comment>',
    `lang` STRING COMMENT '<comment><description>Language from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.lang")</calculationLogic><enum>No enum</enum></comment>',
    `from_source` STRING COMMENT '<comment><description>Request source from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.from")</calculationLogic><enum>No enum</enum></comment>',
    `gps_status` STRING COMMENT '<comment><description>GPS status from CommonHeader location</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.location.status")</calculationLogic><enum>No enum</enum></comment>',
    `gps_longitude` STRING COMMENT '<comment><description>GPS longitude from CommonHeader location</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.location.longitude")</calculationLogic><enum>No enum</enum></comment>',
    `gps_latitude` STRING COMMENT '<comment><description>GPS latitude from CommonHeader location</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.location.latitude")</calculationLogic><enum>No enum</enum></comment>',
    `device_model` STRING COMMENT '<comment><description>Device model from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.device_model")</calculationLogic><enum>No enum</enum></comment>',
    `network_type` STRING COMMENT '<comment><description>Network type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.network_type")</calculationLogic><enum>No enum</enum></comment>',
    `cellular_type` STRING COMMENT '<comment><description>Cellular type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.cellular_type")</calculationLogic><enum>No enum</enum></comment>',
    `event_code` STRING COMMENT '<comment><description>Event code from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.event_code")</calculationLogic><enum>No enum</enum></comment>',
    `shopeepay_user_id` STRING COMMENT '<comment><description>ShopeePay user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.shopeepay_user_id")</calculationLogic><enum>No enum</enum></comment>',
    `extension` STRING COMMENT '<comment><description>Extension parameters in JSON format from ReqParams</description><calculationLogic>get_json_object(value, "$.ReqParams")</calculationLogic><enum>No enum</enum></comment>',
    
    -- 子业务类型
    `sub_biz_type` STRING COMMENT '<comment><description>Sub business type from ReqParams</description><calculationLogic>get_json_object(value, "$.ReqParams.sub_biz_type")</calculationLogic><enum>No enum</enum></comment>',
    `biz_type` STRING COMMENT '<comment><description>Business type from ReqParams</description><calculationLogic>get_json_object(value, "$.ReqParams.biz_type")</calculationLogic><enum>No enum</enum></comment>',
    
    -- Rsp.RiskInsight 相关字段
    `handle_begin_time` BIGINT COMMENT '<comment><description>Handle begin timestamp from RiskInsight</description><calculationLogic>cast(get_json_object(value, "$.Rsp.RiskInsight.HandleBeginTime") as bigint)</calculationLogic><enum>No enum</enum></comment>',
    `handle_end_time` BIGINT COMMENT '<comment><description>Handle end timestamp from RiskInsight</description><calculationLogic>cast(get_json_object(value, "$.Rsp.RiskInsight.HandleEndTime") as bigint)</calculationLogic><enum>No enum</enum></comment>',
    `strategy_id` STRING COMMENT '<comment><description>Strategy ID from RiskInsight</description><calculationLogic>get_json_object(value, "$.Rsp.RiskInsight.StrategyId")</calculationLogic><enum>No enum</enum></comment>',
    `final_result` STRING COMMENT '<comment><description>Final check result from RiskInsight</description><calculationLogic>get_json_object(value, "$.Rsp.RiskInsight.CheckResult")</calculationLogic><enum>No enum</enum></comment>',
    `reasons` STRING COMMENT '<comment><description>Risk reasons in JSON format from RiskInsight</description><calculationLogic>get_json_object(value, "$.Rsp.RiskInsight.Reasons")</calculationLogic><enum>No enum</enum></comment>',
    `mark` STRING COMMENT '<comment><description>Risk mark from RiskInsight</description><calculationLogic>get_json_object(value, "$.Rsp.RiskInsight.Mark")</calculationLogic><enum>No enum</enum></comment>',
    `node_results` STRING COMMENT '<comment><description>Node results in JSON format from RiskInsight</description><calculationLogic>get_json_object(value, "$.Rsp.RiskInsight.NodeResult")</calculationLogic><enum>No enum</enum></comment>',
    `fm_check_info` STRING COMMENT '<comment><description>FM check information from RiskInsight</description><calculationLogic>get_json_object(value, "$.Rsp.RiskInsight.fmCheckInfo")</calculationLogic><enum>No enum</enum></comment>',
    `task_result_array` STRING COMMENT '<comment><description>Task results array in JSON format from RiskInsight</description><calculationLogic>get_json_object(value, "$.Rsp.RiskInsight.TaskResults")</calculationLogic><enum>No enum</enum></comment>',
    `workflowstatus` BIGINT COMMENT '<comment><description>Workflow status from RiskInsight</description><calculationLogic>cast(get_json_object(value, "$.Rsp.RiskInsight.WorkflowStatus") as bigint)</calculationLogic><enum>No enum</enum></comment>',
    `task_run_step` STRING COMMENT '<comment><description>Task run step from RiskInsight</description><calculationLogic>get_json_object(value, "$.Rsp.RiskInsight.TaskRunStep")</calculationLogic><enum>No enum</enum></comment>',
    `x_notes` STRING COMMENT '<comment><description>X notes from RiskInsight</description><calculationLogic>get_json_object(value, "$.Rsp.RiskInsight.X_Notes")</calculationLogic><enum>No enum</enum></comment>',

    -- RspExtension 相关字段
    `RspExtension` STRING COMMENT '<comment><description>Response extension in JSON format</description><calculationLogic>get_json_object(value, "$.RspExtension")</calculationLogic><enum>No enum</enum></comment>',
    `check_result` STRING COMMENT '<comment><description>Check result from RspExtension</description><calculationLogic>get_json_object(value, "$.RspExtension.CheckResult")</calculationLogic><enum>No enum</enum></comment>',
    `check_result_code` STRING COMMENT '<comment><description>Check result code from RspExtension</description><calculationLogic>get_json_object(value, "$.RspExtension.check_result_code")</calculationLogic><enum>No enum</enum></comment>',
    `additional_code` STRING COMMENT '<comment><description>Additional code from RspExtension</description><calculationLogic>get_json_object(value, "$.RspExtension.additional_code")</calculationLogic><enum>No enum</enum></comment>',
    `freeze_time` STRING COMMENT '<comment><description>Freeze time from RspExtension</description><calculationLogic>get_json_object(value, "$.RspExtension.freeze_time")</calculationLogic><enum>No enum</enum></comment>',

    -- step相关字段
    `current_step` STRING COMMENT '<comment><description>Current step in workflow execution</description><calculationLogic>get_workflow_info(value, "current_step")</calculationLogic><enum>No enum</enum></comment>',
    `run_step` STRING COMMENT '<comment><description>Run step path in workflow execution</description><calculationLogic>get_workflow_info(value, "run_step")</calculationLogic><enum>No enum</enum></comment>',
    `step` STRING COMMENT '<comment><description>Step information from workflow</description><calculationLogic>get_workflow_step_info(value, "step")</calculationLogic><enum>No enum</enum></comment>',
    `step_output` STRING COMMENT '<comment><description>Step output from workflow</description><calculationLogic>get_workflow_step_info(value, "step_output")</calculationLogic><enum>No enum</enum></comment>',
    
    -- 其他计算字段
    `create_time` BIGINT COMMENT '<comment><description>Record create timestamp</description><calculationLogic>cast(get_json_object(value, "$.Req.RiskReqHeader.ReqTime") as bigint)</calculationLogic><enum>No enum</enum></comment>',
    `update_time` BIGINT COMMENT '<comment><description>Record update timestamp</description><calculationLogic>cast(substr(dispatch_time, 1, 10) as bigint)</calculationLogic><enum>No enum</enum></comment>',
    `dispatch_time` BIGINT COMMENT '<comment><description>Dispatch time from source</description><calculationLogic>cast(risk.ods_risk_live_kafka_gateway_req_rsp_di_v3.dispatch_time as bigint)</calculationLogic><enum>No enum</enum></comment>',
    
    -- 低频个性化字段
    `value` STRING COMMENT '<comment><description>Original JSON value from source</description><calculationLogic>risk.ods_risk_live_kafka_gateway_req_rsp_di_v3.value</calculationLogic><enum>No enum</enum></comment>',
    `input` STRING COMMENT '<comment><description>Request input in JSON format</description><calculationLogic>get_json_object(value, "$.Req")</calculationLogic><enum>No enum</enum></comment>',
    `output` STRING COMMENT '<comment><description>Workflow output</description><calculationLogic>get_workflow_info(value, "output")</calculationLogic><enum>No enum</enum></comment>',

    -- scene_config相关字段
    `app_id_from_scene_config` STRING COMMENT '<comment><description>Application ID from scene config</description><calculationLogic>risk.dim_risk_strategy_app_scene_config_df.app_id</calculationLogic><enum>No enum</enum></comment>',
    `scene_id_from_scene_config` STRING COMMENT '<comment><description>Scene ID from scene config</description><calculationLogic>risk.dim_risk_strategy_app_scene_config_df.scene_id</calculationLogic><enum>No enum</enum></comment>',
    `scene_type_from_scene_config` STRING COMMENT '<comment><description>Scene type from scene config</description><calculationLogic>risk.dim_risk_strategy_app_scene_config_df.scene_type</calculationLogic><enum>No enum</enum></comment>',
    `product_name_from_scene_config` STRING COMMENT '<comment><description>Product name from scene config</description><calculationLogic>risk.dim_risk_strategy_app_scene_config_df.product_name</calculationLogic><enum>credit, shopeepay, invest</enum></comment>',
    `need_write_workflow_db_from_scene_config` STRING COMMENT '<comment><description>Flag indicating if workflow DB write is needed from scene config</description><calculationLogic>risk.dim_risk_strategy_app_scene_config_df.need_write_workflow_db</calculationLogic><enum>No enum</enum></comment>',
    `topic_name_from_scene_config` STRING COMMENT '<comment><description>Kafka topic name derived from scene config</description><calculationLogic>case when product_name = "credit" then concat("${region}_live_credit_risk_gateway_req_rsp_", app_id) when product_name = "shopeepay" then concat("${region}_live_spp_risk_gateway_req_rsp_", app_id) when product_name = "invest" then concat("${region}_live_invest_risk_gateway_req_rsp_", app_id) end</calculationLogic><enum>No enum</enum></comment>'
)
PARTITIONED BY (
    `product_name` STRING COMMENT '<comment><description>Business name for partitioning</description><calculationLogic>risk.dim_risk_strategy_app_scene_config_df.product_name</calculationLogic><enum>credit, shopeepay, invest</enum></comment>',
    `tn` STRING COMMENT '<comment><description>Topic name for partitioning</description><calculationLogic>risk.ods_risk_live_kafka_gateway_req_rsp_di_v3.tn</calculationLogic><enum>No enum</enum></comment>',
    `dt` STRING COMMENT '<comment><description>Process date partition in yyyy-MM-dd format</description><calculationLogic>risk.ods_risk_live_kafka_gateway_req_rsp_di_v3.dt</calculationLogic><enum>No enum</enum></comment>',
    `grass_date` STRING COMMENT '<comment><description>Data partition date in yyyy-MM-dd format</description><calculationLogic>risk.ods_risk_live_kafka_gateway_req_rsp_di_v3.grass_date</calculationLogic><enum>No enum</enum></comment>'
)
STORED AS ORC TBLPROPERTIES ("orc.compress" = "ZSTD")
LOCATION '${HDFS_PATH}/dwd/dwd_risk_reg_live_kafka_gateway_aio_log_di/grass_region=${REGION}'
COMMENT 'DWD layer table for Risk Gateway AIO log data. Stores parsed risk control request and response data from Kafka, including RiskReqHeader, ReqParams, CommonHeader, RiskInsight results, and workflow step information. Joined with scene config for product categorization.'
;


-- msck repair table ${SCHEMA}.dwd_risk_${region}_live_kafka_gateway_aio_log_di;
-- refresh table ${SCHEMA}.dwd_risk_${region}_live_kafka_gateway_aio_log_di;

ADD JAR hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-biz-udf-1.0-SNAPSHOT-20250113.jar;
create or replace temporary function get_workflow_step_info as 'com.shopee.udf.GetWorkflowInfo';

ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-workflow-20240711.jar;
create or replace temporary function get_workflow_info as 'com.shopee.seamoney.udf.GetWorkflowInfo' using jar 'hdfs://R2/projects/risk/hdfs/udf/hive-udf-workflow-20240711.jar';

insert overwrite table ${SCHEMA}.dwd_risk_${region}_live_kafka_gateway_aio_log_di partition (product_name,tn,dt,grass_date)
select 									
-- RiskReqHeader 相关字段				
    get_json_object(value, '$.Req.RiskReqHeader.Version') as risk_version,				
    get_json_object(value, '$.Req.RiskReqHeader.AppID') as app_id,				
    get_json_object(value, '$.Req.RiskReqHeader.SceneID') as scene_id,				
    get_json_object(value, '$.Req.RiskReqHeader.FlowNo') as flow_no,				
    cast(get_json_object(value, '$.Req.RiskReqHeader.ReqTime') as bigint) as req_time,				
    get_json_object(value, '$.Req.RiskReqHeader.ReqIp') as req_ip,				
    get_json_object(value, '$.Req.RiskReqHeader.ReqServer') as req_server,				
    get_json_object(value, '$.Req.RiskReqHeader.ReqMemo') as req_memo,				
    get_json_object(value, '$.Req.RiskReqHeader.ReqNo') as req_no,				
    get_json_object(value, '$.Req.RiskReqHeader.WorkflowSceneID') as workflow_sceneid,				
    get_json_object(value, '$.Req.RiskReqHeader.ReqType') as req_type,				
    get_json_object(value, '$.Req.RiskReqHeader.ReqAsync') as req_async,				
    get_json_object(value, '$.Req.RiskReqHeader.WorkflowFlowNo') as workflow_flow_no,

-- ReqParams相关字段
    get_json_object(t1.value, '$.ReqParams.encrypted_bank_account_no') as encrypted_bank_account_no,
    get_json_object(t1.value, '$.ReqParams.encrypted_recipient_account') as encrypted_recipient_account,
    coalesce(get_json_object(value, '$.ReqParams.kyc_info.email'), get_json_object(value, '$.ReqParams.KYCInfo.email')) as email,
    coalesce(get_json_object(value, '$.ReqParams.KYCInfo.user_name'), get_json_object(value, '$.ReqParams.kyc_info.user_name')) as user_name,
    coalesce(get_json_object(value, '$.ReqParams.kyc_info.phone'), get_json_object(value, '$.ReqParams.KYCInfo.phone')) as phone,
    get_json_object(value, '$.ReqParams.PhoneNo') as PhoneNo,
    coalesce(get_json_object(value, '$.ReqParams.KYCInfo.emergency_contact_name1'), get_json_object(value, '$.ReqParams.kyc_info.emergency_contact_name1')) as emergency_contact_name1,
    coalesce(get_json_object(value, '$.ReqParams.kyc_info.emergency_contact_name2'), get_json_object(value, '$.ReqParams.KYCInfo.emergency_contact_name2')) as emergency_contact_name2,
    coalesce(get_json_object(value, '$.ReqParams.kyc_info.emergency_contact_phone1'), get_json_object(value, '$.ReqParams.KYCInfo.emergency_contact_phone1')) as emergency_contact_phone1,
    coalesce(get_json_object(value, '$.ReqParams.kyc_info.emergency_contact_phone2'), get_json_object(value, '$.ReqParams.KYCInfo.emergency_contact_phone2')) as emergency_contact_phone2,
    get_json_object(value, '$.ReqParams.user_name_by_ocr') as user_name_by_user ,
    get_json_object(value, '$.ReqParams.id_card_no_by_ocr') as user_name_by_ocr ,
    coalesce(get_json_object(value, '$.ReqParams.KYCInfo.id_card_no_by_ocr'), get_json_object(value, '$.ReqParams.kyc_info.id_card_no_by_ocr')) as id_card_no_by_ocr,
    coalesce(get_json_object(value, '$.ReqParams.kyc_info.id_card_no'), get_json_object(value, '$.ReqParams.KYCInfo.id_card_no')) as id_card_no,

-- ReqParams.CommonHeader 相关字段				
    get_json_object(value, '$.ReqParams.CommonHeader.version') as version,				
    get_json_object(value, '$.ReqParams.CommonHeader.seq_id') as seq_id,				
    get_json_object(value, '$.ReqParams.CommonHeader.module') as module,				
    get_json_object(value, '$.ReqParams.CommonHeader.cmd') as cmd,				
    get_json_object(value, '$.ReqParams.CommonHeader.client_ip') as client_ip,				
    get_json_object(value, '$.ReqParams.CommonHeader.device_type') as device_type,				
    get_json_object(value, '$.ReqParams.CommonHeader.platform_type') as platform_type,
    get_json_object(value, '$.ReqParams.CommonHeader.original_platform_type') as source_platform_type,
    get_json_object(value, '$.ReqParams.CommonHeader.traffic_platform_type') as traffic_platform_type,					
    get_json_object(value, '$.ReqParams.CommonHeader.platform_token') as platform_token,				
    get_json_object(value, '$.ReqParams.CommonHeader.platform_user_id') as platform_user_id,
    get_json_object(value, '$.ReqParams.CommonHeader.original_platform_user_id') as source_platform_user_id,
    get_json_object(value, '$.ReqParams.CommonHeader.traffic_platform_user_id') as traffic_platform_user_id,					
    get_json_object(value, '$.ReqParams.CommonHeader.credit_user_id') as credit_user_id,				
    get_json_object(value, '$.ReqParams.CommonHeader.region') as region,				
    get_json_object(value, '$.ReqParams.CommonHeader.device_brand') as device_brand,				
    get_json_object(value, '$.ReqParams.CommonHeader.device_id') as device_id,				
    get_json_object(value, '$.ReqParams.CommonHeader.system_type') as system_type,				
    get_json_object(value, '$.ReqParams.CommonHeader.system_version') as system_version,				
    get_json_object(value, '$.ReqParams.CommonHeader.app_version') as app_version,
    get_json_object(value, '$.ReqParams.CommonHeader.app_type') as app_type,
    get_json_object(value, '$.ReqParams.CommonHeader.szdf_token') as szdf_token,				
    get_json_object(value, '$.ReqParams.CommonHeader.imei') as imei,				
    get_json_object(value, '$.ReqParams.CommonHeader.device_fingerprint') as device_fingerprint,				
    get_json_object(value, '$.ReqParams.CommonHeader.lang') as lang,				
    get_json_object(value, '$.ReqParams.CommonHeader.from') as from_source,				
    get_json_object(value, '$.ReqParams.CommonHeader.location.status') as gps_status,				
    get_json_object(value, '$.ReqParams.CommonHeader.location.longitude') as gps_longitude,				
    get_json_object(value, '$.ReqParams.CommonHeader.location.latitude') as gps_latitude,				
    get_json_object(value, '$.ReqParams.CommonHeader.device_model') as device_model,				
    get_json_object(value, '$.ReqParams.CommonHeader.network_type') as network_type,				
    get_json_object(value, '$.ReqParams.CommonHeader.cellular_type') as cellular_type,				
    get_json_object(value, '$.ReqParams.CommonHeader.event_code') as event_code,				
    get_json_object(value, '$.ReqParams.CommonHeader.shopeepay_user_id') as shopeepay_user_id,				
    get_json_object(value, '$.ReqParams') as extension,	

    -- 子业务类型				
    get_json_object(value, '$.ReqParams.sub_biz_type') as sub_biz_type,				
    get_json_object(value, '$.ReqParams.biz_type') as biz_type,				
                    
    -- Rsp.RiskInsight 相关字段				
    cast(get_json_object(value, '$.Rsp.RiskInsight.HandleBeginTime') as bigint) as handle_begin_time,				
    cast(get_json_object(value, '$.Rsp.RiskInsight.HandleEndTime') as bigint) as handle_end_time,				
    get_json_object(value, '$.Rsp.RiskInsight.StrategyId') as strategy_id,				
    get_json_object(value, '$.Rsp.RiskInsight.CheckResult') as final_result,				
    get_json_object(value, '$.Rsp.RiskInsight.Reasons') as reasons,				
    get_json_object(value, '$.Rsp.RiskInsight.Mark') as mark,				
    get_json_object(value, '$.Rsp.RiskInsight.NodeResult') as node_results,				
    get_json_object(value, '$.Rsp.RiskInsight.fmCheckInfo') as fm_check_info,				
    get_json_object(value, '$.Rsp.RiskInsight.TaskResults') as task_result_array,
    cast(get_json_object(t1.value,'$.Rsp.RiskInsight.WorkflowStatus')as bigint) as workflowstatus,	
    get_json_object(t1.value, '$.Rsp.RiskInsight.TaskRunStep') as task_run_step,
    get_json_object(t1.value, '$.Rsp.RiskInsight.X_Notes') as x_notes,


    -- RspExtension 相关字段
    get_json_object(t1.value, '$.RspExtension') as RspExtension,	
    get_json_object(t1.value, '$.RspExtension.CheckResult')  as check_result,
    get_json_object(t1.value, '$.RspExtension.check_result_code') as check_result_code, 
    get_json_object(t1.value, '$.RspExtension.additional_code') as additional_code ,
    get_json_object(t1.value, '$.RspExtension.freeze_time') as  freeze_time,

    -- step相关字段
    get_workflow_info(t1.value,"current_step") as current_step,
    get_workflow_info(t1.value,"run_step") as run_step,
    get_workflow_step_info(t1.value,"step") as step,
    get_workflow_step_info(t1.value,'step_output') as  step_output, 
    -- null as current_step,
    -- null as run_step,
    -- null as step,
    -- null as step_output, 

    -- 其他计算字段				
    cast(get_json_object(value, '$.Req.RiskReqHeader.ReqTime') as bigint) as create_time,
    cast(substr(dispatch_time,1,10) as bigint)  as update_time,		
    cast(t1.dispatch_time as bigint) as dispatch_time,	

    -- 低频个性化字段
    t1.value,
    get_json_object(t1.value,'$.Req') as input,
    get_workflow_info(t1.value,"output") as output,
    -- null as output,

    --scene_config相关字段
    t2.app_id as app_id_from_scene_config,
    t2.scene_id as scene_id_from_scene_config,
    t2.scene_type as scene_type_from_scene_config,
    t2.product_name as product_name_from_scene_config,
    t2.need_write_workflow_db as need_write_workflow_db_from_scene_config,
    t2.topic_name as topic_name_from_scene_config,
    --分区字段
    t2.product_name,
    t1.tn,	
    t1.dt,			
    t1.grass_date				
    FROM risk.ods_risk_live_kafka_gateway_req_rsp_di_v3 t1
    inner join
    (
        select
            app_id,
            scene_id,
            scene_type,
            product_name,
            need_write_workflow_db,
            case
                when product_name = 'credit' then concat('${region}_live_credit_risk_gateway_req_rsp_', app_id)
                when product_name = 'shopeepay' then concat('${region}_live_spp_risk_gateway_req_rsp_', app_id)
                when product_name = 'invest' then concat('${region}_live_invest_risk_gateway_req_rsp_', app_id)
            end as topic_name
            from risk.dim_risk_strategy_app_scene_config_df
            where grass_region = upper('${region}')
            and grass_date = '${grass_date}'
            and product_name = '${biz_name}'
            group by 1, 2,3,4,5,6
    ) t2 on concat(t1.app_id,'-',t1.scene_id) = concat(t2.app_id,'-',t2.scene_id)		
    WHERE (t1.dt ='${ds}' or t1.dt = '${ods_date_t0}')				
    AND t1.grass_region = '${REGION}'				
    AND get_json_object(value, '$.Req.RiskReqHeader.AppID') is not null;	
				