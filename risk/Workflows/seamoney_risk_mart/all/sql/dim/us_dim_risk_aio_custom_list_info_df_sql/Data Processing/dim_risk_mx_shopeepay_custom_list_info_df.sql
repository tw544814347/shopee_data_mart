--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-29
-- Theme Domain：       costom_list dim表(所有名单的信息)
-- Description:         策略名单维度表
-- Data Granularity:    
-- 变更历史： update by zongyi.lu@shopee.com 新增合并小文件参数
-- update by zongyi.lu@shopee.com 2024-11-05 新增字段 de_table_config,screening_switch; jira https://jira.shopee.io/browse/SPSK-184747

--********************************************************************--

add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


insert overwrite table ${SCHEMA}.dim_risk_${region}_${product_line}_custom_list_info_df partition(grass_date='${grass_date}')
select 
id as list_id          
,list_name       
,property        
,status          
,data_type       
,list_source     
,actions         
,de_table_name   
,remark          
,description     
,creator         
,format_time(create_time,upper('${region}') )    as create_time
,format_time(update_time,upper('${region}') )    as update_time
,category        
,version         
,total           
,data_hash       
,fit_scene       
,scenario_based  
,screening_switch
,de_table_config
from risk.ods__${product_line}_risk_control_${region}_db__custom_list_tab__df
where grass_date='${grass_date}'
;