

    alter table risk.ods__credit_risk_control_id_ldn_db__model_req_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_ldn_db/model_req_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_ldn_db__model_req_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_ldn_db__model_req_tab;
create external table risk.ods__credit_risk_control_id_ldn_db__model_req_tab
(
 id                                                                                                   bigint               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,flow_no                                                                                              string               comment ''
,req_no                                                                                               string               comment ''
,model_status                                                                                         bigint               comment ''
,model_input                                                                                          string               comment ''
,model_result                                                                                         string               comment ''
,model_provider                                                                                       string               comment ''
,model_name                                                                                           string               comment ''
,model_version                                                                                        string               comment ''
,model_code                                                                                           bigint               comment ''
,notify_result                                                                                        string               comment ''
,notify_time                                                                                          bigint               comment ''
,query_result                                                                                         string               comment ''
,query_time                                                                                           bigint               comment ''
,query_count                                                                                          bigint               comment ''
,version                                                                                              bigint               comment ''
,remark                                                                                               string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,processor_name                                                                                       string               comment ''
,model_run_status                                                                                     bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_ldn_db/model_req_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_ldn_db__model_req_tab;
