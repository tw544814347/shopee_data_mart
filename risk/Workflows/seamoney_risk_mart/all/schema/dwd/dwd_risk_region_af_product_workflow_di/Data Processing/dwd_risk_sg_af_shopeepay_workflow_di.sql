DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_${region_lower}_af_${product}_workflow_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_${region_lower}_af_${product}_workflow_di
(
        id                     string COMMENT '<comment><description>Primary key identifier, same as flow_no</description><calculationLogic>id from dwd_risk_${region_lower}_af_kafka_workflow_di</calculationLogic><enum>No enum</enum></comment>',
        app_id                 string COMMENT '<comment><description>App identifier</description><calculationLogic>app_id from dwd_risk_${region_lower}_af_kafka_workflow_di</calculationLogic><enum>No enum</enum></comment>',
        scene_id               bigint COMMENT '<comment><description>Scene identifier</description><calculationLogic>scene_id from dwd_risk_${region_lower}_af_kafka_workflow_di</calculationLogic><enum>No enum</enum></comment>',
        platform_user_id       string COMMENT '<comment><description>Platform user identifier</description><calculationLogic>platform_user_id from dwd_risk_${region_lower}_af_kafka_workflow_di</calculationLogic><enum>No enum</enum></comment>',
        flow_no                string COMMENT '<comment><description>Workflow flow number, used for deduplication</description><calculationLogic>flow_no from dwd_risk_${region_lower}_af_kafka_workflow_di</calculationLogic><enum>No enum</enum></comment>',
        seq_id                 string COMMENT '<comment><description>Sequence identifier</description><calculationLogic>seq_id from dwd_risk_${region_lower}_af_kafka_workflow_di</calculationLogic><enum>No enum</enum></comment>',
        current_step           string COMMENT '<comment><description>Current workflow step</description><calculationLogic>current_step from dwd_risk_${region_lower}_af_kafka_workflow_di</calculationLogic><enum>No enum</enum></comment>',
        run_step               string COMMENT '<comment><description>Workflow run step path</description><calculationLogic>run_step from dwd_risk_${region_lower}_af_kafka_workflow_di</calculationLogic><enum>No enum</enum></comment>',
        status                 bigint COMMENT '<comment><description>Workflow status code</description><calculationLogic>status from dwd_risk_${region_lower}_af_kafka_workflow_di</calculationLogic><enum>No enum</enum></comment>',
        input                  string COMMENT '<comment><description>Request JSON input</description><calculationLogic>input from dwd_risk_${region_lower}_af_kafka_workflow_di</calculationLogic><enum>No enum</enum></comment>',
        output                 string COMMENT '<comment><description>Workflow output result</description><calculationLogic>output from dwd_risk_${region_lower}_af_kafka_workflow_di</calculationLogic><enum>No enum</enum></comment>',
        version                bigint COMMENT '<comment><description>Version field</description><calculationLogic>version from dwd_risk_${region_lower}_af_kafka_workflow_di</calculationLogic><enum>No enum</enum></comment>',
        create_time            string COMMENT '<comment><description>Creation timestamp converted to local timezone</description><calculationLogic>format_time(create_time, region_upper)</calculationLogic><enum>No enum</enum></comment>',
        update_time            string COMMENT '<comment><description>Update timestamp converted to local timezone</description><calculationLogic>format_time(update_time, region_upper)</calculationLogic><enum>No enum</enum></comment>',
        req_no                 string COMMENT '<comment><description>Request number</description><calculationLogic>req_no from dwd_risk_${region_lower}_af_kafka_workflow_di</calculationLogic><enum>No enum</enum></comment>',
        req_md5                string COMMENT '<comment><description>MD5 hash of appId, sceneId, and platformUserId</description><calculationLogic>req_md5 from dwd_risk_${region_lower}_af_kafka_workflow_di</calculationLogic><enum>No enum</enum></comment>',
        cluster_id             bigint COMMENT '<comment><description>Cluster identifier</description><calculationLogic>cluster_id from dwd_risk_${region_lower}_af_kafka_workflow_di</calculationLogic><enum>1-K8S, 2-PHYSICAL_MACHINE</enum></comment>',
        async_flag             bigint COMMENT '<comment><description>Async processing flag</description><calculationLogic>async_flag from dwd_risk_${region_lower}_af_kafka_workflow_di</calculationLogic><enum>No enum</enum></comment>',
        source_platform_type STRING COMMENT '<comment><description>Original platform type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.original_platform_type")</calculationLogic><enum>No enum</enum></comment>',
        source_platform_user_id STRING COMMENT '<comment><description>Original platform user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.original_platform_user_id")</calculationLogic><enum>No enum</enum></comment>',
        traffic_platform_type STRING COMMENT '<comment><description>Traffic platform type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.traffic_platform_type")</calculationLogic><enum>No enum</enum></comment>',
        traffic_platform_user_id STRING COMMENT '<comment><description>Traffic platform user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.traffic_platform_user_id")</calculationLogic><enum>No enum</enum></comment>',
        shopeepay_user_id STRING COMMENT '<comment><description>ShopeePay user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.shopeepay_user_id")</calculationLogic><enum>No enum</enum></comment>',
        platform_type STRING COMMENT '<comment><description>Platform type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.platform_type")</calculationLogic><enum>No enum</enum></comment>'   
)
PARTITIONED BY
(
    grass_date string COMMENT '<comment><description>Biz Local Date based on create_time</description><calculationLogic>date(format_time(create_time, region_upper))</calculationLogic><enum>No enum</enum></comment>'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_${region_lower}_af_${product}_workflow_di/grass_region=${region_upper}'
COMMENT 'Data warehouse detail table for credit workflow information, deduplicated by flow_no keeping the latest record.'
;
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_${region_lower}_af_${product}_workflow_di;