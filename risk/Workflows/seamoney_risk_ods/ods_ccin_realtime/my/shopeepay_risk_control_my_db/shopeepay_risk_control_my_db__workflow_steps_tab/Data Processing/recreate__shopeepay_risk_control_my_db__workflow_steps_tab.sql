

    alter table risk.ods__shopeepay_risk_control_my_db__workflow_steps_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/workflow_steps_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__shopeepay_risk_control_my_db__workflow_steps_tab__df;



    drop table if exists risk.ods__shopeepay_risk_control_my_db__workflow_steps_tab;
create external table risk.ods__shopeepay_risk_control_my_db__workflow_steps_tab
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
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/workflow_steps_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__shopeepay_risk_control_my_db__workflow_steps_tab;
