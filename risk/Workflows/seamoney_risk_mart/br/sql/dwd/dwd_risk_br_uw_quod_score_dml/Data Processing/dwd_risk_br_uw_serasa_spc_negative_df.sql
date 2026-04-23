ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_serasa_spc_negative_df partition(grass_date ='${grass_date}')
select 
     get_json_object(t1.header_data,'$.PlatformUserId')                                                                      as platform_user_id
    ,get_json_object(resp_raw_data,'$.reports[0].registration.documentNumber')    as document_number
    ,md5(concat(get_json_object(tbl.spc_negative,'$.occurrenceDate'),get_json_object(tbl.spc_negative,'$.contractId')))      as loan_id
    ,get_json_object(tbl.spc_negative,'$.occurrenceDate')                                                                    as occurrence_date     
    ,get_json_object(tbl.spc_negative,'$.occurrenceStatus')                                                                  as occurrence_status   
    ,get_json_object(tbl.spc_negative,'$.legalNatureId')                                                                     as legal_nature_id     
    ,get_json_object(tbl.spc_negative,'$.legalNature')                                                                       as legal_nature        
    ,get_json_object(tbl.spc_negative,'$.contractId')                                                                        as contract_id         
    ,get_json_object(tbl.spc_negative,'$.creditorBusinessId')                                                                as creditor_business_id
    ,get_json_object(tbl.spc_negative,'$.creditorName')                                                                      as creditor_name       
    ,cast(get_json_object(tbl.spc_negative,'$.amount') as decimal(32,4))                                                     as amount              
    ,get_json_object(tbl.spc_negative,'$.city')                                                                              as city                
    ,get_json_object(tbl.spc_negative,'$.federalUnit')                                                                       as federal_unit        
    ,get_json_object(tbl.spc_negative,'$.principal')                                                                         as principal           
from risk.ods__credit_risk_datafetch_br_db__identity_data_tab__df  t1
lateral view explode(json_to_array(get_json_object(t1.resp_raw_data,'$.optionalFeatures.negativeData.spcNegative.spcNegativeResponse'))) tbl as spc_negative 
where grass_date ='${grass_date}'
and data_source_name = 'SerasaInfo'
and get_json_object(resp_raw_data,'$.optionalFeatures.negativeData.spcNegative.summary.count') >0
;
