

    alter table risk.ods__credit_risk_control_my_db__node_rule_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/node_rule_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__node_rule_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__node_rule_tab;
create external table risk.ods__credit_risk_control_my_db__node_rule_tab
(
 id                                                                                                   bigint               comment ''
,tree_id                                                                                              bigint               comment ''
,tree_version                                                                                         bigint               comment ''
,node_id                                                                                              string               comment ''
,node_rule                                                                                            string               comment ''
,node_description                                                                                     string               comment ''
,update_user                                                                                          string               comment ''
,update_time                                                                                          bigint               comment ''
,create_user                                                                                          string               comment ''
,create_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/node_rule_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__node_rule_tab;
