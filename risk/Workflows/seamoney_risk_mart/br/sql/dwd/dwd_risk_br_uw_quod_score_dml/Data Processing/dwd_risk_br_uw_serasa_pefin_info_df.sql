ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_serasa_pefin_info_df partition(grass_date ='${grass_date}')
select 
     get_json_object(t1.header_data,'$.PlatformUserId')                                                                          as platform_user_id
    ,get_json_object(resp_raw_data,'$.reports[0].registration.documentNumber')                                                   as document_number
    ,md5(concat(get_json_object(tbl.pefin_response,'$.occurrenceDate'),get_json_object(tbl.pefin_response,'$.contractId')))      as loan_id
    ,get_json_object(tbl.pefin_response,'$.occurrenceDate')                                                                      as occurrence_date      
    ,get_json_object(tbl.pefin_response,'$.legalNatureId')                                                                       as legal_nature_id       
    ,get_json_object(tbl.pefin_response,'$.legalNature')                                                                         as legal_nature            
    ,get_json_object(tbl.pefin_response,'$.contractId')                                                                          as contractor_id            
    ,get_json_object(tbl.pefin_response,'$.creditorName')                                                                        as creditor_name       
    ,cast(get_json_object(tbl.pefin_response,'$.amount') as decimal(32,4) )                                                      as amount
    ,get_json_object(tbl.pefin_response,'$.city')                                                                                as city          
    ,get_json_object(tbl.pefin_response,'$.federalUnit')                                                                         as federal_unit  
    ,get_json_object(tbl.pefin_response,'$.publicAgency')                                                                        as public_agency 
    ,get_json_object(tbl.pefin_response,'$.principal')                                                                           as principal     
from risk.ods__credit_risk_datafetch_br_db__identity_data_tab__df  t1
lateral view explode(json_to_array(get_json_object(t1.resp_raw_data,'$.reports[0].negativeData.pefin.pefinResponse'))) tbl as pefin_response 
where grass_date ='${grass_date}'
and data_source_name = 'SerasaInfo'
and get_json_object(resp_raw_data,'$.reports[0].negativeData.pefin.summary.count') >0
;