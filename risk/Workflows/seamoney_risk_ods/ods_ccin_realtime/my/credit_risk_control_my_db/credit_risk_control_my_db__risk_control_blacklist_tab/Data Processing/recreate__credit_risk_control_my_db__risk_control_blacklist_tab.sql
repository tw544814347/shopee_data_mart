

    alter table risk.ods__credit_risk_control_my_db__risk_control_blacklist_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/risk_control_blacklist_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__risk_control_blacklist_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__risk_control_blacklist_tab;
create external table risk.ods__credit_risk_control_my_db__risk_control_blacklist_tab
(
 id                                                                                                   bigint               comment ''
,record_id                                                                                            string               comment ''
,type                                                                                                 bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,status                                                                                               bigint               comment ''
,operator                                                                                             string               comment ''
,reason                                                                                               string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/risk_control_blacklist_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__risk_control_blacklist_tab;
