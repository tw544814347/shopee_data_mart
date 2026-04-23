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


insert overwrite table risk.dwd_risk_id_uw_cbi_fasility_base_info_df partition(grass_date='${grass_date}')           

select 
    t3.trace_id                 
    ,t3.credit_user_id          
    ,t3.platform_user_id        
    ,t3.flow_no                 
    ,t3.ktp_no                  
    ,t3.cbi_report_no  
    ,t3.cbi_status              
    ,t3.cbi_is_error 
    ,t3.report_update_time
    ,t3.is_active                  
    ,t3.creditor_category          
    ,t3.credit_contract            
    ,cast(replace(t3.loan_amt,'.','') as decimal)          as loan_amt              
    ,cast(replace(t3.initial_loan_amt,'.','') as decimal)  as initial_loan_amt         
    ,cast(replace(t3.os_amt,'.','') as decimal)            as os_amt                     
    ,t3.branch                     
    ,t3.penalty                    
    ,t3.restructure_frequency      
    ,t3.overdue_freq               
    ,t3.credit_category            
    ,t3.usage_type                 
    ,t3.interest_type              
    ,t3.total_overdue_days         
    ,t3.debit_category             
    ,t3.description                
    ,t3.restructure_method_id      
    ,t3.bad_reason                 
    ,t3.economy_sector             
    ,t3.credit_nature              
    ,t3.initial_contract_no        
    ,t3.interest                   
    ,t3.credit_start_date          
    ,t3.initial_contract_date      
    ,t3.final_contract_date        
    ,t3.report_create_date         
    ,t3.due_date                   
    ,t3.condition_date             
    ,t3.bad_date                   
    ,t3.final_restructure_date     
    ,t3.overdue_interest           
    ,t3.overdue_principal          
    ,t3.collateral_list    
    ,max(case when rn=1 then t3.credit_year_month_data else null end) as year_month_1
    ,max(case when rn=2 then t3.credit_year_month_data else null end) as year_month_2 
    ,max(case when rn=3 then t3.credit_year_month_data else null end) as year_month_3 
    ,max(case when rn=4 then t3.credit_year_month_data else null end) as year_month_4 
    ,max(case when rn=5 then t3.credit_year_month_data else null end) as year_month_5 
    ,max(case when rn=6 then t3.credit_year_month_data else null end) as year_month_6 
    ,max(case when rn=7 then t3.credit_year_month_data else null end) as year_month_7 
    ,max(case when rn=8 then t3.credit_year_month_data else null end) as year_month_8 
    ,max(case when rn=9 then t3.credit_year_month_data else null end) as year_month_9 
    ,max(case when rn=10 then t3.credit_year_month_data else null end) as year_month_10 
    ,max(case when rn=11 then t3.credit_year_month_data else null end) as year_month_11
    ,max(case when rn=12 then t3.credit_year_month_data else null end) as year_month_12
    ,max(case when rn=13 then t3.credit_year_month_data else null end) as year_month_13
    ,max(case when rn=14 then t3.credit_year_month_data else null end) as year_month_14
    ,max(case when rn=15 then t3.credit_year_month_data else null end) as year_month_15
    ,max(case when rn=16 then t3.credit_year_month_data else null end) as year_month_16
    ,max(case when rn=17 then t3.credit_year_month_data else null end) as year_month_17
    ,max(case when rn=18 then t3.credit_year_month_data else null end) as year_month_18
    ,max(case when rn=19 then t3.credit_year_month_data else null end) as year_month_19
    ,max(case when rn=20 then t3.credit_year_month_data else null end) as year_month_20
    ,max(case when rn=21 then t3.credit_year_month_data else null end) as year_month_21
    ,max(case when rn=22 then t3.credit_year_month_data else null end) as year_month_22
    ,max(case when rn=23 then t3.credit_year_month_data else null end) as year_month_23
    ,max(case when rn=24 then t3.credit_year_month_data else null end) as year_month_24

    ,max(case when rn=1 then t3.credit_collect_ability else null end) as year_month_1_quality
    ,max(case when rn=2 then t3.credit_collect_ability else null end) as year_month_2_quality 
    ,max(case when rn=3 then t3.credit_collect_ability else null end) as year_month_3_quality 
    ,max(case when rn=4 then t3.credit_collect_ability else null end) as year_month_4_quality 
    ,max(case when rn=5 then t3.credit_collect_ability else null end) as year_month_5_quality 
    ,max(case when rn=6 then t3.credit_collect_ability else null end) as year_month_6_quality 
    ,max(case when rn=7 then t3.credit_collect_ability else null end) as year_month_7_quality 
    ,max(case when rn=8 then t3.credit_collect_ability else null end) as year_month_8_quality 
    ,max(case when rn=9 then t3.credit_collect_ability else null end) as year_month_9_quality 
    ,max(case when rn=10 then t3.credit_collect_ability else null end) as year_month_10_quality
    ,max(case when rn=11 then t3.credit_collect_ability else null end) as year_month_11_quality
    ,max(case when rn=12 then t3.credit_collect_ability else null end) as year_month_12_quality
    ,max(case when rn=13 then t3.credit_collect_ability else null end) as year_month_13_quality
    ,max(case when rn=14 then t3.credit_collect_ability else null end) as year_month_14_quality
    ,max(case when rn=15 then t3.credit_collect_ability else null end) as year_month_15_quality
    ,max(case when rn=16 then t3.credit_collect_ability else null end) as year_month_16_quality
    ,max(case when rn=17 then t3.credit_collect_ability else null end) as year_month_17_quality
    ,max(case when rn=18 then t3.credit_collect_ability else null end) as year_month_18_quality
    ,max(case when rn=19 then t3.credit_collect_ability else null end) as year_month_19_quality
    ,max(case when rn=20 then t3.credit_collect_ability else null end) as year_month_20_quality
    ,max(case when rn=21 then t3.credit_collect_ability else null end) as year_month_21_quality
    ,max(case when rn=22 then t3.credit_collect_ability else null end) as year_month_22_quality
    ,max(case when rn=23 then t3.credit_collect_ability else null end) as year_month_23_quality
    ,max(case when rn=24 then t3.credit_collect_ability else null end) as year_month_24_quality

    ,max(case when rn=1 then t3.credit_day_past_due else null end) as year_month_1_overdue_days
    ,max(case when rn=2 then t3.credit_day_past_due else null end) as year_month_2_overdue_days
    ,max(case when rn=3 then t3.credit_day_past_due else null end) as year_month_3_overdue_days
    ,max(case when rn=4 then t3.credit_day_past_due else null end) as year_month_4_overdue_days
    ,max(case when rn=5 then t3.credit_day_past_due else null end) as year_month_5_overdue_days
    ,max(case when rn=6 then t3.credit_day_past_due else null end) as year_month_6_overdue_days
    ,max(case when rn=7 then t3.credit_day_past_due else null end) as year_month_7_overdue_days
    ,max(case when rn=8 then t3.credit_day_past_due else null end) as year_month_8_overdue_days
    ,max(case when rn=9 then t3.credit_day_past_due else null end) as year_month_9_overdue_days
    ,max(case when rn=10 then t3.credit_day_past_due else null end) as year_month_10_overdue_days
    ,max(case when rn=11 then t3.credit_day_past_due else null end) as year_month_11_overdue_days
    ,max(case when rn=12 then t3.credit_day_past_due else null end) as year_month_12_overdue_days
    ,max(case when rn=13 then t3.credit_day_past_due else null end) as year_month_13_overdue_days
    ,max(case when rn=14 then t3.credit_day_past_due else null end) as year_month_14_overdue_days
    ,max(case when rn=15 then t3.credit_day_past_due else null end) as year_month_15_overdue_days
    ,max(case when rn=16 then t3.credit_day_past_due else null end) as year_month_16_overdue_days
    ,max(case when rn=17 then t3.credit_day_past_due else null end) as year_month_17_overdue_days
    ,max(case when rn=18 then t3.credit_day_past_due else null end) as year_month_18_overdue_days
    ,max(case when rn=19 then t3.credit_day_past_due else null end) as year_month_19_overdue_days
    ,max(case when rn=20 then t3.credit_day_past_due else null end) as year_month_20_overdue_days
    ,max(case when rn=21 then t3.credit_day_past_due else null end) as year_month_21_overdue_days
    ,max(case when rn=22 then t3.credit_day_past_due else null end) as year_month_22_overdue_days
    ,max(case when rn=23 then t3.credit_day_past_due else null end) as year_month_23_overdue_days
    ,max(case when rn=24 then t3.credit_day_past_due else null end) as year_month_24_overdue_days
from (
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
    ,t2.is_active                  
    ,t2.creditor_category          
    ,t2.credit_contract            
    ,t2.loan_amt                   
    ,t2.initial_loan_amt           
    ,t2.os_amt                     
    ,t2.branch                     
    ,t2.penalty                    
    ,t2.restructure_frequency      
    ,t2.overdue_freq               
    ,t2.credit_category            
    ,t2.usage_type                 
    ,t2.interest_type              
    ,t2.total_overdue_days         
    ,t2.debit_category             
    ,t2.description                
    ,t2.restructure_method_id      
    ,t2.bad_reason                 
    ,t2.economy_sector             
    ,t2.credit_nature              
    ,t2.initial_contract_no        
    ,t2.interest                   
    ,t2.credit_start_date          
    ,t2.initial_contract_date      
    ,t2.final_contract_date        
    ,t2.report_create_date         
    ,t2.due_date                   
    ,t2.condition_date             
    ,t2.bad_date                   
    ,t2.final_restructure_date     
    ,t2.overdue_interest           
    ,t2.overdue_principal          
    ,t2.collateral_list    
    ,t2.credit_payment_history_list 
    ,get_json_object(tbl.credit_payment_history,'$.CREDIT_PaymentHistoryList_Item.CREDIT_YearMonthData') as credit_year_month_data
    ,get_json_object(tbl.credit_payment_history,'$.CREDIT_PaymentHistoryList_Item.CREDIT_Collectability') as credit_collect_ability
    ,get_json_object(tbl.credit_payment_history,'$.CREDIT_PaymentHistoryList_Item.CREDIT_DayPastDue') as credit_day_past_due
    ,row_number() over(partition by t2.trace_id,t2.credit_user_id,t2.platform_user_id,t2.flow_no,t2.ktp_no,t2.cbi_report_no,t2.cbi_status,t2.cbi_is_error,t2.report_update_time,t2.is_active,t2.creditor_category,t2.credit_contract,t2.loan_amt,t2.initial_loan_amt,t2.os_amt,t2.branch,t2.penalty,t2.restructure_frequency,t2.overdue_freq,t2.credit_category,t2.usage_type,t2.interest_type,t2.total_overdue_days,t2.debit_category,t2.description,t2.restructure_method_id,t2.bad_reason,t2.economy_sector,t2.credit_nature,t2.initial_contract_no,t2.interest,t2.credit_start_date,t2.initial_contract_date,t2.final_contract_date,t2.report_create_date,t2.due_date,t2.condition_date,t2.bad_date,t2.final_restructure_date,t2.overdue_interest,t2.overdue_principal,t2.collateral_list order by from_unixtime(unix_timestamp(get_json_object(tbl.credit_payment_history,'$.CREDIT_PaymentHistoryList_Item.CREDIT_YearMonthData'),'MMM-yy')) asc ) rn 
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
        ,'True' as is_active                  
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_CreditorCategory')                                       as creditor_category          
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_CreditContract')                                         as credit_contract            
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_Limit')                                                  as loan_amt                   
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_InitialLimit')                                           as initial_loan_amt           
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_Outstanding')                                            as os_amt                     
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_Branch')                                                 as branch                     
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_Penalty')                                                as penalty                    
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_RetructureFrequency')                                    as restructure_frequency      
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_FreqOfArrears')                                          as overdue_freq               
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_CreditType')                                             as credit_category            
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_UsageType')                                              as usage_type                 
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_InterestType')                                           as interest_type              
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_DayPastDue')                                             as total_overdue_days         
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_DebtorCategory')                                         as debit_category             
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_Remarks')                                                as description                
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_RestructureMethode')                                     as restructure_method_id      
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_CauseOfDefault')                                         as bad_reason                 
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_EconomicSector')                                         as economy_sector             
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_CreditNature')                                           as credit_nature              
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_InitialContractNumber')                                  as initial_contract_no        
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_InterestRate')                                           as interest                   
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_InitialCreditDate')                                      as credit_start_date          
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_InitialContractDate')                                    as initial_contract_date      
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_LastContractDate')                                       as final_contract_date        
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_YearMonthData')                                          as report_create_date         
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_DueDate')                                                as due_date                   
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_ConditionDate')                                          as condition_date             
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_DefaultDate')                                            as bad_date                   
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_LastRestructureDate')                                    as final_restructure_date     
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_ArrearsOnInterest')                                      as overdue_interest           
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_ArrearsOnPrincipal')                                     as overdue_principal          
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_CollateralOnFacility.CREDIT_CollateralOnFacilityList')   as collateral_list    
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ActiveFacility_AsDebtorList_Item.CREDIT_PaymentHistory.CREDIT_PaymentHistoryList')               as credit_payment_history_list 
        from  risk.dwd_risk_id_uw_cbi_base_info_df t1 
        lateral view explode(json_to_array(get_json_object(t1.slik_report,'$.result.BureauReport.CreditFacilityDetail.CREDIT_ActiveFacility_AsDebtor.CREDIT_ActiveFacility_AsDebtorList'))) tbl as credit_activafacilty_asdebtorlist
        where t1.grass_date ='${grass_date}'
    ) t2 
    lateral view explode(json_to_array(credit_payment_history_list)) tbl as credit_payment_history
) t3 
group by 
t3.trace_id                 
    ,t3.credit_user_id          
    ,t3.platform_user_id        
    ,t3.flow_no                 
    ,t3.ktp_no                  
    ,t3.cbi_report_no  
    ,t3.cbi_status              
    ,t3.cbi_is_error 
    ,t3.report_update_time
    ,t3.is_active                  
    ,t3.creditor_category          
    ,t3.credit_contract            
    ,t3.loan_amt                   
    ,t3.initial_loan_amt           
    ,t3.os_amt                     
    ,t3.branch                     
    ,t3.penalty                    
    ,t3.restructure_frequency      
    ,t3.overdue_freq               
    ,t3.credit_category            
    ,t3.usage_type                 
    ,t3.interest_type              
    ,t3.total_overdue_days         
    ,t3.debit_category             
    ,t3.description                
    ,t3.restructure_method_id      
    ,t3.bad_reason                 
    ,t3.economy_sector             
    ,t3.credit_nature              
    ,t3.initial_contract_no        
    ,t3.interest                   
    ,t3.credit_start_date          
    ,t3.initial_contract_date      
    ,t3.final_contract_date        
    ,t3.report_create_date         
    ,t3.due_date                   
    ,t3.condition_date             
    ,t3.bad_date                   
    ,t3.final_restructure_date     
    ,t3.overdue_interest           
    ,t3.overdue_principal          
    ,t3.collateral_list  

union all 
select 
    t3.trace_id                 
    ,t3.credit_user_id          
    ,t3.platform_user_id        
    ,t3.flow_no                 
    ,t3.ktp_no                  
    ,t3.cbi_report_no  
    ,t3.cbi_status              
    ,t3.cbi_is_error 
    ,t3.report_update_time
    ,t3.is_active                  
    ,t3.creditor_category          
    ,t3.credit_contract            
    ,cast(replace(t3.loan_amt,'.','') as decimal)          as loan_amt              
    ,cast(replace(t3.initial_loan_amt,'.','') as decimal)  as initial_loan_amt         
    ,cast(replace(t3.os_amt,'.','') as decimal)            as os_amt                     
    ,t3.branch                     
    ,t3.penalty                    
    ,t3.restructure_frequency      
    ,t3.overdue_freq               
    ,t3.credit_category            
    ,t3.usage_type                 
    ,t3.interest_type              
    ,t3.total_overdue_days         
    ,t3.debit_category             
    ,t3.description                
    ,t3.restructure_method_id      
    ,t3.bad_reason                 
    ,t3.economy_sector             
    ,t3.credit_nature              
    ,t3.initial_contract_no        
    ,t3.interest                   
    ,t3.credit_start_date          
    ,t3.initial_contract_date      
    ,t3.final_contract_date        
    ,t3.report_create_date         
    ,t3.due_date                   
    ,t3.condition_date             
    ,t3.bad_date                   
    ,t3.final_restructure_date     
    ,t3.overdue_interest           
    ,t3.overdue_principal          
    ,t3.collateral_list    
    ,max(case when rn=1 then t3.credit_year_month_data else null end) as year_month_1
    ,max(case when rn=2 then t3.credit_year_month_data else null end) as year_month_2 
    ,max(case when rn=3 then t3.credit_year_month_data else null end) as year_month_3 
    ,max(case when rn=4 then t3.credit_year_month_data else null end) as year_month_4 
    ,max(case when rn=5 then t3.credit_year_month_data else null end) as year_month_5 
    ,max(case when rn=6 then t3.credit_year_month_data else null end) as year_month_6 
    ,max(case when rn=7 then t3.credit_year_month_data else null end) as year_month_7 
    ,max(case when rn=8 then t3.credit_year_month_data else null end) as year_month_8 
    ,max(case when rn=9 then t3.credit_year_month_data else null end) as year_month_9 
    ,max(case when rn=10 then t3.credit_year_month_data else null end) as year_month_10 
    ,max(case when rn=11 then t3.credit_year_month_data else null end) as year_month_11
    ,max(case when rn=12 then t3.credit_year_month_data else null end) as year_month_12
    ,max(case when rn=13 then t3.credit_year_month_data else null end) as year_month_13
    ,max(case when rn=14 then t3.credit_year_month_data else null end) as year_month_14
    ,max(case when rn=15 then t3.credit_year_month_data else null end) as year_month_15
    ,max(case when rn=16 then t3.credit_year_month_data else null end) as year_month_16
    ,max(case when rn=17 then t3.credit_year_month_data else null end) as year_month_17
    ,max(case when rn=18 then t3.credit_year_month_data else null end) as year_month_18
    ,max(case when rn=19 then t3.credit_year_month_data else null end) as year_month_19
    ,max(case when rn=20 then t3.credit_year_month_data else null end) as year_month_20
    ,max(case when rn=21 then t3.credit_year_month_data else null end) as year_month_21
    ,max(case when rn=22 then t3.credit_year_month_data else null end) as year_month_22
    ,max(case when rn=23 then t3.credit_year_month_data else null end) as year_month_23
    ,max(case when rn=24 then t3.credit_year_month_data else null end) as year_month_24

    ,max(case when rn=1 then t3.credit_collect_ability else null end) as year_month_1_quality
    ,max(case when rn=2 then t3.credit_collect_ability else null end) as year_month_2_quality 
    ,max(case when rn=3 then t3.credit_collect_ability else null end) as year_month_3_quality 
    ,max(case when rn=4 then t3.credit_collect_ability else null end) as year_month_4_quality 
    ,max(case when rn=5 then t3.credit_collect_ability else null end) as year_month_5_quality 
    ,max(case when rn=6 then t3.credit_collect_ability else null end) as year_month_6_quality 
    ,max(case when rn=7 then t3.credit_collect_ability else null end) as year_month_7_quality 
    ,max(case when rn=8 then t3.credit_collect_ability else null end) as year_month_8_quality 
    ,max(case when rn=9 then t3.credit_collect_ability else null end) as year_month_9_quality 
    ,max(case when rn=10 then t3.credit_collect_ability else null end) as year_month_10_quality
    ,max(case when rn=11 then t3.credit_collect_ability else null end) as year_month_11_quality
    ,max(case when rn=12 then t3.credit_collect_ability else null end) as year_month_12_quality
    ,max(case when rn=13 then t3.credit_collect_ability else null end) as year_month_13_quality
    ,max(case when rn=14 then t3.credit_collect_ability else null end) as year_month_14_quality
    ,max(case when rn=15 then t3.credit_collect_ability else null end) as year_month_15_quality
    ,max(case when rn=16 then t3.credit_collect_ability else null end) as year_month_16_quality
    ,max(case when rn=17 then t3.credit_collect_ability else null end) as year_month_17_quality
    ,max(case when rn=18 then t3.credit_collect_ability else null end) as year_month_18_quality
    ,max(case when rn=19 then t3.credit_collect_ability else null end) as year_month_19_quality
    ,max(case when rn=20 then t3.credit_collect_ability else null end) as year_month_20_quality
    ,max(case when rn=21 then t3.credit_collect_ability else null end) as year_month_21_quality
    ,max(case when rn=22 then t3.credit_collect_ability else null end) as year_month_22_quality
    ,max(case when rn=23 then t3.credit_collect_ability else null end) as year_month_23_quality
    ,max(case when rn=24 then t3.credit_collect_ability else null end) as year_month_24_quality

    ,max(case when rn=1 then t3.credit_day_past_due else null end) as year_month_1_overdue_days
    ,max(case when rn=2 then t3.credit_day_past_due else null end) as year_month_2_overdue_days
    ,max(case when rn=3 then t3.credit_day_past_due else null end) as year_month_3_overdue_days
    ,max(case when rn=4 then t3.credit_day_past_due else null end) as year_month_4_overdue_days
    ,max(case when rn=5 then t3.credit_day_past_due else null end) as year_month_5_overdue_days
    ,max(case when rn=6 then t3.credit_day_past_due else null end) as year_month_6_overdue_days
    ,max(case when rn=7 then t3.credit_day_past_due else null end) as year_month_7_overdue_days
    ,max(case when rn=8 then t3.credit_day_past_due else null end) as year_month_8_overdue_days
    ,max(case when rn=9 then t3.credit_day_past_due else null end) as year_month_9_overdue_days
    ,max(case when rn=10 then t3.credit_day_past_due else null end) as year_month_10_overdue_days
    ,max(case when rn=11 then t3.credit_day_past_due else null end) as year_month_11_overdue_days
    ,max(case when rn=12 then t3.credit_day_past_due else null end) as year_month_12_overdue_days
    ,max(case when rn=13 then t3.credit_day_past_due else null end) as year_month_13_overdue_days
    ,max(case when rn=14 then t3.credit_day_past_due else null end) as year_month_14_overdue_days
    ,max(case when rn=15 then t3.credit_day_past_due else null end) as year_month_15_overdue_days
    ,max(case when rn=16 then t3.credit_day_past_due else null end) as year_month_16_overdue_days
    ,max(case when rn=17 then t3.credit_day_past_due else null end) as year_month_17_overdue_days
    ,max(case when rn=18 then t3.credit_day_past_due else null end) as year_month_18_overdue_days
    ,max(case when rn=19 then t3.credit_day_past_due else null end) as year_month_19_overdue_days
    ,max(case when rn=20 then t3.credit_day_past_due else null end) as year_month_20_overdue_days
    ,max(case when rn=21 then t3.credit_day_past_due else null end) as year_month_21_overdue_days
    ,max(case when rn=22 then t3.credit_day_past_due else null end) as year_month_22_overdue_days
    ,max(case when rn=23 then t3.credit_day_past_due else null end) as year_month_23_overdue_days
    ,max(case when rn=24 then t3.credit_day_past_due else null end) as year_month_24_overdue_days
from (
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
    ,t2.is_active                  
    ,t2.creditor_category          
    ,t2.credit_contract            
    ,t2.loan_amt                   
    ,t2.initial_loan_amt           
    ,t2.os_amt                     
    ,t2.branch                     
    ,t2.penalty                    
    ,t2.restructure_frequency      
    ,t2.overdue_freq               
    ,t2.credit_category            
    ,t2.usage_type                 
    ,t2.interest_type              
    ,t2.total_overdue_days         
    ,t2.debit_category             
    ,t2.description                
    ,t2.restructure_method_id      
    ,t2.bad_reason                 
    ,t2.economy_sector             
    ,t2.credit_nature              
    ,t2.initial_contract_no        
    ,t2.interest                   
    ,t2.credit_start_date          
    ,t2.initial_contract_date      
    ,t2.final_contract_date        
    ,t2.report_create_date         
    ,t2.due_date                   
    ,t2.condition_date             
    ,t2.bad_date                   
    ,t2.final_restructure_date     
    ,t2.overdue_interest           
    ,t2.overdue_principal          
    ,t2.collateral_list    
    ,t2.credit_payment_history_list 
    ,get_json_object(tbl.credit_payment_history,'$.CREDIT_PaymentHistoryList_Item.CREDIT_YearMonthData') as credit_year_month_data
    ,get_json_object(tbl.credit_payment_history,'$.CREDIT_PaymentHistoryList_Item.CREDIT_Collectability') as credit_collect_ability
    ,get_json_object(tbl.credit_payment_history,'$.CREDIT_PaymentHistoryList_Item.CREDIT_DayPastDue') as credit_day_past_due
    ,row_number() over(partition by t2.trace_id,t2.credit_user_id,t2.platform_user_id,t2.flow_no,t2.ktp_no,t2.cbi_report_no,t2.cbi_status,t2.cbi_is_error,t2.report_update_time,t2.is_active,t2.creditor_category,t2.credit_contract,t2.loan_amt,t2.initial_loan_amt,t2.os_amt,t2.branch,t2.penalty,t2.restructure_frequency,t2.overdue_freq,t2.credit_category,t2.usage_type,t2.interest_type,t2.total_overdue_days,t2.debit_category,t2.description,t2.restructure_method_id,t2.bad_reason,t2.economy_sector,t2.credit_nature,t2.initial_contract_no,t2.interest,t2.credit_start_date,t2.initial_contract_date,t2.final_contract_date,t2.report_create_date,t2.due_date,t2.condition_date,t2.bad_date,t2.final_restructure_date,t2.overdue_interest,t2.overdue_principal,t2.collateral_list order by from_unixtime(unix_timestamp(get_json_object(tbl.credit_payment_history,'$.CREDIT_PaymentHistoryList_Item.CREDIT_YearMonthData'),'MMM-yy')) asc ) rn 
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
        ,'Flase' as is_active                  
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_CreditorCategory')                                       as creditor_category          
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_CreditContract')                                         as credit_contract            
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_Limit')                                                  as loan_amt                   
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_InitialLimit')                                           as initial_loan_amt           
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_Outstanding')                                            as os_amt                     
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_Branch')                                                 as branch                     
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_Penalty')                                                as penalty                    
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_RetructureFrequency')                                    as restructure_frequency      
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_FreqOfArrears')                                          as overdue_freq               
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_CreditType')                                             as credit_category            
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_UsageType')                                              as usage_type                 
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_InterestType')                                           as interest_type              
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_DayPastDue')                                             as total_overdue_days         
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_DebtorCategory')                                         as debit_category             
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_Remarks')                                                as description                
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_RestructureMethode')                                     as restructure_method_id      
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_CauseOfDefault')                                         as bad_reason                 
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_EconomicSector')                                         as economy_sector             
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_CreditNature')                                           as credit_nature              
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_InitialContractNumber')                                  as initial_contract_no        
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_InterestRate')                                           as interest                   
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_InitialCreditDate')                                      as credit_start_date          
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_InitialContractDate')                                    as initial_contract_date      
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_LastContractDate')                                       as final_contract_date        
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_YearMonthData')                                          as report_create_date         
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_DueDate')                                                as due_date                   
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_ConditionDate')                                          as condition_date             
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_DefaultDate')                                            as bad_date                   
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_LastRestructureDate')                                    as final_restructure_date     
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_ArrearsOnInterest')                                      as overdue_interest           
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_ArrearsOnPrincipal')                                     as overdue_principal          
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_CollateralOnFacility.CREDIT_CollateralOnFacilityList')   as collateral_list    
        ,get_json_object(tbl.credit_activafacilty_asdebtorlist,'$.CREDIT_ClosedFacility_AsDebtorList_Item.CREDIT_PaymentHistory.CREDIT_PaymentHistoryList')               as credit_payment_history_list 
        from  risk.dwd_risk_id_uw_cbi_base_info_df t1 
        lateral view explode(json_to_array(get_json_object(t1.slik_report,'$.result.BureauReport.CreditFacilityDetail.CREDIT_ClosedFacility_AsDebtor.CREDIT_ClosedFacility_AsDebtorList'))) tbl as credit_activafacilty_asdebtorlist
        where t1.grass_date ='${grass_date}'
    ) t2 
    lateral view explode(json_to_array(credit_payment_history_list)) tbl as credit_payment_history
) t3 
group by 
t3.trace_id                 
    ,t3.credit_user_id          
    ,t3.platform_user_id        
    ,t3.flow_no                 
    ,t3.ktp_no                  
    ,t3.cbi_report_no  
    ,t3.cbi_status              
    ,t3.cbi_is_error 
    ,t3.report_update_time
    ,t3.is_active                  
    ,t3.creditor_category          
    ,t3.credit_contract            
    ,t3.loan_amt                   
    ,t3.initial_loan_amt           
    ,t3.os_amt                     
    ,t3.branch                     
    ,t3.penalty                    
    ,t3.restructure_frequency      
    ,t3.overdue_freq               
    ,t3.credit_category            
    ,t3.usage_type                 
    ,t3.interest_type              
    ,t3.total_overdue_days         
    ,t3.debit_category             
    ,t3.description                
    ,t3.restructure_method_id      
    ,t3.bad_reason                 
    ,t3.economy_sector             
    ,t3.credit_nature              
    ,t3.initial_contract_no        
    ,t3.interest                   
    ,t3.credit_start_date          
    ,t3.initial_contract_date      
    ,t3.final_contract_date        
    ,t3.report_create_date         
    ,t3.due_date                   
    ,t3.condition_date             
    ,t3.bad_date                   
    ,t3.final_restructure_date     
    ,t3.overdue_interest           
    ,t3.overdue_principal          
    ,t3.collateral_list  
;

