

    alter table risk.ods__cf_risk_underwriting_id_db__credit_instalment_history_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/cf_risk_underwriting_xx_db/credit_instalment_history_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__cf_risk_underwriting_id_db__credit_instalment_history_tab__df;



    drop table if exists risk.ods__cf_risk_underwriting_id_db__credit_instalment_history_tab;
create external table risk.ods__cf_risk_underwriting_id_db__credit_instalment_history_tab
(
 hid                                                                                                  bigint               comment ''
,id                                                                                                   bigint               comment ''
,platform_type                                                                                        bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,term                                                                                                 bigint               comment ''
,interest_rate                                                                                        bigint               comment ''
,checkout_cap                                                                                         bigint               comment ''
,status                                                                                               bigint               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,operator                                                                                             string               comment ''
,notes                                                                                                string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/cf_risk_underwriting_xx_db/credit_instalment_history_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__cf_risk_underwriting_id_db__credit_instalment_history_tab;
