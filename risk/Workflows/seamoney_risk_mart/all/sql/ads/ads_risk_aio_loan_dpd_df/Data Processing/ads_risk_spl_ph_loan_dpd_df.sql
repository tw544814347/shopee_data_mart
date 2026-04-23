--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2023-11-23T14:00:00
-- Theme Domain：       loan_dpd
-- Description:         loan 粒度的dpd统计数据,第一期算逾期,整笔loan就算逾期
-- Data Granularity:    loan_id
-- 变更历史：
--         2024-01-10 如果第一期已经还清,则不再继续算dpd
--         2024-03-01 新增字段 first_loan_disburse_month,product_type,loan_type,first_instalment_term,principal_refund,principal_deduct ,has_valid_loan           
--********************************************************************--
create or replace temporary view tmp_first_instalment_info_${product}_${region} as
select 
credit_user_id  
,loan_id
,max_dpd 
,max_dpd_eod
,bill_term as first_instalment_term
from credit_mart.dws_${product}_${region}_instalment_repayment_df t1 
where t1.grass_date  = '${grass_date}'
and cur_term_num = 1
;
-- 计算 first_loan_disburse_month select userid, min(loan_disburse_month) group by userid, 用户第一笔loan的loan_disburse_month
create or replace temporary view tmp_loan_disburse_month_${product}_${region} as
select 
credit_user_id  
,min(loan_disbursed_month) as first_loan_disbursed_month
from credit_mart.dws_${product}_${region}_loan_repayment_df t1 
where t1.grass_date  = '${grass_date}'
group by credit_user_id
;

-- 计算 principal_refund principal_deduct has_valid_loan
create or replace temporary view tmp_loan_info_${product}_${region} as
select 
loan_id
,credit_user_id  
,platform_user_id
,principal_refund
,principal_deduct
,case when nvl(total_amount_repayable,0) - nvl(total_amount_refund,0) - nvl(total_amount_deduct,0) > 0 then 1 else 0 end has_valid_loan
-- spl/spl xtra: biz_type = 3/7
-- bcl/bcl xtra: 目前只有ID有这个字段 sub_biz_type = 0/102, 其他地区没有字段
-- scl 没有字段 
,${product_flag_column}  as product_type
,date_format(add_months(to_date(first_instalment_due_time), -1), 'yyyyMM') as disbursement_term
,loan_disbursed_month
${comment_out},case when (DAY(CAST(first_instalment_due_time AS TIMESTAMP)) NOT IN (6,16) OR restructured_type = 1 OR principal_repayable - principal_refund <= 0) then 1 else 0 end as is_vintage_exclusion
from credit_mart.dws_${product}_${region}_loan_repayment_df t1 
where t1.grass_date  = '${grass_date}'
;

-- 从instalment拉链表中取出已经还清的第一期start_date end_date 
-- 已经还清 end_date =9999-12-31 and principal_os=0
create or replace temporary view tmp_first_instalment_clear_info_${product}_${region} as
select 
loan_id
,min(start_date) as start_date
,min(end_date)   as end_date
from risk.dws_risk_${product}_${region}_instalment_repayment_zi t1 
where cur_term_num = 1
and principal_os=0
and end_date ='9999-12-31'
group by loan_id
;

insert overwrite table ${SCHEMA}.ads_risk_${product}_${region}_loan_dpd_df partition(grass_date)
select  
t1.credit_user_id
,t6.platform_user_id
,t1.loan_id
,t6.loan_disbursed_month
,case when day(t1.first_instalment_due_time)<= 15 then date_format(add_months(t1.first_instalment_due_time,-1),'yyyyMM') else date_format(t1.first_instalment_due_time,'yyyyMM') end  as loan_disbursed_month_new
,t1.first_instalment_due_time
,case when t3.credit_user_id is not null then t3.max_dpd else 0 end      as max_dpd
,case when t3.credit_user_id is not null then t3.max_dpd_eod else 0 end  as max_dpd_eod
,max(t1.principal_repayable) as principal_repayable
,max(t1.loan_tenure)         as loan_tenure
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, -11)>=date(t1.start_date) and date_add(first_instalment_due_time,-11)<=date(t1.end_date) and date_add(first_instalment_due_time,-11)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, -11)<t4.start_date and date_add(first_instalment_due_time, -11)>=date(t1.start_date) and date_add(first_instalment_due_time,-11)<=date(t1.end_date) and date_add(first_instalment_due_time,-11)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd9_minus
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, -10)>=date(t1.start_date) and date_add(first_instalment_due_time,-10)<=date(t1.end_date) and date_add(first_instalment_due_time,-10)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, -10)<t4.start_date and date_add(first_instalment_due_time, -10)>=date(t1.start_date) and date_add(first_instalment_due_time,-10)<=date(t1.end_date) and date_add(first_instalment_due_time,-10)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd8_minus
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, -9)>=date(t1.start_date) and date_add(first_instalment_due_time,-9)<=date(t1.end_date) and date_add(first_instalment_due_time,-9)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, -9)<t4.start_date and date_add(first_instalment_due_time, -9)>=date(t1.start_date) and date_add(first_instalment_due_time,-9)<=date(t1.end_date) and date_add(first_instalment_due_time,-9)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd7_minus
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, -8)>=date(t1.start_date) and date_add(first_instalment_due_time,-8)<=date(t1.end_date) and date_add(first_instalment_due_time,-8)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, -8)<t4.start_date and date_add(first_instalment_due_time, -8)>=date(t1.start_date) and date_add(first_instalment_due_time,-8)<=date(t1.end_date) and date_add(first_instalment_due_time,-8)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd6_minus
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, -7)>=date(t1.start_date) and date_add(first_instalment_due_time,-7)<=date(t1.end_date) and date_add(first_instalment_due_time,-7)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, -7)<t4.start_date and date_add(first_instalment_due_time, -7)>=date(t1.start_date) and date_add(first_instalment_due_time,-7)<=date(t1.end_date) and date_add(first_instalment_due_time,-7)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd5_minus
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, -6)>=date(t1.start_date) and date_add(first_instalment_due_time,-6)<=date(t1.end_date) and date_add(first_instalment_due_time,-6)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, -6)<t4.start_date and date_add(first_instalment_due_time, -6)>=date(t1.start_date) and date_add(first_instalment_due_time,-6)<=date(t1.end_date) and date_add(first_instalment_due_time,-6)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd4_minus
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, -5)>=date(t1.start_date) and date_add(first_instalment_due_time,-5)<=date(t1.end_date) and date_add(first_instalment_due_time,-5)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, -5)<t4.start_date and date_add(first_instalment_due_time, -5)>=date(t1.start_date) and date_add(first_instalment_due_time,-5)<=date(t1.end_date) and date_add(first_instalment_due_time,-5)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd3_minus
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, -4)>=date(t1.start_date) and date_add(first_instalment_due_time,-4)<=date(t1.end_date) and date_add(first_instalment_due_time,-4)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, -4)<t4.start_date and date_add(first_instalment_due_time, -4)>=date(t1.start_date) and date_add(first_instalment_due_time,-4)<=date(t1.end_date) and date_add(first_instalment_due_time,-4)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd2_minus
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, -3)>=date(t1.start_date) and date_add(first_instalment_due_time,-3)<=date(t1.end_date) and date_add(first_instalment_due_time,-3)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, -3)<t4.start_date and date_add(first_instalment_due_time, -3)>=date(t1.start_date) and date_add(first_instalment_due_time,-3)<=date(t1.end_date) and date_add(first_instalment_due_time,-3)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd1_minus
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, -2)>=date(t1.start_date) and date_add(first_instalment_due_time,-2)<=date(t1.end_date) and date_add(first_instalment_due_time,-2)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, -2)<t4.start_date and date_add(first_instalment_due_time, -2)>=date(t1.start_date) and date_add(first_instalment_due_time,-2)<=date(t1.end_date) and date_add(first_instalment_due_time,-2)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd0
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, -1)>=date(t1.start_date) and date_add(first_instalment_due_time,-1)<=date(t1.end_date) and date_add(first_instalment_due_time,-1)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, -1)<t4.start_date and date_add(first_instalment_due_time, -1)>=date(t1.start_date) and date_add(first_instalment_due_time,-1)<=date(t1.end_date) and date_add(first_instalment_due_time,-1)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd1 
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, -0)>=date(t1.start_date) and date_add(first_instalment_due_time,-0)<=date(t1.end_date) and date_add(first_instalment_due_time,-0)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, -0)<t4.start_date and date_add(first_instalment_due_time, -0)>=date(t1.start_date) and date_add(first_instalment_due_time,-0)<=date(t1.end_date) and date_add(first_instalment_due_time,-0)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd2 
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 1)>=date(t1.start_date) and date_add(first_instalment_due_time,1)<=date(t1.end_date) and date_add(first_instalment_due_time,1)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 1)<t4.start_date and date_add(first_instalment_due_time, 1)>=date(t1.start_date) and date_add(first_instalment_due_time,1)<=date(t1.end_date) and date_add(first_instalment_due_time,1)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd3 
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 2)>=date(t1.start_date) and date_add(first_instalment_due_time,2)<=date(t1.end_date) and date_add(first_instalment_due_time,2)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 2)<t4.start_date and date_add(first_instalment_due_time, 2)>=date(t1.start_date) and date_add(first_instalment_due_time,2)<=date(t1.end_date) and date_add(first_instalment_due_time,2)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd4 
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 3)>=date(t1.start_date) and date_add(first_instalment_due_time,3)<=date(t1.end_date) and date_add(first_instalment_due_time,3)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 3)<t4.start_date and date_add(first_instalment_due_time, 3)>=date(t1.start_date) and date_add(first_instalment_due_time,3)<=date(t1.end_date) and date_add(first_instalment_due_time,3)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd5 
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 4)>=date(t1.start_date) and date_add(first_instalment_due_time,4)<=date(t1.end_date) and date_add(first_instalment_due_time,4)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 4)<t4.start_date and date_add(first_instalment_due_time, 4)>=date(t1.start_date) and date_add(first_instalment_due_time,4)<=date(t1.end_date) and date_add(first_instalment_due_time,4)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd6 
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 5)>=date(t1.start_date) and date_add(first_instalment_due_time,5)<=date(t1.end_date) and date_add(first_instalment_due_time,5)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 5)<t4.start_date and date_add(first_instalment_due_time, 5)>=date(t1.start_date) and date_add(first_instalment_due_time,5)<=date(t1.end_date) and date_add(first_instalment_due_time,5)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd7 
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 6)>=date(t1.start_date) and date_add(first_instalment_due_time,6)<=date(t1.end_date) and date_add(first_instalment_due_time,6)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 6)<t4.start_date and date_add(first_instalment_due_time, 6)>=date(t1.start_date) and date_add(first_instalment_due_time,6)<=date(t1.end_date) and date_add(first_instalment_due_time,6)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd8 
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 7)>=date(t1.start_date) and date_add(first_instalment_due_time,7)<=date(t1.end_date) and date_add(first_instalment_due_time,7)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 7)<t4.start_date and date_add(first_instalment_due_time, 7)>=date(t1.start_date) and date_add(first_instalment_due_time,7)<=date(t1.end_date) and date_add(first_instalment_due_time,7)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd9 
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 8)>=date(t1.start_date) and date_add(first_instalment_due_time,8)<=date(t1.end_date) and date_add(first_instalment_due_time,8)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 8)<t4.start_date and date_add(first_instalment_due_time, 8)>=date(t1.start_date) and date_add(first_instalment_due_time,8)<=date(t1.end_date) and date_add(first_instalment_due_time,8)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd10
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 9)>=date(t1.start_date) and date_add(first_instalment_due_time,9)<=date(t1.end_date) and date_add(first_instalment_due_time,9)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 9)<t4.start_date and date_add(first_instalment_due_time, 9)>=date(t1.start_date) and date_add(first_instalment_due_time,9)<=date(t1.end_date) and date_add(first_instalment_due_time,9)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd11
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 10)>=date(t1.start_date) and date_add(first_instalment_due_time,10)<=date(t1.end_date) and date_add(first_instalment_due_time,10)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 10)<t4.start_date and date_add(first_instalment_due_time, 10)>=date(t1.start_date) and date_add(first_instalment_due_time,10)<=date(t1.end_date) and date_add(first_instalment_due_time,10)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd12
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 11)>=date(t1.start_date) and date_add(first_instalment_due_time,11)<=date(t1.end_date) and date_add(first_instalment_due_time,11)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 11)<t4.start_date and date_add(first_instalment_due_time, 11)>=date(t1.start_date) and date_add(first_instalment_due_time,11)<=date(t1.end_date) and date_add(first_instalment_due_time,11)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd13
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 12)>=date(t1.start_date) and date_add(first_instalment_due_time,12)<=date(t1.end_date) and date_add(first_instalment_due_time,12)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 12)<t4.start_date and date_add(first_instalment_due_time, 12)>=date(t1.start_date) and date_add(first_instalment_due_time,12)<=date(t1.end_date) and date_add(first_instalment_due_time,12)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd14
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 13)>=date(t1.start_date) and date_add(first_instalment_due_time,13)<=date(t1.end_date) and date_add(first_instalment_due_time,13)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 13)<t4.start_date and date_add(first_instalment_due_time, 13)>=date(t1.start_date) and date_add(first_instalment_due_time,13)<=date(t1.end_date) and date_add(first_instalment_due_time,13)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd15
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 14)>=date(t1.start_date) and date_add(first_instalment_due_time,14)<=date(t1.end_date) and date_add(first_instalment_due_time,14)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 14)<t4.start_date and date_add(first_instalment_due_time, 14)>=date(t1.start_date) and date_add(first_instalment_due_time,14)<=date(t1.end_date) and date_add(first_instalment_due_time,14)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd16
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 15)>=date(t1.start_date) and date_add(first_instalment_due_time,15)<=date(t1.end_date) and date_add(first_instalment_due_time,15)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 15)<t4.start_date and date_add(first_instalment_due_time, 15)>=date(t1.start_date) and date_add(first_instalment_due_time,15)<=date(t1.end_date) and date_add(first_instalment_due_time,15)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd17
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 16)>=date(t1.start_date) and date_add(first_instalment_due_time,16)<=date(t1.end_date) and date_add(first_instalment_due_time,16)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 16)<t4.start_date and date_add(first_instalment_due_time, 16)>=date(t1.start_date) and date_add(first_instalment_due_time,16)<=date(t1.end_date) and date_add(first_instalment_due_time,16)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd18
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 17)>=date(t1.start_date) and date_add(first_instalment_due_time,17)<=date(t1.end_date) and date_add(first_instalment_due_time,17)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 17)<t4.start_date and date_add(first_instalment_due_time, 17)>=date(t1.start_date) and date_add(first_instalment_due_time,17)<=date(t1.end_date) and date_add(first_instalment_due_time,17)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd19
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 18)>=date(t1.start_date) and date_add(first_instalment_due_time,18)<=date(t1.end_date) and date_add(first_instalment_due_time,18)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 18)<t4.start_date and date_add(first_instalment_due_time, 18)>=date(t1.start_date) and date_add(first_instalment_due_time,18)<=date(t1.end_date) and date_add(first_instalment_due_time,18)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd20
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 19)>=date(t1.start_date) and date_add(first_instalment_due_time,19)<=date(t1.end_date) and date_add(first_instalment_due_time,19)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 19)<t4.start_date and date_add(first_instalment_due_time, 19)>=date(t1.start_date) and date_add(first_instalment_due_time,19)<=date(t1.end_date) and date_add(first_instalment_due_time,19)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd21
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 20)>=date(t1.start_date) and date_add(first_instalment_due_time,20)<=date(t1.end_date) and date_add(first_instalment_due_time,20)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 20)<t4.start_date and date_add(first_instalment_due_time, 20)>=date(t1.start_date) and date_add(first_instalment_due_time,20)<=date(t1.end_date) and date_add(first_instalment_due_time,20)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd22
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 21)>=date(t1.start_date) and date_add(first_instalment_due_time,21)<=date(t1.end_date) and date_add(first_instalment_due_time,21)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 21)<t4.start_date and date_add(first_instalment_due_time, 21)>=date(t1.start_date) and date_add(first_instalment_due_time,21)<=date(t1.end_date) and date_add(first_instalment_due_time,21)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd23
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 22)>=date(t1.start_date) and date_add(first_instalment_due_time,22)<=date(t1.end_date) and date_add(first_instalment_due_time,22)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 22)<t4.start_date and date_add(first_instalment_due_time, 22)>=date(t1.start_date) and date_add(first_instalment_due_time,22)<=date(t1.end_date) and date_add(first_instalment_due_time,22)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd24
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 23)>=date(t1.start_date) and date_add(first_instalment_due_time,23)<=date(t1.end_date) and date_add(first_instalment_due_time,23)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 23)<t4.start_date and date_add(first_instalment_due_time, 23)>=date(t1.start_date) and date_add(first_instalment_due_time,23)<=date(t1.end_date) and date_add(first_instalment_due_time,23)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd25
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 24)>=date(t1.start_date) and date_add(first_instalment_due_time,24)<=date(t1.end_date) and date_add(first_instalment_due_time,24)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 24)<t4.start_date and date_add(first_instalment_due_time, 24)>=date(t1.start_date) and date_add(first_instalment_due_time,24)<=date(t1.end_date) and date_add(first_instalment_due_time,24)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd26
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 25)>=date(t1.start_date) and date_add(first_instalment_due_time,25)<=date(t1.end_date) and date_add(first_instalment_due_time,25)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 25)<t4.start_date and date_add(first_instalment_due_time, 25)>=date(t1.start_date) and date_add(first_instalment_due_time,25)<=date(t1.end_date) and date_add(first_instalment_due_time,25)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd27
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 26)>=date(t1.start_date) and date_add(first_instalment_due_time,26)<=date(t1.end_date) and date_add(first_instalment_due_time,26)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 26)<t4.start_date and date_add(first_instalment_due_time, 26)>=date(t1.start_date) and date_add(first_instalment_due_time,26)<=date(t1.end_date) and date_add(first_instalment_due_time,26)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd28
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 27)>=date(t1.start_date) and date_add(first_instalment_due_time,27)<=date(t1.end_date) and date_add(first_instalment_due_time,27)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 27)<t4.start_date and date_add(first_instalment_due_time, 27)>=date(t1.start_date) and date_add(first_instalment_due_time,27)<=date(t1.end_date) and date_add(first_instalment_due_time,27)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd29
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 28)>=date(t1.start_date) and date_add(first_instalment_due_time,28)<=date(t1.end_date) and date_add(first_instalment_due_time,28)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 28)<t4.start_date and date_add(first_instalment_due_time, 28)>=date(t1.start_date) and date_add(first_instalment_due_time,28)<=date(t1.end_date) and date_add(first_instalment_due_time,28)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd30
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 29)>=date(t1.start_date) and date_add(first_instalment_due_time,29)<=date(t1.end_date) and date_add(first_instalment_due_time,29)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 29)<t4.start_date and date_add(first_instalment_due_time, 29)>=date(t1.start_date) and date_add(first_instalment_due_time,29)<=date(t1.end_date) and date_add(first_instalment_due_time,29)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd31
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 59)>=date(t1.start_date) and date_add(first_instalment_due_time,59)<=date(t1.end_date) and date_add(first_instalment_due_time,59)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 59)<t4.start_date and date_add(first_instalment_due_time, 59)>=date(t1.start_date) and date_add(first_instalment_due_time,59)<=date(t1.end_date) and date_add(first_instalment_due_time,59)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd60
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 89)>=date(t1.start_date) and date_add(first_instalment_due_time,89)<=date(t1.end_date) and date_add(first_instalment_due_time,89)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 89)<t4.start_date and date_add(first_instalment_due_time, 89)>=date(t1.start_date) and date_add(first_instalment_due_time,89)<=date(t1.end_date) and date_add(first_instalment_due_time,89)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd90
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 119)>=date(t1.start_date) and date_add(first_instalment_due_time,119)<=date(t1.end_date) and date_add(first_instalment_due_time,119)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 119)<t4.start_date and date_add(first_instalment_due_time, 119)>=date(t1.start_date) and date_add(first_instalment_due_time,119)<=date(t1.end_date) and date_add(first_instalment_due_time,119)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd120
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 149)>=date(t1.start_date) and date_add(first_instalment_due_time,149)<=date(t1.end_date) and date_add(first_instalment_due_time,149)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 149)<t4.start_date and date_add(first_instalment_due_time, 149)>=date(t1.start_date) and date_add(first_instalment_due_time,149)<=date(t1.end_date) and date_add(first_instalment_due_time,149)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd150
,sum(case when t4.loan_id is null and date_add(first_instalment_due_time, 179)>=date(t1.start_date) and date_add(first_instalment_due_time,179)<=date(t1.end_date) and date_add(first_instalment_due_time,179)<=date('${grass_date}')  then principal_os 
          when t4.loan_id is not null and date_add(first_instalment_due_time, 179)<t4.start_date and date_add(first_instalment_due_time, 179)>=date(t1.start_date) and date_add(first_instalment_due_time,179)<=date(t1.end_date) and date_add(first_instalment_due_time,179)<=date('${grass_date}')  then principal_os 
          else 0 end ) as loan_principal_os_dpd180
,max(t5.first_loan_disbursed_month) as first_loan_disbursed_month
,nvl(max(case when '${product}' = 'spl' and t6.product_type = 3   then 'SPL'
              when '${product}' = 'spl' and t6.product_type = 7   then 'SPL Xtra'
              when '${product}' = 'bcl' and t6.product_type = 102 then 'BCL Xtra'
              when '${product}' = 'bcl' then 'BCL'
              when '${product}' = 'scl' then 'SCL'
              else null  
          end), upper('${product}')) as product_type        
,nvl(max(case when '${product}' = 'spl' and t6.product_type = 3   then 'SPL'
              when '${product}' = 'spl' and t6.product_type = 7   then 'Cicilan Handphone Loan'
              when '${product}' = 'bcl' and t6.product_type = 102 then 'BCL Xtra'
              when '${product}' = 'bcl' then 'BCL'
              when '${product}' = 'scl' then 'SCL'
              else null  
         end), upper('${product}')) as loan_type            
,max(t3.first_instalment_term)      as first_instalment_term
,max(t6.principal_refund)           as principal_refund 
,max(t6.principal_deduct)           as principal_deduct
,max(t6.has_valid_loan)             as has_valid_loan
,max(t6.disbursement_term)          as disbursement_term
${comment_out}    ,max(t6.is_vintage_exclusion) as is_vintage_exclusion
,'${grass_date}'                    as grass_date 
from (
    select 
    t1.platform_user_id                       as platform_user_id
    ,t1.credit_user_id                        as credit_user_id
    ,t1.loan_id                               as loan_id          
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
    from risk.dws_risk_${product}_${region}_loan_repayment_zi t1
    where first_instalment_due_time is not null
) t1 
left join tmp_first_instalment_info_${product}_${region} t3  on t1.credit_user_id = t3.credit_user_id and t1.loan_id = t3.loan_id
left join tmp_first_instalment_clear_info_${product}_${region} t4 on t1.loan_id = t4.loan_id 
left join tmp_loan_disburse_month_${product}_${region} t5 on t1.credit_user_id = t5.credit_user_id 
left join tmp_loan_info_${product}_${region} t6 on t1.credit_user_id = t6.credit_user_id and t1.loan_id = t6.loan_id
group by t1.credit_user_id
,t6.platform_user_id
,case when day(t1.first_instalment_due_time)<= 15 then date_format(add_months(t1.first_instalment_due_time,-1),'yyyyMM') else date_format(t1.first_instalment_due_time,'yyyyMM') end
,t1.first_instalment_due_time
,t1.loan_id
,t6.loan_disbursed_month
,case when t3.credit_user_id is not null then t3.max_dpd else 0 end
,case when t3.credit_user_id is not null then t3.max_dpd_eod else 0 end 
;

