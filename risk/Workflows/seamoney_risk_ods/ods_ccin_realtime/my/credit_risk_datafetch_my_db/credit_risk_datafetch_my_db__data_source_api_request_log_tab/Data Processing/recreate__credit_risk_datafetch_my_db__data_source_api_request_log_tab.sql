

    alter table risk.ods__credit_risk_datafetch_my_db__data_source_api_request_log_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_datafetch_xx_db/data_source_api_request_log_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_datafetch_my_db__data_source_api_request_log_tab__df;



    drop table if exists risk.ods__credit_risk_datafetch_my_db__data_source_api_request_log_tab;
create external table risk.ods__credit_risk_datafetch_my_db__data_source_api_request_log_tab
(
 id                                                                                                   bigint               comment ''
,data_source_name                                                                                     string               comment ''
,url                                                                                                  string               comment ''
,request_method                                                                                       string               comment ''
,request_header                                                                                       string               comment ''
,request_body                                                                                         string               comment ''
,response_body                                                                                        string               comment ''
,response_code                                                                                        bigint               comment ''
,time_cost_ms                                                                                         bigint               comment ''
,error_info                                                                                           string               comment ''
,trace_id                                                                                             string               comment ''
,request_key                                                                                          string               comment ''
,create_time                                                                                          string               comment ''
,update_time                                                                                          string               comment ''
,scene_id                                                                                             bigint               comment ''
,flow_no                                                                                              string               comment ''
,risk_req_no                                                                                          string               comment ''
,app_id                                                                                               string               comment ''
,entity                                                                                               string               comment ''
,call_scene                                                                                           bigint               comment ''
,response_body_encrypt                                                                                string               comment ''
,request_body_encrypt                                                                                 string               comment ''
,request_header_encrypt                                                                               string               comment ''
,archive_batch_no                                                                                     string               comment ''
 ,response_body_encrypt_data                                                                           string               comment ''
,response_body_encrypt_md5                                                                            string               comment ''
,response_body_encrypt_mask                                                                           string               comment ''
,request_body_encrypt_data                                                                            string               comment ''
,request_body_encrypt_md5                                                                             string               comment ''
,request_body_encrypt_mask                                                                            string               comment ''
,request_header_encrypt_data                                                                          string               comment ''
,request_header_encrypt_md5                                                                           string               comment ''
,request_header_encrypt_mask                                                                          string               comment ''
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_datafetch_xx_db/data_source_api_request_log_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_datafetch_my_db__data_source_api_request_log_tab;
