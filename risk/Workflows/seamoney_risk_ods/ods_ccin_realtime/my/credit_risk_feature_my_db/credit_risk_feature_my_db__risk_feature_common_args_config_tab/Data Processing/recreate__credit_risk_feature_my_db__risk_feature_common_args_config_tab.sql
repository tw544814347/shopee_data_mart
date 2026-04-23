

    alter table risk.ods__credit_risk_feature_my_db__risk_feature_common_args_config_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_common_args_config_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_feature_my_db__risk_feature_common_args_config_tab__df;



    drop table if exists risk.ods__credit_risk_feature_my_db__risk_feature_common_args_config_tab;
create external table risk.ods__credit_risk_feature_my_db__risk_feature_common_args_config_tab
(
 id                                                                                                   bigint               comment ''
,category                                                                                             bigint               comment ''
,sub_category                                                                                         string               comment ''
,json_key                                                                                             string               comment ''
,json_path                                                                                            string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,creator                                                                                              string               comment ''
,operator                                                                                             string               comment ''
,region                                                                                               string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_common_args_config_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_feature_my_db__risk_feature_common_args_config_tab;
