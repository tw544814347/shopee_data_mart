-- credit.ods__credit_core_debt_spl_id_db__plan_tab__df
-- credit.ods__credit_core_debt_spl_id_db__bill_detail_tab__df
-- credit.ods__credit_core_debt_spl_id_db__loan_tab__df

-- credit.ods__credit_core_debt_spl_id_db__bill_tab__df

-- plan表关联bill_detail、loan
create or replace temporary view kafka_source_table_join as
select 
    cast(plan.user_id as string) as user_id,
    trim(replace(bill.bill_no, '_', '-')) as bill_no,
    loan.product_code as product_code
from credit.ods__credit_core_debt_spl_id_db__plan_tab__df plan 
    inner join credit.ods__credit_core_debt_spl_id_db__bill_detail_tab__df bill on plan.plan_no = bill.plan_no
    inner join credit.ods__credit_core_debt_spl_id_db__loan_tab__df loan on plan.debt_no = loan.loan_no
where plan.grass_date = '${bizdate}'
    and plan.user_id is not null
    and plan.debt_no is not null
    and plan.plan_no is not null
    and plan.biz_type = 3
    and bill.grass_date = '${bizdate}'
    and bill.bill_no is not null
    and bill.plan_no is not null
    and bill.biz_type = 3
    and loan.grass_date = '${bizdate}'
    and loan.loan_no is not null 
    and loan.biz_type = 3
;

insert overwrite table ${SCHEMA}.repaid_bills_num_spl_normal_history partition (grass_date = '${ds}')
select 
    SUBSTRING(MD5(user_id), 0, 2) || '_' || user_id || '_' || bill_no as rowkey,
    case when count(case when product_code not in ('id_spl_lite_bnpl_001') then 1 end)>0  then '0' else '1' end as qf,
    null as qf1
from kafka_source_table_join
group by SUBSTRING(MD5(user_id), 0, 2) || '_' || user_id || '_' || bill_no
union all 
select 
    SUBSTRING(MD5(cast(user_id AS string)), 0, 2) || '_' || cast(user_id AS string) || '_' || trim(replace(bill_no, '_', '-')) as row_key,
    '0' as qf,
    '1' as qf1
from credit.ods__credit_core_debt_spl_id_db__bill_tab__df
where grass_date = '${bizdate}'
    and bill_no is not null
    and user_id is not null
    and bill_status in (2, 3)
    and biz_type=3
    and amount = 0
;


