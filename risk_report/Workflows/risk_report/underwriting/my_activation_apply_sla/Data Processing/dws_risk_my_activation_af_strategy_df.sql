-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-09-01
-- Theme Domain:        Activation AF Strategy
-- Data Granularity:    apply_no
-- Description:         Activation AF Strategy Summary Table
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-09-01 - chengguo.liu - 初始化
-- =============================================================================

add jar hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

--drop table if exists risk_report.dws_risk_${region}_activation_af_strategy_df;
create external table if not exists risk_report.dws_risk_${region}_activation_af_strategy_df
(
    flow_trace_id string comment '流程追踪ID，用于关联申请流程',
    workflow_flow_no string comment 'AF工作流流水号',
    flow_no string comment 'AF策略流水号',
    shopeepay_user_id string comment 'ShopeePay用户ID',
    biz_id string comment '业务ID，格式: shopeepay_user_id_case_id',
    check_result string comment 'AF检查结果码: 1=自动通过, 2=自动拒绝, 32006=人工审核, 3=等待第三方数据',
    check_result_name string comment 'AF检查结果名称: Auto Approve/Auto Reject/Screening/Waiting For Third Data/Others',
    req_time string comment 'AF请求时间戳(毫秒)',
    handle_end_time string comment 'AF处理结束时间戳(毫秒)',
    req_date string comment 'AF请求时间(格式化后)',
    handle_end_date string comment 'AF处理结束时间(格式化后)',
    risk_scene_id string comment '风控场景ID: 80048=激活场景'
)
COMMENT 'Tag:risk report summary table'
partitioned by (grass_date string comment "YYYY-MM-DD 日期分区")
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/dws/dws_risk_reg_activation_af_strategy_df/grass_region=${grass_region}'
;
--msck repair table risk_report.dws_risk_${region}_activation_af_strategy_df;

create or replace temporary view activation_credit_af_strategy_base as 
SELECT    
    get_json_object(extension, '$.flow_trace_id') AS flow_trace_id,
    workflow_flow_no,
    flow_no,
    shopeepay_user_id,
    CONCAT(shopeepay_user_id, '_', get_json_object(extension, '$.case_id')) AS biz_id,
    check_result,
    CASE
        WHEN check_result = 1     THEN 'Auto Approve'
        WHEN check_result = 2     THEN 'Auto Reject'
        WHEN check_result = 32006 THEN 'Screening'
        WHEN check_result = 3     THEN 'Waiting For Third Data'
        ELSE 'Others'
    END AS check_result_name,
    req_time,
    handle_end_time,
    format_time(req_time, '${grass_region}') as req_date,
    format_time(cast(handle_end_time/1000 as bigint), '${grass_region}') as handle_end_date,
    risk_scene_id
FROM      risk.dwd_risk_${shopeepay_af_region}_spp_gateway_req_rsp_final_result_di
WHERE     1 = ${has_shopeepay_af_region}
  and     grass_date >= date_sub('${current_grass_date}', 190)
  and     risk_scene_id = '80048'
  --and     get_json_object(extension, '$.flow_trace_id') <> ''
;

create or replace temporary view activation_credit_af_strategy as 
SELECT    
    flow_trace_id,
    workflow_flow_no,
    flow_no,
    shopeepay_user_id,
    biz_id,
    check_result,
    check_result_name,
    req_time,
    handle_end_time,
    req_date,
    handle_end_date,
    risk_scene_id,
    row_number() over (
        partition by flow_trace_id
        order by handle_end_time desc
    ) as rank_id
FROM activation_credit_af_strategy_base
;

insert overwrite risk_report.dws_risk_${region}_activation_af_strategy_df PARTITION (grass_date = '${grass_date}')
select
    t1.flow_trace_id,
    t1.workflow_flow_no,
    t1.flow_no,
    t1.shopeepay_user_id,
    t1.biz_id,
    t1.check_result,
    t1.check_result_name,
    t1.req_time,
    t1.handle_end_time,
    t1.req_date,
    t1.handle_end_date,
    t1.risk_scene_id
from
(
    select
        flow_trace_id,
        workflow_flow_no,
        flow_no,
        shopeepay_user_id,
        biz_id,
        check_result,
        check_result_name,
        req_time,
        handle_end_time,
        req_date,
        handle_end_date,
        risk_scene_id
    from activation_credit_af_strategy
    where rank_id = 1
) t1
;