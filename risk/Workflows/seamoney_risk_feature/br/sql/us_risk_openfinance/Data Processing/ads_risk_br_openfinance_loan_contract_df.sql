use ${SCHEMA};
drop table if exists ${SCHEMA}.ads_risk_br_openfinance_loan_contract_df;
create external table if not exists ${SCHEMA}.ads_risk_br_openfinance_loan_contract_df
(
    user_id                          string 
    ,id_card_no                         string 
    ,loan_id                             string 
    ,contract_id                         string 
    ,product_type                     string 
    ,create_time_ts                  bigint 
    ,contracts                      string 
    ,find                           string 
)partitioned by(
    grass_date                      string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION 'hdfs://D2/projects/risk/hdfs/dev/ads/ads_risk_br_openfinance_loan_contract_df/grass_region=BR'
;

msck repair table ${SCHEMA}.ads_risk_br_openfinance_loan_contract_df;
refresh table ${SCHEMA}.ads_risk_br_openfinance_loan_contract_df;


insert overwrite ${SCHEMA}.ads_risk_br_openfinance_loan_contract_df partition (grass_date = '${ds}')
    select t1.user_id, t1.id_card_no, loan_id, t2.contract_id, product_type, t2.create_time_ts
            ,case when product_type = 'SPL' then format_string(
                            '{
                                "contractId": [{"key": "internalResourceId", "value": "%s"}],
                                "productType": "%s",
                                "productSubType": "%s",
                                "ipocCode": "%s"
                            }',
                            contract_id,
                            br_product_type,
                            product_sub_type,   
                            concat('48751854', product_code, '1', cast(id_card_no as string), contract_id)
                        ) 
                    when product_type in ('BCL', 'SCL') then format_string(
                            '{
                                "contractId": [{"key": "internalResourceId", "value": "%s"}],
                                "productType": "%s",
                                "productSubType": "%s",
                                "productSubTypeCategory": "CREDITO_PESSOAL_CLEAN",
                                "ipocCode": "%s"
                            }',
                            contract_id,
                            br_product_type,
                            product_sub_type,   
                            concat('48751854', product_code, '1', cast(id_card_no as string), contract_id)
                        )  
                    end  AS contracts
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
                ),
                    named_struct(
                        'taxType', 'NOMINAL',
                        'interestRateType', interest_rate_type,
                        'taxPeriodicity', tax_periodicity,
                        'calculation', calculation,
                        'referentialRateIndexerType', referential_rate_indexer_type,
                        'preFixedRate', COALESCE(cast(cast(ROUND(12 * (POWER(1 + CAST(t3.eir AS DECIMAL(30, 6)), 1.0/12) - 1), 6) as decimal(30, 6)) as string), '0.000000')
                    )
                ),
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
                    'preFixedRate', t3.annual_eir
                ),
                    named_struct(
                        'taxType', 'NOMINAL',
                        'interestRateType', interest_rate_type,
                        'taxPeriodicity', tax_periodicity,
                        'calculation', calculation,
                        'referentialRateIndexerType', referential_rate_indexer_type,
                        'preFixedRate', COALESCE(
                                            CAST(
                                                CAST(
                                                    ROUND(12 * CAST(t3.eir AS DECIMAL(30,6)), 6)
                                                AS DECIMAL(30,6))
                                            AS STRING),
                                        '0.000000')
                    )
                ),
                'contractedFees', array(),
                'contractedFinanceCharges', array(
                    named_struct('chargeType', charge_type),
                    named_struct('chargeType', charge_type2),
                    named_struct('chargeType', charge_type3),
                    named_struct('chargeType', charge_type4)
                ),
                'hasInsuranceContracted', false,
                'nextInstalmentAmount', named_struct("instalment_list", t4.instalment_list)  -- 写入Hbase, 服务端处理
                -- 'nextInstalmentAmount', nvl(cast(amount as string), '0.00')  
            ))
            END AS find
        from (
        select distinct user_id, id_card_no, id_card_no_encrypt_data
        from credit.ods__credit_usercenter_member_br_db__user_id_card_info_tab
        where id_card_type = 52
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
                ,'AA'                               as tax_periodicity
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

        from credit.ods__credit_funding_transaction_br_db__loan_application_request_tab
        where product_type in ('SPL', 'BCL', 'SCL')
        -- and match_status = 500
    ) t2 on cast(t1.user_id as string) = t2.credit_user_id
    right join (
        select user_id, loan_no, cast(cast(get_json_object(extra_cal_rate, '$.1') as decimal(30, 6)) as string) as cet, cast(cast(POWER(1 + CAST(get_json_object(extra_cal_rate, '$.2') AS DOUBLE), 1.0 / 12) - 1 as decimal(30, 6)) as string) AS eir
               ,cast(CAST(get_json_object(extra_cal_rate, '$.2') AS decimal(30, 6)) as string) as annual_eir
        from credit.ods__credit_core_debt_br_db__loan_tab
        union all 
        select user_id, loan_no, cast(cast(get_json_object(extra_cal_rate, '$.1') as decimal(30, 6)) as string) as cet, cast(cast(POWER(1 + CAST(get_json_object(extra_cal_rate, '$.2') AS DOUBLE), 1.0 / 12) - 1 as decimal(30, 6)) as string) AS eir
               ,cast(CAST(get_json_object(extra_cal_rate, '$.2') AS decimal(30, 6)) as string) as annual_eir
        from credit.ods__credit_core_debt_cl_br_db__loan_tab
        where biz_type = 1
    ) t3 on t2.credit_user_id = t3.user_id and t2.loan_id = t3.loan_no
    left join (
        select user_id, debt_no
                , collect_list(
                    struct(
                        due_date as due_date,
                        amount as amount,
                        plan_no as instalment_id 
                    )
                ) AS instalment_list
        from (
            select t1.user_id, t1.debt_no, t1.plan_no, substr(if(due_date='1970-01-01 00:00:00',null,from_unixtime(unix_timestamp(substr(due_date, 1, 19))+3600* -3,'yyyy-MM-dd HH:mm:ss')), 1, 10) as due_date
                    ,CAST(CAST(
                        principal + interest + fee1 + fee2 + fee3 + fee4 + fee5 + fee6 + fee7 + fee8
                        AS decimal(30, 4)
                    ) AS STRING) as amount
            from (
                select *
                from credit.ods__credit_core_debt_cl_br_db__plan_tab
            ) t1 left join (
                select *
                from credit.ods__credit_core_debt_cl_br_db__plan_money_category_tab
                where money_category = 1
            ) t2 on t1.plan_no = t2.plan_no and t1.user_id = t2.user_id and t1.debt_no = t2.debt_no 
        )
        group by 1,2
    ) t4 on t2.credit_user_id = t4.user_id and t2.loan_id = t4.debt_no
    where contract_id is not null
;
