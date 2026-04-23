

    alter table risk.ods__credit_risk_datafetch_my_db__data_source_monthly_transaction_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_datafetch_xx_db/data_source_monthly_transaction_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_datafetch_my_db__data_source_monthly_transaction_tab__df;



    drop table if exists risk.ods__credit_risk_datafetch_my_db__data_source_monthly_transaction_tab;
create external table risk.ods__credit_risk_datafetch_my_db__data_source_monthly_transaction_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,data_source_name                                                                                     string               comment ''
,entity                                                                                               string               comment ''
,before_tax                                                                                           decimal(30,10)       comment ''
,after_tax                                                                                            decimal(30,10)       comment ''
,remark                                                                                               string               comment ''
,operator                                                                                             string               comment ''
,year_month                                                                                           bigint               comment ''
,update_time                                                                                          bigint               comment ''
,create_time                                                                                          bigint               comment ''
,invoice                                                                                              string               comment ''
,actual_cost                                                                                          decimal(30,10)       comment ''
,estimated_cost                                                                                       decimal(30,10)       comment ''
,meta_data_id                                                                                         bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_datafetch_xx_db/data_source_monthly_transaction_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_datafetch_my_db__data_source_monthly_transaction_tab;
