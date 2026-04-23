

    drop table if exists risk.ods__credit_risk_underwriting_id_db__limit_rate_tab;

    create external table risk.ods__credit_risk_underwriting_id_db__limit_rate_tab
    (
     id                                                                                                   decimal(20,0)        comment ''
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        bigint               comment ''
,app_id                                                                                               bigint               comment 'APP_ID: 1, APP_ID_CASH_LOAN: 2, APP_ID_SELLER_LOAN:3, APP_ID_FAST_ESCROW: 4,APP_ID_PARTNER_LOAN: 5,APP_ID_SPL_LITE:6'
,sub_biz_type                                                                                         string               comment ''
,version                                                                                              bigint               comment ''
,currency_units                                                                                       bigint               comment ''
,operator                                                                                             string               comment ''
,sync_credit_status                                                                                   bigint               comment 'sync UC status'
,event_id                                                                                             string               comment ''
,event_detail                                                                                         string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,activation_source                                                                                    bigint               comment ''
,source                                                                                               string               comment ''
,limit_info                                                                                           string               comment 'sis output of limit info, json'
,installment_info                                                                                     string               comment ''
,rate_info                                                                                            string               comment 'sis output of rate info, json'
,other_info                                                                                           string               comment 'user other info, json'
,notes                                                                                                string               comment ''
     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_underwriting_xx_db/limit_rate_tab__df__temp/grass_region=ID/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_underwriting_id_db__limit_rate_tab;

    

    drop table if exists risk.ods__credit_risk_underwriting_id_db__limit_rate_tab__df;

    create external table risk.ods__credit_risk_underwriting_id_db__limit_rate_tab__df
    (
     id                                                                                                   decimal(20,0)        comment ''
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        bigint               comment ''
,app_id                                                                                               bigint               comment 'APP_ID: 1, APP_ID_CASH_LOAN: 2, APP_ID_SELLER_LOAN:3, APP_ID_FAST_ESCROW: 4,APP_ID_PARTNER_LOAN: 5,APP_ID_SPL_LITE:6'
,sub_biz_type                                                                                         string               comment ''
,version                                                                                              bigint               comment ''
,currency_units                                                                                       bigint               comment ''
,operator                                                                                             string               comment ''
,sync_credit_status                                                                                   bigint               comment 'sync UC status'
,event_id                                                                                             string               comment ''
,event_detail                                                                                         string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,activation_source                                                                                    bigint               comment ''
,source                                                                                               string               comment ''
,limit_info                                                                                           string               comment 'sis output of limit info, json'
,installment_info                                                                                     string               comment ''
,rate_info                                                                                            string               comment 'sis output of rate info, json'
,other_info                                                                                           string               comment 'user other info, json'
,notes                                                                                                string               comment ''
     ,_event string
    )partitioned by(grass_date string)
    stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_underwriting_xx_db/limit_rate_tab__df__temp/grass_region=ID'
    ;

    msck repair table risk.ods__credit_risk_underwriting_id_db__limit_rate_tab__df;

    refresh table risk.ods__credit_risk_underwriting_id_db__limit_rate_tab__df;

    