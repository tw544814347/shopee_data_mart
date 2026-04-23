--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2023-11-23T14:00:00
-- Theme Domain：       bill_dpd
-- Description:         bill_id 粒度的dpd统计数据
-- Data Granularity:    bill_id
-- 变更历史：
--********************************************************************--

--  is_rollover 用户在当期bill之前是否还存在未还清的bill(1.截止目前还没还 2.历史bill还清时间>当前bil的duetime )
--  case when (history_bill_term < bill_term) and (history_clear_time is null or history_clear_time > month_due_time)then 1 else 0 end
create or replace temporary view tmp_credit_user_id_his_rollover_bill_${product}_${region} as 
select 
t1.credit_user_id   as credit_user_id
,t1.bill_term       as bill_term
,max(case  when t1.clear_time is not null and t1.clear_time < t1.month_bill_time then -10	-- early repaid
       when t1.clear_time is null then datediff('${grass_date}',to_date(t1.month_due_time))+2
       else datediff(to_date(t1.clear_time),to_date(t1.month_due_time) )+1
    end)             as max_dpd
,count(1)           as is_rollover
from credit_mart.dws_${product}_aio_${region}_bill_repayment_df t1
join (
    select 
    credit_user_id 
    ,bill_term 
    ,month_due_time
    ,clear_time
    from credit_mart.dws_${product}_aio_${region}_bill_repayment_df
    where grass_date ='${grass_date}'
    and principal_repayable>0
    and product_id = ${product_id}
) t2 on t1.credit_user_id = t2.credit_user_id
where t1.grass_date  = '${grass_date}'
and t1.principal_repayable > 0
and t1.bill_term > t2.bill_term 
and t1.product_id = ${product_id}
and (t2.clear_time is null or t2.clear_time > t1.month_due_time)
group by t1.credit_user_id
,t1.bill_term
;

--  bill的类维度数据
create or replace temporary view tmp_credit_user_id_bill_info_${product}_${region} as
select 
credit_user_id 
,bill_term 
,bill_id 
,max_dpd_eod as  max_dpd -- 2025-05-14 上线MX地区任务时, credit_mart已下线该字段，查询后没有用户访问这个字段，改成dpd_eod了
,max_dpd_eod
,principal_repayable
,principal_refund
,principal_deduct
,total_amount_repayable
,total_amount_refund   
,total_amount_deduct   
from credit_mart.dws_${product}_aio_${region}_bill_repayment_df t1 
where t1.grass_date  = '${grass_date}'
and t1.product_id = ${product_id}
;

-- 计算dpd
insert overwrite table ${SCHEMA}.ads_risk_${product}_${region}_bill_dpd_df partition(grass_date)
select  
t1.credit_user_id
,t1.platform_user_id
,t1.bill_id
,t1.bill_term
,case when day(t1.month_due_time)<= 15 then date_format(add_months(t1.month_due_time,-1),'yyyyMM') else date_format(t1.month_due_time,'yyyyMM') end  as bill_term_new
,to_date(t1.month_bill_time)  as bill_date 
,to_date(t1.month_due_time)   as due_date
,case when t3.credit_user_id is not null and t3.total_amount_repayable - t3.total_amount_refund - t3.total_amount_deduct>0 then 1 else 0 end has_new_bill
,case when t3.credit_user_id is not null then t3.max_dpd else 0 end      as max_dpd
,case when t3.credit_user_id is not null then t3.max_dpd_eod else 0 end  as max_dpd_eod
,case when t2.credit_user_id is not null then t2.is_rollover else 0 end  as is_rollover
,case when t3.credit_user_id is not null then t3.principal_repayable else 0 end     as principal_repayable
,case when t3.credit_user_id is not null then t3.principal_refund  else 0 end       as principal_refund       
,case when t3.credit_user_id is not null then t3.principal_deduct  else 0 end       as principal_deduct       
,case when t3.credit_user_id is not null then t3.total_amount_repayable else 0 end  as total_amount_repayable 
,case when t3.credit_user_id is not null then t3.total_amount_refund else 0 end     as total_amount_refund    
,case when t3.credit_user_id is not null then t3.total_amount_deduct else 0 end     as total_amount_deduct    
,sum(case when date_add(month_due_time,-11)>=t1.start_date and date_add(month_due_time,-11)<=t1.end_date and date_add(month_due_time,-11)<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd9_minus
,sum(case when date_add(month_due_time,-10)>=t1.start_date and date_add(month_due_time,-10)<=t1.end_date and date_add(month_due_time,-10)<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd8_minus
,sum(case when date_add(month_due_time,-9 )>=t1.start_date and date_add(month_due_time,-9 )<=t1.end_date and date_add(month_due_time,-9 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd7_minus
,sum(case when date_add(month_due_time,-8 )>=t1.start_date and date_add(month_due_time,-8 )<=t1.end_date and date_add(month_due_time,-8 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd6_minus
,sum(case when date_add(month_due_time,-7 )>=t1.start_date and date_add(month_due_time,-7 )<=t1.end_date and date_add(month_due_time,-7 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd5_minus
,sum(case when date_add(month_due_time,-6 )>=t1.start_date and date_add(month_due_time,-6 )<=t1.end_date and date_add(month_due_time,-6 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd4_minus
,sum(case when date_add(month_due_time,-5 )>=t1.start_date and date_add(month_due_time,-5 )<=t1.end_date and date_add(month_due_time,-5 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd3_minus
,sum(case when date_add(month_due_time,-4 )>=t1.start_date and date_add(month_due_time,-4 )<=t1.end_date and date_add(month_due_time,-4 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd2_minus
,sum(case when date_add(month_due_time,-3 )>=t1.start_date and date_add(month_due_time,-3 )<=t1.end_date and date_add(month_due_time,-3 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd1_minus
,sum(case when date_add(month_due_time,-2 )>=t1.start_date and date_add(month_due_time,-2 )<=t1.end_date and date_add(month_due_time,-2 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd0
,sum(case when date_add(month_due_time,-1 )>=t1.start_date and date_add(month_due_time,-1 )<=t1.end_date and date_add(month_due_time,-1 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd1 
,sum(case when date_add(month_due_time,-0 )>=t1.start_date and date_add(month_due_time,-0 )<=t1.end_date and date_add(month_due_time,-0 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd2 
,sum(case when date_add(month_due_time,1  )>=t1.start_date and date_add(month_due_time,1  )<=t1.end_date and date_add(month_due_time,1  )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd3 
,sum(case when date_add(month_due_time,2  )>=t1.start_date and date_add(month_due_time,2  )<=t1.end_date and date_add(month_due_time,2  )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd4 
,sum(case when date_add(month_due_time,3  )>=t1.start_date and date_add(month_due_time,3  )<=t1.end_date and date_add(month_due_time,3  )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd5 
,sum(case when date_add(month_due_time,4  )>=t1.start_date and date_add(month_due_time,4  )<=t1.end_date and date_add(month_due_time,4  )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd6 
,sum(case when date_add(month_due_time,5  )>=t1.start_date and date_add(month_due_time,5  )<=t1.end_date and date_add(month_due_time,5  )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd7 
,sum(case when date_add(month_due_time,6  )>=t1.start_date and date_add(month_due_time,6  )<=t1.end_date and date_add(month_due_time,6  )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd8 
,sum(case when date_add(month_due_time,7  )>=t1.start_date and date_add(month_due_time,7  )<=t1.end_date and date_add(month_due_time,7  )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd9 
,sum(case when date_add(month_due_time,8  )>=t1.start_date and date_add(month_due_time,8  )<=t1.end_date and date_add(month_due_time,8  )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd10
,sum(case when date_add(month_due_time,9  )>=t1.start_date and date_add(month_due_time,9  )<=t1.end_date and date_add(month_due_time,9  )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd11
,sum(case when date_add(month_due_time,10 )>=t1.start_date and date_add(month_due_time,10 )<=t1.end_date and date_add(month_due_time,10 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd12
,sum(case when date_add(month_due_time,11 )>=t1.start_date and date_add(month_due_time,11 )<=t1.end_date and date_add(month_due_time,11 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd13
,sum(case when date_add(month_due_time,12 )>=t1.start_date and date_add(month_due_time,12 )<=t1.end_date and date_add(month_due_time,12 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd14
,sum(case when date_add(month_due_time,13 )>=t1.start_date and date_add(month_due_time,13 )<=t1.end_date and date_add(month_due_time,13 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd15
,sum(case when date_add(month_due_time,14 )>=t1.start_date and date_add(month_due_time,14 )<=t1.end_date and date_add(month_due_time,14 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd16
,sum(case when date_add(month_due_time,15 )>=t1.start_date and date_add(month_due_time,15 )<=t1.end_date and date_add(month_due_time,15 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd17
,sum(case when date_add(month_due_time,16 )>=t1.start_date and date_add(month_due_time,16 )<=t1.end_date and date_add(month_due_time,16 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd18
,sum(case when date_add(month_due_time,17 )>=t1.start_date and date_add(month_due_time,17 )<=t1.end_date and date_add(month_due_time,17 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd19
,sum(case when date_add(month_due_time,18 )>=t1.start_date and date_add(month_due_time,18 )<=t1.end_date and date_add(month_due_time,18 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd20
,sum(case when date_add(month_due_time,19 )>=t1.start_date and date_add(month_due_time,19 )<=t1.end_date and date_add(month_due_time,19 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd21
,sum(case when date_add(month_due_time,20 )>=t1.start_date and date_add(month_due_time,20 )<=t1.end_date and date_add(month_due_time,20 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd22
,sum(case when date_add(month_due_time,21 )>=t1.start_date and date_add(month_due_time,21 )<=t1.end_date and date_add(month_due_time,21 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd23
,sum(case when date_add(month_due_time,22 )>=t1.start_date and date_add(month_due_time,22 )<=t1.end_date and date_add(month_due_time,22 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd24
,sum(case when date_add(month_due_time,23 )>=t1.start_date and date_add(month_due_time,23 )<=t1.end_date and date_add(month_due_time,23 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd25
,sum(case when date_add(month_due_time,24 )>=t1.start_date and date_add(month_due_time,24 )<=t1.end_date and date_add(month_due_time,24 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd26
,sum(case when date_add(month_due_time,25 )>=t1.start_date and date_add(month_due_time,25 )<=t1.end_date and date_add(month_due_time,25 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd27
,sum(case when date_add(month_due_time,26 )>=t1.start_date and date_add(month_due_time,26 )<=t1.end_date and date_add(month_due_time,26 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd28
,sum(case when date_add(month_due_time,27 )>=t1.start_date and date_add(month_due_time,27 )<=t1.end_date and date_add(month_due_time,27 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd29
,sum(case when date_add(month_due_time,28 )>=t1.start_date and date_add(month_due_time,28 )<=t1.end_date and date_add(month_due_time,28 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd30
,sum(case when date_add(month_due_time,29 )>=t1.start_date and date_add(month_due_time,29 )<=t1.end_date and date_add(month_due_time,29 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd31
,sum(case when date_add(month_due_time,59 )>=t1.start_date and date_add(month_due_time,59 )<=t1.end_date and date_add(month_due_time,59 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd60
,sum(case when date_add(month_due_time,89 )>=t1.start_date and date_add(month_due_time,89 )<=t1.end_date and date_add(month_due_time,89 )<='${grass_date}'then t1.principal_os else 0 end ) as principal_os_dpd90
,sum(case when date_add(month_due_time,119 )>=t1.start_date and date_add(month_due_time,119 )<=t1.end_date and date_add(month_due_time,119 )<='${grass_date}' then t1.principal_os else 0 end ) as principal_os_dpd120
,sum(case when date_add(month_due_time,149 )>=t1.start_date and date_add(month_due_time,149 )<=t1.end_date and date_add(month_due_time,149 )<='${grass_date}' then t1.principal_os else 0 end ) as principal_os_dpd150
,sum(case when date_add(month_due_time,179 )>=t1.start_date and date_add(month_due_time,179 )<=t1.end_date and date_add(month_due_time,179 )<='${grass_date}' then t1.principal_os else 0 end ) as principal_os_dpd180
,sum(case when date_add(month_due_time,-1 )>=t1.start_date and date_add(month_due_time,-1 )<=t1.end_date and date_add(month_due_time,-1 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd1 
,sum(case when date_add(month_due_time,-0 )>=t1.start_date and date_add(month_due_time,-0 )<=t1.end_date and date_add(month_due_time,-0 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd2 
,sum(case when date_add(month_due_time,1  )>=t1.start_date and date_add(month_due_time,1  )<=t1.end_date and date_add(month_due_time,1  )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd3 
,sum(case when date_add(month_due_time,2  )>=t1.start_date and date_add(month_due_time,2  )<=t1.end_date and date_add(month_due_time,2  )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd4 
,sum(case when date_add(month_due_time,3  )>=t1.start_date and date_add(month_due_time,3  )<=t1.end_date and date_add(month_due_time,3  )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd5 
,sum(case when date_add(month_due_time,4  )>=t1.start_date and date_add(month_due_time,4  )<=t1.end_date and date_add(month_due_time,4  )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd6 
,sum(case when date_add(month_due_time,5  )>=t1.start_date and date_add(month_due_time,5  )<=t1.end_date and date_add(month_due_time,5  )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd7 
,sum(case when date_add(month_due_time,6  )>=t1.start_date and date_add(month_due_time,6  )<=t1.end_date and date_add(month_due_time,6  )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd8 
,sum(case when date_add(month_due_time,7  )>=t1.start_date and date_add(month_due_time,7  )<=t1.end_date and date_add(month_due_time,7  )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd9 
,sum(case when date_add(month_due_time,8  )>=t1.start_date and date_add(month_due_time,8  )<=t1.end_date and date_add(month_due_time,8  )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd10
,sum(case when date_add(month_due_time,9  )>=t1.start_date and date_add(month_due_time,9  )<=t1.end_date and date_add(month_due_time,9  )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd11
,sum(case when date_add(month_due_time,10 )>=t1.start_date and date_add(month_due_time,10 )<=t1.end_date and date_add(month_due_time,10 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd12
,sum(case when date_add(month_due_time,11 )>=t1.start_date and date_add(month_due_time,11 )<=t1.end_date and date_add(month_due_time,11 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd13
,sum(case when date_add(month_due_time,12 )>=t1.start_date and date_add(month_due_time,12 )<=t1.end_date and date_add(month_due_time,12 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd14
,sum(case when date_add(month_due_time,13 )>=t1.start_date and date_add(month_due_time,13 )<=t1.end_date and date_add(month_due_time,13 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd15
,sum(case when date_add(month_due_time,14 )>=t1.start_date and date_add(month_due_time,14 )<=t1.end_date and date_add(month_due_time,14 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd16
,sum(case when date_add(month_due_time,15 )>=t1.start_date and date_add(month_due_time,15 )<=t1.end_date and date_add(month_due_time,15 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd17
,sum(case when date_add(month_due_time,16 )>=t1.start_date and date_add(month_due_time,16 )<=t1.end_date and date_add(month_due_time,16 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd18
,sum(case when date_add(month_due_time,17 )>=t1.start_date and date_add(month_due_time,17 )<=t1.end_date and date_add(month_due_time,17 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd19
,sum(case when date_add(month_due_time,18 )>=t1.start_date and date_add(month_due_time,18 )<=t1.end_date and date_add(month_due_time,18 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd20
,sum(case when date_add(month_due_time,19 )>=t1.start_date and date_add(month_due_time,19 )<=t1.end_date and date_add(month_due_time,19 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd21
,sum(case when date_add(month_due_time,20 )>=t1.start_date and date_add(month_due_time,20 )<=t1.end_date and date_add(month_due_time,20 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd22
,sum(case when date_add(month_due_time,21 )>=t1.start_date and date_add(month_due_time,21 )<=t1.end_date and date_add(month_due_time,21 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd23
,sum(case when date_add(month_due_time,22 )>=t1.start_date and date_add(month_due_time,22 )<=t1.end_date and date_add(month_due_time,22 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd24
,sum(case when date_add(month_due_time,23 )>=t1.start_date and date_add(month_due_time,23 )<=t1.end_date and date_add(month_due_time,23 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd25
,sum(case when date_add(month_due_time,24 )>=t1.start_date and date_add(month_due_time,24 )<=t1.end_date and date_add(month_due_time,24 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd26
,sum(case when date_add(month_due_time,25 )>=t1.start_date and date_add(month_due_time,25 )<=t1.end_date and date_add(month_due_time,25 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd27
,sum(case when date_add(month_due_time,26 )>=t1.start_date and date_add(month_due_time,26 )<=t1.end_date and date_add(month_due_time,26 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd28
,sum(case when date_add(month_due_time,27 )>=t1.start_date and date_add(month_due_time,27 )<=t1.end_date and date_add(month_due_time,27 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd29
,sum(case when date_add(month_due_time,28 )>=t1.start_date and date_add(month_due_time,28 )<=t1.end_date and date_add(month_due_time,28 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd30
,sum(case when date_add(month_due_time,29 )>=t1.start_date and date_add(month_due_time,29 )<=t1.end_date and date_add(month_due_time,29 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd31
,sum(case when date_add(month_due_time,59 )>=t1.start_date and date_add(month_due_time,59 )<=t1.end_date and date_add(month_due_time,59 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd61
,sum(case when date_add(month_due_time,89 )>=t1.start_date and date_add(month_due_time,89 )<=t1.end_date and date_add(month_due_time,89 )<='${grass_date}'then t1.total_amount_os else 0 end ) as total_amount_os_dpd91
,sum(case when date_add(month_due_time,119 )>=t1.start_date and date_add(month_due_time,119 )<=t1.end_date and date_add(month_due_time,119 )<='${grass_date}' then t1.total_amount_os else 0 end ) as total_amount_os_dpd121
,sum(case when date_add(month_due_time,149 )>=t1.start_date and date_add(month_due_time,149 )<=t1.end_date and date_add(month_due_time,149 )<='${grass_date}' then t1.total_amount_os else 0 end ) as total_amount_os_dpd151
,sum(case when date_add(month_due_time,179 )>=t1.start_date and date_add(month_due_time,179 )<=t1.end_date and date_add(month_due_time,179 )<='${grass_date}' then t1.total_amount_os else 0 end ) as total_amount_os_dpd181
,'${grass_date}' as grass_date 
from ${SCHEMA}.dws_risk_${product}_${region}_bill_repayment_zi t1 
left join tmp_credit_user_id_his_rollover_bill_${product}_${region} t2 on t1.credit_user_id = t2.credit_user_id and t1.bill_term = t2.bill_term
left join tmp_credit_user_id_bill_info_${product}_${region} t3  on t1.credit_user_id = t3.credit_user_id and t1.bill_term = t3.bill_term and t1.bill_id = t3.bill_id 
where to_date(t1.month_bill_time)<='${grass_date}'
and start_date <='${grass_date}'
group by t1.credit_user_id
,t1.platform_user_id
,t1.bill_id
,t1.bill_term
,case when day(t1.month_due_time)<= 15 then date_format(add_months(t1.month_due_time,-1),'yyyyMM') else date_format(t1.month_due_time,'yyyyMM') end
,to_date(t1.month_bill_time) 
,to_date(t1.month_due_time) 
,case when t3.credit_user_id is not null and t3.total_amount_repayable - t3.total_amount_refund - t3.total_amount_deduct>0 then 1 else 0 end
,case when t3.credit_user_id is not null then t3.max_dpd else 0 end      
,case when t3.credit_user_id is not null then t3.max_dpd_eod else 0 end  
,case when t2.credit_user_id is not null then t2.is_rollover else 0 end  
,case when t3.credit_user_id is not null then t3.principal_repayable else 0 end    
,case when t3.credit_user_id is not null then t3.principal_refund  else 0 end      
,case when t3.credit_user_id is not null then t3.principal_deduct  else 0 end      
,case when t3.credit_user_id is not null then t3.total_amount_repayable else 0 end 
,case when t3.credit_user_id is not null then t3.total_amount_refund else 0 end    
,case when t3.credit_user_id is not null then t3.total_amount_deduct else 0 end    

