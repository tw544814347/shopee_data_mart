
    
    alter table risk.ods__credit_risk_control_id_db__offline_policy_task_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/offline_policy_task_tab__df/grass_region=ID/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__offline_policy_task_tab__df;

    


    drop table if exists risk.ods__credit_risk_control_id_db__offline_policy_task_tab;

    create external table risk.ods__credit_risk_control_id_db__offline_policy_task_tab
    (
     id                                                                                                   bigint               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,policy_tree_id                                                                                       bigint               comment ''
,policy_tree_version                                                                                  bigint               comment ''
,user_group_id                                                                                        bigint               comment ''
,user_group_name                                                                                      string               comment ''
,run_time                                                                                             string               comment ''
,status                                                                                               bigint               comment '-1invalid, 1valid'
,description                                                                                          string               comment ''
,operator                                                                                             string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/offline_policy_task_tab__df/grass_region=ID/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_control_id_db__offline_policy_task_tab;

    