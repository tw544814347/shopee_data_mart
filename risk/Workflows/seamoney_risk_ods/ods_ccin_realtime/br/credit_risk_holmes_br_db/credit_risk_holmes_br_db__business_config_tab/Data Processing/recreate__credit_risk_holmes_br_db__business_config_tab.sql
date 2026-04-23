
    
    alter table risk.ods__credit_risk_holmes_br_db__business_config_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_holmes_xx_db/business_config_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_holmes_br_db__business_config_tab__df;

    


    drop table if exists risk.ods__credit_risk_holmes_br_db__business_config_tab;

    create external table risk.ods__credit_risk_holmes_br_db__business_config_tab
    (
     id                                                                                                   decimal(20,0)        comment 'id, primary key'
,create_time                                                                                          bigint               comment 'created time'
,update_time                                                                                          bigint               comment 'updated time'
,biz                                                                                                  string               comment 'biz'
,is_show                                                                                              bigint               comment 'can show in page, 0-no, 1-yes'
,version                                                                                              bigint               comment 'version'
,operator                                                                                             string               comment 'operator'
,config_name                                                                                          string               comment 'config name'
,config_value                                                                                         string               comment 'config name value'
,config_desc                                                                                          string               comment 'description'
,config_status                                                                                        bigint               comment 'status'
,config_modules                                                                                       string               comment 'use in witch modules, string array'
,version_status                                                                                       bigint               comment 'version status, 1-history, 2-current'

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_holmes_xx_db/business_config_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_holmes_br_db__business_config_tab;

    