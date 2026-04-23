--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-07-10
-- Theme Domain：       workflow
-- Description:         将workflow_tab 从统一topic中还原
-- Data Granularity:    
-- 变更历史：
-- update by zongyi.lu@shopee.com 20240909 切换成 risk.dwd_risk_${region_lower}_af_kafka_workflow_di
-- update by lili 新增dfs五个字段
--********************************************************************--
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


with kafka_tab as (
select 
        id                   
        ,wfid                
        ,platform_user_id    
        ,step                
        ,status              
        ,input               
        ,output              
        ,next                
        ,version
        ,source_platform_type
        ,source_platform_user_id
        ,traffic_platform_type
        ,traffic_platform_user_id
        ,shopeepay_user_id
        ,platform_type
        ,format_time(create_time,'${region_upper}') as create_time
        ,format_time(update_time  ,'${region_upper}') as update_time   
        ,date(format_time(create_time,'${region_upper}')) as grass_date
        ,row_number() over(partition by wfid, step order by update_time desc) rn 
    -- from risk.ods__${product}_risk_control_${region_lower}_db__workflow_steps_tab__df  t1
    from risk.dwd_risk_${region_lower}_af_kafka_workflow_step_di t1 
    where grass_date>= date_sub('${grass_date}',90)
    and product_name ='${product}'
    and date(format_time(create_time,'${region_upper}'))>= date_sub('${grass_date}',90)
)

insert overwrite table ${SCHEMA}.dwd_risk_${region_lower}_af_${product}_workflow_step_di partition(grass_date)
select 
    id                   
    ,wfid                
    ,platform_user_id    
    ,step                
    ,status              
    ,input               
    ,output              
    ,next                
    ,version             
    ,create_time
    ,update_time
    ,source_platform_type
    ,source_platform_user_id
    ,traffic_platform_type
    ,traffic_platform_user_id
    ,shopeepay_user_id   
    ,platform_type
    ,grass_date
from kafka_tab
where rn = 1
;