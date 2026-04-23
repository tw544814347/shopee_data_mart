
    
    alter table risk.ods__credit_risk_feature_br_db__risk_feature_outer_proto_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_outer_proto_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_feature_br_db__risk_feature_outer_proto_tab__df;

    


    drop table if exists risk.ods__credit_risk_feature_br_db__risk_feature_outer_proto_tab;

    create external table risk.ods__credit_risk_feature_br_db__risk_feature_outer_proto_tab
    (
     id                                                                                                   decimal(20,0)        comment ''
,pb_file_name                                                                                         string               comment ''
,pb_type                                                                                              string               comment ''
,commit_id                                                                                            string               comment ''
,pb_content                                                                                           string               comment ''
,running_status                                                                                       bigint               comment ''
,creator                                                                                              string               comment ''
,updater                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,store_path                                                                                           string               comment ''
,region                                                                                               string               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_feature_xx_db/risk_feature_outer_proto_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_feature_br_db__risk_feature_outer_proto_tab;

    