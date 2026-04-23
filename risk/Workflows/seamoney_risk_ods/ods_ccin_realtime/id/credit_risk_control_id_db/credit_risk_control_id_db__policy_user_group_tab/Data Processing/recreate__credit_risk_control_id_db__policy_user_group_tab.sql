

    alter table risk.ods__credit_risk_control_id_db__policy_user_group_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/policy_user_group_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__policy_user_group_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__policy_user_group_tab;
create external table risk.ods__credit_risk_control_id_db__policy_user_group_tab
(
 id                                                                                                   bigint               comment ''
,group_name                                                                                           string               comment ''
,source                                                                                               bigint               comment ''
,description                                                                                          string               comment ''
,version                                                                                              bigint               comment ''
,amount                                                                                               bigint               comment ''
,tags                                                                                                 string               comment ''
,type                                                                                                 bigint               comment ''
,operator                                                                                             string               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/policy_user_group_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__policy_user_group_tab;
