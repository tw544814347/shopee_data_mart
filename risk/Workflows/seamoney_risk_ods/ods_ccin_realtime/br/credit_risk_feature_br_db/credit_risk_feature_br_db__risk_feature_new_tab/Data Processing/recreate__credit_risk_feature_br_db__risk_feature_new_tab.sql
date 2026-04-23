
    
    alter table risk.ods__credit_risk_feature_br_db__risk_feature_new_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_new_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_feature_br_db__risk_feature_new_tab__df;

    

    
    alter table risk.ods__credit_risk_feature_br_db__risk_feature_new_tab__df add if not exists partition(grass_date='${smd_grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_new_tab__df/grass_region=BR/grass_date=${smd_grass_date}'
    ;
    refresh table risk.ods__credit_risk_feature_br_db__risk_feature_new_tab__df;

    


    drop table if exists risk.ods__credit_risk_feature_br_db__risk_feature_new_tab;

    create external table risk.ods__credit_risk_feature_br_db__risk_feature_new_tab
    (
     id                                                                                                   bigint               comment ''
,feature_name                                                                                         string               comment ''
,category                                                                                             bigint               comment ''
,fit_scope                                                                                            string               comment ''
,default_value                                                                                        string               comment ''
,version_status                                                                                       bigint               comment ''
,tags                                                                                                 string               comment ''
,version                                                                                              bigint               comment ''
,description                                                                                          string               comment ''
,status                                                                                               bigint               comment ''
,execute_engine                                                                                       string               comment ''
,script                                                                                               string               comment ''
,require_params                                                                                       string               comment ''
,query_fields                                                                                         string               comment ''
,data_source                                                                                          string               comment ''
,template_id                                                                                          bigint               comment ''
,return_type                                                                                          bigint               comment ''
,template_param                                                                                       string               comment ''
,feature_extensions                                                                                   string               comment ''
,data_source_param                                                                                    string               comment ''
,binning_rules                                                                                        string               comment ''
,creator                                                                                              string               comment ''
,updater                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,region                                                                                               string               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_new_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_feature_br_db__risk_feature_new_tab;

    