

    alter table risk.ods__credit_risk_control_id_ldn_db__workflow_steps_shadow_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_ldn_db/workflow_steps_shadow_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_ldn_db__workflow_steps_shadow_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_ldn_db__workflow_steps_shadow_tab;
create external table risk.ods__credit_risk_control_id_ldn_db__workflow_steps_shadow_tab
(
 id                                                                                                   bigint               comment ''
,wfid                                                                                                 bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,step                                                                                                 string               comment ''
,status                                                                                               bigint               comment ''
,input                                                                                                string               comment ''
,output                                                                                               string               comment ''
,next                                                                                                 string               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,input_encrypt                                                                                        string               comment ''
,shopeepay_user_id                                                                                    string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_ldn_db/workflow_steps_shadow_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_ldn_db__workflow_steps_shadow_tab;
