

    alter table risk.ods__credit_risk_control_id_db__fe_strategy_group_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/fe_strategy_group_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__fe_strategy_group_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__fe_strategy_group_tab;
create external table risk.ods__credit_risk_control_id_db__fe_strategy_group_tab
(
 id                                                                                                   bigint               comment ''
,name                                                                                                 string               comment ''
,description                                                                                          string               comment ''
,metrics                                                                                              string               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,serial_type                                                                                          bigint               comment ''
,default_result_id                                                                                    bigint               comment ''
,version                                                                                              bigint               comment ''
,version_status                                                                                       bigint               comment ''
,status                                                                                               bigint               comment ''
,category                                                                                             bigint               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,app_scene_ids                                                                                        string               comment ''
,sub_category                                                                                         bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/fe_strategy_group_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__fe_strategy_group_tab;
