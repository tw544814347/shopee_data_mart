-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-08-25
-- Theme Domain:        UnderWriting
-- Data Granularity:    app_id+scene_id+flow_no
-- Description:         invoke_policy_result_history_tab dwd表
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-08-25 - chengguo.liu - 初始化
-- =============================================================================


create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

insert overwrite ${SCHEMA}.dwd_risk_${region}_underwriting_invoke_policy_result_history_df PARTITION (grass_date = '${bizdate}')
select
    id
    ,flow_no
    ,req_params
    ,rsp
    ,format_time(create_time, '${grass_region}') as create_time
    ,format_time(update_time, '${grass_region}') as update_time
    ,app_id
    ,scene_id
    ,platform_user_id
    ,platform_type
    ,format_time(pending_start_time, '${grass_region}') as pending_start_time
    ,format_time(pending_finish_time, '${grass_region}') as pending_finish_time
    ,result_code
from risk.ods__cf_risk_underwriting_id_db__invoke_policy_result_history_tab__df
where grass_date = '${bizdate}'
union all
select
    id
    ,flow_no
    ,req_params
    ,rsp
    ,format_time(create_time, '${grass_region}') as create_time
    ,format_time(update_time, '${grass_region}') as update_time
    ,app_id
    ,scene_id
    ,platform_user_id
    ,platform_type
    ,format_time(pending_start_time, '${grass_region}') as pending_start_time
    ,format_time(pending_finish_time, '${grass_region}') as pending_finish_time
    ,result_code
from risk.ods__ldn_risk_underwriting_id_db__invoke_policy_result_history_tab__df
where grass_date = '${bizdate}'
;
