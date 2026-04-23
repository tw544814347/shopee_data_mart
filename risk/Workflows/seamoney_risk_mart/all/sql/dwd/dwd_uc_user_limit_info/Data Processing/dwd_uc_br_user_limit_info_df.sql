
add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


insert overwrite table ${SCHEMA}.dwd_uc_${region}_user_limit_info_df partition(app_id,grass_date)
select
 t1.platform_user_id                                                     as platform_user_id              
,t1.platform_type                                                        as platform_type                
,t1.sub_biz_type                                                         as sub_biz_type                 
,t1.operator                                                             as operator                     
,format_time(t1.create_time,upper('${region}'))                          as create_time
,format_time(t1.update_time,upper('${region}'))                          as update_time                    
,t1.activation_source                                                    as activation_source           
,t1.version                                                              as version                      
,t1.currency_units                                                       as currency_units               
,t1.sync_credit_status                                                   as sync_credit_status           
,t1.event_id                                                             as event_id                     
,t1.event_detail                                                         as event_detail                 
,t1.source                                                               as source                       
,cast(get_json_object(t1.limit_info,'$.base_limit') as bigint)                    as base_limit               
,cast(get_json_object(t1.limit_info,'$.bnpl_limit') as bigint)                    as bnpl_limit                   
,cast(get_json_object(t1.limit_info,'$.installment_limit') as bigint)             as installment_limit            
,cast(get_json_object(t1.limit_info,'$.advanced_limit') as bigint)                as advanced_limit               
,cast(get_json_object(t1.limit_info,'$.total_limit') as bigint)                   as total_limit                  
,cast(get_json_object(t1.limit_info,'$.temporary_limit') as bigint)               as temporary_limit              
,get_json_object(t1.limit_info,'$.temp_limit_start_time')                         as temp_limit_start_time        
,get_json_object(t1.limit_info,'$.temp_limit_end_time')                           as temp_limit_end_time          
,cast(get_json_object(t1.limit_info,'$.ceiling_limit') as bigint)                 as ceiling_limit                
,cast(get_json_object(t1.limit_info,'$.customer_level_credit_limit') as bigint)   as customer_level_credit_limit  
,t1.app_id                                                                        as app_id
,'${grass_date}'                                                                  as grass_date 
from risk.ods__credit_risk_underwriting_${region}_db__limit_rate_tab__df t1 
where t1.grass_date ='${grass_date}' 
;
