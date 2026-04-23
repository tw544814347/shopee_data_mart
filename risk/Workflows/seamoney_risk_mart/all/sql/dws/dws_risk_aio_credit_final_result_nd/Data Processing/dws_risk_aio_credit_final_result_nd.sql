--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-10-14
-- Theme Domain：       反欺诈日志dws(aio 表 dws_risk_aio_credit_final_result_nd)
-- Description:         credit live 反欺诈日志数据dws jira: https://jira.shopee.io/browse/SPFDT-44546
--                      https://docs.google.com/spreadsheets/d/1xeEqGpGDLVDy6ss1ZtIs_frUhoiJYo-aBiFKLXATDW8/edit?pli=1&gid=89359632#gid=89359632
-- Data Granularity:    req_no+app_id+scene_id+flow_no
-- ID 取190天，其他region 取370天
-- 变更历史：
--********************************************************************--

drop table if exists risk.dws_risk_aio_credit_final_result_nd;
CREATE TABLE risk.dws_risk_aio_credit_final_result_nd  (
app_id                 string comment 'app_id'
,scene_id               string comment 'scene_id'
,product_code           string comment 'product_code'
,flow_no                string comment 'flow_no'
,req_time               string comment 'req_time'
,req_no                 string comment 'req_no'
,seq_id                 string comment 'seq_id'
,platform_type          string comment 'platform_type'
,platform_user_id       string comment 'platform_user_id'
,credit_user_id         string comment 'credit_user_id'
,handle_begin_time      string comment 'handle_begin_time  YYYY-MM-dd HH:mm:ss'
,handle_end_time        string comment 'handle_end_time  YYYY-MM-dd HH:mm:ss'
,final_result           string comment 'final_result'
,workflow_flow_no       string comment 'workflow_flow_no'
,app_type               string comment 'app_type'
,check_result           string comment 'check_result'
,check_result_code      string comment 'check_result_code'
,task_run_step          string comment 'task_run_step'
,last_task_run_step     string comment 'last_task_run_step'
,req_time_local         string comment 'local req_time YYYY-MM-dd HH:mm:ss'
,scene_type_1           string comment 'scene_type_1'
,is_workflow            string comment 'is_workflow'
)
PARTITIONED BY ( 
    grass_region string comment 'grass_region'
    ,grass_date string comment 'grass_date')
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_kafka/dws/dws_risk_aio_credit_final_result_nd'
;

msck repair table risk.dws_risk_aio_credit_final_result_nd;
