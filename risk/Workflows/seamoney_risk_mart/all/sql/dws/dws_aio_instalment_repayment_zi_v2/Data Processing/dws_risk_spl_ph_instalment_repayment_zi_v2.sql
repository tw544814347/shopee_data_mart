--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-01
-- Theme Domain：       instalment_id
-- Description:         DWS instalment_id根据principal_os 做的拉链表
-- Data Granularity:    instalment_id
--********************************************************************--

-- 涉及的region&product
-- SCL: PH MY
-- BCL: PH MY

-- -- 初始化任务
-- insert overwrite table ${SCHEMA}.dws_risk_${product}_${region}_instalmentrepayment_zi
-- select 
-- t1.instalment_id                                                                      as instalment_id
-- ,t1.loan_id                                                                           as loan_id
-- ,t1.credit_user_id                                                                    as credit_user_id
-- ,t1.platform_user_id                                                                  as platform_user_id
-- ,t1.month_bill_time                                                                   as month_bill_time
-- ,t1.month_due_time                                                                    as month_due_time
-- ,t1.principal_repayable                                                               as principal_repayable
-- ,t1.principal_os                                                                      as principal_os
-- ,'2021-12-01'                                                                         as start_date
-- ,'9999-12-31'                                                                         as end_date
-- from  credit_mart.dws_${product}_${region}_instalment_repayment_df t1 
-- where grass_date='2021-12-01' -- 初始化日期
-- -- 账单应还金额大于0 (剔除旧系统提前生成的未来账单)
-- and t1.principal_repayable>0 
-- ; 



-- 将前一天(grass_date-1)的9999-12-31的数据存储到date_sub('${grass_date},1') 的分区中
-- 如何获得(grass_date-1)的9999-12-31的数据
-- 1.不变(start_date - 9999-12-31)
-- 2.有变化(start_date,grass_date-1)
-- 3.有变化(grass_date,9999-12-31) 这部分不用,这部分是新增记录
-- 因此(grass_date-1)的9999-12-31的数据 包括1,2两部分,
-- 另外只保留60天retention dws_risk_${product}_${region}_instalment_repayment_9999_df
insert overwrite table  ${SCHEMA}.dws_risk_${product}_${region}_instalment_repayment_9999_df partition(grass_date)
select 
instalment_id                 
,loan_id                      
,credit_user_id               
,platform_user_id             
,month_due_time               
,cur_term_num                 
,principal_repayable          
,principal_os                 
,principal_refund             
,principal_deduct             
,total_amount_repayable       
,total_amount_refund          
,total_amount_deduct          
,total_amount_os              
,loan_disbursed_month         
,first_instalment_due_time    
,bill_due_day                 
,new_repeat_user              
,loan_tenure                  
,loan_months_on_book          
,loan_months_after_due        
,loan_principal_repayable     
,loan_principal_os            
,start_date             
,'9999-12-31' as end_date               
,date_sub('${grass_date}',1) as grass_date 
from ${SCHEMA}.dws_risk_${product}_${region}_instalment_repayment_zi_v2 t1
where start_date<'${grass_date}'
and end_date>=date_sub('${grass_date}',1) 
;

create or replace temporary view tmp_term_instalment_is_update_v2 as
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
,t3.loan_disbursed_month                     as loan_disbursed_month     
,t3.first_instalment_due_time                as first_instalment_due_time
,t3.bill_due_day                             as bill_due_day             
,t3.new_repeat_user                          as new_repeat_user          
,t3.loan_tenure                              as loan_tenure              
,t3.loan_months_on_book                      as loan_months_on_book      
,t3.loan_months_after_due                    as loan_months_after_due    
,t3.loan_principal_repayable                 as loan_principal_repayable 
,t3.loan_principal_os                        as loan_principal_os
-- 1-表示instalment_id为新增; 2-表示instalment_id的os没有更新; 3-表示instalment_id的os有更新
,case when t2.instalment_id is null then 1 
      when t2.instalment_id is not null and t1.principal_os = t2.principal_os then 2 
      when t2.instalment_id is not null and t1.principal_os <> t2.principal_os then 3
      end     as update_type
from credit_mart.dws_${product}_${region}_instalment_repayment_df t1 
left join (
select 
instalment_id
,loan_id
,credit_user_id
,principal_os
from credit_mart.dws_${product}_${region}_instalment_repayment_df
where grass_date = date_add('${grass_date}',-1)
and principal_repayable>0 
) t2 on t1.instalment_id = t2.instalment_id 
left join (
    select 
     loan_id                                                            as  loan_id          
    ,loan_disbursed_month                                               as  loan_disbursed_month
    ,first_instalment_due_time                                          as  first_instalment_due_time
    ,day(first_instalment_due_time)                                     as  bill_due_day       
    ,case when is_first_bill_loan = 1 then 'New' else 'Repeat' end      as  new_repeat_user      
    ,loan_tenure                                                        as  loan_tenure        
    ,months_on_book                                                     as  loan_months_on_book        
    ,months_after_due                                                   as  loan_months_after_due       
    ,principal_repayable                                                as  loan_principal_repayable    
    ,principal_os                                                       as  loan_principal_os 
    from  credit_mart.dws_${product}_${region}_loan_repayment_df
    where grass_date = '${grass_date}' 
) t3 on t1.loan_id = t3.loan_id
where t1.grass_date = '${grass_date}' 
-- 账单应还金额大于0 (剔除旧系统提前生成的未来账单)
and t1.principal_repayable>0 
;

-- 当日发生退款的loan
create or replace temporary view tmp_refund_loan_info_${product}_${region} as
select 
    loan_id              as loan_id,
    principal_os         as principal_os,
    grass_date           as grass_date
from credit_mart.dws_${product}_${region}_loan_repayment_df a 
WHERE a.grass_date = '${grass_date}'
and refund_time is not null 
and to_date(refund_time)>='${grass_date}'
-- and principal_refund>0
;

insert overwrite table ${SCHEMA}.dws_risk_${product}_${region}_instalment_repayment_zi_v2 partition(end_date)
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
-- 如果当天有退款,则将loan_principal_os 更新为退款之后的os, end_date<grass_date 的记录 loan_principal_os不用改变
,case when t2.loan_id is not null and t1.end_date>='${grass_date}' then t2.principal_os else t1.loan_principal_os  end      as loan_principal_os
,t1.start_date                               as start_date
,t1.end_date                                 as end_date
from (
-- 有更新的部分
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
,case when t2.instalment_id is not null and t1.end_date='9999-12-31' then date_add('${grass_date}',-1)
      else t1.end_date end                   as end_date                 
from ${SCHEMA}.dws_risk_${product}_${region}_instalment_repayment_9999_df t1
left join tmp_term_instalment_is_update_v2 t2 on t1.instalment_id = t2.instalment_id and t2.update_type = 3
where t1.grass_date=date_sub('${grass_date}',1)
-- 新增的数据 
union all 
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
,'${grass_date}'                             as start_date
,'9999-12-31'                                as end_date
from tmp_term_instalment_is_update_v2 t1
where update_type in(1,3)
) t1 
left join tmp_refund_loan_info_${product}_${region} t2 on t1.loan_id  = t2.loan_id 
;