--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-11-06
-- Theme Domain：       workflow
-- Description:         将workflow_tab 从统一topic中还原
-- Data Granularity:    
-- 变更历史：
-- update by zongyi.lu@shopee.com 20241113 切换成 risk.dwd_risk_${region_lower}_af_kafka_workflow_di
-- update by wei.tao@shopee.com 20250331 https://jira.shopee.io/browse/SPFDT-50409
-- update by lili 增加 source_platform_type、source_platform_user_id、traffic_platform_type、traffic_platform_user_id,shopeepay_user_id字段
--********************************************************************--
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp' using jar 'hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar'
;

create temporary view tmp_distinct_flow_no_1 as 
select 
    id                
    ,app_id           
    ,scene_id         
    ,platform_user_id 
    ,flow_no          
    ,seq_id           
    ,current_step     
    ,run_step         
    ,status           
    ,input            
    ,output           
    ,version          
    ,create_time
    ,update_time     
    ,req_no           
    ,req_md5          
    ,cluster_id       
    ,async_flag
    ,source_platform_type
    ,source_platform_user_id
    ,traffic_platform_type
    ,traffic_platform_user_id
    ,shopeepay_user_id
    ,platform_type   
    ,grass_date
from(
    select 
      flow_no               as id                  
      ,app_id               as app_id             
      ,cast(scene_id as bigint)              as scene_id           
      ,platform_user_id     as platform_user_id   
      ,flow_no              as flow_no            
      ,seq_id               as seq_id    
      ,split(case when task_run_step like '%END%' then concat(run_step,'/END') else run_step end, '/')[size(split(case when task_run_step like '%END%' then concat(run_step,'/END') else run_step end, '/'))-1]         as current_step       
      ,case when task_run_step like '%END%' then concat(run_step,'/END') else run_step end as run_step           
      ,workflowstatus       as status             
      ,input                as input              
      ,output               as output             
      ,null                 as version            
      ,create_time          as create_time        
      ,case when update_time<create_time or update_time is null then create_time else  update_time end    as update_time        
      ,concat(req_no ,'_',app_id)               as req_no             
      ,md5(concat('appId=',app_id,'sceneId=',scene_id,'platformUserId=',platform_user_id))  as req_md5            
      ,null           as cluster_id         
      ,null           as async_flag         
      ,null           as req_type        
      ,dispatch_time
      ,source_platform_type
      ,source_platform_user_id
      ,traffic_platform_type
      ,traffic_platform_user_id
      ,shopeepay_user_id
      ,platform_type        
      ,grass_date
    ,row_number() over(partition by flow_no order by dispatch_time desc, size(split(run_step,'/')) desc) rn 
    from risk.dwd_risk_${region_lower}_live_kafka_gateway_aio_log_di
    where grass_date>=date_sub('${grass_date}',90) 
    and product_name='${product}'
    and scene_type_from_scene_config = 'workflow'
    and need_write_workflow_db_from_scene_config = 1
    and date(format_time(create_time,'${region_upper}'))>= date_sub('${grass_date}',90)
) t1 
where rn = 1 
;


--因为数据会延迟很久，所以重新刷新90天前这天的数据，如果延迟超过90天，数据仍然会丢失
insert overwrite table ${SCHEMA}.dwd_risk_${region_lower}_af_${product}_workflow_di partition(grass_date)
select 
        id                
        ,app_id           
        ,scene_id         
        ,platform_user_id 
        ,flow_no          
        ,seq_id           
        ,current_step     
        ,run_step         
        ,status           
        ,input            
        ,output           
        ,version          
        ,format_time(create_time,'${region_upper}') as create_time
        ,format_time(update_time  ,'${region_upper}') as update_time      
        ,req_no           
        ,req_md5          
        ,cluster_id       
        ,async_flag
        ,source_platform_type
        ,source_platform_user_id
        ,traffic_platform_type
        ,traffic_platform_user_id
        ,shopeepay_user_id
        ,platform_type             
        , date(format_time(create_time,'${region_upper}')) as grass_date
    -- from risk.ods__${product}_risk_control_${region_lower}_db__workflow_tab__df  t1
    from tmp_distinct_flow_no_1 t1 
    where grass_date>=date_sub('${grass_date}',90)
    and date(format_time(create_time,'${region_upper}'))>=date_sub('${grass_date}',90);