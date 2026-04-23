

    alter table risk.ods__shopeepay_risk_control_id_db__custom_list_action_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/custom_list_action_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__shopeepay_risk_control_id_db__custom_list_action_tab__df;



    drop table if exists risk.ods__shopeepay_risk_control_id_db__custom_list_action_tab;
create external table risk.ods__shopeepay_risk_control_id_db__custom_list_action_tab
(
 id                                                                                                   bigint               comment ''
,action_name                                                                                          string               comment ''
,action_attr                                                                                          string               comment ''
,status                                                                                               bigint               comment ''
,description                                                                                          string               comment ''
,creator                                                                                              string               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/custom_list_action_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__shopeepay_risk_control_id_db__custom_list_action_tab;
