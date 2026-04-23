--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-01
-- Theme Domain：       loan
-- Description:         DWS loan根据principal_os 做的拉链表
-- Data Granularity:    loan_id
-- update by zongyi.lu@shopee.com 2024-09-11 simple_disburse_month-> loan_disbursed_month
--********************************************************************--
-- TL: ID, MY, TH
-- -- 初始化任务
-- insert overwrite table ${SCHEMA}.dws_risk_${product}_${region}_loan_repayment_zi
-- select 
-- platform_user_id                                                    as  platform_user_id
-- ,credit_user_id                                                     as  credit_user_id
-- ,loan_id                                                            as  loan_id          
-- ,loan_disbursed_month                                               as  loan_disbursed_month
-- ,first_instalment_due_time                                          as  first_instalment_due_time
-- ,day(first_instalment_due_time)                                     as  bill_due_day       
-- ,case when is_first_bill_loan = 1 then 'New' else 'Repeat' end    as  new_repeat_user      
-- ,loan_tenure                                                        as  loan_tenure        
-- ,months_on_book                                                     as  months_on_book        
-- ,months_after_due                                                   as  months_after_due       
-- ,principal_repayable                                                as  principal_repayable    
-- ,principal_os                                                       as  principal_os                       
-- ,'2021-12-01'                                                       as  start_date
-- ,'9999-12-31'                                                       as  end_date
-- from  credit_mart.dws_${product}_${region}_loan_repayment_df t1 
-- where grass_date='2021-12-01' -- 初始化日期
-- ;  
 

-- insert overwrite table risk.dws_risk_${product}_${region}_loan_repayment_zi_his 
-- select 
--  platform_user_id                      as platform_user_id
-- ,credit_user_id                        as credit_user_id
-- ,loan_id                               as loan_id          
-- ,loan_disbursed_month                  as loan_disbursed_month
-- ,first_instalment_due_time             as first_instalment_due_time
-- ,bill_due_day                          as bill_due_day       
-- ,new_repeat_user                       as new_repeat_user      
-- ,loan_tenure                           as loan_tenure        
-- ,months_on_book                        as months_on_book        
-- ,months_after_due                      as months_after_due   
-- ,clear_status                          as clear_status          
-- ,dpd_eod                               as dpd_eod
-- ,principal_repayable                   as principal_repayable    
-- ,principal_os                          as principal_os              
-- ,start_date                            as start_date
-- ,end_date                              as end_date
-- from risk.dws_risk_${product}_${region}_loan_repayment_zi t1
-- where start_date <'${grass_date}'
-- group by 
--  platform_user_id          
-- ,credit_user_id            
-- ,loan_id                   
-- ,loan_disbursed_month      
-- ,first_instalment_due_time 
-- ,bill_due_day              
-- ,new_repeat_user           
-- ,loan_tenure               
-- ,months_on_book            
-- ,months_after_due  
-- ,clear_status      
-- ,dpd_eod     
-- ,principal_repayable       
-- ,principal_os              
-- ,start_date                
-- ,end_date                                
-- ;

-- 将前一天(grass_date-1)的9999-12-31的数据存储到date_sub('${grass_date},1') 的分区中
-- 如何获得(grass_date-1)的9999-12-31的数据
-- 1.不变(start_date - 9999-12-31)
-- 2.有变化(start_date,grass_date-1)
-- 3.有变化(grass_date,9999-12-31) 这部分不用,这部分是新增记录
-- 因此(grass_date-1)的9999-12-31的数据 包括1,2两部分,
-- 另外只保留60天retention dws_risk_${product}_${region}_instalment_repayment_9999_df
insert overwrite table  ${SCHEMA}.dws_risk_${product}_${region}_loan_repayment_9999_df partition(grass_date)
select 
platform_user_id              
,credit_user_id               
,loan_id                      
,loan_disbursed_month         
,first_instalment_due_time    
,bill_due_day                 
,new_repeat_user              
,loan_tenure                  
,months_on_book               
,months_after_due             
,clear_status                 
,dpd_eod                      
,principal_repayable          
,principal_os                                     
,start_date             
,'9999-12-31' as end_date  
,t1.simple_disburse_month
,t1.disburse_time                
,date_sub('${grass_date}',1) as grass_date 
from ${SCHEMA}.dws_risk_${product}_${region}_loan_repayment_zi_v2 t1
where start_date<'${grass_date}'
and end_date>=date_sub('${grass_date}',1) 
;

create or replace temporary view tmp_term_loan_is_update_${product}_${region}_v2 as
select 
t1.platform_user_id                                                    as  platform_user_id
,t1.credit_user_id                                                     as  credit_user_id
,t1.loan_id                                                            as  loan_id          
,t1.simple_disburse_month                                              as  loan_disbursed_month
,t1.first_instalment_due_time                                          as  first_instalment_due_time
,day(t1.first_instalment_due_time)                                     as  bill_due_day       
,case when t1.is_first_bill_loan = 1 then 'New' else 'Repeat' end      as  new_repeat_user      
,t1.loan_tenure                                                        as  loan_tenure        
,t1.months_on_book                                                     as  months_on_book        
,t1.months_after_due                                                   as  months_after_due 
,t1.clear_status                                                       as  clear_status   
,t1.dpd_eod                                                            as  dpd_eod        
,t1.principal_repayable                                                as  principal_repayable    
,t1.principal_os                                                       as  principal_os         
,t1.simple_disburse_month
,t1.disburse_time                 
-- 1-表示loan为新增; 2-表示loan的os没有更新; 3-表示loan的os有更新
,case when t2.loan_id is null then 1 
      when t2.loan_id is not null and t1.principal_os = t2.principal_os 
            and ((t1.dpd_eod = 0 and t2.dpd_eod = 0) or (t1.dpd_eod <> 0 and t2.dpd_eod <> 0 and t1.dpd_eod > t2.dpd_eod)) then 2 
      when (t2.loan_id is not null and t1.principal_os <> t2.principal_os) 
            or (t2.dpd_eod is not null and t1.dpd_eod < t2.dpd_eod) 
            or (t2.dpd_eod is not null and t1.dpd_eod <> 0 and t2.dpd_eod = 0) then 3
      end   as update_type
from credit_mart.dws_${product}_aio_${region}_loan_repayment_df t1 
left join (
select 
loan_id
,principal_os
,dpd_eod
from credit_mart.dws_${product}_aio_${region}_loan_repayment_df
where grass_date = date_add('${grass_date}',-1)
  and product_id = ${product_id}
-- and months_on_book > 0
) t2 on t1.loan_id = t2.loan_id 
where t1.grass_date = '${grass_date}' 
  and t1.product_id = ${product_id}
-- and t1.months_on_book > 0
;


insert overwrite table ${SCHEMA}.dws_risk_${product}_${region}_loan_repayment_zi_v2 partition(end_date)
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
,case when t2.update_type = 2 and t1.end_date='9999-12-31'then t2.dpd_eod 
      else t1.dpd_eod end                 as dpd_eod      
,t1.principal_repayable                   as principal_repayable    
,t1.principal_os                          as principal_os 
,t1.start_date                                                                        as start_date
,t1.simple_disburse_month
,t1.disburse_time   
,case when t2.loan_id is not null and t2.update_type = 3 and t1.end_date='9999-12-31' then date_add('${grass_date}',-1)
      else t1.end_date end                                                            as end_date                 
from ${SCHEMA}.dws_risk_${product}_${region}_loan_repayment_9999_df  t1 
left join tmp_term_loan_is_update_${product}_${region}_v2  t2 on t1.loan_id = t2.loan_id
where t1.grass_date = date_add('${grass_date}',-1)
-- 新增的loan_id数据 
union all 
select 
t1.platform_user_id                       as platform_user_id
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
,'${grass_date}'                          as start_date
,t1.simple_disburse_month
,t1.disburse_time   
,'9999-12-31'                             as end_date
from tmp_term_loan_is_update_${product}_${region}_v2  t1
where update_type in(1,3)
;