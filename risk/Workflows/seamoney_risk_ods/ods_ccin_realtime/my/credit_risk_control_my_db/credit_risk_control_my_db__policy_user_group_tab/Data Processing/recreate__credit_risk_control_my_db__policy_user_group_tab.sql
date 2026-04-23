
    
    alter table risk.ods__credit_risk_control_my_db__policy_user_group_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/policy_user_group_tab__df/grass_region=MY/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__policy_user_group_tab__df;

    


    drop table if exists risk.ods__credit_risk_control_my_db__policy_user_group_tab;

    create external table risk.ods__credit_risk_control_my_db__policy_user_group_tab
    (
     id                                                                                                   bigint               comment ''
,group_name                                                                                           string               comment ''
,source                                                                                               bigint               comment '1 manual upload, 2 de offline, 3 risk real time, 4 seamoney data offline'
,description                                                                                          string               comment ''
,version                                                                                              bigint               comment ''
,amount                                                                                               bigint               comment ''
,tags                                                                                                 string               comment ''
,type                                                                                                 bigint               comment '1 custom, 2 pre defined'
,operator                                                                                             string               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/policy_user_group_tab__df/grass_region=MY/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_control_my_db__policy_user_group_tab;

    