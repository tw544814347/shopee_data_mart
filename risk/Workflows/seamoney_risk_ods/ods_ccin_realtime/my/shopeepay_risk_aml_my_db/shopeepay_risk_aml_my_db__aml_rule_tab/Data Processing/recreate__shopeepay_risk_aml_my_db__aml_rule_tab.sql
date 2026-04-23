

    alter table risk.ods__shopeepay_risk_aml_my_db__aml_rule_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_aml_xx_db/aml_rule_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__shopeepay_risk_aml_my_db__aml_rule_tab__df;



    drop table if exists risk.ods__shopeepay_risk_aml_my_db__aml_rule_tab;
create external table risk.ods__shopeepay_risk_aml_my_db__aml_rule_tab
(
 id                                                                                                   bigint               comment ''
,rule_id                                                                                              string               comment ''
,entity                                                                                               string               comment ''
,frequency                                                                                            string               comment ''
,threshold                                                                                            string               comment ''
,look_back_period                                                                                     bigint               comment ''
,status                                                                                               bigint               comment ''
,version_status                                                                                       bigint               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,creator                                                                                              string               comment ''
,extra_info                                                                                           string               comment ''
,rule_name                                                                                            string               comment ''
,type                                                                                                 bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/shopeepay_risk_aml_xx_db/aml_rule_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__shopeepay_risk_aml_my_db__aml_rule_tab;
