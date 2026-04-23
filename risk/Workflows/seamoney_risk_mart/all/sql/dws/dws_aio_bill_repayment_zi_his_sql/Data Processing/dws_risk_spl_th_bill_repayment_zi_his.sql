--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-07-04
-- Theme Domain：       bill_id拉链表定期备份
-- Description:         DWS bill_id根据principal_os 做的拉链表
-- Data Granularity:    bill_id
-- 变更历史
--********************************************************************--

-- 涉及的region&product
-- SPL: ID TH PH MY SG BR VN 
-- SCL: ID TH
-- BCL: ID TH 
-- -- 初始化任务
insert overwrite table ${SCHEMA}.dws_risk_${product}_${region}_bill_repayment_zi_his partition(grass_date)
select 
t1.bill_id                              as bill_id
,t1.credit_user_id                      as credit_user_id
,t1.platform_user_id                    as platform_user_id
,t1.bill_term                           as bill_term
,t1.month_bill_time                     as month_bill_time
,t1.month_due_time                      as month_due_time
,t1.principal_repayable                 as principal_repayable
,t1.principal_os                        as principal_os
,t1.principal_refund                    as principal_refund       
,t1.principal_deduct                    as principal_deduct       
,t1.total_amount_repayable              as total_amount_repayable 
,t1.total_amount_refund                 as total_amount_refund    
,t1.total_amount_deduct                 as total_amount_deduct    
,t1.total_amount_os                     as total_amount_os   
,t1.start_date                          as start_date
,t1.end_date                            as end_date  
,current_date()                         as grass_date 
from risk.dws_risk_${product}_${region}_bill_repayment_zi_v2 t1 
;
