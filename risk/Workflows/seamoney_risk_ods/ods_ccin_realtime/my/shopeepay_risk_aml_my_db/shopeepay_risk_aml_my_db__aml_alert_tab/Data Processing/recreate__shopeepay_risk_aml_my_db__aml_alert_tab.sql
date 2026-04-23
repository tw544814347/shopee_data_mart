

    alter table risk.ods__shopeepay_risk_aml_my_db__aml_alert_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_aml_xx_db/aml_alert_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__shopeepay_risk_aml_my_db__aml_alert_tab__df;



    drop table if exists risk.ods__shopeepay_risk_aml_my_db__aml_alert_tab;
create external table risk.ods__shopeepay_risk_aml_my_db__aml_alert_tab
(
 id                                                                                                   bigint               comment ''
,related_case_id                                                                                      bigint               comment ''
,related_task_id                                                                                      bigint               comment ''
,related_rule_id                                                                                      bigint               comment ''
,transaction_list                                                                                     string               comment ''
,status                                                                                               bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,related_organized_case_uuid                                                                          string               comment ''
,meta_info                                                                                            string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_aml_xx_db/aml_alert_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__shopeepay_risk_aml_my_db__aml_alert_tab;
