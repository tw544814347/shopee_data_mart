

    alter table risk.ods__shopeepay_risk_control_my_db__custom_list_history_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/custom_list_history_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__shopeepay_risk_control_my_db__custom_list_history_tab__df;



    drop table if exists risk.ods__shopeepay_risk_control_my_db__custom_list_history_tab;
create external table risk.ods__shopeepay_risk_control_my_db__custom_list_history_tab
(
 hid                                                                                                  decimal(20,0)        comment ''
,id                                                                                                   decimal(20,0)        comment ''
,list_name                                                                                            string               comment ''
,property                                                                                             bigint               comment ''
,status                                                                                               bigint               comment ''
,data_type                                                                                            string               comment ''
,list_source                                                                                          string               comment ''
,actions                                                                                              string               comment ''
,de_table_name                                                                                        string               comment ''
,remark                                                                                               string               comment ''
,description                                                                                          string               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,category                                                                                             bigint               comment ''
,version                                                                                              bigint               comment ''
,total                                                                                                bigint               comment ''
,data_hash                                                                                            string               comment ''
,scenario_based                                                                                       bigint               comment ''
,fit_scene                                                                                            string               comment ''
,screening_switch                                                                                     bigint               comment ''
,de_table_config                                                                                      string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/custom_list_history_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__shopeepay_risk_control_my_db__custom_list_history_tab;
