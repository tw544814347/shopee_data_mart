

    alter table risk.ods__credit_risk_control_my_db__challenge_record_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/challenge_record_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__challenge_record_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__challenge_record_tab;
create external table risk.ods__credit_risk_control_my_db__challenge_record_tab
(
 id                                                                                                   bigint               comment ''
,biz                                                                                                  string               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,event_code                                                                                           string               comment ''
,req_no                                                                                               string               comment ''
,challenge_type                                                                                       bigint               comment ''
,req_memo                                                                                             string               comment ''
,platform_type                                                                                        bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,jumpback_url                                                                                         string               comment ''
,callback_url                                                                                         string               comment ''
,challenge_data                                                                                       string               comment ''
,timeout_seconds                                                                                      bigint               comment ''
,result                                                                                               bigint               comment ''
,record_status                                                                                        bigint               comment ''
,extra_info                                                                                           string               comment ''
,failure_info                                                                                         string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,shopeepay_user_id                                                                                    string               comment ''
,extension                                                                                            string               comment ''
,query_no                                                                                             string               comment ''
,challenge_data_encrypt                                                                               string               comment ''
,original_platform_type                                                                               bigint               comment ''
,archive_batch_no                                                                                     string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/challenge_record_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__challenge_record_tab;
