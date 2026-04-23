ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_serasa_notary_info_df partition(grass_date ='${grass_date}')
select 
     get_json_object(t1.header_data,'$.PlatformUserId')                                                                           as platform_user_id
    ,get_json_object(resp_raw_data,'$.reports[0].registration.documentNumber')                                                   as document_number
    ,md5(concat(get_json_object(tbl.notary_response,'$.occurrenceDate'),get_json_object(tbl.notary_response,'$.officeNumber')))   as loan_id            
    ,get_json_object(tbl.notary_response,'$.occurrenceDate')                                                                      as occurrence_date        
    ,cast(get_json_object(tbl.notary_response,'$.amount') as decimal(32,4) )                                                      as amount
    ,get_json_object(tbl.notary_response,'$.officeNumber')                                                                        as office_number          
    ,get_json_object(tbl.notary_response,'$.officeName')                                                                          as office_name  
    ,get_json_object(tbl.notary_response,'$.city')                                                                                as city 
    ,get_json_object(tbl.notary_response,'$.federalUnit')                                                                         as federal_unit     
from risk.ods__credit_risk_datafetch_br_db__identity_data_tab__df  t1
lateral view explode(json_to_array(get_json_object(t1.resp_raw_data,'$.reports[0].negativeData.notary.notaryResponse'))) tbl as notary_response 
where grass_date ='${grass_date}'
and data_source_name = 'SerasaInfo'
and get_json_object(resp_raw_data,'$.reports[0].negativeData.notary.summary.count') >0
;
