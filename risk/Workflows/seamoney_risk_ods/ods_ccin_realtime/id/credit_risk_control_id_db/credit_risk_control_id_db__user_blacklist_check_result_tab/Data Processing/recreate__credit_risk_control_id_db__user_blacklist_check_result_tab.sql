

    alter table risk.ods__credit_risk_control_id_db__user_blacklist_check_result_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/user_blacklist_check_result_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__user_blacklist_check_result_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__user_blacklist_check_result_tab;
create external table risk.ods__credit_risk_control_id_db__user_blacklist_check_result_tab
(
 id                                                                                                   decimal(20,0)        comment '""'
,platform_user_id                                                                                     string               comment 'platform_user_id'
,platform_type                                                                                        bigint               comment 'platform_type'
,flow_no                                                                                              string               comment 'flow numbwe'
,id_number                                                                                            string               comment 'customer idNuber(NIK)'
,response_status                                                                                      string               comment 'response_status'
,response_time                                                                                        bigint               comment 'response_time'
,transaction_id                                                                                       string               comment 'the request id, the max length is 64'
,pricing_strategy                                                                                     string               comment 'whether the request will be charged, enum type: FREE, PAY'
,recommendation                                                                                       string               comment 'Bpsdata recommended decision: PASS, REJECT, NEEDS_VERIFICATION'
,default_list_result                                                                                  string               comment 'List of Blacklist check result detailed information json'
,extra                                                                                                string               comment 'Extra response info such as exception message json'
,is_deleted                                                                                           bigint               comment 'soft delete field, 0: not deleted, 1: deleted'
,version                                                                                              bigint               comment 'optimistic lock'
,create_time                                                                                          bigint               comment 'create timestamp of this user'
,update_time                                                                                          bigint               comment 'update timestamp of this user'
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/user_blacklist_check_result_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__user_blacklist_check_result_tab;
