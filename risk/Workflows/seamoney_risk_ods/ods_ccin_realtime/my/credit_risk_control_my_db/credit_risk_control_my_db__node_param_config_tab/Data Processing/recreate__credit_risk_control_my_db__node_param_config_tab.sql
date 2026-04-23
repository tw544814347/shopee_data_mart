

    alter table risk.ods__credit_risk_control_my_db__node_param_config_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/node_param_config_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__node_param_config_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__node_param_config_tab;
create external table risk.ods__credit_risk_control_my_db__node_param_config_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,tree_id                                                                                              bigint               comment ''
,node_id                                                                                              string               comment ''
,sis_field                                                                                            string               comment ''
,sis_field_type                                                                                       bigint               comment ''
,default_value                                                                                        string               comment ''
,field                                                                                                string               comment ''
,data_source                                                                                          string               comment ''
,tag                                                                                                  string               comment ''
,create_user                                                                                          string               comment ''
,create_time                                                                                          bigint               comment ''
,feature_version                                                                                      bigint               comment ''
,value_type                                                                                           bigint               comment ''
,sis_value_type                                                                                       string               comment ''
,sis_data_array_size                                                                                  bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/node_param_config_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__node_param_config_tab;
