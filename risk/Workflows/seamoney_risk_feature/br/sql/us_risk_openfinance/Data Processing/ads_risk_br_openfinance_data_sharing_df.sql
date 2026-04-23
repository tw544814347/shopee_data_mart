-- add jar hdfs://D2/projects/credit/hdfs/udf/hive-udf.jar; 
-- drop temporary function if exists format_time; 
-- create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

SET spark.sql.session.timeZone = America/Sao_Paulo;

drop table if exists ${SCHEMA}.ads_risk_br_openfinance_data_sharing_df;
create external table if not exists ${SCHEMA}.ads_risk_br_openfinance_data_sharing_df
(    
    credit_user_id                  string 
    ,cpf                            string 
    ,loan_id                        string 
    ,contract_id                    string
    ,product_type                   string
    ,create_time_ts                 bigint
    ,user_name                      string 
    -- API 
    ,contracts                      string 
    ,find                           string 
    ,scheduled_instalments          string 
    ,payments                       string
)partitioned by(
    grass_date                      string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION 'hdfs://D2/projects/risk/hdfs/dev/ads/ads_risk_br_openfinance_data_sharing_df/grass_region=BR'
;

msck repair table ${SCHEMA}.ads_risk_br_openfinance_data_sharing_df;
refresh table ${SCHEMA}.ads_risk_br_openfinance_data_sharing_df;


-- /contracts (loan)
with loan_info as (
    select t1.user_id, t1.id_card_no, loan_id, t2.contract_id, product_type, t2.create_time_ts, t1.user_name
            ,CASE 
            WHEN product_type = 'SPL' THEN 
                to_json(named_struct(
                    'contractId', contract_id,
                    'productType', br_product_type,
                    'productSubType', product_sub_type,
                    'ipocCode', concat('48751854', product_code, '1', cast(id_card_no as string), contract_id)
                ))
            WHEN product_type IN ('BCL', 'SCL') THEN 
                to_json(named_struct(
                    'contractId', contract_id,
                    'productType', br_product_type,
                    'productSubType', product_sub_type,
                    'productSubTypeCategory', 'CREDITO_PESSOAL_CLEAN',
                    'ipocCode', concat('48751854', product_code, '1', cast(id_card_no as string), contract_id)
                ))
            END AS contracts
    -- /find (loan)

        ,CASE WHEN product_type = 'SPL' THEN to_json(named_struct(
                'contractNumber', contract_id,
                'ipocCode', concat('48751854', product_code, '1', cast(id_card_no as string), contract_id),
                'productName', product_name,
                'productType', br_product_type,
                'productSubType', product_sub_type,
                'contractDate', substr(create_time, 1, 10),
                'contractAmount', total_principal,
                'instalmentPeriodicity', instalment_periodicity,
                'CET', t3.cet,
                'amortizationScheduled', amortization_scheduled,
                'interestRates', array(named_struct(
                    'taxType', tax_type,
                    'interestRateType', interest_rate_type,
                    'taxPeriodicity', tax_periodicity,
                    'calculation', calculation,
                    'referentialRateIndexerType', referential_rate_indexer_type,
                    'preFixedRate', t3.eir
                )),
                'contractedFees', array(),  -- 空数组
                'contractedFinanceCharges', array(
                    named_struct('chargeType', charge_type),
                    named_struct('chargeType', charge_type2),
                    named_struct('chargeType', charge_type3),
                    named_struct('chargeType', charge_type4)
                )
            ))

            WHEN product_type IN ('BCL', 'SCL') THEN to_json(named_struct(
                'contractNumber', contract_id,
                'ipocCode', concat('48751854', product_code, '1', cast(id_card_no as string), contract_id),
                'productName', product_name,
                'productType', br_product_type,
                'productSubType', product_sub_type,
                'productSubTypeCategory', 'CREDITO_PESSOAL_CLEAN',
                'contractDate', substr(create_time, 1, 10),
                'contractAmount', cast(total_principal as string) ,
                'instalmentPeriodicity', instalment_periodicity,
                'CET', t3.cet,
                'amortizationScheduled', amortization_scheduled,
                'cnpjConsignee', '48751854000136',
                'interestRates', array(named_struct(
                    'taxType', tax_type,
                    'interestRateType', interest_rate_type,
                    'taxPeriodicity', tax_periodicity,
                    'calculation', calculation,
                    'referentialRateIndexerType', referential_rate_indexer_type,
                    'preFixedRate', t3.eir
                )),
                'contractedFees', array(),
                'contractedFinanceCharges', array(
                    named_struct('chargeType', charge_type),
                    named_struct('chargeType', charge_type2),
                    named_struct('chargeType', charge_type3),
                    named_struct('chargeType', charge_type4)
                ),
                'hasInsuranceContracted', false,
                -- 'nextInstalmentAmount', named_struct("instalment_list", t4.instalment_list)  -- 写入Hbase, 服务端处理
                'nextInstalmentAmount', nvl(cast(next_instalment_total_amount_repayable as string), '0.00')  
            ))
            END AS find
    
    -- /scheduled-instalments (loan)
    from (
        select distinct user_id, id_card_no, id_card_no_encrypt_data, replace(user_name, ' ', '|') as user_name
        from credit.ods__credit_usercenter_member_br_db__user_id_card_info_tab__df
        where id_card_type = 52
         and grass_date = '${ds}'
    ) t1 left join (
        select  credit_user_id
                ,product_type
                ,to_unix_timestamp(if(create_time='1970-01-01 00:00:00',null,from_unixtime(unix_timestamp(substr(create_time, 1, 19))+3600* -3,'yyyy-MM-dd HH:mm:ss'))) * 1000 as create_time_ts -- ms级别
                ,case when product_type = 'SPL' then 'FINANCIAMENTOS'
                      when product_type = 'BCL' then 'EMPRESTIMOS'
                      when product_type = 'SCL' then 'EMPRESTIMOS'
                      else null 
                end as br_product_type
                ,contract_id
                ,loan_id
                ,case when product_type = 'SPL' then '0402'
                      when product_type = 'BCL' then '0203'
                      when product_type = 'SCL' then '0215'
                      else null 
                end as product_code
                ,if(create_time='1970-01-01 00:00:00',null,from_unixtime(unix_timestamp(substr(create_time, 1, 19))+3600* -3,'yyyy-MM-dd HH:mm:ss')) as create_time
                ,cast(cast(total_principal as decimal(30, 4)) as string) as total_principal
                ,case when product_type = 'SPL' then 'SParcelado'
                      when product_type = 'BCL' then 'SCrédito'
                      when product_type = 'SCL' then 'Empréstimo para Vendedores'
                      else null 
                end as product_name            
                ,case when product_type = 'SPL' then 'AQUISICAO_BENS_OUTROS_BENS'
                      when product_type = 'BCL' then 'CREDITO_PESSOAL_SEM_CONSIGNACAO'
                      when product_type = 'SCL' then 'CREDITO_PESSOAL_SEM_CONSIGNACAO'
                      else null 
                end as product_sub_type  
                ,'PRICE'                            as amortization_scheduled           
                ,'COMPOSTO'                         as interest_rate_type          
                ,'AM'                               as tax_periodicity
                ,'30/365'                           as calculation
                ,'PRE_FIXADO'                       as referential_rate_indexer_type
                ,'0.000000'                         as post_fixed_rate
                ,'POR_PARCELA'                      as fee_charge_type1             
                ,'PERCENTUAL'                       as fee_charge1       

                ,'MENSAL'                                                        as instalment_periodicity   
                ,'EFETIVA'                                                       as tax_type                
                -- ,''                                                              as fee_name1                -- 待确定
                -- ,''                                                              as fee_code1                -- 待确定
                ,'JUROS_REMUNERATORIOS_POR_ATRASO'                               as charge_type              -- 待确定
                ,'JUROS_MORA_ATRASO'                                             as charge_type2              -- 待确定
                ,'MULTA_ATRASO_PAGAMENTO'                                        as charge_type3              -- 待确定
                ,'IOF_CONTRATACAO'                                               as charge_type4              -- 待确定

        from credit.ods__credit_funding_transaction_br_db__loan_application_request_tab__df
        where product_type in ('SPL', 'BCL', 'SCL')
          and grass_date = '${ds}'
        -- and match_status = 500
    ) t2 on cast(t1.user_id as string) = t2.credit_user_id
    right join (
        select user_id, loan_no, cast(cast(get_json_object(extra_cal_rate, '$.1') as decimal(30, 6)) as string) as cet, cast(cast(POWER(1 + CAST(get_json_object(extra_cal_rate, '$.2') AS DOUBLE), 1.0 / 12) - 1 as decimal(30, 6)) as string) AS eir
        from credit.ods__credit_core_debt_br_db__loan_tab__df
        where grass_date = '${ds}'
        union all 
        select user_id, loan_no, cast(cast(get_json_object(extra_cal_rate, '$.1') as decimal(30, 6)) as string) as cet, cast(cast(POWER(1 + CAST(get_json_object(extra_cal_rate, '$.2') AS DOUBLE), 1.0 / 12) - 1 as decimal(30, 6)) as string) AS eir
        from credit.ods__credit_core_debt_cl_br_db__loan_tab__df
        where grass_date = '${ds}'
          and biz_type = 1
    ) t3 on t2.credit_user_id = t3.user_id and t2.loan_id = t3.loan_no
    left join (
        select distinct user_id, debt_no, first_value(amount) OVER (PARTITION BY user_id, debt_no order by due_date asc) AS next_instalment_total_amount_repayable
        from (
            select t1.user_id, t1.debt_no, t1.plan_no, substr(if(due_date='1970-01-01 00:00:00',null,from_unixtime(unix_timestamp(substr(due_date, 1, 19))+3600* -3,'yyyy-MM-dd HH:mm:ss')), 1, 10) as due_date
                    ,CAST(CAST(
                        principal + interest + fee1 + fee2 + fee3 + fee4 + fee5 + fee6 + fee7 + fee8
                        AS DECIMAL(30, 4)
                    ) AS STRING) as amount
            from (
                select *
                from credit.ods__credit_core_debt_cl_br_db__plan_tab__df
                where grass_date = '${ds}'
            ) t1 left join (
                select *
                from credit.ods__credit_core_debt_cl_br_db__plan_money_category_tab__df
                where money_category = 1
                  and grass_date = '${ds}'
            ) t2 on t1.plan_no = t2.plan_no and t1.user_id = t2.user_id and t1.debt_no = t2.debt_no 
            where substr(if(due_date='1970-01-01 00:00:00',null,from_unixtime(unix_timestamp(substr(due_date, 1, 19))+3600* -3,'yyyy-MM-dd HH:mm:ss')), 1, 10) >= substr(current_date(), 1, 10)
        )
    ) t4 on t2.credit_user_id = t4.user_id and t2.loan_id = t4.debt_no
    --     select user_id, debt_no
    --             , collect_list(
    --                 struct(
    --                     due_date as due_date,
    --                     amount as value,
    --                     plan_no as instalment_id 
    --                 )
    --             ) AS instalment_list
    --     from (
    --         select t1.user_id, t1.debt_no, t1.plan_no, substr(if(due_date='1970-01-01 00:00:00',null,from_unixtime(unix_timestamp(substr(due_date, 1, 19))+3600* -3,'yyyy-MM-dd HH:mm:ss')), 1, 10) as due_date
    --                 ,CAST(CAST(
    --                     principal + interest + fee1 + fee2 + fee3 + fee4 + fee5 + fee6 + fee7 + fee8
    --                     AS decimal(30, 4)
    --                 ) AS STRING) as amount
    --         from (
    --             select *
    --             from credit.ods__credit_core_debt_cl_br_db__plan_tab
    --         ) t1 left join (
    --             select *
    --             from credit.ods__credit_core_debt_cl_br_db__plan_money_category_tab
    --             where money_category = 1
    --         ) t2 on t1.plan_no = t2.plan_no and t1.user_id = t2.user_id and t1.debt_no = t2.debt_no 
    --     )
    --     group by 1,2
    -- ) t4 on t2.credit_user_id = t4.user_id and t2.loan_id = t4.debt_no
    where contract_id is not null
),

scheduled_info as (
    select  user_id 
            ,debt_no as loan_id
            ,product_type
            ,to_json(struct(
                'MES' as typeNumberOfInstalments,
                cast(total_instalments as int) as totalNumberOfInstalments,
                'MES' as typeContractRemaining,
                cast(remaining_instalments as int) as contractRemainingNumber,
                cast(paid_instaments as int) as paidInstalments,
                cast(due_instalments as int) as dueInstalments,
                cast(pastdue_instalments as int) as pastDueInstalments,
                from_json(balloon_payment, 'array<struct<dueDate:string,amount:struct<amount:string,currency:string>>>') as balloonPayments
            )) as scheduled_instalments
    from (
        select  tt1.user_id 
                ,tt1.debt_no
                ,tt1.product_type
                ,count(distinct tt1.plan_no) as total_instalments
                ,sum(if(clear_status = 3, 1, 0)) as paid_instaments
                ,sum(if(clear_status in (1, 2), 1, 0)) as due_instalments
                ,sum(if(overdue_status = 1, 1, 0)) as pastdue_instalments
                ,sum(if(substr(current_date(), 1, 10) <= due_date, 1, 0)) as remaining_instalments
                ,to_json(collect_list(
                    struct(
                        tt1.due_date as dueDate,
                        struct(
                            cast(cast(tt2.sum_amount as decimal(30, 4)) as string) as amount,
                            'BRL' as currency
                        ) as amount
                    )
                )) AS balloon_payment
        from (
            select  user_id, debt_no, plan_no, clear_status, overdue_status
                    , substr(if(due_date='1970-01-01 00:00:00',null,from_unixtime(unix_timestamp(substr(due_date, 1, 19))+3600* -3,'yyyy-MM-dd HH:mm:ss')), 1, 10) as due_date
                    ,case when biz_type = 1 then 'BCL'
                            when biz_type = 2 then 'SCL'
                            when biz_type = 3 then 'SPL'
                            else null 
                        end as product_type 
            from credit.ods__credit_core_debt_br_db__plan_tab__df 
            where grass_date = '${ds}'
            union all 
            select user_id, debt_no, plan_no, clear_status, overdue_status
                    , substr(if(due_date='1970-01-01 00:00:00',null,from_unixtime(unix_timestamp(substr(due_date, 1, 19))+3600* -3,'yyyy-MM-dd HH:mm:ss')), 1, 10) as due_date
                    ,case when biz_type = 1 then 'BCL'
                            when biz_type = 2 then 'SCL'
                            when biz_type = 3 then 'SPL'
                            else null 
                        end as product_type 
            from credit.ods__credit_core_debt_cl_br_db__plan_tab__df
            where grass_date = '${ds}'
        ) tt1 left join (
            select user_id, debt_no, plan_no, cast(principal+interest+fee1+fee2+fee3+fee4+fee5+fee6+fee7+fee8 as decimal(30, 4)) as sum_amount
            from credit.ods__credit_core_debt_br_db__plan_money_category_tab__df
            where money_category = 1
              and grass_date = '${ds}'
            union all 
            select user_id, debt_no, plan_no, cast(principal+interest+fee1+fee2+fee3+fee4+fee5+fee6+fee7+fee8 as decimal(30, 4)) as sum_amount
            from credit.ods__credit_core_debt_cl_br_db__plan_money_category_tab__df
            where money_category = 1
              and grass_date = '${ds}'
        ) tt2 on tt1.user_id = tt2.user_id and tt1.debt_no = tt2.debt_no and tt1.plan_no = tt2.plan_no
        group by tt1.user_id ,tt1.debt_no,tt1.product_type
    )
),

payments_info as (
    select  loan_id
            ,user_id 
            ,product_type
            ,to_json(struct(
                cast(cast(loan_outstanding as decimal(30, 4)) as string) as contractOutstandingBalance,
                max(update_os_time) as lastUpdatedContractOutstandingBalance,
                cast(remaining_amount as string) as totalRemainingAmount,
                collect_list(
                    struct(
                        array(struct(
                            'repayId' as key,
                            payment_id as value
                        )) as paymentId,
                        cast(is_over_parcel_payment as boolean) as isOverParcelPayment,
                        from_json(instalment_info, 'array<struct<key:string,value:string>>') as instalmentId,
                        paid_date as paidDate,
                        currency as currency,
                        paid_amount as paidAmount,
                        from_json(over_parcel, 'struct<fees:array<struct<feeName:string,feeCode:string,feeAmount:string>>,charges:array<struct<chargeType:string,chargeAmount:string>>>') as overParcel
                    )
                ) as releases
            )) AS payments
    from (
        select  t1.user_id 
                ,t1.product_type
                ,t1.relate_biz_id as payment_id 
                ,t1.debt_no      as loan_id 
                ,'true'          as is_over_parcel_payment
                ,t1.instalment_info
                ,t1.paid_date
                ,t1.update_os_time
                ,t4.remaining_amount
                ,t1.currency
                ,cast(cast(t1.paid_amount as decimal(30,4)) as string) as paid_amount
                ,to_json(struct(
                    t2.fees_array as fees,
                    t2.charges_array as charges
                )) AS over_parcel
                ,cast(cast(t3.loan_outstanding as decimal(30, 4)) as string) as loan_outstanding
        from (
            select  relate_biz_id
                    ,debt_no
                    ,paid_date
                    ,update_os_time
                    ,'BRL' as currency
                    ,product_type
                    ,user_id
                    ,to_json(collect_list(
                        struct(
                            'planNo' as key,
                            plan_no as value
                        )
                    )) AS instalment_info
                    ,sum(repay_amount) as paid_amount
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
                                'HH:mm:ss'
                                ),
                                'Z'
                            )
                        ) as update_os_time
                        ,sum(repay_amount) as repay_amount
                    from credit.ods__credit_core_debt_br_db__repay_flow_tab__df
                    where grass_date = '${ds}'
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
                                    'HH:mm:ss'
                                    ),
                                    'Z'
                                )
                            ) as update_os_time
                            ,sum(repay_amount) as repay_amount
                    from credit.ods__credit_core_debt_cl_br_db__repay_flow_tab__df
                    where grass_date = '${ds}'
                    group by 1,2,3,4,5,6,7
                )
                group by 1,2,3,4,5,6,7
        ) t1 left join (
            select  relate_biz_id
                    ,debt_no
                    ,filter(collect_list(null), x -> x is not null) AS fees_array
                    ,filter(collect_list(charge_struct), x -> x is not null) AS charges_array
            from (
            select  relate_biz_id
                    ,debt_no
                    ,struct(
                        'null' as feeName,
                        'null' as feeCode,
                        cast(cast(sum(if(fee_type = 1, repay_amount, 0)) as decimal(30, 4)) as string) as feeAmount
                    ) AS fee_struct
                    ,cast(null as struct<chargeType:string,chargeAmount:string>) as charge_struct
            from credit.ods__credit_core_debt_br_db__repay_flow_tab__df
            where fee_type = 1
            and grass_date = '${ds}'
            group by 1,2
            union all 
            select  relate_biz_id
                    ,debt_no
                    ,cast(null as struct<feeName:string,feeCode:string,feeAmount:string>) as fee_struct
                    ,struct(
                        'JUROS_REMUNERATORIOS_POR_ATRASO' as chargeType,
                        cast(cast(sum(if(fee_type = 2, repay_amount, 0)) as decimal(30, 4)) as string) as chargeAmount
                    ) AS charge_struct
            from credit.ods__credit_core_debt_br_db__repay_flow_tab__df 
            where fee_type = 2
              and grass_date = '${ds}'
            group by 1,2
            union all 
            select  relate_biz_id
                    ,debt_no
                    ,cast(null as struct<feeName:string,feeCode:string,feeAmount:string>) as fee_struct
                    ,struct(
                        'JUROS_MORA_ATRASO' as chargeType,
                        cast(cast(sum(if(fee_type = 3, repay_amount, 0)) as decimal(30, 4)) as string) as chargeAmount
                    ) AS charge_struct
            from credit.ods__credit_core_debt_br_db__repay_flow_tab__df 
            where fee_type = 3
            and grass_date = '${ds}'
            group by 1,2
            union all 
            select  relate_biz_id
                    ,debt_no
                    ,cast(null as struct<feeName:string,feeCode:string,feeAmount:string>) as fee_struct
                    ,struct(
                        'MULTA_ATRASO_PAGAMENTO' as chargeType,
                        cast(cast(sum(if(fee_type = 4, repay_amount, 0)) as decimal(30, 4)) as string) as chargeAmount
                    ) AS charge_struct
            from credit.ods__credit_core_debt_br_db__repay_flow_tab__df 
            where fee_type = 4
             and grass_date = '${ds}'
            group by 1,2
            union all 
            select  relate_biz_id
                    ,debt_no
                    ,cast(null as struct<feeName:string,feeCode:string,feeAmount:string>) as fee_struct
                    ,struct(
                        'IOF_CONTRATACAO' as chargeType,
                        cast(cast(sum(if(fee_type = 16, repay_amount, 0)) as decimal(30, 4)) as string) as chargeAmount
                    ) AS charge_struct
            from credit.ods__credit_core_debt_br_db__repay_flow_tab__df 
            where fee_type = 16
              and grass_date = '${ds}'
            group by 1,2
        )
        group by 1,2
        union all 
        select  relate_biz_id
                ,debt_no
                ,filter(collect_list(null), x -> x is not null) AS fees_array
                ,filter(collect_list(charge_struct), x -> x is not null) AS charges_array
        from (
            select  relate_biz_id
                    ,debt_no
                    ,struct(
                        'null' as feeName,
                        'null' as feeCode,
                        cast(cast(sum(if(fee_type = 1, repay_amount, 0)) as decimal(30, 4)) as string) as feeAmount
                    ) AS fee_struct
                    ,cast(null as struct<chargeType:string,chargeAmount:string>) as charge_struct
            from credit.ods__credit_core_debt_cl_br_db__repay_flow_tab__df 
            where fee_type = 1
              and grass_date = '${ds}'
            group by 1,2
            union all 
            select  relate_biz_id
                    ,debt_no
                    ,cast(null as struct<feeName:string,feeCode:string,feeAmount:string>) as fee_struct
                    ,struct(
                        'JUROS_REMUNERATORIOS_POR_ATRASO' as chargeType,
                        cast(cast(sum(if(fee_type = 2, repay_amount, 0)) as decimal(30, 4)) as string) as chargeAmount
                    ) AS charge_struct
            from credit.ods__credit_core_debt_cl_br_db__repay_flow_tab__df 
            where fee_type = 2
              and grass_date = '${ds}'
            group by 1,2
            union all 
            select  relate_biz_id
                    ,debt_no
                    ,cast(null as struct<feeName:string,feeCode:string,feeAmount:string>) as fee_struct
                    ,struct(
                        'JUROS_MORA_ATRASO' as chargeType,
                        cast(cast(sum(if(fee_type = 3, repay_amount, 0)) as decimal(30, 4)) as string) as chargeAmount
                    ) AS charge_struct
            from credit.ods__credit_core_debt_cl_br_db__repay_flow_tab__df 
            where fee_type = 3
              and grass_date = '${ds}'
            group by 1,2
            union all 
            select  relate_biz_id
                    ,debt_no
                    ,cast(null as struct<feeName:string,feeCode:string,feeAmount:string>) as fee_struct
                    ,struct(
                        'MULTA_ATRASO_PAGAMENTO' as chargeType,
                        cast(cast(sum(if(fee_type = 4, repay_amount, 0)) as decimal(30, 4)) as string) as chargeAmount
                    ) AS charge_struct
            from credit.ods__credit_core_debt_cl_br_db__repay_flow_tab__df 
            where fee_type = 4
              and grass_date = '${ds}'
            group by 1,2
            union all 
            select  relate_biz_id
                    ,debt_no
                    ,cast(null as struct<feeName:string,feeCode:string,feeAmount:string>) as fee_struct
                    ,struct(
                        'IOF_CONTRATACAO' as chargeType,
                        cast(cast(sum(if(fee_type = 16, repay_amount, 0)) as decimal(30, 4)) as string) as chargeAmount
                    ) AS charge_struct
            from credit.ods__credit_core_debt_cl_br_db__repay_flow_tab__df 
            where fee_type = 16
            and grass_date = '${ds}'
            group by 1,2
            )
            group by 1,2
        ) t2 on t1.relate_biz_id = t2.relate_biz_id and t1.debt_no = t2.debt_no
        left join (
            select distinct loan_no, loan_outstanding from credit.ods__credit_core_debt_br_db__loan_tab__df 
            where grass_date = '${ds}'
            union all 
            select distinct loan_no, loan_outstanding from credit.ods__credit_core_debt_cl_br_db__loan_tab__df 
            where grass_date = '${ds}'
        ) t3 on t1.debt_no = t3.loan_no
        left join (
            select user_id, debt_no, sum(if(money_category=1, CAST(principal + interest + fee1 + fee2 + fee3 + fee4 + fee5 + fee6 + fee7 + fee8 AS decimal(30, 4)), - CAST(principal + interest + fee1 + fee2 + fee3 + fee4 + fee5 + fee6 + fee7 + fee8 AS decimal(30, 4))) ) as remaining_amount
            from credit.ods__credit_core_debt_br_db__plan_money_category_tab__df 
            where grass_date = '${ds}'
            group by 1,2 
            union all 
            select user_id, debt_no, sum(if(money_category=1, CAST(principal + interest + fee1 + fee2 + fee3 + fee4 + fee5 + fee6 + fee7 + fee8 AS decimal(30, 4)), - CAST(principal + interest + fee1 + fee2 + fee3 + fee4 + fee5 + fee6 + fee7 + fee8 AS decimal(30, 4))) ) as remaining_amount
            from credit.ods__credit_core_debt_cl_br_db__plan_money_category_tab__df 
            where grass_date = '${ds}'
            group by 1,2
        ) t4 on t1.user_id = t4.user_id and t1.debt_no = t4.debt_no
    )
    group by user_id, loan_id ,product_type, loan_outstanding, remaining_amount
)

insert overwrite ${SCHEMA}.ads_risk_br_openfinance_data_sharing_df partition (grass_date = '${ds}')
select t1.user_id, t1.id_card_no, t1.loan_id, t1.contract_id, t1.product_type, t1.create_time_ts, t1.user_name
        ,t1.contracts                     
        ,t1.find                          
        ,t2.scheduled_instalments         
        ,t3.payments                      
from (
    select  user_id, id_card_no, loan_id, contract_id, product_type, contracts, find, create_time_ts, user_name
    from loan_info
) t1 left join (
    select user_id, loan_id, product_type, scheduled_instalments 
    from scheduled_info
) t2 on t1.user_id = t2.user_id and t1.loan_id = t2.loan_id 
left join (
    select user_id, loan_id, product_type, payments
    from payments_info
) t3 on t1.user_id = t3.user_id and t1.loan_id = t3.loan_id
;