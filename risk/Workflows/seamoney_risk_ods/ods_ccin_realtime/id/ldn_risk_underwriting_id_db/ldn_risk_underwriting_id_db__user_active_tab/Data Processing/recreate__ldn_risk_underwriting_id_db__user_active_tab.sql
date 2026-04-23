

    alter table risk.ods__ldn_risk_underwriting_id_db__user_active_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/ldn_risk_underwriting_xx_db/user_active_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__ldn_risk_underwriting_id_db__user_active_tab__df;



    drop table if exists risk.ods__ldn_risk_underwriting_id_db__user_active_tab;
create external table risk.ods__ldn_risk_underwriting_id_db__user_active_tab
(
 id                                                                                                   bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        bigint               comment ''
,app_id                                                                                               string               comment ''
,app_user_id                                                                                          string               comment ''
,source                                                                                               string               comment ''
,description                                                                                          string               comment ''
,create_time                                                                                          bigint               comment ''
,user_type                                                                                            bigint               comment '0 other, 1 spl,2 new user'
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/ldn_risk_underwriting_xx_db/user_active_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__ldn_risk_underwriting_id_db__user_active_tab;
