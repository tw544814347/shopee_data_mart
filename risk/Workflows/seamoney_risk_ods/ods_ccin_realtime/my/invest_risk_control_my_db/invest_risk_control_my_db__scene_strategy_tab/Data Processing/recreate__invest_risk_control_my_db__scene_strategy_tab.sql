

    alter table risk.ods__invest_risk_control_my_db__scene_strategy_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/invest_risk_control_xx_db/scene_strategy_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__invest_risk_control_my_db__scene_strategy_tab__df;



    drop table if exists risk.ods__invest_risk_control_my_db__scene_strategy_tab;
create external table risk.ods__invest_risk_control_my_db__scene_strategy_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,ori_id                                                                                               decimal(20,0)        comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,strategy_script                                                                                      string               comment ''
,l3_rule_group_id                                                                                     decimal(20,0)        comment ''
,version                                                                                              bigint               comment ''
,status                                                                                               bigint               comment ''
,running                                                                                              bigint               comment ''
,description                                                                                          string               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,version_status                                                                                       bigint               comment ''
,scene_group_id                                                                                       bigint               comment ''
,engine                                                                                               string               comment ''
,af_conf_id                                                                                           bigint               comment ''
,strategy_type                                                                                        bigint               comment ''
,strategy_package                                                                                     string               comment ''
,fe_scene_id                                                                                          decimal(20,0)        comment ''
,released                                                                                             bigint               comment ''
,sub_category                                                                                         bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/invest_risk_control_xx_db/scene_strategy_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__invest_risk_control_my_db__scene_strategy_tab;
