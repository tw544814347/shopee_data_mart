

    alter table risk.ods__credit_risk_control_id_db__credit_realtime_credit_list_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/credit_realtime_credit_list_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__credit_realtime_credit_list_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__credit_realtime_credit_list_tab;
create external table risk.ods__credit_risk_control_id_db__credit_realtime_credit_list_tab
(
 id                                                                                                   integer              comment ''
,app_id                                                                                               string               comment ''
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        integer              comment ''
,user_type                                                                                            integer              comment ''
,status                                                                                               integer              comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,sync_tag_status                                                                                      bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/credit_realtime_credit_list_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__credit_realtime_credit_list_tab;
