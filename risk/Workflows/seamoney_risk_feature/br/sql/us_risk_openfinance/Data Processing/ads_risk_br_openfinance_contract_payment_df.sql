drop table if exists ${SCHEMA}.ads_risk_br_openfinance_contract_payment_df;
create external table if not exists ${SCHEMA}.ads_risk_br_openfinance_contract_payment_df
(    
    credit_user_id                  string 
    ,loan_id                        string 
    ,instalment_id                  string 
    ,contract_id                    string
    ,related_biz_id                 string
    ,product_type                   string
    -- API 
    ,repayment                       string 
)partitioned by(
    grass_date                      string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION 'hdfs://D2/projects/risk/hdfs/dev/ads/ads_risk_br_openfinance_contract_payment_df/grass_region=BR'
;

msck repair table ${SCHEMA}.ads_risk_br_openfinance_contract_payment_df;
refresh table ${SCHEMA}.ads_risk_br_openfinance_contract_payment_df;

with payments_info as (
    select  loan_id
            ,user_id 
            ,payment_id as related_biz_id
            ,instalment_id
            ,product_type
            ,to_json(
                struct(
                    update_os_time as lastUpdatedDateTime,
                    array(struct(
                        payment_id as paymentId,
                        cast(is_over_parcel_payment as boolean) as isOverParcelPayment,
                        instalment_id as instalmentId,
                        paid_date as paidDate,
                        currency as currency,
                        paid_amount as paidAmount,
                        from_json(over_parcel, 'struct<fees:array<struct<feeName:string,feeCode:string,feeAmount:string>>,charges:array<struct<chargeType:string,chargeAmount:string>>>') as overParcel
                    )) as releases
                )
            ) AS repayment
    from (
        select  t1.user_id 
                ,t1.product_type
                ,t1.relate_biz_id as payment_id 
                ,t1.debt_no      as loan_id 
                ,t1.plan_no      as instalment_id
                ,'true'          as is_over_parcel_payment
                ,t1.paid_date
                ,t1.update_os_time
                ,t1.currency
                ,cast(cast(t1.paid_amount as decimal(30,4)) as string) as paid_amount
                ,to_json(struct(
                    t2.fees_array as fees,
                    t2.charges_array as charges
                )) AS over_parcel
                ,cast(cast(t3.loan_outstanding as decimal(30, 4)) as string) as loan_outstanding
        from (
                select  distinct relate_biz_id
                    ,debt_no
                    ,plan_no 
                    ,user_id
                    ,case when biz_type = 1 then 'BCL'
                        when biz_type = 2 then 'SCL'
                        when biz_type = 3 then 'SPL'
                        else null 
                    end as product_type 
                    ,substr(if(transaction_time='1970-01-01 00:00:00',null,from_unixtime(unix_timestamp(substr(transaction_time, 1, 19))+3600* -3,'yyyy-MM-dd HH:mm:ss')), 1, 10) as paid_date
                    ,IF(
                        transaction_time = '1970-01-01 00:00:00',
                        NULL,
                        concat(
                            date_format(
                            from_unixtime(unix_timestamp(substr(transaction_time, 1, 19)) + 3600 * -3),
                            'yyyy-MM-dd'
                            ),
                            'T',
                            date_format(
                            from_unixtime(unix_timestamp(substr(transaction_time, 1, 19)) + 3600 * -3),
                            'HH:mm:ss.SSS'
                            ),
                            'Z'
                        )
                    ) as update_os_time
                    ,'BRL' as currency
                    ,sum(repay_amount) as paid_amount
                from credit.ods__credit_core_debt_br_db__repay_flow_tab
                group by 1,2,3,4,5,6,7
                union all 
                select  distinct relate_biz_id
                        ,debt_no
                        ,plan_no 
                        ,user_id
                        ,case when biz_type = 1 then 'BCL'
                            when biz_type = 2 then 'SCL'
                            when biz_type = 3 then 'SPL'
                            else null 
                        end as product_type 
                        ,substr(if(transaction_time='1970-01-01 00:00:00',null,from_unixtime(unix_timestamp(substr(transaction_time, 1, 19))+3600* -3,'yyyy-MM-dd HH:mm:ss')), 1, 10) as paid_date
                        ,IF(
                            transaction_time = '1970-01-01 00:00:00',
                            NULL,
                            concat(
                                date_format(
                                from_unixtime(unix_timestamp(substr(transaction_time, 1, 19)) + 3600 * -3),
                                'yyyy-MM-dd'
                                ),
                                'T',
                                date_format(
                                from_unixtime(unix_timestamp(substr(transaction_time, 1, 19)) + 3600 * -3),
                                'HH:mm:ss.SSS'
                                ),
                                'Z'
                            )
                        ) as update_os_time
                        ,'BRL' as currency
                        ,sum(repay_amount) as paid_amount
                from credit.ods__credit_core_debt_cl_br_db__repay_flow_tab
                group by 1,2,3,4,5,6,7
        ) t1 left join (
            select  relate_biz_id
                    ,debt_no
                    ,plan_no
                    ,filter(collect_list(null), x -> x is not null) AS fees_array
                    ,filter(collect_list(charge_struct), x -> x is not null) AS charges_array
            from (
                select  relate_biz_id
                        ,debt_no
                        ,plan_no
                        ,struct(
                            'null' as feeName,
                            'null' as feeCode,
                            cast(cast(sum(if(fee_type = 1, repay_amount, 0)) as decimal(30, 4)) as string) as feeAmount
                        ) AS fee_struct
                        ,cast(null as struct<chargeType:string,chargeAmount:string>) as charge_struct
                from credit.ods__credit_core_debt_br_db__repay_flow_tab
                where fee_type = 1
                group by 1,2,3
                union all 
                select  relate_biz_id
                        ,debt_no
                        ,plan_no
                        ,cast(null as struct<feeName:string,feeCode:string,feeAmount:string>) as fee_struct
                        ,struct(
                            'JUROS_REMUNERATORIOS_POR_ATRASO' as chargeType,
                            cast(cast(sum(if(fee_type = 2, repay_amount, 0)) as decimal(30, 4)) as string) as chargeAmount
                        ) AS charge_struct
                from credit.ods__credit_core_debt_br_db__repay_flow_tab
                where fee_type = 2
                group by 1,2,3
                union all 
                select  relate_biz_id
                        ,debt_no
                        ,plan_no
                        ,cast(null as struct<feeName:string,feeCode:string,feeAmount:string>) as fee_struct
                        ,struct(
                            'JUROS_MORA_ATRASO' as chargeType,
                            cast(cast(sum(if(fee_type = 3, repay_amount, 0)) as decimal(30, 4)) as string) as chargeAmount
                        ) AS charge_struct
                from credit.ods__credit_core_debt_br_db__repay_flow_tab
                where fee_type = 3
                group by 1,2,3
                union all 
                select  relate_biz_id
                        ,debt_no
                        ,plan_no
                        ,cast(null as struct<feeName:string,feeCode:string,feeAmount:string>) as fee_struct
                        ,struct(
                            'MULTA_ATRASO_PAGAMENTO' as chargeType,
                            cast(cast(sum(if(fee_type = 4, repay_amount, 0)) as decimal(30, 4)) as string) as chargeAmount
                        ) AS charge_struct
                from credit.ods__credit_core_debt_br_db__repay_flow_tab
                where fee_type = 4
                group by 1,2,3
                union all 
                select  relate_biz_id
                        ,debt_no
                        ,plan_no
                        ,cast(null as struct<feeName:string,feeCode:string,feeAmount:string>) as fee_struct
                        ,struct(
                            'IOF_CONTRATACAO' as chargeType,
                            cast(cast(sum(if(fee_type = 16, repay_amount, 0)) as decimal(30, 4)) as string) as chargeAmount
                        ) AS charge_struct
                from credit.ods__credit_core_debt_br_db__repay_flow_tab
                where fee_type = 16
                group by 1,2,3
            )
            group by 1,2,3
            union all 
            select  relate_biz_id
                    ,debt_no
                    ,plan_no
                    ,filter(collect_list(null), x -> x is not null) AS fees_array
                    ,filter(collect_list(charge_struct), x -> x is not null) AS charges_array
            from (
                select  relate_biz_id
                        ,debt_no
                        ,plan_no
                        ,struct(
                            'null' as feeName,
                            'null' as feeCode,
                            cast(cast(sum(if(fee_type = 1, repay_amount, 0)) as decimal(30, 4)) as string) as feeAmount
                        ) AS fee_struct
                        ,cast(null as struct<chargeType:string,chargeAmount:string>) as charge_struct
                from credit.ods__credit_core_debt_cl_br_db__repay_flow_tab
                where fee_type = 1
                group by 1,2,3
                union all 
                select  relate_biz_id
                        ,debt_no
                        ,plan_no
                        ,cast(null as struct<feeName:string,feeCode:string,feeAmount:string>) as fee_struct
                        ,struct(
                            'JUROS_REMUNERATORIOS_POR_ATRASO' as chargeType,
                            cast(cast(sum(if(fee_type = 2, repay_amount, 0)) as decimal(30, 4)) as string) as chargeAmount
                        ) AS charge_struct
                from credit.ods__credit_core_debt_cl_br_db__repay_flow_tab
                where fee_type = 2
                group by 1,2,3
                union all 
                select  relate_biz_id
                        ,debt_no
                        ,plan_no
                        ,cast(null as struct<feeName:string,feeCode:string,feeAmount:string>) as fee_struct
                        ,struct(
                            'JUROS_MORA_ATRASO' as chargeType,
                            cast(cast(sum(if(fee_type = 3, repay_amount, 0)) as decimal(30, 4)) as string) as chargeAmount
                        ) AS charge_struct
                from credit.ods__credit_core_debt_cl_br_db__repay_flow_tab
                where fee_type = 3
                group by 1,2,3
                union all 
                select  relate_biz_id
                        ,debt_no
                        ,plan_no
                        ,cast(null as struct<feeName:string,feeCode:string,feeAmount:string>) as fee_struct
                        ,struct(
                            'MULTA_ATRASO_PAGAMENTO' as chargeType,
                            cast(cast(sum(if(fee_type = 4, repay_amount, 0)) as decimal(30, 4)) as string) as chargeAmount
                        ) AS charge_struct
                from credit.ods__credit_core_debt_cl_br_db__repay_flow_tab
                where fee_type = 4
                group by 1,2,3
                union all 
                select  relate_biz_id
                        ,debt_no
                        ,plan_no
                        ,cast(null as struct<feeName:string,feeCode:string,feeAmount:string>) as fee_struct
                        ,struct(
                            'IOF_CONTRATACAO' as chargeType,
                            cast(cast(sum(if(fee_type = 16, repay_amount, 0)) as decimal(30, 4)) as string) as chargeAmount
                        ) AS charge_struct
                from credit.ods__credit_core_debt_cl_br_db__repay_flow_tab
                where fee_type = 16
                group by 1,2,3
            )
            group by 1,2,3
        ) t2 on t1.relate_biz_id = t2.relate_biz_id and t1.debt_no = t2.debt_no and t1.plan_no = t2.plan_no
        left join (
            select distinct loan_no, loan_outstanding from credit.ods__credit_core_debt_br_db__loan_tab
            union all 
            select distinct loan_no, loan_outstanding from credit.ods__credit_core_debt_cl_br_db__loan_tab
        ) t3 on t1.debt_no = t3.loan_no
    )
)


insert overwrite ${SCHEMA}.ads_risk_br_openfinance_contract_payment_df partition(grass_date='${ds}')
select *
from (
    select  t1.credit_user_id                   
        ,t1.loan_id     
        ,t2.instalment_id
        ,t1.contract_id                    
        ,t2.related_biz_id    
        ,t1.product_type                   
        -- API 
        ,t2.repayment
    from (
        select loan_id
                ,credit_user_id
                ,contract_id
                ,product_type
        from credit.ods__credit_funding_transaction_br_db__loan_application_request_tab
        where product_type in ('SPL', 'BCL', 'SCL')
    ) t1
    right join
    (
        select loan_id
            ,user_id 
            ,related_biz_id
            ,instalment_id
            ,repayment 
        from   payments_info
    ) t2
    on t1.loan_id = t2.loan_id and t1.credit_user_id = t2.user_id
)
where related_biz_id is not null and product_type <> 'SCL'