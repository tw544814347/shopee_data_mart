
    
    alter table risk.ods__shopeepay_risk_control_br_db__risk_event_attributes_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/risk_event_attributes_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__shopeepay_risk_control_br_db__risk_event_attributes_tab__df;

    


    drop table if exists risk.ods__shopeepay_risk_control_br_db__risk_event_attributes_tab;

    create external table risk.ods__shopeepay_risk_control_br_db__risk_event_attributes_tab
    (
     id                                                                                                   bigint               comment ''
,event_code                                                                                           string               comment ''
,key                                                                                                  string               comment ''
,value                                                                                                string               comment ''
,description                                                                                          string               comment ''
,status                                                                                               bigint               comment ''
,operator                                                                                             string               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/risk_event_attributes_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__shopeepay_risk_control_br_db__risk_event_attributes_tab;

    