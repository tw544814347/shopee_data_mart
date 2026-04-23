
    
    alter table risk.ods__credit_risk_datafetch_br_db__identity_fetch_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_datafetch_xx_db/identity_fetch_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_datafetch_br_db__identity_fetch_tab__df;

    


    drop table if exists risk.ods__credit_risk_datafetch_br_db__identity_fetch_tab;

    create external table risk.ods__credit_risk_datafetch_br_db__identity_fetch_tab
    (
     id                                                                                                   decimal(20,0)        comment ''
,unique_key                                                                                           string               comment ''
,data_source_name                                                                                     string               comment ''
,req_key                                                                                              string               comment ''
,req_header                                                                                           string               comment ''
,req                                                                                                  string               comment ''
,extra_info                                                                                           string               comment ''
,retry_count                                                                                          bigint               comment ''
,resp_code                                                                                            bigint               comment ''
,trace_id                                                                                             string               comment ''
,app_key                                                                                              string               comment ''
,data_year_month                                                                                      string               comment ''
,create_time                                                                                          string               comment ''
,update_time                                                                                          string               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_datafetch_xx_db/identity_fetch_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_datafetch_br_db__identity_fetch_tab;

    