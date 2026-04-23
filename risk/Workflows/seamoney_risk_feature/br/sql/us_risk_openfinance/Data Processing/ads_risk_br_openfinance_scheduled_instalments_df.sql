use ${SCHEMA};
drop table if exists ${SCHEMA}.ads_risk_br_openfinance_scheduled_instalments_df;
create external table if not exists ${SCHEMA}.ads_risk_br_openfinance_scheduled_instalments_df
(
    user_id                          string 
    ,debt_no                         string 
    ,product_type                    string 
    ,plan_no                         string 
    ,contract_id                     string 
    ,qf                              string 
    ,rowkey                          string 
    ,flag                            int 
    ,update_time_ts                  bigint 
)partitioned by(
    grass_date                      string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION 'hdfs://D2/projects/risk/hdfs/dev/ads/ads_risk_br_openfinance_scheduled_instalments_df/grass_region=BR'
;

msck repair table ${SCHEMA}.ads_risk_br_openfinance_scheduled_instalments_df;
refresh table ${SCHEMA}.ads_risk_br_openfinance_scheduled_instalments_df;


insert overwrite ${SCHEMA}.ads_risk_br_openfinance_scheduled_instalments_df partition (grass_date = '${ds}')
select  tt1.user_id 
        ,tt1.debt_no
        ,tt1.product_type
        ,tt1.plan_no
        ,tt3.contract_id
        ,to_json(struct(
            struct(
                tt1.due_date as dueDate,
                struct(
                    cast(tt2.sum_amount as string) as amount,
                    'BRL' as currency
                ) as amount
            ) AS balloon_payment,
            tt1.clear_status as clear_status,
            tt1.overdue_status as overdue_status
        )) as qf
        ,concat(substr(md5(tt3.contract_id), 1, 2), '_', tt3.contract_id, '_', tt1.plan_no) as rowkey
        ,1 as flag
        ,update_time_ts
from (
    select  user_id, debt_no, plan_no, clear_status, overdue_status
            , substr(if(due_date='1970-01-01 00:00:00',null,from_unixtime(unix_timestamp(substr(due_date, 1, 19))+3600* -3,'yyyy-MM-dd HH:mm:ss')), 1, 10) as due_date
            ,case when biz_type = 1 then 'BCL'
                    when biz_type = 2 then 'SCL'
                    when biz_type = 3 then 'SPL'
                    else null 
                end as product_type 
    from credit.ods__credit_core_debt_br_db__plan_tab
    union all 
    select user_id, debt_no, plan_no, clear_status, overdue_status
            , substr(if(due_date='1970-01-01 00:00:00',null,from_unixtime(unix_timestamp(substr(due_date, 1, 19))+3600* -3,'yyyy-MM-dd HH:mm:ss')), 1, 10) as due_date
            ,case when biz_type = 1 then 'BCL'
                    when biz_type = 2 then 'SCL'
                    when biz_type = 3 then 'SPL'
                    else null 
                end as product_type 
    from credit.ods__credit_core_debt_cl_br_db__plan_tab
    where biz_type = 1
) tt1 left join (
    select user_id, debt_no, plan_no, cast(principal+interest+fee1+fee2+fee3+fee4+fee5+fee6+fee7+fee8 as decimal(30, 4)) as sum_amount, (unix_timestamp(substr(update_time, 1, 19))+3600 * -3) * 1000 as update_time_ts
    from credit.ods__credit_core_debt_br_db__plan_money_category_tab
    where money_category = 1
    union all 
    select user_id, debt_no, plan_no, cast(principal+interest+fee1+fee2+fee3+fee4+fee5+fee6+fee7+fee8 as decimal(30, 4)) as sum_amount, (unix_timestamp(substr(update_time, 1, 19))+3600 * -3) * 1000 as update_time_ts
    from credit.ods__credit_core_debt_cl_br_db__plan_money_category_tab
    where money_category = 1
      and biz_type = 1
) tt2 on tt1.user_id = tt2.user_id and tt1.debt_no = tt2.debt_no and tt1.plan_no = tt2.plan_no
left join (
    select loan_id, product_type, credit_user_id, contract_id
    from credit.ods__credit_funding_transaction_br_db__loan_application_request_tab
    where product_type in ('SPL', 'BCL', 'SCL')
    -- and match_status = 500
) tt3 on tt1.user_id = tt3.credit_user_id and tt1.debt_no = tt3.loan_id 
union all 
select  tt1.user_id 
        ,tt1.debt_no
        ,tt3.product_type
        ,tt1.plan_no
        ,tt3.contract_id
        ,tt1.sum_amount as qf 
        ,concat(substr(md5(cast(tt1.debt_no as string)), 1, 2), '_', tt1.debt_no, '_', tt1.user_id, '_', tt1.plan_no) as rowkey
        ,2 as flag
        ,update_time_ts
from (    
    select user_id, debt_no, plan_no, cast(principal+interest+fee1+fee2+fee3+fee4+fee5+fee6+fee7+fee8 as decimal(30, 4)) as sum_amount, (unix_timestamp(substr(update_time, 1, 19))+3600 * -3) * 1000 as update_time_ts
    from credit.ods__credit_core_debt_br_db__plan_money_category_tab
    where money_category = 1
    union all 
    select user_id, debt_no, plan_no, cast(principal+interest+fee1+fee2+fee3+fee4+fee5+fee6+fee7+fee8 as decimal(30, 4)) as sum_amount, (unix_timestamp(substr(update_time, 1, 19))+3600 * -3) * 1000 as update_time_ts
    from credit.ods__credit_core_debt_cl_br_db__plan_money_category_tab
    where money_category = 1
      and biz_type = 1
) tt1 
left join (
    select loan_id, product_type, credit_user_id, contract_id
    from credit.ods__credit_funding_transaction_br_db__loan_application_request_tab
    where product_type in ('SPL', 'BCL', 'SCL')
    -- and match_status = 500
) tt3 on tt1.user_id = tt3.credit_user_id and tt1.debt_no = tt3.loan_id 
;
