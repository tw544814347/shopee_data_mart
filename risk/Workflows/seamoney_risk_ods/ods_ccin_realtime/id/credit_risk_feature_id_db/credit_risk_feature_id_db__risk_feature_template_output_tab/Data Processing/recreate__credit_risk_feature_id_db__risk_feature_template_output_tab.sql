
    
    alter table risk.ods__credit_risk_feature_id_db__risk_feature_template_output_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_template_output_tab__df/grass_region=ID/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_feature_id_db__risk_feature_template_output_tab__df;

    


    drop table if exists risk.ods__credit_risk_feature_id_db__risk_feature_template_output_tab;

    create external table risk.ods__credit_risk_feature_id_db__risk_feature_template_output_tab
    (
     id                                                                                                   decimal(20,0)        comment ''
,template_id                                                                                          decimal(20,0)        comment ''
,return_type                                                                                          bigint               comment 'feature result return type'
,case_value                                                                                           string               comment 'case_value'
,case_desc                                                                                            string               comment 'case_desc'
,creator                                                                                              string               comment 'creator'
,updater                                                                                              string               comment 'updater'
,create_time                                                                                          bigint               comment 'create_time'
,update_time                                                                                          bigint               comment 'update_time'
,region                                                                                               string               comment 'region'

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_template_output_tab__df/grass_region=ID/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_feature_id_db__risk_feature_template_output_tab;

    