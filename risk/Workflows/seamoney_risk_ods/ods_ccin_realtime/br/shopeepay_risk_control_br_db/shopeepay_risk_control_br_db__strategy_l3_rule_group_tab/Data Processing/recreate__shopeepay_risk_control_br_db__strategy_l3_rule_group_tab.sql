
    
    alter table risk.ods__shopeepay_risk_control_br_db__strategy_l3_rule_group_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/strategy_l3_rule_group_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__shopeepay_risk_control_br_db__strategy_l3_rule_group_tab__df;

    


    drop table if exists risk.ods__shopeepay_risk_control_br_db__strategy_l3_rule_group_tab;

    create external table risk.ods__shopeepay_risk_control_br_db__strategy_l3_rule_group_tab
    (
     id                                                                                                   decimal(20,0)        comment ''
,ori_id                                                                                               decimal(20,0)        comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,group_name                                                                                           string               comment ''
,group_script                                                                                         string               comment ''
,l3_rules                                                                                             string               comment ''
,default_result_id                                                                                    bigint               comment ''
,version                                                                                              bigint               comment ''
,status                                                                                               bigint               comment ''
,description                                                                                          string               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,category                                                                                             bigint               comment ''
,version_status                                                                                       bigint               comment ''
,list_config                                                                                          string               comment ''
,serial_type                                                                                          bigint               comment '0: not support serial, default value, 1: serial'
,strategy_type                                                                                        bigint               comment '0: old version srtategy type, 1: riskfeature'
,group_script_v2                                                                                      string               comment ''
,rets                                                                                                 string               comment 'rets description'

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/strategy_l3_rule_group_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__shopeepay_risk_control_br_db__strategy_l3_rule_group_tab;

    