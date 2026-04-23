
    
    alter table risk.ods__credit_risk_datafetch_br_db__identity_data_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_datafetch_xx_db/identity_data_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_datafetch_br_db__identity_data_tab__df;

    


    drop table if exists risk.ods__credit_risk_datafetch_br_db__identity_data_tab;

    create external table risk.ods__credit_risk_datafetch_br_db__identity_data_tab
    (
     id                                                                                                   decimal(20,0)        comment ''
,request_key                                                                                          string               comment ''
,data_source_name                                                                                     string               comment ''
,data_source_code                                                                                     bigint               comment ''
,header_data                                                                                          string               comment ''
,req_data                                                                                             string               comment ''
,extra_info                                                                                           string               comment ''
,resp_raw_data                                                                                        string               comment ''
,trace_id                                                                                             string               comment ''
,create_time                                                                                          string               comment ''
,update_time                                                                                          string               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_datafetch_xx_db/identity_data_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_datafetch_br_db__identity_data_tab;

    