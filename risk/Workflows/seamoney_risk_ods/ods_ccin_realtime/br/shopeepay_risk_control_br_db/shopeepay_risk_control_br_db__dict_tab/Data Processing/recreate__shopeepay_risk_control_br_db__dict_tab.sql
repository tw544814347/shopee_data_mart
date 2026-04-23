
    
    alter table risk.ods__shopeepay_risk_control_br_db__dict_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/dict_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__shopeepay_risk_control_br_db__dict_tab__df;

    


    drop table if exists risk.ods__shopeepay_risk_control_br_db__dict_tab;

    create external table risk.ods__shopeepay_risk_control_br_db__dict_tab
    (
     id                                                                                                   decimal(20,0)        comment ''
,dict_key                                                                                             string               comment 'Dictionary key (type key)'
,dict_name                                                                                            string               comment 'Dictionary name'
,dict_value                                                                                           string               comment 'Dictionary value'
,parent_dict_key                                                                                      string               comment 'Parent dictionary key (parent type key)'
,leaf_node                                                                                            bigint               comment 'Whether it is a leaf node, 1 is, 0 is no'
,description                                                                                          string               comment 'description'
,status                                                                                               bigint               comment 'status'
,creator                                                                                              string               comment 'creator'
,create_time                                                                                          bigint               comment 'create time'
,update_time                                                                                          bigint               comment 'update time'

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/dict_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__shopeepay_risk_control_br_db__dict_tab;

    