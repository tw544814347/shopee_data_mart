--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-10-14
-- Theme Domain：       反欺诈日志dws
-- Description:         credit live 反欺诈日志数据dws jira: https://jira.shopee.io/browse/SPFDT-44546
--                      https://docs.google.com/spreadsheets/d/1xeEqGpGDLVDy6ss1ZtIs_frUhoiJYo-aBiFKLXATDW8/edit?pli=1&gid=89359632#gid=89359632
-- Data Granularity:    req_no+app_id+scene_id+flow_no
-- ID 取190天，其他region 取370天
-- 变更历史：
-- update by zongyi.lu@shopee.com 2024-10-21 处理task_run_step risk工作流有1个子工作流的概念,子工作流服务于各类型的加验
--                                           WHEN 
--                                           第1步的切割枚举 IN ('return_result_standard_pass','return_result_standard_reject')--子工作流结果返回步骤
--                                           THEN
--                                           取值 = 切割后倒数第4个的值
-- update by zongyi.lu@shopee.com 2024-10-22 如果字符串不包含"END"eg./anti_fraud_10012/anti_fraud_10013/invoke_policy 取最后分组的值:invoke_policy; 包含END 则按照原来的逻辑
-- update by wei.tao 2025-03-17 jira:https://jira.shopee.io/browse/SPFDT-50064 
--********************************************************************--

add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


insert overwrite table risk.dws_risk_${region}_credit_final_result_nd partition(grass_date ='${grass_date}')
select 
    tt1.app_id 
    ,tt1.scene_id
    ,tt1.product_code
    ,tt1.flow_no 
    ,tt1.req_time 
    ,tt1.req_no -- TH的表字段名是req_on 其他是reqno
    ,tt1.seq_id
    ,tt1.platform_type
    ,tt1.platform_user_id
    ,tt1.credit_user_id
    ,tt1.handle_begin_time
    ,tt1.handle_end_time
    ,tt1.final_result
    ,tt1.workflow_flow_no
    ,tt1.app_type
    ,tt1.check_result
    ,tt1.check_result_code
    ,tt1.task_run_step
    ,tt1.last_task_run_step
    ,tt1.req_time_local
    ,tt1.scene_type_1
    ,tt1.is_workflow
from (
    select 
    t1.app_id 
    ,t1.scene_id
    ,get_json_object(t1.extension, '$.product_code')  as product_code
    ,t1.flow_no 
    ,t1.req_time 
    ,t1.${req_no} as req_no -- TH的表字段名是req_on 其他是reqno
    ,t1.seq_id
    ,t1.platform_type
    ,t1.platform_user_id
    ,t1.credit_user_id
    ,format_time(cast(round(t1.handle_begin_time/1000,0) as bigint),upper('${region}')) as handle_begin_time
    ,format_time(cast(round(t1.handle_end_time/1000,0) as bigint),upper('${region}')) as handle_end_time
    ,t1.final_result
    ,t1.workflow_flow_no
    ,t1.app_type
    ,t1.check_result
    ,t1.check_result_code
    ,t1.task_run_step
    -- ,split(t1.task_run_step, '/')[size(split(t1.task_run_step, '/')) - 3] as last_task_run_step
    ,case when t1.task_run_step not like '%END' then split(t1.task_run_step, '/')[size(split(t1.task_run_step, '/')) - 1]
          when split(t1.task_run_step, '/')[size(split(t1.task_run_step, '/')) - 3] in ('return_result_standard_pass','return_result_standard_reject')
          then split(t1.task_run_step, '/')[size(split(t1.task_run_step, '/')) - 4] 
          else split(t1.task_run_step, '/')[size(split(t1.task_run_step, '/')) - 3] end as last_task_run_step 
    ,format_time(t1.req_time,upper('${region}')) as req_time_local
    ,scene_type_1
    ,is_workflow
    ,ROW_NUMBER() OVER (
        PARTITION BY t1.workflow_flow_no,t1.app_id,t1.scene_id
        ORDER BY req_time, handle_end_time DESC
        ) AS rn
    from risk.dwd_risk_${region}_strategy_final_result_merge_di_v2 t1 
    join (
        SELECT
            CONCAT('${region}', '_live_credit_risk_gateway_req_rsp_', app_id) AS topic_name,
            scene_id AS risk_scene_id,
            prod,
            scene_type_1,
            is_workflow
        FROM risk.dim_credit_risk_scene_id
        WHERE UPPER(region) IN (UPPER('${region}'), 'ALL') -- ALL: kyc voi 所有 region 都一样，因此在 gsheet 中是就存成了 ALL
        GROUP BY 1,2,3,4,5 -- 去重，去重，去重，去重，去重
    ) t2  on t1.topic_name = t2.topic_name and t1.risk_scene_id = t2.risk_scene_id
    where t1.grass_date >= cast(date_sub('${grass_date}',${req_days}) as string)
    and t1.grass_date <= cast('${grass_date}' as string)
) tt1 
where tt1.rn=1
;