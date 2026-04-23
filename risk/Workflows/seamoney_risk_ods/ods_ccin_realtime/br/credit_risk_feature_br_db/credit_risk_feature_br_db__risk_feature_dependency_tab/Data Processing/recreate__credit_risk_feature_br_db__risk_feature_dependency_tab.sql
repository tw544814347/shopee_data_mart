
    
    alter table risk.ods__credit_risk_feature_br_db__risk_feature_dependency_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_dependency_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_feature_br_db__risk_feature_dependency_tab__df;

    


    drop table if exists risk.ods__credit_risk_feature_br_db__risk_feature_dependency_tab;

    create external table risk.ods__credit_risk_feature_br_db__risk_feature_dependency_tab
    (
     id                                                                                                   decimal(20,0)        comment ''
,feature_category                                                                                     bigint               comment 'feature category'
,feature_name                                                                                         string               comment 'feature name'
,feature_version                                                                                      bigint               comment 'feature version'
,dependency_feature_category                                                                          bigint               comment 'feature category'
,dependency_feature_name                                                                              string               comment 'dependency feature name'
,dependency_feature_version                                                                           bigint               comment 'dependency feature version'
,creator                                                                                              string               comment 'creator'
,create_time                                                                                          bigint               comment 'create_time'
,region                                                                                               string               comment 'region'

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_dependency_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_feature_br_db__risk_feature_dependency_tab;

    