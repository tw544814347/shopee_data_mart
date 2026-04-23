

    alter table risk.ods__credit_risk_control_id_ldn_db__workflow_shadow_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_ldn_db/workflow_shadow_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_ldn_db__workflow_shadow_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_ldn_db__workflow_shadow_tab;
create external table risk.ods__credit_risk_control_id_ldn_db__workflow_shadow_tab
(
 id                                                                                                   bigint               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,flow_no                                                                                              string               comment ''
,seq_id                                                                                               string               comment ''
,current_step                                                                                         string               comment ''
,run_step                                                                                             string               comment ''
,status                                                                                               bigint               comment ''
,input                                                                                                string               comment ''
,output                                                                                               string               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,req_no                                                                                               string               comment ''
,req_md5                                                                                              string               comment ''
,cluster_id                                                                                           bigint               comment ''
,async_flag                                                                                           bigint               comment ''
,input_encrypt                                                                                        string               comment ''
,original_platform_type                                                                               bigint               comment ''
,shopeepay_user_id                                                                                    string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_ldn_db/workflow_shadow_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_ldn_db__workflow_shadow_tab;
