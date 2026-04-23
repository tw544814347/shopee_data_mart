

    alter table risk.ods__credit_risk_control_id_db__tc_pool_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/tc_pool_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__tc_pool_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__tc_pool_tab;
create external table risk.ods__credit_risk_control_id_db__tc_pool_tab
(
 id                                                                                                   bigint               comment '""'
,app_id                                                                                               string               comment '""'
,platform_user_id                                                                                     string               comment '""'
,platform_type                                                                                        integer              comment '""'
,user_type                                                                                            integer              comment '""'
,source                                                                                               integer              comment '1 manual, 2 auto'
,sync_tag_status                                                                                      bigint               comment '""'
,status                                                                                               integer              comment '-2 removed, 1 active, -1 inactive'
,create_time                                                                                          bigint               comment '""'
,update_time                                                                                          bigint               comment '""'
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/tc_pool_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__tc_pool_tab;
