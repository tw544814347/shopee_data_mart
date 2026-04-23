
    
    alter table risk.ods__credit_risk_control_my_db__offline_policy_task_batch_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/offline_policy_task_batch_tab__df/grass_region=MY/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__offline_policy_task_batch_tab__df;

    


    drop table if exists risk.ods__credit_risk_control_my_db__offline_policy_task_batch_tab;

    create external table risk.ods__credit_risk_control_my_db__offline_policy_task_batch_tab
    (
     id                                                                                                   bigint               comment ''
,offline_task_id                                                                                      bigint               comment ''
,start_time                                                                                           bigint               comment ''
,end_time                                                                                             bigint               comment ''
,run_policy_status                                                                                    bigint               comment '1waiting,2running,3done,4canceld'
,run_policy_result                                                                                    string               comment ''
,sync_status                                                                                          bigint               comment ''
,sync_result                                                                                          string               comment '-1to run policy, 1pending confirm, 2running, 3success, 4partially fail, 5canceled, 6expired'
,descriptionn                                                                                         string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,gen_result_file_status                                                                               bigint               comment '1waiting,2running,3success,4failed'
,run_policy_output_file                                                                               string               comment 'output file path'
,run_policy_failed_file                                                                               string               comment 'policy failed file path'
,gen_sync_failed_file_status                                                                          bigint               comment '1waiting,2running,3success,4failed'
,sync_failed_file                                                                                     string               comment 'sync failed file path'

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/offline_policy_task_batch_tab__df/grass_region=MY/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_control_my_db__offline_policy_task_batch_tab;

    