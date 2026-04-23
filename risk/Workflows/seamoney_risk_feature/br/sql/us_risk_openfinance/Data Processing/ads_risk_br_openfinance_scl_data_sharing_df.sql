-- add jar hdfs://D2/projects/credit/hdfs/udf/hive-udf.jar; 
-- drop temporary function if exists format_time; 
-- create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

SET spark.sql.session.timeZone = America/Sao_Paulo;

drop table if exists ${SCHEMA}.ads_risk_br_openfinance_scl_data_sharing_df;
create external table if not exists ${SCHEMA}.ads_risk_br_openfinance_scl_data_sharing_df
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
)partitioned by(
    grass_date                      string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION 'hdfs://D2/projects/risk/hdfs/dev/ads/ads_risk_br_openfinance_scl_data_sharing_df/grass_region=BR'
;

msck repair table ${SCHEMA}.ads_risk_br_openfinance_scl_data_sharing_df;
refresh table ${SCHEMA}.ads_risk_br_openfinance_scl_data_sharing_df;


-- /contracts (loan)
with loan_info as (
    select t3.user_id, t5.cpf as id_card_no, t3.loan_no as loan_id, t2.contract_id, t2.product_type, t2.create_time_ts
            , t5.user_name as user_name
            ,CASE 
            WHEN product_type = 'SPL' THEN 
                to_json(named_struct(
                    'contractId', contract_id,
                    'productType', br_product_type,
                    'productSubType', product_sub_type,
                    'ipocCode', concat('48751854', product_code, '1', cast(t5.cpf as string), contract_id)
                ))
            WHEN product_type IN ('BCL', 'SCL') THEN 
                to_json(named_struct(
                    'contractId', contract_id,
                    'productType', br_product_type,
                    'productSubType', product_sub_type,
                    'productSubTypeCategory', 'CREDITO_PESSOAL_CLEAN',
                    'ipocCode', concat('48751854', product_code, '1', cast(t5.cpf as string), contract_id)
                ))
            END AS contracts

            -- if(product_type = 'SCL', t5.cpf, t1.id_card_no)
    from (
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
        where product_type in ('SCL')
          and grass_date = '${ds}'
        -- and match_status = 500
    ) t2 
    right join (
        select user_id, loan_no, cast(cast(get_json_object(extra_cal_rate, '$.1') as decimal(30, 6)) as string) as cet, cast(cast(POWER(1 + CAST(get_json_object(extra_cal_rate, '$.2') AS DOUBLE), 1.0 / 12) - 1 as decimal(30, 6)) as string) AS eir
        from credit.ods__credit_core_debt_cl_br_db__loan_tab__df
        where grass_date = '${ds}'
          and biz_type = 2
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
    left join (
        select credit_user_id, user_name, cpf
        from ${SCHEMA}.dim_risk_br_openfinance_scl_user_cpf_mapping_df
        where grass_date = '${ds}'
    ) t5 on t2.credit_user_id = t5.credit_user_id
    where contract_id is not null
)

insert overwrite ${SCHEMA}.ads_risk_br_openfinance_scl_data_sharing_df partition (grass_date = '${ds}')
select t1.user_id, t1.id_card_no, t1.loan_id, t1.contract_id, t1.product_type, t1.create_time_ts, t1.user_name
        ,t1.contracts                                      
from (
    select  user_id, id_card_no, loan_id, contract_id, product_type, contracts, create_time_ts, user_name
    from loan_info
)  t1
;