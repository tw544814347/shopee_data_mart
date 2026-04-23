

    alter table risk.ods__credit_risk_control_id_db__risk_antifraud_config_tree_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/risk_antifraud_config_tree_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__risk_antifraud_config_tree_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__risk_antifraud_config_tree_tab;
create external table risk.ods__credit_risk_control_id_db__risk_antifraud_config_tree_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,region                                                                                               string               comment ''
,config_name                                                                                          string               comment ''
,config_tag                                                                                           string               comment ''
,config_tree                                                                                          string               comment ''
,bpmn_xml                                                                                             string               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,output_id                                                                                            bigint               comment ''
,strategy_type                                                                                        bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/risk_antifraud_config_tree_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__risk_antifraud_config_tree_tab;
