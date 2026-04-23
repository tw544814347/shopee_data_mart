--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-01-22
-- Theme Domain：       user_identity_log
-- Description:         user_identity_log
-- Data Granularity:    
-- 变更历史：
--********************************************************************--



add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


insert overwrite table ${SCHEMA}.dwd_risk_${region}_user_identity_log_df partition(grass_date='${grass_date}')
select 
id                                              as id       
,flow_no                                        as flow_no                    
,id_no                                          as id_no                      
,name                                           as name                       
,birth_date                                     as birth_date                 
,birth_place                                    as birth_place                
,identity_photo_url                             as identity_photo_url         
,selfie_photo_url                               as selfie_photo_url           
,name_match                                     as name_match                 
,birth_date_match                               as birth_date_match           
,birth_place_match                              as birth_place_match          
,rsp_address                                    as rsp_address                
,selfie_photo_match_score                       as selfie_photo_match_score   
,rsp_code                                       as rsp_code                   
,errors                                         as errors                     
,format_time(create_time,upper('${region}'))    as create_time       
,format_time(update_time,upper('${region}'))    as update_time               
,req_channel                                    as req_channel                
,req_no                                         as req_no                     
,format_time(req_time,upper('${region}'))       as req_time                   
,req_status                                     as req_status      
,asli_version                                   as asli_version       
from risk.ods__credit_risk_control_${region}_db__user_identity_log_tab__df
where grass_date ='${grass_date}'
;