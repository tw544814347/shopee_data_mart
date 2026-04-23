

    alter table risk.ods__credit_risk_control_id_db__user_identity_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/user_identity_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__user_identity_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__user_identity_tab;
create external table risk.ods__credit_risk_control_id_db__user_identity_tab
(
 id                                                                                                   bigint               comment ''
,id_no                                                                                                string               comment ''
,id_type                                                                                              bigint               comment ''
,user_name                                                                                            string               comment ''
,birth_date                                                                                           string               comment ''
,birth_place                                                                                          string               comment ''
,identity_photo_url                                                                                   string               comment ''
,selfie_photo_url                                                                                     string               comment ''
,photo_match_score                                                                                    bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/user_identity_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__user_identity_tab;
