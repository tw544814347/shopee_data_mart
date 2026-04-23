

    alter table risk.ods__credit_risk_control_id_ldn_db__screen_ops_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_ldn_db/screen_ops_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_ldn_db__screen_ops_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_ldn_db__screen_ops_tab;
create external table risk.ods__credit_risk_control_id_ldn_db__screen_ops_tab
(
 id                                                                                                   bigint               comment ''
,screen_id                                                                                            string               comment ''
,operate_type                                                                                         bigint               comment ''
,content                                                                                              string               comment ''
,content_map_no                                                                                       string               comment ''
,operator                                                                                             string               comment ''
,operator_map_no                                                                                      string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_ldn_db/screen_ops_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_ldn_db__screen_ops_tab;
