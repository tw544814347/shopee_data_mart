

    alter table risk.ods__credit_risk_control_id_db__risk_event_module_config_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/risk_event_module_config_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__risk_event_module_config_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__risk_event_module_config_tab;
create external table risk.ods__credit_risk_control_id_db__risk_event_module_config_tab
(
 id                                                                                                   bigint               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             string               comment ''
,event_code                                                                                           string               comment ''
,config                                                                                               string               comment ''
,module_type                                                                                          string               comment ''
,grey_config                                                                                          string               comment ''
,grey_percentage                                                                                      bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,operator                                                                                             string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/risk_event_module_config_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__risk_event_module_config_tab;
