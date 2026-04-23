

    alter table risk.ods__credit_risk_control_id_db__policy_tree_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/policy_tree_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__policy_tree_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__policy_tree_tab;
create external table risk.ods__credit_risk_control_id_db__policy_tree_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,region                                                                                               string               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,tree_id                                                                                              bigint               comment ''
,tree_version                                                                                         bigint               comment ''
,tree_type                                                                                            bigint               comment ''
,tree_status                                                                                          bigint               comment ''
,start_time                                                                                           bigint               comment ''
,end_time                                                                                             bigint               comment ''
,init_flow_time                                                                                       bigint               comment ''
,init_flow_ratio                                                                                      bigint               comment ''
,run_with_new_flow                                                                                    bigint               comment ''
,mail_flag                                                                                            bigint               comment ''
,description                                                                                          string               comment ''
,operator                                                                                             string               comment ''
,create_time                                                                                          bigint               comment ''
,create_user                                                                                          string               comment ''
,update_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/policy_tree_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__policy_tree_tab;
