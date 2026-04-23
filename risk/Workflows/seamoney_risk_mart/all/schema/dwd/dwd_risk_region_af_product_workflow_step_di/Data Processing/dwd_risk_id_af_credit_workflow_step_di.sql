DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_${region_lower}_af_${product}_workflow_step_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_${region_lower}_af_${product}_workflow_step_di
(
id                       bigint                comment ''
,wfid                    string               comment ''
,platform_user_id        string               comment ''
,step                    string               comment ''
,status                  bigint               comment ''
,input                   string               comment ''
,output                  string               comment ''
,next                    string               comment ''
,version                 bigint               comment ''
,create_time             string               comment ''
,update_time             string               comment ''
,source_platform_type STRING COMMENT '<comment><description>Original platform type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.original_platform_type")</calculationLogic><enum>No enum</enum></comment>'
,source_platform_user_id STRING COMMENT '<comment><description>Original platform user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.original_platform_user_id")</calculationLogic><enum>No enum</enum></comment>'
,traffic_platform_type STRING COMMENT '<comment><description>Traffic platform type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.traffic_platform_type")</calculationLogic><enum>No enum</enum></comment>'
,traffic_platform_user_id STRING COMMENT '<comment><description>Traffic platform user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.traffic_platform_user_id")</calculationLogic><enum>No enum</enum></comment>'
,shopeepay_user_id STRING COMMENT '<comment><description>ShopeePay user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.shopeepay_user_id")</calculationLogic><enum>No enum</enum></comment>'   
,platform_type     STRING COMMENT '<comment><description>Original platform type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.platform_type")</calculationLogic><enum>No enum</enum></comment>'
)
PARTITIONED BY
(
  grass_date string comment 'create_time,YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_${region_lower}_af_${product}_workflow_step_di/grass_region=${region_upper}';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_${region_lower}_af_${product}_workflow_step_di;