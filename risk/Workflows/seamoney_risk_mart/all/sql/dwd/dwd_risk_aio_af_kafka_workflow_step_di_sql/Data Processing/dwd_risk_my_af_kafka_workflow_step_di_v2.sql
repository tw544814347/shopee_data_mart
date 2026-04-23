--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-09-15
-- Theme Domain：       workflow_step
-- Description:         将workflow_steps_tab 从统一topic中还原
-- Data Granularity:    
-- 变更历史：
    -- 有 不带 v2 后缀的表更改为 v2，新增一个 process_date 分区来解决晚到问题 + 使用 dt 来筛选替代 grass_date 的筛选条件 注：SG 集群的逻辑和 US 有差异，和之前逻辑保持一致，SG 使用模板，US 单独部署
-- update by lili dwd缓冲层替换ods
-- update by lili 增加对 MX 和 BR 场景下输出字段的处理
-- update by lili 新增dfs的五个字段
--********************************************************************--
ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create or replace temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

-- ADD JAR hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-biz-udf-1.0-SNAPSHOT-20250113.jar;
-- create or replace temporary function get_workflow_info as 'com.shopee.udf.GetWorkflowInfo';

-- create or replace temporary view tmp_appid_scene_id_tab as
-- select
--       product_name
--       ,app_id
--       ,scene_id
-- from risk.dim_risk_strategy_app_scene_config_df
-- where
--       grass_region = '${grass_region}'
--       and grass_date = '${grass_date}'
--       and scene_type = 'workflow'
--       and need_write_workflow_db = 1
-- group by product_name, app_id, scene_id
-- ;


insert overwrite table risk.dwd_risk_${region}_af_kafka_workflow_step_di_v2 partition(product_name,grass_date,process_date)
select 
id                     
,flow_no as wfid         
,flow_no           
,platform_user_id
,get_json_object(step_json,'$.CurrentStep') as step                  
,cast(get_json_object(step_json,'$.Status') as bigint) as status                
,input                 
,case 
    when upper('${region}') in ('MX', 'BR') 
    then get_json_object(step_json,'$.output')
    else step_json
end as output
,case 
    when upper('${region}') in ('MX', 'BR') 
    then case when task_run_step like '%END%' then 'END' else get_json_object(step_json,'$.Next_step') end
    else case when get_json_object(step_json,'$.NextStep') = '' and task_run_step like '%END%' then 'END' else get_json_object(step_json,'$.NextStep') end
end as next                    
,version               
,create_time        
,case when update_time<create_time or update_time is null then create_time else  update_time end    as update_time          
,req_type
,source_platform_type
,source_platform_user_id
,traffic_platform_type
,traffic_platform_user_id
,shopeepay_user_id
,platform_type
,product_name
,grass_date   
,'${ds}'     as process_date
from (
      select 
      0 as id                     
      ,0 as wfid                  
      ,platform_user_id  
      ,flow_no    
      ,step                  
      -- ,cast(get_json_object(t1.value,'$.Rsp.RiskInsight.TaskResults.Status') as bigint)      as status                
      ,null  as input                 
      ,step_output as  output                
      ,null next                  
      ,null version               
      ,create_time        
      ,update_time         
      ,null req_type 
      ,task_run_step
      ,source_platform_type
      ,source_platform_user_id
      ,traffic_platform_type
      ,traffic_platform_user_id
      ,shopeepay_user_id
      ,platform_type
      ,product_name_from_scene_config as product_name
      ,grass_date             
      from risk.dwd_risk_${region}_live_kafka_gateway_aio_log_di t1
      where t1.dt >= cast(date_sub('${grass_date}',0) as string) and t1.dt <= cast(date_add('${grass_date}',1) as string) 
      and scene_type_from_scene_config = 'workflow'
      and need_write_workflow_db_from_scene_config = 1
) a 
lateral view explode(json_to_array(output)) tbl as step_json 
