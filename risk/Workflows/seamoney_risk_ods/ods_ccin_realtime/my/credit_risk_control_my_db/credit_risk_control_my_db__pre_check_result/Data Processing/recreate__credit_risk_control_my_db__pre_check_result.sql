

    alter table risk.ods__credit_risk_control_my_db__pre_check_result__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/pre_check_result__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__pre_check_result__df;



    drop table if exists risk.ods__credit_risk_control_my_db__pre_check_result;
create external table risk.ods__credit_risk_control_my_db__pre_check_result
(
 id                                                                                                   bigint               comment ''
,task_id                                                                                              bigint               comment ''
,template_type                                                                                        bigint               comment ''
,total_rows                                                                                           bigint               comment ''
,number_of_failures                                                                                   bigint               comment ''
,custom_header_data                                                                                   string               comment ''
,custom_body_data                                                                                     string               comment ''
,inconsistent_filename                                                                                string               comment ''
,fail_filename                                                                                        string               comment ''
,status                                                                                               bigint               comment ''
,operator                                                                                             string               comment ''
,description                                                                                          string               comment ''
,update_time                                                                                          bigint               comment ''
,create_time                                                                                          bigint               comment ''
,notes                                                                                                string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/pre_check_result__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__pre_check_result;
