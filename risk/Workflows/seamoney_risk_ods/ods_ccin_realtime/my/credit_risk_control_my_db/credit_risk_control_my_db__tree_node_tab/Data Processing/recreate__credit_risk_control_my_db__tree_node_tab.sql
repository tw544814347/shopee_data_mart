

    alter table risk.ods__credit_risk_control_my_db__tree_node_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/tree_node_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__tree_node_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__tree_node_tab;
create external table risk.ods__credit_risk_control_my_db__tree_node_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,tree_id                                                                                              bigint               comment ''
,tree_name                                                                                            string               comment ''
,node_id                                                                                              string               comment ''
,parent_node_id                                                                                       string               comment ''
,depth                                                                                                bigint               comment ''
,description                                                                                          string               comment ''
,create_user                                                                                          string               comment ''
,create_time                                                                                          bigint               comment ''
,render_id                                                                                            string               comment ''
,node_type                                                                                            string               comment ''
,node_name                                                                                            string               comment ''
,use_new_router                                                                                       bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/tree_node_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__tree_node_tab;
