

    alter table risk.ods__credit_risk_control_my_db__batch_task_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/batch_task_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__batch_task_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__batch_task_tab;
create external table risk.ods__credit_risk_control_my_db__batch_task_tab
(
 task_id                                                                                              bigint               comment ''
,filename                                                                                             string               comment ''
,status                                                                                               bigint               comment ''
,version                                                                                              bigint               comment ''
,number_of_rows                                                                                       bigint               comment ''
,number_of_failures                                                                                   bigint               comment ''
,upload_time                                                                                          bigint               comment ''
,finish_time                                                                                          bigint               comment ''
,operator                                                                                             string               comment ''
,fail_filename                                                                                        string               comment ''
,task_name                                                                                            string               comment ''
,task_type                                                                                            bigint               comment ''
,task_policy                                                                                          bigint               comment ''
,task_extension                                                                                       string               comment ''
,description                                                                                          string               comment ''
,update_time                                                                                          bigint               comment ''
,full_report                                                                                          string               comment ''
,failed_report                                                                                        string               comment ''
,check_failed_report                                                                                  string               comment ''
,api_type                                                                                             bigint               comment ''
,call_asli_status                                                                                     bigint               comment ''
,upload_status                                                                                        bigint               comment ''
,pfb_version                                                                                          string               comment ''
,screening_time                                                                                       bigint               comment ''
,screening_type                                                                                       bigint               comment ''
,notes                                                                                                string               comment ''
,file_type                                                                                            bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/batch_task_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__batch_task_tab;
