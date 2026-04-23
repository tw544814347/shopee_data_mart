
    
    alter table risk.ods__credit_risk_underwriting_br_db__whitelist_history_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_underwriting_xx_db/whitelist_history_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_underwriting_br_db__whitelist_history_tab__df;

    


    drop table if exists risk.ods__credit_risk_underwriting_br_db__whitelist_history_tab;

    create external table risk.ods__credit_risk_underwriting_br_db__whitelist_history_tab
    (
     hid                                                                                                  bigint               comment 'Auto Increment Id'
,id                                                                                                   bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        bigint               comment ''
,app_id                                                                                               bigint               comment ''
,sub_biz_type                                                                                         string               comment ''
,status                                                                                               bigint               comment ''
,version                                                                                              bigint               comment ''
,operator                                                                                             string               comment ''
,sync_tag_status                                                                                      bigint               comment 'whitelist tag status, 1:financial,1<<1:spl'
,event_id                                                                                             string               comment ''
,event_detail                                                                                         string               comment ''
,credit_type                                                                                          bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,notes                                                                                                string               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_underwriting_xx_db/whitelist_history_tab__df/grass_region=BR/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_underwriting_br_db__whitelist_history_tab;

    