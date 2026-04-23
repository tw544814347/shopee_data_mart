

    alter table risk.ods__credit_risk_control_id_db__strategy_l3_rule_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/strategy_l3_rule_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__strategy_l3_rule_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__strategy_l3_rule_tab;
create external table risk.ods__credit_risk_control_id_db__strategy_l3_rule_tab
(
 id                                                                                                   bigint               comment ''
,ori_id                                                                                               bigint               comment ''
,l3_rule_name                                                                                         string               comment ''
,l3_rule_script                                                                                       string               comment ''
,l2_ruls                                                                                              string               comment ''
,expression                                                                                           string               comment ''
,extention                                                                                            string               comment ''
,version                                                                                              integer              comment ''
,description                                                                                          string               comment ''
,status                                                                                               byte                 comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          integer              comment ''
,update_time                                                                                          integer              comment ''
,category                                                                                             byte                 comment ''
,version_status                                                                                       byte                 comment ''
,error_default                                                                                        string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/strategy_l3_rule_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__strategy_l3_rule_tab;
