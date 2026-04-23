

    alter table risk.ods__cf_risk_underwriting_id_db__whitelist_history_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/cf_risk_underwriting_xx_db/whitelist_history_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__cf_risk_underwriting_id_db__whitelist_history_tab__df;



    drop table if exists risk.ods__cf_risk_underwriting_id_db__whitelist_history_tab;
create external table risk.ods__cf_risk_underwriting_id_db__whitelist_history_tab
(
 hid                                                                                                  bigint               comment 'Auto Increment Id'
,id                                                                                                   bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        bigint               comment ''
,app_id                                                                                               bigint               comment 'APP_ID: 1, APP_ID_CASH_LOAN: 2, APP_ID_SELLER_LOAN:3, APP_ID_FAST_ESCROW: 4,APP_ID_PARTNER_LOAN: 5,APP_ID_SPL_LITE:6'
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
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/cf_risk_underwriting_xx_db/whitelist_history_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__cf_risk_underwriting_id_db__whitelist_history_tab;
