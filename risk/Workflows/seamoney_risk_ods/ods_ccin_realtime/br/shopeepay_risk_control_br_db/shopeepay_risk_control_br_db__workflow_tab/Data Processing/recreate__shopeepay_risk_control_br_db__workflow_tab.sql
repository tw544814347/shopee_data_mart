
    
    alter table risk.ods__shopeepay_risk_control_br_db__workflow_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/workflow_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__shopeepay_risk_control_br_db__workflow_tab__df;

    


    drop table if exists risk.ods__shopeepay_risk_control_br_db__workflow_tab;

    create external table risk.ods__shopeepay_risk_control_br_db__workflow_tab
    (
     id                                                                                                   bigint               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,flow_no                                                                                              string               comment ''
,seq_id                                                                                               string               comment ''
,current_step                                                                                         string               comment 'Process steps'
,run_step                                                                                             string               comment 'Actual execution steps'
,status                                                                                               bigint               comment 'status,0 NOT FNIISH,1 finish but failure,2 finish and success'
,input                                                                                                string               comment 'input json'
,output                                                                                               string               comment 'output json'
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,req_no                                                                                               string               comment 'request number'
,req_md5                                                                                              string               comment 'MD5 of original request parameter'
,cluster_id                                                                                           bigint               comment 'cluster_id ,1 K8S ,2 PHYSICAL_MACHINE'
,async_flag                                                                                           bigint               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/workflow_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__shopeepay_risk_control_br_db__workflow_tab;

    