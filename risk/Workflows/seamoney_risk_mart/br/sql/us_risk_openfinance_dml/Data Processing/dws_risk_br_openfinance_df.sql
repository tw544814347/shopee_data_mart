--********************************************************************--
-- Author:              huangyue@shopee.com
-- Created Time:        2025-09-15T14:00:00
-- Theme Domain：       openfinance data
-- Description:         DWS层, openfinance data receive, 聚合为risk开发的input feature格式, 按照CPF关联打宽
-- Data Granularity:    cpf 
-- 变更历史：
--********************************************************************--

-- drop table if exists ${SCHEMA}.dws_risk_br_openfinance_df;
create external table if not exists ${SCHEMA}.dws_risk_br_openfinance_df (
        shopee_user_id                                  string   comment 'shopee user id'
        ,cpf                                            string   comment 'BR user id card no'
        ,request_date                                   string   comment 'reuqest date'
        ,request_time                                   string   comment 'request time'
        ,get_open_finance_personal_account_data         string   comment 'openfinance account API data'
        ,get_open_finance_personal_loan_data            string   comment 'openfinance loan API data'
        ,get_open_finance_personal_financing_data       string   comment 'openfinance financing API data'
        ,get_open_finance_personal_registration_data    string   comment 'openfinance personal API data'
        ,get_open_finance_personal_credit_card_data     string   comment 'openfinance credit card account API data'
)
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd","orc.stripe.size"="268435456"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_openfinance_df/grass_region=BR/';
-- msck repair table ${SCHEMA}.dws_risk_br_openfinance_df;

insert overwrite ${SCHEMA}.dws_risk_br_openfinance_df partition (grass_date = '${ds}')
select  t1.shopee_user_id
        ,t1.cpf
        ,t1.request_date
        ,t1.request_time
        ,t2.get_open_finance_personal_account_data
        ,t3.get_open_finance_personal_loan_data
        ,t4.get_open_finance_personal_financing_data
        ,t5.get_open_finance_personal_registration_data
        ,t6.get_open_finance_personal_credit_card_data
from (
    select cpf
            ,request_date
            ,request_time
            ,shopee_user_id
    from (
        select  cpf
                ,shopee_user_id
                ,request_time
                ,request_date
                ,row_number() over(partition by cpf, shopee_user_id order by request_time desc) as rn
        from    risk.dwd_risk_br_openfinance_df
        where grass_date = '${ds}'
    )
    where rn = 1
) t1 left join (
    select  shopee_user_id
            ,cpf
            ,data as get_open_finance_personal_account_data
    from risk.dwd_risk_br_openfinance_account_df
    where grass_date = '${ds}'
) t2 on t1.cpf = t2.cpf  
and t1.shopee_user_id = t2.shopee_user_id
left join (
    select  shopee_user_id
            ,cpf
            ,data as get_open_finance_personal_loan_data
    from risk.dwd_risk_br_openfinance_loan_df
    where grass_date = '${ds}'
) t3 on t1.cpf = t3.cpf 
and t1.shopee_user_id = t3.shopee_user_id
left join (
    select  shopee_user_id
            ,cpf
            ,data as get_open_finance_personal_financing_data
    from risk.dwd_risk_br_openfinance_financing_df
    where grass_date = '${ds}'
) t4 on t1.cpf = t4.cpf 
and t1.shopee_user_id = t4.shopee_user_id
left join (
    select  shopee_user_id
            ,cpf
            ,data as get_open_finance_personal_registration_data
    from risk.dwd_risk_br_openfinance_registration_df
    where grass_date = '${ds}'
) t5 on t1.cpf = t5.cpf 
and t1.shopee_user_id = t5.shopee_user_id
left join (
    select  shopee_user_id
            ,cpf
            ,data as get_open_finance_personal_credit_card_data
    from    risk.dwd_risk_br_openfinance_credit_card_df
    where   grass_date = '${ds}'
) t6
on t1.cpf = t6.cpf 
and t1.shopee_user_id = t6.shopee_user_id
