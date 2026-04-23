

    alter table risk.ods__credit_risk_control_my_db__user_identity_log_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/user_identity_log_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__user_identity_log_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__user_identity_log_tab;
create external table risk.ods__credit_risk_control_my_db__user_identity_log_tab
(
 id                                                                                                   bigint               comment ''
,flow_no                                                                                              string               comment ''
,id_no                                                                                                string               comment ''
,name                                                                                                 string               comment ''
,birth_date                                                                                           string               comment ''
,birth_place                                                                                          string               comment ''
,identity_photo_url                                                                                   string               comment ''
,selfie_photo_url                                                                                     string               comment ''
,name_match                                                                                           bigint               comment ''
,birth_date_match                                                                                     bigint               comment ''
,birth_place_match                                                                                    bigint               comment ''
,rsp_address                                                                                          string               comment ''
,selfie_photo_match_score                                                                             bigint               comment ''
,rsp_code                                                                                             bigint               comment ''
,errors                                                                                               string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,req_no                                                                                               string               comment ''
,req_time                                                                                             bigint               comment ''
,req_status                                                                                           bigint               comment ''
,req_channel                                                                                          string               comment ''
,asli_version                                                                                         string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/user_identity_log_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__user_identity_log_tab;
