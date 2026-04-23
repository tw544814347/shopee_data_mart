
    
    alter table risk.ods__shopeepay_risk_control_br_db__fe_strategy_rule_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/fe_strategy_rule_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__shopeepay_risk_control_br_db__fe_strategy_rule_tab__df;

    

    
    alter table risk.ods__shopeepay_risk_control_br_db__fe_strategy_rule_tab__df add if not exists partition(grass_date='${smd_grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/fe_strategy_rule_tab__df/grass_region=BR/grass_date=${smd_grass_date}'
    ;
    refresh table risk.ods__shopeepay_risk_control_br_db__fe_strategy_rule_tab__df;

    


    drop table if exists risk.ods__shopeepay_risk_control_br_db__fe_strategy_rule_tab;

    create external table risk.ods__shopeepay_risk_control_br_db__fe_strategy_rule_tab
    (
     id                                                                                                   bigint               comment ''
,name                                                                                                 string               comment ''
,description                                                                                          string               comment ''
,level                                                                                                bigint               comment ''
,metrics                                                                                              string               comment ''
,expression                                                                                           string               comment ''
,error_default                                                                                        string               comment ''
,version                                                                                              bigint               comment ''
,version_status                                                                                       bigint               comment ''
,status                                                                                               bigint               comment ''
,category                                                                                             bigint               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/fe_strategy_rule_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__shopeepay_risk_control_br_db__fe_strategy_rule_tab;

    