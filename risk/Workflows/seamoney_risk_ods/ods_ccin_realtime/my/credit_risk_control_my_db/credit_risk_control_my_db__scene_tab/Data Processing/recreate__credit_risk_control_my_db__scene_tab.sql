

    alter table risk.ods__credit_risk_control_my_db__scene_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/scene_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__scene_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__scene_tab;
create external table risk.ods__credit_risk_control_my_db__scene_tab
(
 scene_id                                                                                             bigint               comment ''
,scene_name                                                                                           string               comment ''
,rule_group_ids                                                                                       string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,is_disable                                                                                           bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/scene_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__scene_tab;
