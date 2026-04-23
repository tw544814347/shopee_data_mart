

    alter table risk.ods__shopeepay_risk_control_id_db__strategy_to_l3_group_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/strategy_to_l3_group_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__shopeepay_risk_control_id_db__strategy_to_l3_group_tab__df;



    drop table if exists risk.ods__shopeepay_risk_control_id_db__strategy_to_l3_group_tab;
create external table risk.ods__shopeepay_risk_control_id_db__strategy_to_l3_group_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,strategy_id                                                                                          decimal(20,0)        comment ''
,l3_group_id                                                                                          decimal(20,0)        comment ''
,relate_status                                                                                        bigint               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_control_xx_db/strategy_to_l3_group_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__shopeepay_risk_control_id_db__strategy_to_l3_group_tab;
