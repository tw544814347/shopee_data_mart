--********************************************************************--
-- Author:              chenyingying@shopee.com
-- Created Time:        2025-11-13T14:00:00
-- Theme Domain：       openfinance data
-- Description:         DWS层, openfinance data receive, 聚合为risk开发的input feature格式, 按照CPF关联打宽
-- Data Granularity:    flow_no + platform_user_id(shopee_user_id) 
-- 变更历史：
--********************************************************************--

-- drop table if exists ${SCHEMA}.dws_risk_br_openfinance_request_df;
create external table if not exists ${SCHEMA}.dws_risk_br_openfinance_request_df (
        flow_no                                          string comment 'flow no corresponding to onlinse feature service'
        ,shopee_user_id                                  string   comment 'shopee user id'
        ,cpf                                            string   comment 'BR user id card no'
        ,request_date                                   string   comment 'reuqest date'
        ,request_time                                   string   comment 'request time'
        ,get_open_finance_personal_account_data         string   comment 'openfinance account API data'
        ,get_open_finance_personal_loan_data            string   comment 'openfinance loan API data'
        ,get_open_finance_personal_financing_data       string   comment 'openfinance financing API data'
        ,get_open_finance_personal_registration_data    string   comment 'openfinance personal API data'
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
location '${HDFS_PATH}/risk_mart/dws/dws_risk_openfinance_request_df/grass_region=BR/';
-- msck repair table ${SCHEMA}.dws_risk_br_openfinance_request_df;

insert overwrite ${SCHEMA}.dws_risk_br_openfinance_request_df partition (grass_date = '${ds}')
select  t1.flow_no
        ,t1.shopee_user_id
        ,t1.cpf
        ,t1.request_date
        ,t1.request_time
        ,t2.get_open_finance_personal_account_data
        ,t3.get_open_finance_personal_loan_data
        ,t4.get_open_finance_personal_financing_data
        ,t5.get_open_finance_personal_registration_data
from (
    select  flow_no
            ,cpf
            ,request_date
            ,request_time
            ,shopee_user_id
    from (
        select  flow_no
                ,cpf
                ,request_date
                ,request_time
                ,shopee_user_id 
                ,row_number() over(partition by flow_no, shopee_user_id order by request_time desc) as rn
        from    risk.dwd_risk_br_openfinance_request_df
        where   grass_date = '${ds}'

    )
    where rn = 1
) t1 left join (
    select  shopee_user_id
            ,cpf
            ,flow_no
            ,data as get_open_finance_personal_account_data
    from risk.dwd_risk_br_openfinance_request_account_df
    where grass_date = '${ds}'
) t2 on t1.flow_no = t2.flow_no  
left join (
    select  shopee_user_id
            ,cpf
            ,flow_no
            ,data as get_open_finance_personal_loan_data
    from risk.dwd_risk_br_openfinance_request_loan_df
    where grass_date = '${ds}'
) t3 on t1.flow_no = t3.flow_no 
left join (
    select  shopee_user_id
            ,cpf
            ,flow_no
            ,data as get_open_finance_personal_financing_data
    from risk.dwd_risk_br_openfinance_request_financing_df
    where grass_date = '${ds}'
) t4 on t1.flow_no = t4.flow_no 
left join (
    select  shopee_user_id
            ,cpf
            ,flow_no
            ,data as get_open_finance_personal_registration_data
    from risk.dwd_risk_br_openfinance_request_registration_df
    where grass_date = '${ds}'
) t5 on t1.flow_no = t5.flow_no 