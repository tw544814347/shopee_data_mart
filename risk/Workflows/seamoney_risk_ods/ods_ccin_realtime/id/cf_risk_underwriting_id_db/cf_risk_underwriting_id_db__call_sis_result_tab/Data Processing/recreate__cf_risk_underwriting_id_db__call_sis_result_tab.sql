

    alter table risk.ods__cf_risk_underwriting_id_db__call_sis_result_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/cf_risk_underwriting_xx_db/call_sis_result_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__cf_risk_underwriting_id_db__call_sis_result_tab__df;



    drop table if exists risk.ods__cf_risk_underwriting_id_db__call_sis_result_tab;
create external table risk.ods__cf_risk_underwriting_id_db__call_sis_result_tab
(
 id                                                                                                   bigint               comment ''
,platform_user_id                                                                                     string               comment 'platform_user_id'
,platform_type                                                                                        bigint               comment 'platform_type'
,app_id                                                                                               string               comment 'app_id'
,scene_id                                                                                             string               comment 'scene_id'
,node_id                                                                                              string               comment 'node_id'
,flow_no                                                                                              string               comment 'flow no'
,req                                                                                                  string               comment 'request sis params'
,rsp                                                                                                  string               comment 'the response of sis'
,request_time                                                                                         bigint               comment ''
,decisions_result                                                                                     string               comment 'the final decisions_result'
,reason_codes                                                                                         string               comment 'reason_codes'
,version                                                                                              bigint               comment 'optimistic lock'
,create_time                                                                                          bigint               comment 'create timestamp of this user'
,update_time                                                                                          bigint               comment 'update timestamp of this user'
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/cf_risk_underwriting_xx_db/call_sis_result_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__cf_risk_underwriting_id_db__call_sis_result_tab;
