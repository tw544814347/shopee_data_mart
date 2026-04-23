

    alter table risk.ods__credit_risk_control_id_db__policy_file_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/policy_file_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__policy_file_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__policy_file_tab;
create external table risk.ods__credit_risk_control_id_db__policy_file_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,region                                                                                               string               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,policy_name                                                                                          string               comment ''
,policy_version                                                                                       bigint               comment ''
,policy_file                                                                                          string               comment ''
,policy_file_fingerprint                                                                              string               comment ''
,policy_status                                                                                        bigint               comment ''
,policy_info                                                                                          string               comment ''
,policy_schema                                                                                        string               comment ''
,description                                                                                          string               comment ''
,create_user                                                                                          string               comment ''
,create_time                                                                                          bigint               comment ''
,update_user                                                                                          string               comment ''
,update_time                                                                                          bigint               comment ''
,file_id                                                                                              string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/policy_file_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__policy_file_tab;
