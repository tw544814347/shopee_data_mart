

    alter table risk.ods__credit_risk_control_id_db__policy_tree_operation_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/policy_tree_operation_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__policy_tree_operation_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__policy_tree_operation_tab;
create external table risk.ods__credit_risk_control_id_db__policy_tree_operation_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,policy_tree_tab_id                                                                                   bigint               comment ''
,tree_id                                                                                              bigint               comment ''
,tree_version                                                                                         bigint               comment ''
,start_time                                                                                           bigint               comment ''
,end_time                                                                                             bigint               comment ''
,real_end_time                                                                                        bigint               comment ''
,create_user                                                                                          string               comment ''
,create_time                                                                                          bigint               comment ''
,update_user                                                                                          string               comment ''
,update_time                                                                                          bigint               comment ''
,operate_type                                                                                         bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/policy_tree_operation_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__policy_tree_operation_tab;
