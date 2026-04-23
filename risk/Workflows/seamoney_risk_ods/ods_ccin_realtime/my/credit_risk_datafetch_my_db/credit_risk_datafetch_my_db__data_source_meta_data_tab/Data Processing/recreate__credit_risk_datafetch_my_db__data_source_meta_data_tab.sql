

    alter table risk.ods__credit_risk_datafetch_my_db__data_source_meta_data_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_datafetch_xx_db/data_source_meta_data_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_datafetch_my_db__data_source_meta_data_tab__df;



    drop table if exists risk.ods__credit_risk_datafetch_my_db__data_source_meta_data_tab;
create external table risk.ods__credit_risk_datafetch_my_db__data_source_meta_data_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,data_source_name                                                                                     string               comment ''
,entity                                                                                               string               comment ''
,data_type                                                                                            string               comment ''
,charging_method                                                                                      string               comment ''
,unit_price                                                                                           decimal(30,10)       comment ''
,tax_rate                                                                                             decimal(30,10)       comment ''
,contract_expiry_date                                                                                 bigint               comment ''
,data_status                                                                                          bigint               comment ''
,operator                                                                                             string               comment ''
,doc                                                                                                  string               comment ''
,remark                                                                                               string               comment ''
,update_time                                                                                          bigint               comment ''
,create_time                                                                                          bigint               comment ''
,contract_effective_date                                                                              bigint               comment ''
,tiered_pricing                                                                                       string               comment ''
,version                                                                                              bigint               comment ''
,version_status                                                                                       bigint               comment ''
,monthly_usage_alert                                                                                  bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_datafetch_xx_db/data_source_meta_data_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_datafetch_my_db__data_source_meta_data_tab;
