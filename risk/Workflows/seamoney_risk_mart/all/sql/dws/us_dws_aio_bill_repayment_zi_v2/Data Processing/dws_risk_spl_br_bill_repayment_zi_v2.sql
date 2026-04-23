--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-01
-- Theme Domain：       bill_id
-- Description:         DWS bill_id根据principal_os 做的拉链表
-- Data Granularity:    bill_id 
--********************************************************************--
 
-- 涉及的region&product
-- SPL: ID TH PH MY SG BR VN 
-- SCL: ID TH
-- BCL: ID TH 
-- -- 初始化任务
-- insert overwrite table ${SCHEMA}.dws_risk_${product}_${region}_bill_repayment_zi
-- select 
-- t1.bill_id                                                                            as bill_id
-- ,t1.credit_user_id                                                                    as credit_user_id
-- ,t1.platform_user_id                                                                  as platform_user_id
-- ,t1.bill_term                                                                         as bill_term
-- ,t1.month_bill_time                                                                   as month_bill_time
-- ,t1.month_due_time                                                                    as month_due_time
-- ,t1.principal_repayable                                                               as principal_repayable
-- ,t1.principal_os                                                                      as principal_os
-- ,'2021-12-01'                                                                         as start_date
-- ,'9999-12-31'                                                                         as end_date
-- from  credit_mart.dws_${product}_${region}_bill_repayment_df t1 
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
-- 另外只保留60天retention dws_risk_${product}_${region}_bill_repayment_9999_df
insert overwrite table  ${SCHEMA}.dws_risk_${product}_${region}_bill_repayment_9999_df partition(grass_date)
select 
bill_id                 
,credit_user_id         
,platform_user_id       
,bill_term              
,month_bill_time        
,month_due_time         
,principal_repayable    
,principal_os           
,principal_refund       
,principal_deduct       
,total_amount_repayable 
,total_amount_refund    
,total_amount_deduct    
,total_amount_os        
,start_date             
,'9999-12-31' as end_date               
,date_sub('${grass_date}',1) as grass_date 
from ${SCHEMA}.dws_risk_${product}_${region}_bill_repayment_zi_v2
where start_date<'${grass_date}'
and end_date>=date_sub('${grass_date}',1) 
group by bill_id                 
,credit_user_id         
,platform_user_id       
,bill_term              
,month_bill_time        
,month_due_time         
,principal_repayable    
,principal_os           
,principal_refund       
,principal_deduct       
,total_amount_repayable 
,total_amount_refund    
,total_amount_deduct    
,total_amount_os        
,start_date 
;

create or replace temporary view tmp_term_bill_is_update_v2 as
select 
t1.bill_id                                                                            as bill_id
,t1.credit_user_id                                                                    as credit_user_id
,t1.platform_user_id                                                                  as platform_user_id
,t1.bill_term                                                                         as bill_term
,t1.month_bill_time                                                                   as month_bill_time
,t1.month_due_time                                                                    as month_due_time
,t1.principal_repayable                                                               as principal_repayable
,t1.principal_os                                                                      as principal_os
,t1.principal_refund                                                                  as principal_refund       
,t1.principal_deduct                                                                  as principal_deduct       
,t1.total_amount_repayable                                                            as total_amount_repayable 
,t1.total_amount_refund                                                               as total_amount_refund    
,t1.total_amount_deduct                                                               as total_amount_deduct    
,t1.total_amount_os                                                                   as total_amount_os        
-- 1-表示bill为新增; 2-表示bill的os没有更新; 3-表示bill的os有更新
,case when t2.bill_id is null then 1 
      when t2.bill_id is not null and t1.principal_os = t2.principal_os then 2 
      when t2.bill_id is not null and t1.principal_os <> t2.principal_os then 3
      end     as update_type
from credit_mart.dws_${product}_${region}_bill_repayment_df t1 
left join (
select 
bill_id
,credit_user_id
,bill_term
,principal_os
from credit_mart.dws_${product}_${region}_bill_repayment_df
where grass_date = date_add('${grass_date}',-1)
and principal_repayable>0 
) t2 on t1.bill_id = t2.bill_id 
and t1.bill_term = t2.bill_term 
where t1.grass_date = '${grass_date}' 
-- 账单应还金额大于0 (剔除旧系统提前生成的未来账单)
and t1.principal_repayable>0 
;

insert overwrite table ${SCHEMA}.dws_risk_${product}_${region}_bill_repayment_zi_v2 partition(end_date)
-- 有更新的部分 
select 
t1.bill_id                                                                            as bill_id
,t1.credit_user_id                                                                    as credit_user_id
,t1.platform_user_id                                                                  as platform_user_id
,t1.bill_term                                                                         as bill_term
,t1.month_bill_time                                                                   as month_bill_time
,t1.month_due_time                                                                    as month_due_time
,t1.principal_repayable                                                               as principal_repayable
,t1.principal_os                                                                      as principal_os
,t1.principal_refund                                                                  as principal_refund       
,t1.principal_deduct                                                                  as principal_deduct       
,t1.total_amount_repayable                                                            as total_amount_repayable 
,t1.total_amount_refund                                                               as total_amount_refund    
,t1.total_amount_deduct                                                               as total_amount_deduct    
,t1.total_amount_os                                                                   as total_amount_os   
,t1.start_date                                                                        as start_date
,case when t2.bill_id is not null and t1.end_date='9999-12-31' then date_add('${grass_date}',-1)
      else t1.end_date end                                                            as end_date                 
from ${SCHEMA}.dws_risk_${product}_${region}_bill_repayment_9999_df t1 
left join tmp_term_bill_is_update_v2 t2 on t1.bill_id = t2.bill_id and t1.bill_term = t2.bill_term and t2.update_type = 3
where t1.grass_date=date_sub('${grass_date}',1)
-- 新增的bill数据 
union all 
select 
t1.bill_id                                                                            as bill_id
,t1.credit_user_id                                                                    as credit_user_id
,t1.platform_user_id                                                                  as platform_user_id
,t1.bill_term                                                                         as bill_term
,t1.month_bill_time                                                                   as month_bill_time
,t1.month_due_time                                                                    as month_due_time
,t1.principal_repayable                                                               as principal_repayable
,t1.principal_os                                                                      as principal_os
,t1.principal_refund                                                                  as principal_refund       
,t1.principal_deduct                                                                  as principal_deduct       
,t1.total_amount_repayable                                                            as total_amount_repayable 
,t1.total_amount_refund                                                               as total_amount_refund    
,t1.total_amount_deduct                                                               as total_amount_deduct    
,t1.total_amount_os                                                                   as total_amount_os   
,'${grass_date}'                                                                      as start_date
,'9999-12-31'                                                                         as end_date
from tmp_term_bill_is_update_v2 t1
where update_type in(1,3)
;