--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-01
-- Theme Domain：       loan
-- Description:         DWS loan根据principal_os 做的拉链表
-- Data Granularity:    loan_id
--********************************************************************--

insert overwrite table ${SCHEMA}.dws_risk_${product}_${region}_loan_repayment_zi_his partition(grass_date)
-- 有更新的部分
select 
 t1.platform_user_id                      as platform_user_id
,t1.credit_user_id                        as credit_user_id
,t1.loan_id                               as loan_id          
,t1.loan_disbursed_month                  as loan_disbursed_month
,t1.first_instalment_due_time             as first_instalment_due_time
,t1.bill_due_day                          as bill_due_day       
,t1.new_repeat_user                       as new_repeat_user      
,t1.loan_tenure                           as loan_tenure        
,t1.months_on_book                        as months_on_book        
,t1.months_after_due                      as months_after_due 
,t1.clear_status                          as clear_status   
,t1.dpd_eod                               as dpd_eod      
,t1.principal_repayable                   as principal_repayable    
,t1.principal_os                          as principal_os 
,t1.start_date                            as start_date
,t1.end_date                              as end_date  
,current_date()                           as grass_date               
from risk.dws_risk_${product}_${region}_loan_repayment_zi_v2  t1 
;