

    alter table risk.ods__credit_risk_control_my_db__action_node_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/action_node_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__action_node_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__action_node_tab;
create external table risk.ods__credit_risk_control_my_db__action_node_tab
(
 id                                                                                                   bigint               comment ''
,tree_id                                                                                              bigint               comment ''
,tree_version                                                                                         bigint               comment ''
,node_id                                                                                              string               comment ''
,action_type                                                                                          string               comment ''
,invoke_type                                                                                          string               comment ''
,create_user                                                                                          string               comment ''
,create_time                                                                                          bigint               comment ''
,update_user                                                                                          string               comment ''
,update_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/action_node_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__action_node_tab;
