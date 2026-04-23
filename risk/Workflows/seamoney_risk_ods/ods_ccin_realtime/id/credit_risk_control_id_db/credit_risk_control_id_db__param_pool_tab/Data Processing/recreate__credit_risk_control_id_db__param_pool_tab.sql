

    alter table risk.ods__credit_risk_control_id_db__param_pool_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/param_pool_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__param_pool_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__param_pool_tab;
create external table risk.ods__credit_risk_control_id_db__param_pool_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,region                                                                                               string               comment ''
,app_id                                                                                               string               comment ''
,field                                                                                                string               comment ''
,field_type                                                                                           bigint               comment ''
,value_type                                                                                           string               comment ''
,data_source                                                                                          string               comment ''
,name                                                                                                 string               comment ''
,description                                                                                          string               comment ''
,create_user                                                                                          string               comment ''
,create_time                                                                                          bigint               comment ''
,array_size                                                                                           bigint               comment ''
,scene_id                                                                                             string               comment ''
,field_version                                                                                        bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/param_pool_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__param_pool_tab;
