

    alter table risk.ods__credit_risk_control_my_db__strategy_model_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/strategy_model_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__strategy_model_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__strategy_model_tab;
create external table risk.ods__credit_risk_control_my_db__strategy_model_tab
(
 id                                                                                                   bigint               comment ''
,model_name                                                                                           string               comment ''
,model_version                                                                                        string               comment ''
,model_url                                                                                            string               comment ''
,version                                                                                              bigint               comment ''
,model_description                                                                                    string               comment ''
,model_status                                                                                         bigint               comment ''
,model_history                                                                                        bigint               comment ''
,timeout                                                                                              bigint               comment ''
,inputs                                                                                               string               comment ''
,outputs                                                                                              string               comment ''
,operator                                                                                             string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,binning_rules                                                                                        string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/strategy_model_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__strategy_model_tab;
