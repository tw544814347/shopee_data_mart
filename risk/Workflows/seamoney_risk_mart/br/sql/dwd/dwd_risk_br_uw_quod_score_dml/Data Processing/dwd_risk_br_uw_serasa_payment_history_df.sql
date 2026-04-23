ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_serasa_payment_history_df partition(grass_date ='${grass_date}')
select 
     get_json_object(t1.header_data,'$.PlatformUserId')                           as platform_user_id    
    ,get_json_object(resp_raw_data,'$.reports[0].registration.documentNumber')    as document_number
    ,cast(get_json_object(tbl.spc_negative,'$.initialDayRange') as bigint)        as initial_day_range
    ,cast(get_json_object(tbl.spc_negative,'$.finalDayRange') as bigint)          as final_day_range   
    ,get_json_object(tbl.spc_negative,'$.score')                                  as score     
    ,get_json_object(tbl.spc_negative,'$.range')                                  as range        
    ,get_json_object(tbl.spc_negative,'$.error.message')                          as message         
    ,cast(get_json_object(tbl.spc_negative,'$.error.code') as bigint)             as code          
from risk.ods__credit_risk_datafetch_br_db__identity_data_tab__df  t1
lateral view explode(json_to_array(get_json_object(t1.resp_raw_data,'$.optionalFeatures.paymentshistory.paymentsHistoryResponse'))) tbl as spc_negative 
where grass_date ='${grass_date}'
and data_source_name = 'SerasaInfo'
;