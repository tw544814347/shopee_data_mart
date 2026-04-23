use ${SCHEMA};
-- drop table if exists ${SCHEMA}.dim_risk_br_openfinance_loan_info_df;
create external table if not exists ${SCHEMA}.dim_risk_br_openfinance_loan_info_df
(
    loan_id                         string 
    ,product_type                   string 
    ,credit_user_id                 string 
    ,contract_id                    string
    ,loan_outstanding               string 
    ,eir                            string 
    ,cet                            string 
    ,instalment_list                string 
    ,disburse_timestamp             bigint
    ,rowkey                         string 
)partitioned by(
    grass_date                      string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION 'hdfs://D2/projects/risk/hdfs/dev/ads/dim_risk_br_openfinance_loan_info_df/grass_region=BR'
;

msck repair table ${SCHEMA}.dim_risk_br_openfinance_loan_info_df;
refresh table ${SCHEMA}.dim_risk_br_openfinance_loan_info_df;


insert overwrite ${SCHEMA}.dim_risk_br_openfinance_loan_info_df partition (grass_date = '${ds}')
select t1.loan_id, t1.product_type, t1.credit_user_id, t1.contract_id, t2.loan_outstanding, t2.eir, t2.cet, t3.instalment_list, t2.disburse_timestamp
        ,concat(substr(md5(loan_id), 1, 2), '_', loan_id, '_', credit_user_id) as rowkey
from (
    select loan_id, product_type, credit_user_id, contract_id
    from credit.ods__credit_funding_transaction_br_db__loan_application_request_tab
    where product_type in ('SPL', 'BCL', 'SCL')
    -- and match_status = 500
) t1 right  join (
    select distinct loan_no, cast(cast(loan_outstanding as decimal(30, 4)) as string) as loan_outstanding, cast(cast(get_json_object(extra_cal_rate, '$.1') as decimal(30, 6)) as string) as cet, cast(cast(POWER(1 + CAST(get_json_object(extra_cal_rate, '$.2') AS DOUBLE), 1.0 / 12) - 1 as decimal(30, 6)) as string) AS eir
            ,unix_timestamp(substr(disburse_time, 1, 19))+3600* -3 as disburse_timestamp
    from credit.ods__credit_core_debt_br_db__loan_tab
    union all 
    select distinct loan_no, cast(cast(loan_outstanding as decimal(30, 4)) as string) as loan_outstanding,  cast(cast(get_json_object(extra_cal_rate, '$.1') as decimal(30, 6)) as string) as cet, cast(cast(POWER(1 + CAST(get_json_object(extra_cal_rate, '$.2') AS DOUBLE), 1.0 / 12) - 1 as decimal(30, 6)) as string) AS eir
            ,unix_timestamp(substr(disburse_time, 1, 19))+3600* -3 as disburse_timestamp
    from credit.ods__credit_core_debt_cl_br_db__loan_tab
    where biz_type = 1
) t2 on t1.loan_id = t2.loan_no
left join (
    select tt1.user_id, tt1.debt_no, 
            to_json(
                struct(
                    collect_list(
                        struct(
                            substr(if(due_date='1970-01-01 00:00:00',null,from_unixtime(unix_timestamp(substr(due_date, 1, 19))+3600* -3,'yyyy-MM-dd HH:mm:ss')), 1, 10) as due_date,
                            CAST(CAST( principal + interest + fee1 + fee2 + fee3 + fee4 + fee5 + fee6 + fee7 + fee8 AS decimal(30, 4)) AS STRING)  as amount,
                            tt1.plan_no as instalment_id
                        )
                    ) as instalment_list
                )
             ) as instalment_list
    from (
        select *
        from credit.ods__credit_core_debt_cl_br_db__plan_tab
        where biz_type = 1
    ) tt1 left join (
        select *
        from credit.ods__credit_core_debt_cl_br_db__plan_money_category_tab
        where money_category = 1
          and biz_type = 1
    ) tt2 on tt1.user_id = tt2.user_id and tt1.debt_no = tt2.debt_no and tt1.plan_no = tt2.plan_no
    group by 1,2
    union all 
        select tt1.user_id, tt1.debt_no, 
            to_json(
                struct(
                    collect_list(
                        struct(
                            substr(if(due_date='1970-01-01 00:00:00',null,from_unixtime(unix_timestamp(substr(due_date, 1, 19))+3600* -3,'yyyy-MM-dd HH:mm:ss')), 1, 10) as due_date,
                            CAST(CAST( principal + interest + fee1 + fee2 + fee3 + fee4 + fee5 + fee6 + fee7 + fee8 AS decimal(30, 4)) AS STRING)  as amount,
                            tt1.plan_no as instalment_id
                        )
                    ) as instalment_list
                )
             ) as instalment_list
    from (
        select *
        from credit.ods__credit_core_debt_br_db__plan_tab
    ) tt1 left join (
        select *
        from credit.ods__credit_core_debt_br_db__plan_money_category_tab
        where money_category = 1
    ) tt2 on tt1.user_id = tt2.user_id and tt1.debt_no = tt2.debt_no and tt1.plan_no = tt2.plan_no
    group by 1,2
) t3 on t1.credit_user_id = t3.user_id and t1.loan_id = t3.debt_no
where contract_id is not null 
;