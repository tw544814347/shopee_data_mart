
    
    alter table risk.ods__shopeepay_risk_control_br_db__workflow_steps_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/workflow_steps_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__shopeepay_risk_control_br_db__workflow_steps_tab__df;

    


    drop table if exists risk.ods__shopeepay_risk_control_br_db__workflow_steps_tab;

    create external table risk.ods__shopeepay_risk_control_br_db__workflow_steps_tab
    (
     id                                                                                                   bigint               comment ''
,wfid                                                                                                 bigint               comment 'The id of the work table, used to associate the total process'
,platform_user_id                                                                                     string               comment ''
,step                                                                                                 string               comment 'Step type'
,status                                                                                               bigint               comment 'status,0 TODO 1 SUCESS 2 FAIL'
,input                                                                                                string               comment 'step input json'
,output                                                                                               string               comment ''
,next                                                                                                 string               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/workflow_steps_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__shopeepay_risk_control_br_db__workflow_steps_tab;

    