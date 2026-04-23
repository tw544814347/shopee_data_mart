

    alter table risk.ods__credit_risk_datafetch_id_db__archive_live_testing_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_datafetch_xx_db/archive_live_testing_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_datafetch_id_db__archive_live_testing_tab__df;



    drop table if exists risk.ods__credit_risk_datafetch_id_db__archive_live_testing_tab;
create external table risk.ods__credit_risk_datafetch_id_db__archive_live_testing_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,data_source_name                                                                                     string               comment ''
,url                                                                                                  string               comment ''
,request_method                                                                                       string               comment ''
,request_header                                                                                       string               comment ''
,request_body                                                                                         string               comment ''
,response_body                                                                                        string               comment ''
,response_code                                                                                        bigint               comment ''
,time_cost_ms                                                                                         decimal(20,0)        comment ''
,error_info                                                                                           string               comment ''
,trace_id                                                                                             string               comment ''
,request_key                                                                                          string               comment ''
,create_time                                                                                          string               comment ''
,update_time                                                                                          string               comment ''
,request_header_encrypt                                                                               string               comment ''
,request_body_encrypt                                                                                 string               comment ''
,response_body_encrypt                                                                                string               comment ''
,archive_batch_no                                                                                     string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_datafetch_xx_db/archive_live_testing_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_datafetch_id_db__archive_live_testing_tab;
