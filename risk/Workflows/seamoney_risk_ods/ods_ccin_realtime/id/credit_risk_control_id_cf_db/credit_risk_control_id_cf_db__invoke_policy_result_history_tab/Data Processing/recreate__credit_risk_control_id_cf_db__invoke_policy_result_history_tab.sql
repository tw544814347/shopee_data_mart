

    alter table risk.ods__credit_risk_control_id_cf_db__invoke_policy_result_history_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_cf_db/invoke_policy_result_history_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_cf_db__invoke_policy_result_history_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_cf_db__invoke_policy_result_history_tab;
create external table risk.ods__credit_risk_control_id_cf_db__invoke_policy_result_history_tab
(
 id                                                                                                   bigint               comment ''
,flow_no                                                                                              string               comment ''
,req_params                                                                                           string               comment ''
,rsp                                                                                                  string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        bigint               comment ''
,pending_start_time                                                                                   bigint               comment ''
,pending_finish_time                                                                                  bigint               comment ''
,result_code                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_cf_db/invoke_policy_result_history_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_cf_db__invoke_policy_result_history_tab;
