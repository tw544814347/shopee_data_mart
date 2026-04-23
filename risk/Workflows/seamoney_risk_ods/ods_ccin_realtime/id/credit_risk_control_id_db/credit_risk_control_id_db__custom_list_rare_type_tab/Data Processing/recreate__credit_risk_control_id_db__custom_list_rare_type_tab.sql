

    alter table risk.ods__credit_risk_control_id_db__custom_list_rare_type_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/custom_list_rare_type_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__custom_list_rare_type_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__custom_list_rare_type_tab;
create external table risk.ods__credit_risk_control_id_db__custom_list_rare_type_tab
(
 id                                                                                                   bigint               comment ''
,data                                                                                                 string               comment ''
,data_type                                                                                            byte                 comment ''
,custom_list_id                                                                                       bigint               comment ''
,data_source                                                                                          string               comment ''
,action_detail                                                                                        string               comment ''
,action_fail_detail                                                                                   string               comment ''
,action_status                                                                                        bigint               comment ''
,remark                                                                                               string               comment ''
,status                                                                                               byte                 comment ''
,description                                                                                          string               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          integer              comment ''
,update_time                                                                                          integer              comment ''
,expire_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/custom_list_rare_type_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__custom_list_rare_type_tab;
