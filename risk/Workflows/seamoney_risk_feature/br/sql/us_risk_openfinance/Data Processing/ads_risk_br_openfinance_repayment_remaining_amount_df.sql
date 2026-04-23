SET spark.sql.session.timeZone = America/Sao_Paulo;

use ${SCHEMA};
-- drop table if exists ${SCHEMA}.ads_risk_br_openfinance_repayment_remaining_amount_df;
create external table if not exists ${SCHEMA}.ads_risk_br_openfinance_repayment_remaining_amount_df(
    user_id                          string 
    ,debt_no                         string 
    ,product_type                    string 
    ,plan_no                         string 
    ,contract_id                     string 
    ,repayable                       string 
    ,repaid                          string
    ,refund                          string
    ,deduct                          string
    ,rowkey                          string 
    ,rowkey2                         string
    ,outstanding                     string 
)partitioned by(
    grass_date                      string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION 'hdfs://D2/projects/risk/hdfs/dev/ads/ads_risk_br_openfinance_repayment_remaining_amount_df/grass_region=BR'
;

msck repair table ${SCHEMA}.ads_risk_br_openfinance_repayment_remaining_amount_df;
refresh table ${SCHEMA}.ads_risk_br_openfinance_repayment_remaining_amount_df;


insert overwrite ${SCHEMA}.ads_risk_br_openfinance_repayment_remaining_amount_df partition (grass_date = '${ds}')
select  tt1.user_id 
        ,tt1.debt_no
        ,tt3.product_type
        ,tt1.plan_no
        ,tt3.contract_id
        ,tt1.repayable
        ,tt2.repaid
        ,tt4.refund 
        ,tt5.deduct
        ,concat(substr(md5(cast(tt3.contract_id as string)), 1, 2), '_', tt3.contract_id, '_', '2', '_', tt1.plan_no) as rowkey
        ,concat(substr(md5(cast(tt3.contract_id as string)), 1, 2), '_', tt3.contract_id, '_', '3', '_', tt6.disburse_timestamp) as rowkey2
        ,cast(cast(tt6.loan_outstanding as decimal(30, 4)) as string)    as outstanding
from (    
    select user_id, debt_no, plan_no, money_category, cast(principal+interest+fee1+fee2+fee3+fee4+fee5+fee6+fee7+fee8 as decimal(30, 4)) as repayable
    from credit.ods__credit_core_debt_br_db__plan_money_category_tab
    where money_category = 1
    union all 
    select user_id, debt_no, plan_no, money_category, cast(principal+interest+fee1+fee2+fee3+fee4+fee5+fee6+fee7+fee8 as decimal(30, 4)) as repayable
    from credit.ods__credit_core_debt_cl_br_db__plan_money_category_tab
    where money_category = 1
      and biz_type = 1
) tt1 
left join (
    select user_id, debt_no, plan_no, money_category, cast(principal+interest+fee1+fee2+fee3+fee4+fee5+fee6+fee7+fee8 as decimal(30, 4)) as repaid
    from credit.ods__credit_core_debt_br_db__plan_money_category_tab
    where money_category = 2
        union all 
    select user_id, debt_no, plan_no, money_category, cast(principal+interest+fee1+fee2+fee3+fee4+fee5+fee6+fee7+fee8 as decimal(30, 4)) as repayable
    from credit.ods__credit_core_debt_cl_br_db__plan_money_category_tab
    where money_category = 2
      and biz_type = 1
) tt2 on tt1.user_id = tt2.user_id and tt1.debt_no = tt2.debt_no and tt1.plan_no = tt2.plan_no 
left join (
    select user_id, debt_no, plan_no, money_category, cast(principal+interest+fee1+fee2+fee3+fee4+fee5+fee6+fee7+fee8 as decimal(30, 4)) as refund
    from credit.ods__credit_core_debt_br_db__plan_money_category_tab
    where money_category = 3
        union all 
    select user_id, debt_no, plan_no, money_category, cast(principal+interest+fee1+fee2+fee3+fee4+fee5+fee6+fee7+fee8 as decimal(30, 4)) as repayable
    from credit.ods__credit_core_debt_cl_br_db__plan_money_category_tab
    where money_category = 3
      and biz_type = 1
) tt4 on tt1.user_id = tt4.user_id and tt1.debt_no = tt4.debt_no and tt1.plan_no = tt4.plan_no 
left join (
    select user_id, debt_no, plan_no, money_category, cast(principal+interest+fee1+fee2+fee3+fee4+fee5+fee6+fee7+fee8 as decimal(30, 4)) as deduct
    from credit.ods__credit_core_debt_br_db__plan_money_category_tab
    where money_category = 4
        union all 
    select user_id, debt_no, plan_no, money_category, cast(principal+interest+fee1+fee2+fee3+fee4+fee5+fee6+fee7+fee8 as decimal(30, 4)) as repayable
    from credit.ods__credit_core_debt_cl_br_db__plan_money_category_tab
    where money_category = 4
      and biz_type = 1
) tt5 on tt1.user_id = tt5.user_id and tt1.debt_no = tt5.debt_no and tt1.plan_no = tt5.plan_no 
left join (
    select loan_id, product_type, credit_user_id, contract_id, disbursement_date
    from credit.ods__credit_funding_transaction_br_db__loan_application_request_tab
    where product_type in ('SPL', 'BCL', 'SCL')
    -- and match_status = 500
) tt3 on tt1.user_id = tt3.credit_user_id and tt1.debt_no = tt3.loan_id 
left join (
    select user_id, loan_no, loan_outstanding, unix_timestamp(substr(disburse_time, 1, 19))+3600* -3 as disburse_timestamp
    from credit.ods__credit_core_debt_br_db__loan_tab
    union all 
    select user_id, loan_no, loan_outstanding, unix_timestamp(substr(disburse_time, 1, 19))+3600* -3 as disburse_timestamp
    from credit.ods__credit_core_debt_cl_br_db__loan_tab
    where biz_type = 1
) tt6 on tt1.user_id = tt6.user_id and tt1.debt_no = tt6.loan_no
where tt3.contract_id is not null 
;

