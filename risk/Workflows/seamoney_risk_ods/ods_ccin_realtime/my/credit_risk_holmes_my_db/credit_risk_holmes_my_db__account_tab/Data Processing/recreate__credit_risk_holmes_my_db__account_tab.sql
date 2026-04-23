

    alter table risk.ods__credit_risk_holmes_my_db__account_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_holmes_xx_db/account_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_holmes_my_db__account_tab__df;



    drop table if exists risk.ods__credit_risk_holmes_my_db__account_tab;
create external table risk.ods__credit_risk_holmes_my_db__account_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,name                                                                                                 string               comment ''
,email                                                                                                string               comment ''
,avatar                                                                                               string               comment ''
,permissions                                                                                          string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_holmes_xx_db/account_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_holmes_my_db__account_tab;
