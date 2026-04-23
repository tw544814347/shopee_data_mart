

    alter table risk.ods__cf_risk_underwriting_id_db__dp_whitelist_history_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/cf_risk_underwriting_xx_db/dp_whitelist_history_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__cf_risk_underwriting_id_db__dp_whitelist_history_tab__df;



    drop table if exists risk.ods__cf_risk_underwriting_id_db__dp_whitelist_history_tab;
create external table risk.ods__cf_risk_underwriting_id_db__dp_whitelist_history_tab
(
 hid                                                                                                  bigint               comment ''
,id                                                                                                   bigint               comment 'whitelist row Id'
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        bigint               comment 'platform type:0unknown，1shopee'
,user_type                                                                                            bigint               comment 'user type:0unknown，1DP'
,status                                                                                               bigint               comment ' enable status: 1enable，-1disable'
,version                                                                                              bigint               comment 'row version'
,sync_enable_status                                                                                   bigint               comment 'sync white list status: 1todo, 2sync success,'
,operator                                                                                             string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,notes                                                                                                string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/cf_risk_underwriting_xx_db/dp_whitelist_history_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__cf_risk_underwriting_id_db__dp_whitelist_history_tab;
