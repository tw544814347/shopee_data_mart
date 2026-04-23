insert overwrite table risk.dwd_risk_br_uw_serasa_personal_info_df partition(grass_date ='${grass_date}')
select 
     get_json_object(header_data,'$.PlatformUserId')                                                                         as platform_user_id
     ,get_json_object(resp_raw_data,'$.reports[0].registration.documentNumber')                                              as document_number     
     ,get_json_object(resp_raw_data,'$.reports[0].registration.consumerName')                                                as name                
     ,get_json_object(resp_raw_data,'$.reports[0].registration.motherName')                                                  as mother_name         
     ,get_json_object(resp_raw_data,'$.reports[0].registration.birthDate')                                                   as birth_date          
     ,get_json_object(resp_raw_data,'$.reports[0].registration.statusRegistration')                                          as status_registration 
     ,get_json_object(resp_raw_data,'$.reports[0].registration.statusDate')                                                  as status_date         
     ,get_json_object(resp_raw_data,'$.reports[0].registration.address.addressLine')                                         as address_line        
     ,get_json_object(resp_raw_data,'$.reports[0].registration.address.district')                                            as address_district    
     ,get_json_object(resp_raw_data,'$.reports[0].registration.address.zipCode')                                             as address_zipcode     
     ,get_json_object(resp_raw_data,'$.reports[0].registration.address.country')                                             as address_country     
     ,get_json_object(resp_raw_data,'$.reports[0].registration.address.city')                                                as address_city        
     ,get_json_object(resp_raw_data,'$.reports[0].registration.address.state')                                               as address_state       
     ,get_json_object(resp_raw_data,'$.reports[0].registration.phone.regionCode')                                            as phone_region_code   
     ,get_json_object(resp_raw_data,'$.reports[0].registration.phone.areaCode')                                              as phone_area_code     
     ,get_json_object(resp_raw_data,'$.reports[0].registration.phone.phoneNumber')                                           as phone_number        
     ,cast(get_json_object(resp_raw_data,'$.reports[0].negativeData.pefin.summary.count') as bigint)                         as pefin_count         
     ,cast(get_json_object(resp_raw_data,'$.reports[0].negativeData.pefin.summary.balance') as decimal(32,4))                as pefin_balance       
     ,cast(get_json_object(resp_raw_data,'$.reports[0].negativeData.refin.summary.count') as bigint)                         as refin_count         
     ,cast(get_json_object(resp_raw_data,'$.reports[0].negativeData.refin.summary.balance') as decimal(32,4))                as refin_balance       
     ,cast(get_json_object(resp_raw_data,'$.reports[0].negativeData.notary.summary.count') as bigint)                        as notary_count        
     ,cast(get_json_object(resp_raw_data,'$.reports[0].negativeData.notary.summary.balance')  as decimal(32,4))              as notary_balance      
     ,cast(get_json_object(resp_raw_data,'$.reports[0].negativeData.check.summary.count') as bigint)                         as check_count         
     ,cast(get_json_object(resp_raw_data,'$.reports[0].negativeData.check.summary.balance') as decimal(32,4))                as check_balance       
     ,cast(get_json_object(resp_raw_data,'$.reports[0].facts.inquiry.summary.count') as bigint)                              as inquiry_count       
     ,cast(get_json_object(resp_raw_data,'$.reports[0].facts.stolenDocuments.summary.count') as bigint)                      as stolen_doc_count    
     ,cast(get_json_object(resp_raw_data,'$.reports[0].facts.stolenDocuments.summary.balance')  as decimal(32,4))            as stolen_doc_balance  
     ,cast(get_json_object(resp_raw_data,'$.optionalFeatures.negativeData.spcNegative.summary.count') as bigint)             as spc_negative_count  
     ,cast(get_json_object(resp_raw_data,'$.optionalFeatures.negativeData.spcNegative.summary.balance') as decimal(32,4))    as spc_negative_balance       
     ,cast(get_json_object(resp_raw_data,'$.optionalFeatures.facts.spcInquires.summary.count') as bigint)                    as spc_inquiry_count   
from risk.ods__credit_risk_datafetch_br_db__identity_data_tab__df
where grass_date ='${grass_date}'
and data_source_name = 'SerasaInfo'
and get_json_object(resp_raw_data,'$.reports[0].registration.documentNumber') is not null 
;