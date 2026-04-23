ADD JAR hdfs://R2/projects/risk/hdfs/udf/hive-udf-snapshot.jar;
create temporary function json_to_array as 'com.shopee.seamoney.udf.JsonToArray';

insert overwrite table risk.dwd_risk_br_uw_serasa_stolen_documents_df partition(grass_date ='${grass_date}')
select 
     get_json_object(t1.header_data,'$.PlatformUserId')                                         as platform_user_id 
    ,get_json_object(resp_raw_data,'$.reports[0].registration.documentNumber')                  as person_document_number
    ,get_json_object(tbl.stolen_document_response,'$.occurrenceDate')                           as occurrence_date
    ,get_json_object(tbl.stolen_document_response,'$.inclusionDate')                            as inclusion_date   
    ,get_json_object(tbl.stolen_document_response,'$.documentType')                             as document_type    
    ,get_json_object(tbl.stolen_document_response,'$.documentNumber')                           as document_number  
    ,get_json_object(tbl.stolen_document_response,'$.issuingAuthority')                         as issuing_authority
    ,get_json_object(tbl.stolen_document_response,'$.detailedReason')                           as detailed_reason  
    ,get_json_object(tbl.stolen_document_response,'$.occurrenceState')                          as occurrence_state 
    ,cast(get_json_object(tbl.stolen_document_response,'$.phoneNumber.regionCode') as bigint)   as region_code      
    ,cast(get_json_object(tbl.stolen_document_response,'$.phoneNumber.areaCode') as bigint)     as area_code        
    ,cast(get_json_object(tbl.stolen_document_response,'$.phoneNumber.phoneNumber') as bigint)  as phone_number     
from risk.ods__credit_risk_datafetch_br_db__identity_data_tab__df  t1
lateral view explode(json_to_array(get_json_object(t1.resp_raw_data,'$.reports[0].facts.stolenDocuments.stolenDocumentsResponse'))) tbl as stolen_document_response 
where grass_date ='${grass_date}'
and data_source_name = 'SerasaInfo'
and get_json_object(resp_raw_data,'$.reports[0].facts.stolenDocuments.summary.count') >0
;