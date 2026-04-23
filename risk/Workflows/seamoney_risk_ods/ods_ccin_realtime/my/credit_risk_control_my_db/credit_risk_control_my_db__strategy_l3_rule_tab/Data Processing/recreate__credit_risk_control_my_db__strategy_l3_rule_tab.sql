

    alter table risk.ods__credit_risk_control_my_db__strategy_l3_rule_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/strategy_l3_rule_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__strategy_l3_rule_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__strategy_l3_rule_tab;
create external table risk.ods__credit_risk_control_my_db__strategy_l3_rule_tab
(
 id                                                                                                   bigint               comment ''
,ori_id                                                                                               bigint               comment ''
,l3_rule_name                                                                                         string               comment ''
,l3_rule_script                                                                                       string               comment ''
,l2_ruls                                                                                              string               comment ''
,expression                                                                                           string               comment ''
,extention                                                                                            string               comment ''
,version                                                                                              bigint               comment ''
,description                                                                                          string               comment ''
,status                                                                                               bigint               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,category                                                                                             bigint               comment ''
,version_status                                                                                       bigint               comment ''
,error_default                                                                                        string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/strategy_l3_rule_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__strategy_l3_rule_tab;
