
    
    alter table risk.ods__credit_score_id_db__mission_template_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_score_xx_db/mission_template_tab__df/grass_region=ID/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_score_id_db__mission_template_tab__df;

    


    drop table if exists risk.ods__credit_score_id_db__mission_template_tab;

    create external table risk.ods__credit_score_id_db__mission_template_tab
    (
     id                                                                                                   decimal(20,0)        comment ''
,mission_name                                                                                         string               comment 'mission name'
,mission_code                                                                                         string               comment 'mission code'
,mission_type                                                                                         bigint               comment 'mission type'
,complete_condition                                                                                   string               comment 'condition list for completing this mission'
,ops                                                                                                  string               comment 'operator email'
,create_time                                                                                          bigint               comment 'created time ms'
,update_time                                                                                          bigint               comment 'update time ms'

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_score_xx_db/mission_template_tab__df/grass_region=ID/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_score_id_db__mission_template_tab;

    