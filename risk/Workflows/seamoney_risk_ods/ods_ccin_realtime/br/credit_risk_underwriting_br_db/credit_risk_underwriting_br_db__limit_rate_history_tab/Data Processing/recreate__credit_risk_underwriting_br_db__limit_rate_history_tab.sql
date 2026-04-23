
    
    alter table risk.ods__credit_risk_underwriting_br_db__limit_rate_history_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_underwriting_xx_db/limit_rate_history_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_underwriting_br_db__limit_rate_history_tab__df;

    


    drop table if exists risk.ods__credit_risk_underwriting_br_db__limit_rate_history_tab;

    create external table risk.ods__credit_risk_underwriting_br_db__limit_rate_history_tab
    (
     hid                                                                                                  bigint               comment 'Auto Increment Id'
,id                                                                                                   decimal(20,0)        comment ''
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        bigint               comment ''
,app_id                                                                                               bigint               comment ''
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
,limit_info                                                                                           string               comment ''
,installment_info                                                                                     string               comment ''
,rate_info                                                                                            string               comment ''
,other_info                                                                                           string               comment ''
,notes                                                                                                string               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_underwriting_xx_db/limit_rate_history_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_underwriting_br_db__limit_rate_history_tab;

    