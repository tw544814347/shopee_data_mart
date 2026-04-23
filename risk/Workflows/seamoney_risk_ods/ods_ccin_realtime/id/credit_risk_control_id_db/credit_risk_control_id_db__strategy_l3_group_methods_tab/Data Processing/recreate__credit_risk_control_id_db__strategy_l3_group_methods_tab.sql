

    alter table risk.ods__credit_risk_control_id_db__strategy_l3_group_methods_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/strategy_l3_group_methods_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__strategy_l3_group_methods_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__strategy_l3_group_methods_tab;
create external table risk.ods__credit_risk_control_id_db__strategy_l3_group_methods_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,name                                                                                                 string               comment ''
,check_result                                                                                         string               comment ''
,ticket_tpl_id                                                                                        bigint               comment ''
,methods_description                                                                                  string               comment ''
,creator                                                                                              string               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,ticket_tpl_ids                                                                                       string               comment ''
,is_not_ticket                                                                                        bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/strategy_l3_group_methods_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__strategy_l3_group_methods_tab;
