

    alter table risk.ods__shopeepay_risk_control_id_db__risk_action_imp_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/risk_action_imp_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__shopeepay_risk_control_id_db__risk_action_imp_tab__df;



    drop table if exists risk.ods__shopeepay_risk_control_id_db__risk_action_imp_tab;
create external table risk.ods__shopeepay_risk_control_id_db__risk_action_imp_tab
(
 id                                                                                                   bigint               comment ''
,event_code                                                                                           string               comment ''
,action_type                                                                                          string               comment ''
,ext_info                                                                                             string               comment ''
,version                                                                                              bigint               comment ''
,operator                                                                                             string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/risk_action_imp_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__shopeepay_risk_control_id_db__risk_action_imp_tab;
