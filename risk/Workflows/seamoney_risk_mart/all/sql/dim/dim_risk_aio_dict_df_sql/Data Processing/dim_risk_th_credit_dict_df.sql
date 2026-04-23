--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-29
-- Theme Domain：       dict dim表(维度信息表)
-- Description:         名单维度表
-- Data Granularity:    
-- 变更历史：
--********************************************************************--
create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

insert overwrite table ${SCHEMA}.dim_risk_${region}_${product_line}_dict_df partition(grass_date='${grass_date}')
select 
dict_key         
,dict_name        
,dict_value       
,parent_dict_key  
,leaf_node        
,description      
,status           
,creator          
,format_time(create_time,upper('${region}') )    as create_time
,format_time(update_time,upper('${region}') )    as update_time   
from risk.ods__${product_line}_risk_control_${region}_db__dict_tab__df 
where grass_date='${grass_date}'