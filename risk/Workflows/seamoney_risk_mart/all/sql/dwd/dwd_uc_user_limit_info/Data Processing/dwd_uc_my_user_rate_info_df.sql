
add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


insert overwrite table ${SCHEMA}.dwd_uc_${region}_user_rate_info_df partition(app_id,grass_date)
select
 t1.platform_user_id                                                              as platform_user_id              
,t1.platform_type                                                                 as platform_type                
,t1.sub_biz_type                                                                  as sub_biz_type                 
,t1.operator                                                                      as operator                     
,format_time(t1.create_time,upper('${region}'))                                   as create_time
,format_time(t1.update_time,upper('${region}'))                                   as update_time                
,t1.activation_source                                                             as activation_source           
,t1.version                                                                       as version                      
,t1.currency_units                                                                as currency_units               
,t1.sync_credit_status                                                            as sync_credit_status           
,t1.event_id                                                                      as event_id                     
,t1.event_detail                                                                  as event_detail                 
,t1.source                                                                        as source                    
,cast(get_json_object(t1.rate_info,'$.admin_fee_rate') as bigint)                as admin_fee_rate               
,cast(get_json_object(t1.rate_info,'$.nominal_interest_rate') as bigint)         as nominal_interest_rate                   
,cast(get_json_object(t1.rate_info,'$.buyer_tx_fee_rate') as bigint)             as buyer_tx_fee_rate            
,cast(get_json_object(t1.rate_info,'$.late_charge_rate') as bigint)              as late_charge_rate               
,cast(get_json_object(t1.rate_info,'$.penalty_interest_rate') as bigint)         as penalty_interest_rate                  
,cast(get_json_object(t1.rate_info,'$.processing_fee_rate') as bigint)           as processing_fee_rate              
,t1.app_id                                                                        as app_id
,'${grass_date}'                                                                  as grass_date 
from risk.ods__credit_risk_underwriting_${region}_db__limit_rate_tab__df t1 
where t1.grass_date ='${grass_date}' 
;
