
    
    alter table risk.ods__credit_risk_control_my_db__offline_policy_task_batch_result_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/offline_policy_task_batch_result_tab__df/grass_region=MY/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__offline_policy_task_batch_result_tab__df;

    


    drop table if exists risk.ods__credit_risk_control_my_db__offline_policy_task_batch_result_tab;

    create external table risk.ods__credit_risk_control_my_db__offline_policy_task_batch_result_tab
    (
     id                                                                                                   bigint               comment ''
,task_id                                                                                              bigint               comment ''
,batch_id                                                                                             bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,credit_user_id                                                                                       string               comment ''
,platform_type                                                                                        bigint               comment ''
,run_policy_status                                                                                    bigint               comment ''
,run_policy_result                                                                                    string               comment ''
,policy_input                                                                                         string               comment ''
,policy_output                                                                                        string               comment ''
,sync_status                                                                                          bigint               comment ''
,sync_result                                                                                          string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/offline_policy_task_batch_result_tab__df/grass_region=MY/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_control_my_db__offline_policy_task_batch_result_tab;

    