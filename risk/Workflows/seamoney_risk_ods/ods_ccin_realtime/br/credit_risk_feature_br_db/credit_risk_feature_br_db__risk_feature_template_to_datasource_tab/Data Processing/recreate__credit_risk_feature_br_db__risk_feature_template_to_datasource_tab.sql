
    
    alter table risk.ods__credit_risk_feature_br_db__risk_feature_template_to_datasource_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_template_to_datasource_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_feature_br_db__risk_feature_template_to_datasource_tab__df;

    


    drop table if exists risk.ods__credit_risk_feature_br_db__risk_feature_template_to_datasource_tab;

    create external table risk.ods__credit_risk_feature_br_db__risk_feature_template_to_datasource_tab
    (
     id                                                                                                   decimal(20,0)        comment ''
,template_id                                                                                          decimal(20,0)        comment ''
,category                                                                                             bigint               comment ''
,datasource                                                                                           string               comment ''
,exclusive                                                                                            bigint               comment ''
,creator                                                                                              string               comment ''
,updater                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,placeholder_type                                                                                     bigint               comment ''
,datasource_name                                                                                      string               comment ''
,datasource_desc                                                                                      string               comment ''
,region                                                                                               string               comment ''
,render_prop                                                                                          string               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_template_to_datasource_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_feature_br_db__risk_feature_template_to_datasource_tab;

    