
    
    alter table risk.ods__shopeepay_risk_control_br_db__custom_list_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/custom_list_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__shopeepay_risk_control_br_db__custom_list_tab__df;

    


    drop table if exists risk.ods__shopeepay_risk_control_br_db__custom_list_tab;

    create external table risk.ods__shopeepay_risk_control_br_db__custom_list_tab
    (
     id                                                                                                   decimal(20,0)        comment ''
,list_name                                                                                            string               comment 'List name'
,property                                                                                             bigint               comment 'List attributes, 1 black list, 2 white list, 3 grey list, etc.'
,status                                                                                               bigint               comment 'List status, 1 is valid, 0 is invalid, -1 is discarded'
,data_type                                                                                            string               comment '"The list contains data types, and the type is indicated by an identifier, and it can contain multiple types, separated by \",\""'
,list_source                                                                                          string               comment 'Data Sources'
,actions                                                                                              string               comment ''
,de_table_name                                                                                        string               comment ''
,remark                                                                                               string               comment 'label'
,description                                                                                          string               comment 'description'
,creator                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,category                                                                                             bigint               comment ''
,version                                                                                              bigint               comment ''
,total                                                                                                bigint               comment ''
,data_hash                                                                                            string               comment ''
,scenario_based                                                                                       bigint               comment ''
,fit_scene                                                                                            string               comment ''
,screening_switch                                                                                     bigint               comment 'the manual audit switch: 1-off, 2-on'

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/custom_list_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__shopeepay_risk_control_br_db__custom_list_tab;

    