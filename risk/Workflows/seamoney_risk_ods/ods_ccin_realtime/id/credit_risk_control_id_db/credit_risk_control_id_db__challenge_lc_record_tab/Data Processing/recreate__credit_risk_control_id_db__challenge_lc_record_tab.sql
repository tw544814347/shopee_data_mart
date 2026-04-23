

    alter table risk.ods__credit_risk_control_id_db__challenge_lc_record_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/challenge_lc_record_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__challenge_lc_record_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__challenge_lc_record_tab;
create external table risk.ods__credit_risk_control_id_db__challenge_lc_record_tab
(
 id                                                                                                   bigint               comment '""'
,flow_no                                                                                              string               comment '""'
,app_id                                                                                               string               comment '""'
,req_no                                                                                               string               comment 'business flowno'
,req_memo                                                                                             string               comment '""'
,platform_type                                                                                        bigint               comment '""'
,platform_user_id                                                                                     string               comment '""'
,app_fe_url                                                                                           string               comment '""'
,app_notify_url                                                                                       string               comment '""'
,lc_data                                                                                              string               comment '""'
,lc_images                                                                                            string               comment '""'
,lc_result                                                                                            bigint               comment '0 unkonow，1 pass, 2 reject'
,anti_spoofing_result                                                                                 bigint               comment '0 unkonow，1 pass, 2 reject'
,anti_spoofing_info                                                                                   string               comment '""'
,result                                                                                               bigint               comment 'final result, 0 unkonow，1 pass, 2 reject'
,status                                                                                               bigint               comment '0 error,1 todo,2 done,3 undone, 4doing'
,description                                                                                          string               comment '""'
,create_time                                                                                          bigint               comment '""'
,update_time                                                                                          bigint               comment '""'
,lc_module_result                                                                                     string               comment ''
,lc_data_encrypt                                                                                      string               comment ''
,req_memo_encrypt                                                                                     string               comment ''
,original_platform_type                                                                               bigint               comment ''
,shopeepay_user_id                                                                                    string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/challenge_lc_record_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__challenge_lc_record_tab;
