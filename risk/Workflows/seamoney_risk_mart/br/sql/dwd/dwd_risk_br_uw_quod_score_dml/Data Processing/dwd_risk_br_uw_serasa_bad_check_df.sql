ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_serasa_bad_check_df partition(grass_date ='${grass_date}')
select 
     get_json_object(t1.header_data,'$.PlatformUserId')                                                                          as platform_user_id
    ,get_json_object(resp_raw_data,'$.reports[0].registration.documentNumber')                                                   as document_number
    ,md5(concat(get_json_object(tbl.check_response,'$.occurrenceDate'),get_json_object(tbl.check_response,'$.bankId'),get_json_object(tbl.check_response,'$.bankAgencyId')))      as loan_id
    ,get_json_object(tbl.check_response,'$.occurrenceDate')                                                                      as occurrence_date        
    ,get_json_object(tbl.check_response,'$.legalSquare')                                                                         as legal_square      
    ,get_json_object(tbl.check_response,'$.bankId')                                                                              as bank_id   
    ,get_json_object(tbl.check_response,'$.bankName')                                                                            as bank_name   
    ,get_json_object(tbl.check_response,'$.bankAgencyId')                                                                        as bank_agency_id   
    ,cast(get_json_object(tbl.check_response,'$.checkCount') as bigint)                                                          as check_count       
    ,get_json_object(tbl.check_response,'$.city')                                                                                as city   
    ,get_json_object(tbl.check_response,'$.federalUnit')                                                                         as federal_unit   
    ,get_json_object(tbl.check_response,'$.checkNumber')                                                                         as check_number   
    ,cast(get_json_object(tbl.check_response,'$.alinea') as bigint)                                                              as alinea   
   
from risk.ods__credit_risk_datafetch_br_db__identity_data_tab__df  t1
lateral view explode(json_to_array(get_json_object(t1.resp_raw_data,'$.reports[0].negativeData.check.checkResponse'))) tbl as check_response 
where grass_date ='${grass_date}'
and data_source_name = 'SerasaInfo'
and get_json_object(resp_raw_data,'$.reports[0].negativeData.check.summary.count') >0
;
