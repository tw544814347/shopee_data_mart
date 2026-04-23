

    alter table risk.ods__cf_risk_underwriting_id_db__invoke_policy_result_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/cf_risk_underwriting_xx_db/invoke_policy_result_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__cf_risk_underwriting_id_db__invoke_policy_result_tab__df;



    drop table if exists risk.ods__cf_risk_underwriting_id_db__invoke_policy_result_tab;
create external table risk.ods__cf_risk_underwriting_id_db__invoke_policy_result_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,trade_id                                                                                             string               comment ''
,flow_no                                                                                              string               comment 'Division table according to flow_no'
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,result_code                                                                                          bigint               comment ''
,reason                                                                                               string               comment ''
,reject_code                                                                                          string               comment ''
,create_time                                                                                          decimal(20,0)        comment ''
,update_time                                                                                          decimal(20,0)        comment ''
,status                                                                                               bigint               comment ' Underwriting status: 1 pending, 2 processing, 3 done'
,req_params                                                                                           string               comment 'Underwriting params'
,risk_level                                                                                           bigint               comment 'Risk level of user'
,limit_info                                                                                           string               comment 'Limit info output by underwriting'
,pending_code                                                                                         string               comment 'Pending code represents the type,like slik'
,risk_grade                                                                                           bigint               comment 'risk grade'
,tree_id                                                                                              bigint               comment ''
,tree_type                                                                                            bigint               comment ''
,tree_version                                                                                         bigint               comment ''
,context_info                                                                                         string               comment ''
,pending_feature                                                                                      string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/cf_risk_underwriting_xx_db/invoke_policy_result_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__cf_risk_underwriting_id_db__invoke_policy_result_tab;
