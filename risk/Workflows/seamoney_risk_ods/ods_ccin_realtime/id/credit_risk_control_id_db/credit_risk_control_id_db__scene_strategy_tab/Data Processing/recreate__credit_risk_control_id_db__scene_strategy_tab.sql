

    alter table risk.ods__credit_risk_control_id_db__scene_strategy_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/scene_strategy_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__scene_strategy_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__scene_strategy_tab;
create external table risk.ods__credit_risk_control_id_db__scene_strategy_tab
(
 id                                                                                                   bigint               comment ''
,ori_id                                                                                               bigint               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,strategy_script                                                                                      string               comment ''
,l3_rule_group_id                                                                                     bigint               comment ''
,version                                                                                              integer              comment ''
,status                                                                                               byte                 comment ''
,running                                                                                              byte                 comment ''
,description                                                                                          string               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          integer              comment ''
,update_time                                                                                          integer              comment ''
,version_status                                                                                       byte                 comment ''
,scene_group_id                                                                                       integer              comment ''
,engine                                                                                               string               comment ''
,af_conf_id                                                                                           bigint               comment ''
,strategy_type                                                                                        bigint               comment ''
,strategy_package                                                                                     string               comment ''
,fe_scene_id                                                                                          bigint               comment ''
,released                                                                                             bigint               comment ''
,sub_category                                                                                         bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/scene_strategy_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__scene_strategy_tab;
