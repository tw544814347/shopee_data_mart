

    alter table risk.ods__credit_risk_control_my_db__policy_output_rule_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/policy_output_rule_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__policy_output_rule_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__policy_output_rule_tab;
create external table risk.ods__credit_risk_control_my_db__policy_output_rule_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,rule_version                                                                                         bigint               comment ''
,version_status                                                                                       bigint               comment ''
,rule_config                                                                                          string               comment ''
,runtime_script                                                                                       string               comment ''
,create_user                                                                                          string               comment ''
,create_time                                                                                          bigint               comment ''
,update_user                                                                                          string               comment ''
,update_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/policy_output_rule_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__policy_output_rule_tab;
