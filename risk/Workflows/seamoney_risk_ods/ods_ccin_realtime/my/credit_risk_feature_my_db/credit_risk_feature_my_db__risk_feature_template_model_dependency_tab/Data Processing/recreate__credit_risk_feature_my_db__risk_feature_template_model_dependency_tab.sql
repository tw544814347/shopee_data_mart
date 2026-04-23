

    alter table risk.ods__credit_risk_feature_my_db__risk_feature_template_model_dependency_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_template_model_dependency_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_feature_my_db__risk_feature_template_model_dependency_tab__df;



    drop table if exists risk.ods__credit_risk_feature_my_db__risk_feature_template_model_dependency_tab;
create external table risk.ods__credit_risk_feature_my_db__risk_feature_template_model_dependency_tab
(
 id                                                                                                   bigint               comment ''
,template_id                                                                                          bigint               comment ''
,model_name                                                                                           string               comment ''
,model_version                                                                                        string               comment ''
,dependency_feature_category                                                                          bigint               comment ''
,dependency_feature_name                                                                              string               comment ''
,dependency_feature_version                                                                           bigint               comment ''
,dependency_feature_return_type                                                                       bigint               comment ''
,model_param_name                                                                                     string               comment ''
,dependency_feature_status                                                                            bigint               comment ''
,creator                                                                                              string               comment ''
,updater                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,region                                                                                               string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_template_model_dependency_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_feature_my_db__risk_feature_template_model_dependency_tab;
