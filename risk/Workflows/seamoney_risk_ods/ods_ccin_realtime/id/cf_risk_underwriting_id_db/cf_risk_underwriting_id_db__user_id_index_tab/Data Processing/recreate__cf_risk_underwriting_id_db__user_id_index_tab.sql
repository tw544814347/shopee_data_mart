
    
    alter table risk.ods__cf_risk_underwriting_id_db__user_id_index_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/cf_risk_underwriting_xx_db/user_id_index_tab__df/grass_region=ID/grass_date=${grass_date}'
    ;
    refresh table risk.ods__cf_risk_underwriting_id_db__user_id_index_tab__df;

    


    drop table if exists risk.ods__cf_risk_underwriting_id_db__user_id_index_tab;

    create external table risk.ods__cf_risk_underwriting_id_db__user_id_index_tab
    (
     user_id                                                                                              decimal(20,0)        comment ''
,platform_type                                                                                        bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,user_type                                                                                            bigint               comment ''
,create_time                                                                                          bigint               comment ''
,sync_tag                                                                                             bigint               comment '0 unsynchronized,1 complete sync'

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/cf_risk_underwriting_xx_db/user_id_index_tab__df/grass_region=ID/grass_date=${grass_date}'
    ;


    refresh table risk.ods__cf_risk_underwriting_id_db__user_id_index_tab;

    