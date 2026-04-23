--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-10-18
-- Theme Domain：       外部数据 cbi user_base_info
-- Description:         外部数据 cbi user_base_info
-- Data Granularity:    https://docs.google.com/spreadsheets/d/1tCaiMiy4NT7Mx2apgnAQZwSHIXBllsQta6EszrVXcSs/edit?gid=1916042379#gid=1916042379
--                      jira: https://jira.shopee.io/browse/SPFDT-45018
-- 变更历史：
--********************************************************************--

insert overwrite table risk.dwd_risk_id_uw_cbi_user_base_info_df partition(grass_date='${grass_date}')
select 
    t1.trace_id                 
    ,t1.credit_user_id          
    ,t1.platform_user_id        
    ,t1.flow_no                 
    ,t1.ktp_no                  
    ,t1.cbi_report_no  
    ,t1.cbi_status              
    ,t1.cbi_is_error            
    ,t1.report_update_time                                                                                                                                             as report_update_time      
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_AddresAndContact.INDID_AddressAsIdentity.INDID_Address')     as address                 
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_EmploymentInfo.INDID_EmploymentEconomicSector')              as business_field_id       
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_EmploymentInfo.INDID_EmploymentEconomicSectorDesc')          as business_field          
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Identity.INDID_IDType')                                      as identity_id             
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Personal.INDID_Gender')                                      as gender_id               
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Personal.INDID_GenderDesc')                                  as gender                  
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_AddresAndContact.INDID_AddressAsIdentity.INDID_City')        as city_id                 
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_AddresAndContact.INDID_AddressAsIdentity.INDID_CityDesc')    as city                    
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_AddresAndContact.INDID_AddressAsIdentity.INDID_District')    as district                
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_AddresAndContact.INDID_AddressAsIdentity.INDID_SubDistrict') as village                 
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Personal.INDID_EducationLevel')                              as degree_id               
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Personal.INDID_EducationLevelDesc')                          as degree                  
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_AddresAndContact.INDID_AddressAsIdentity.INDID_PostalCode')  as zipcode                 
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Personal.INDID_FullName')                                    as name                    
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_AddresAndContact.INDID_AddressAsIdentity.INDID_Country')     as country_id              
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_AddresAndContact.INDID_AddressAsIdentity.INDID_CountryDesc') as country                 
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Identity.INDID_IDNumber')                                    as identity_number         
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_Identity.INDID_TaxNumber')                                   as npwp                    
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_EmploymentInfo.INDID_Employment')                            as job_id                  
    ,get_json_object(t1.slik_report,'$.result.BureauReport.IndividualIdentitySubject.INDID_Information.INDID_EmploymentInfo.INDID_EmploymentDesc')                        as job  
from  risk.dwd_risk_id_uw_cbi_base_info_df t1 
where t1.grass_date ='${grass_date}'
;


