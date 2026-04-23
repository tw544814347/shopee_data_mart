

    alter table risk.ods__credit_risk_control_my_db__rule_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/rule_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__rule_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__rule_tab;
create external table risk.ods__credit_risk_control_my_db__rule_tab
(
 rule_id                                                                                              bigint               comment ''
,rule_name                                                                                            string               comment ''
,op                                                                                                   string               comment ''
,feature_id                                                                                           bigint               comment ''
,value                                                                                                string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,status                                                                                               bigint               comment ''
,label                                                                                                string               comment ''
,desc                                                                                                 string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/rule_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__rule_tab;
