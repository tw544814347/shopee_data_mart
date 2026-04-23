drop table if exists risk.dwd_risk_${region}_af_kafka_workflow_step_di_v2;

create external table if not exists risk.dwd_risk_${region}_af_kafka_workflow_step_di_v2
(
        id                     bigint COMMENT '<comment><description>Primary key identifier, fixed value 0</description><calculationLogic>0</calculationLogic><enum>No enum</enum></comment>',
        wfid                   string COMMENT '<comment><description>Workflow identifier, same as flow_no</description><calculationLogic>flow_no</calculationLogic><enum>No enum</enum></comment>',
        flow_no                string COMMENT '<comment><description>Workflow flow number from RiskReqHeader</description><calculationLogic>get_json_object(value,\'$.Req.RiskReqHeader.FlowNo\')</calculationLogic><enum>No enum</enum></comment>',
        platform_user_id       string COMMENT '<comment><description>Platform user identifier from CommonHeader</description><calculationLogic>get_json_object(value,\'$.ReqParams.CommonHeader.platform_user_id\')</calculationLogic><enum>No enum</enum></comment>',
        step                   string COMMENT '<comment><description>Current workflow step extracted from step_json</description><calculationLogic>get_json_object(step_json,\'$.CurrentStep\')</calculationLogic><enum>No enum</enum></comment>',
        status                 bigint COMMENT '<comment><description>Step status code extracted from step_json</description><calculationLogic>cast(get_json_object(step_json,\'$.Status\') as bigint)</calculationLogic><enum>No enum</enum></comment>',
        input                  string COMMENT '<comment><description>Input field, currently not used</description><calculationLogic>null</calculationLogic><enum>No enum</enum></comment>',
        output                 string COMMENT '<comment><description>Step JSON output from workflow</description><calculationLogic>step_json from lateral view explode(json_to_array(get_workflow_info(value,\'step_output\')))</calculationLogic><enum>No enum</enum></comment>',
        next                   string COMMENT '<comment><description>Next workflow step, returns END if NextStep is empty and task_run_step contains END</description><calculationLogic>case when NextStep = \'\' and task_run_step like \'%END%\' then \'END\' else NextStep end</calculationLogic><enum>No enum</enum></comment>',
        version                bigint COMMENT '<comment><description>Version field, currently not used</description><calculationLogic>null</calculationLogic><enum>No enum</enum></comment>',
        create_time            bigint COMMENT '<comment><description>Request timestamp from RiskReqHeader</description><calculationLogic>cast(get_json_object(value,\'$.Req.RiskReqHeader.ReqTime\') as bigint)</calculationLogic><enum>No enum</enum></comment>',
        update_time            bigint COMMENT '<comment><description>Update timestamp with fallback to create_time</description><calculationLogic>case when update_time &lt; create_time or update_time is null then create_time else update_time end</calculationLogic><enum>No enum</enum></comment>',
        req_type               string COMMENT '<comment><description>Request type field, currently not used</description><calculationLogic>null</calculationLogic><enum>No enum</enum></comment>',
        source_platform_type STRING COMMENT '<comment><description>Original platform type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.original_platform_type")</calculationLogic><enum>No enum</enum></comment>',
        source_platform_user_id STRING COMMENT '<comment><description>Original platform user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.original_platform_user_id")</calculationLogic><enum>No enum</enum></comment>',
        traffic_platform_type STRING COMMENT '<comment><description>Traffic platform type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.traffic_platform_type")</calculationLogic><enum>No enum</enum></comment>',
        traffic_platform_user_id STRING COMMENT '<comment><description>Traffic platform user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.traffic_platform_user_id")</calculationLogic><enum>No enum</enum></comment>',
        shopeepay_user_id STRING COMMENT '<comment><description>ShopeePay user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.shopeepay_user_id")</calculationLogic><enum>No enum</enum></comment>',
        platform_type STRING COMMENT '<comment><description>Platform type identifier</description><calculationLogic>cast(platform_type as STRING) from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>1-Shopee, 5-ShopeePay</enum></comment>'
    )
partitioned by(
    product_name string COMMENT '<comment><description>Product name identifier</description><calculationLogic>product_name from dim_risk_strategy_app_scene_config_df</calculationLogic><enum>credit, shopeepay, invest</enum></comment>',
    grass_date string COMMENT '<comment><description>Biz Local Date based on create_time</description><calculationLogic>grass_date</calculationLogic><enum>No enum</enum></comment>',
    process_date string COMMENT '<comment><description>Data processing date to handle late arriving data</description><calculationLogic>ds</calculationLogic><enum>No enum</enum></comment>'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_aio_af_kafka_workflow_step_di_v2/grass_region=${upper_region}'
COMMENT 'Data warehouse detail table for workflow step information, exploded from workflow output.'
;

MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_${region}_af_kafka_workflow_step_di_v2;