--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-07-04
-- Theme Domain：       instalment_id拉链表定期备份
-- Description:         DWS instalment_id根据principal_os 做的拉链表
-- Data Granularity:    instalment_id
-- 变更历史
--********************************************************************--

-- 涉及的region&product
-- SPL: ID TH PH MY SG BR VN 
-- SCL: ID TH
-- BCL: ID TH 
-- -- 初始化任务
insert overwrite table ${SCHEMA}.dws_risk_${product}_${region}_instalment_repayment_zi_his partition(grass_date)
select 
t1.instalment_id                             as instalment_id
,t1.loan_id                                  as loan_id
,t1.credit_user_id                           as credit_user_id
,t1.platform_user_id                         as platform_user_id
,t1.month_due_time                           as month_due_time
,t1.cur_term_num                             as cur_term_num
,t1.principal_repayable                      as principal_repayable
,t1.principal_os                             as principal_os
,t1.principal_refund                         as principal_refund
,t1.principal_deduct                         as principal_deduct
,t1.total_amount_repayable                   as total_amount_repayable
,t1.total_amount_refund                      as total_amount_refund   
,t1.total_amount_deduct                      as total_amount_deduct 
,t1.total_amount_os                          as total_amount_os
,t1.loan_disbursed_month                     as loan_disbursed_month     
,t1.first_instalment_due_time                as first_instalment_due_time
,t1.bill_due_day                             as bill_due_day             
,t1.new_repeat_user                          as new_repeat_user          
,t1.loan_tenure                              as loan_tenure              
,t1.loan_months_on_book                      as loan_months_on_book      
,t1.loan_months_after_due                    as loan_months_after_due    
,t1.loan_principal_repayable                 as loan_principal_repayable 
,t1.loan_principal_os                        as loan_principal_os
,t1.start_date                               as start_date
,t1.end_date                                 as end_date
,current_date()                              as grass_date 
from ${SCHEMA}.dws_risk_${product}_${region}_instalment_repayment_zi_v2 t1
