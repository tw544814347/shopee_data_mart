

    alter table risk.ods__credit_risk_control_id_db__gray_strategy_stat_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/gray_strategy_stat_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_id_db__gray_strategy_stat_tab__df;



    drop table if exists risk.ods__credit_risk_control_id_db__gray_strategy_stat_tab;
create external table risk.ods__credit_risk_control_id_db__gray_strategy_stat_tab
(
 id                                                                                                   bigint               comment ''
,app_id                                                                                               string               comment ''
,scene_id                                                                                             bigint               comment ''
,old_strategy_id                                                                                      bigint               comment ''
,gray_strategy_id                                                                                     bigint               comment ''
,gray_proportion                                                                                      bigint               comment ''
,stat_status                                                                                          bigint               comment ''
,old_req_total                                                                                        bigint               comment ''
,old_pass_total                                                                                       bigint               comment ''
,old_reject_total                                                                                     bigint               comment ''
,old_verify_total                                                                                     bigint               comment ''
,old_error_total                                                                                      bigint               comment ''
,gray_req_total                                                                                       bigint               comment ''
,gray_pass_total                                                                                      bigint               comment ''
,gray_reject_total                                                                                    bigint               comment ''
,gray_verify_total                                                                                    bigint               comment ''
,gray_error_total                                                                                     bigint               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/gray_strategy_stat_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_id_db__gray_strategy_stat_tab;
