

    alter table risk.ods__credit_risk_control_id_db__user_involve_task_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/user_involve_task_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__user_involve_task_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__user_involve_task_tab;
create external table risk.ods__credit_risk_control_id_db__user_involve_task_tab
(
 id                                                                                                   bigint               comment ''
,task_id                                                                                              string               comment ''
,task_category                                                                                        byte                 comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,status                                                                                               byte                 comment ''
,result                                                                                               byte                 comment ''
,result_info                                                                                          string               comment ''
,task_info                                                                                            string               comment ''
,task_output                                                                                          string               comment ''
,sign                                                                                                 string               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/user_involve_task_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__user_involve_task_tab;
