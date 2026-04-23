
    
    alter table risk.ods__shopeepay_risk_control_br_db__fe_scene_strategy_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/fe_scene_strategy_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__shopeepay_risk_control_br_db__fe_scene_strategy_tab__df;

    

    
    alter table risk.ods__shopeepay_risk_control_br_db__fe_scene_strategy_tab__df add if not exists partition(grass_date='${smd_grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/fe_scene_strategy_tab__df/grass_region=BR/grass_date=${smd_grass_date}'
    ;
    refresh table risk.ods__shopeepay_risk_control_br_db__fe_scene_strategy_tab__df;

    


    drop table if exists risk.ods__shopeepay_risk_control_br_db__fe_scene_strategy_tab;

    create external table risk.ods__shopeepay_risk_control_br_db__fe_scene_strategy_tab
    (
     id                                                                                                   bigint               comment ''
,uuid                                                                                                 string               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,description                                                                                          string               comment ''
,version                                                                                              bigint               comment ''
,version_status                                                                                       bigint               comment ''
,strategy_package                                                                                     string               comment ''
,layout_data                                                                                          string               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/fe_scene_strategy_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__shopeepay_risk_control_br_db__fe_scene_strategy_tab;

    