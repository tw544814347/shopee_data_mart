

    alter table risk.ods__credit_risk_control_my_db__strategy_l3_rule_group_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/strategy_l3_rule_group_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__strategy_l3_rule_group_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__strategy_l3_rule_group_tab;
create external table risk.ods__credit_risk_control_my_db__strategy_l3_rule_group_tab
(
 id                                                                                                   bigint               comment ''
,ori_id                                                                                               bigint               comment ''
,group_name                                                                                           string               comment ''
,group_script                                                                                         string               comment ''
,l3_rules                                                                                             string               comment ''
,default_result_id                                                                                    bigint               comment ''
,version                                                                                              bigint               comment ''
,status                                                                                               bigint               comment ''
,description                                                                                          string               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,category                                                                                             bigint               comment ''
,version_status                                                                                       bigint               comment ''
,list_config                                                                                          string               comment ''
,serial_type                                                                                          bigint               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,strategy_type                                                                                        bigint               comment ''
,group_script_v2                                                                                      string               comment ''
,rets                                                                                                 string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/strategy_l3_rule_group_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__strategy_l3_rule_group_tab;
