--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-10-18
-- Theme Domain：       外部数据 cbi fasility_collateral_info
-- Description:         外部数据 cbi fasility_collateral_info
-- Data Granularity:    https://docs.google.com/spreadsheets/d/1tCaiMiy4NT7Mx2apgnAQZwSHIXBllsQta6EszrVXcSs/edit?gid=1916042379#gid=1916042379
--                      jira: https://jira.shopee.io/browse/SPFDT-45018
-- 变更历史： 
--********************************************************************--
create or replace temporary function json_to_array as 'com.shopee.udf.JsonToArray' using jar 'hdfs://R2/projects/risk/hdfs/udf/seamoney-risk-tool-udf-1.0-SNAPSHOT-jar-with-dependencies.jar';


insert overwrite table risk.dwd_risk_id_uw_cbi_fasility_collateral_info_df partition(grass_date='${grass_date}')           

select 
    t2.trace_id                 
    ,t2.credit_user_id          
    ,t2.platform_user_id        
    ,t2.flow_no                 
    ,t2.ktp_no                  
    ,t2.cbi_report_no  
    ,t2.cbi_status              
    ,t2.cbi_is_error 
    ,t2.report_update_time
    ,t2.initial_contract_no
    ,get_json_object(tbl.credit_collatera_on_facility_list,'$.CREDIT_CollateralOnFacilityList_Item.CREDIT_CollateralType')         as collateral_type                               
    ,get_json_object(tbl.credit_collatera_on_facility_list,'$.CREDIT_CollateralOnFacilityList_Item.CREDIT_SecurityAssignmentType') as binding_type                                  
    ,get_json_object(tbl.credit_collatera_on_facility_list,'$.CREDIT_CollateralOnFacilityList_Item.CREDIT_CollateralOwnerName')    as name_of_the_collateral_owner                  
    ,get_json_object(tbl.credit_collatera_on_facility_list,'$.CREDIT_CollateralOnFacilityList_Item.CREDIT_ValueByIndpnAppraiser')  as collateral_value_by_independent_appraiser     
    ,get_json_object(tbl.credit_collatera_on_facility_list,'$.CREDIT_CollateralOnFacilityList_Item.CREDIT_ValueBySubmitter')       as collateral_value_by_ljk                      
    ,get_json_object(tbl.credit_collatera_on_facility_list,'$.CREDIT_CollateralOnFacilityList_Item.CREDIT_ValueAsNOJP')            as collateral_value_njop                        
    ,get_json_object(tbl.credit_collatera_on_facility_list,'$.CREDIT_CollateralOnFacilityList_Item.CREDIT_CollateralReg')          as register_code                                 
    ,get_json_object(tbl.credit_collatera_on_facility_list,'$.CREDIT_CollateralOnFacilityList_Item.CREDIT_CoverageProportion')     as percentage_of_paripasu   
from (
    select 
    t1.trace_id                 
    ,t1.credit_user_id          
    ,t1.platform_user_id        
    ,t1.flow_no                 
    ,t1.ktp_no                  
    ,t1.cbi_report_no  
    ,t1.cbi_status              
    ,t1.cbi_is_error 
    ,t1.report_update_time
    ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_InitialContractNumber') as initial_contract_no
    ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_CollateralOnFacility.CREDIT_CollateralOnFacilityList') as credit_collatera_on_facility_list
    from  risk.dwd_risk_id_uw_cbi_base_info_df t1
    lateral view explode(json_to_array(get_json_object(t1.slik_report,'$.result.BureauReport.CreditFacilityDetail.CREDIT_ActiveFacility_AsDebtor.CREDIT_ActiveFacility_AsDebtorList'))) tbl as credit_activafacilty_asdebtorlist
    where t1.grass_date ='${grass_date}'
) t2 
lateral view explode(json_to_array(credit_collatera_on_facility_list)) tbl as credit_collatera_on_facility_list



union all 
select 
    t2.trace_id                 
    ,t2.credit_user_id          
    ,t2.platform_user_id        
    ,t2.flow_no                 
    ,t2.ktp_no                  
    ,t2.cbi_report_no  
    ,t2.cbi_status              
    ,t2.cbi_is_error 
    ,t2.report_update_time
    ,t2.initial_contract_no
    ,get_json_object(tbl.credit_collatera_on_facility_list,'$.CREDIT_CollateralOnFacilityList_Item.CREDIT_CollateralType')         as collateral_type                               
    ,get_json_object(tbl.credit_collatera_on_facility_list,'$.CREDIT_CollateralOnFacilityList_Item.CREDIT_SecurityAssignmentType') as binding_type                                  
    ,get_json_object(tbl.credit_collatera_on_facility_list,'$.CREDIT_CollateralOnFacilityList_Item.CREDIT_CollateralOwnerName')    as name_of_the_collateral_owner                  
    ,get_json_object(tbl.credit_collatera_on_facility_list,'$.CREDIT_CollateralOnFacilityList_Item.CREDIT_ValueByIndpnAppraiser')  as collateral_value_by_independent_appraiser     
    ,get_json_object(tbl.credit_collatera_on_facility_list,'$.CREDIT_CollateralOnFacilityList_Item.CREDIT_ValueBySubmitter')       as collateral_value_by_ljk                      
    ,get_json_object(tbl.credit_collatera_on_facility_list,'$.CREDIT_CollateralOnFacilityList_Item.CREDIT_ValueAsNOJP')            as collateral_value_njop                        
    ,get_json_object(tbl.credit_collatera_on_facility_list,'$.CREDIT_CollateralOnFacilityList_Item.CREDIT_CollateralReg')          as register_code                                 
    ,get_json_object(tbl.credit_collatera_on_facility_list,'$.CREDIT_CollateralOnFacilityList_Item.CREDIT_CoverageProportion')     as percentage_of_paripasu   
from (
    select 
    t1.trace_id                 
    ,t1.credit_user_id          
    ,t1.platform_user_id        
    ,t1.flow_no                 
    ,t1.ktp_no                  
    ,t1.cbi_report_no  
    ,t1.cbi_status              
    ,t1.cbi_is_error 
    ,t1.report_update_time
    ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_InitialContractNumber') as initial_contract_no
    ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_CollateralOnFacility.CREDIT_CollateralOnFacilityList') as credit_collatera_on_facility_list
    from  risk.dwd_risk_id_uw_cbi_base_info_df t1
    lateral view explode(json_to_array(get_json_object(t1.slik_report,'$.result.BureauReport.CreditFacilityDetail.CREDIT_ClosedFacility_AsDebtor.CREDIT_ClosedFacility_AsDebtorList'))) tbl as credit_activafacilty_asdebtorlist
    where t1.grass_date ='${grass_date}'
) t2 
lateral view explode(json_to_array(credit_collatera_on_facility_list)) tbl as credit_collatera_on_facility_list
;


