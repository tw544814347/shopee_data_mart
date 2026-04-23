

    alter table risk.ods__credit_risk_holmes_my_db__business_config_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_holmes_xx_db/business_config_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_holmes_my_db__business_config_tab__df;



    drop table if exists risk.ods__credit_risk_holmes_my_db__business_config_tab;
create external table risk.ods__credit_risk_holmes_my_db__business_config_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,biz                                                                                                  string               comment ''
,is_show                                                                                              bigint               comment ''
,version                                                                                              bigint               comment ''
,operator                                                                                             string               comment ''
,config_name                                                                                          string               comment ''
,config_value                                                                                         string               comment ''
,config_desc                                                                                          string               comment ''
,config_status                                                                                        bigint               comment ''
,config_modules                                                                                       string               comment ''
,version_status                                                                                       bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_holmes_xx_db/business_config_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_holmes_my_db__business_config_tab;
