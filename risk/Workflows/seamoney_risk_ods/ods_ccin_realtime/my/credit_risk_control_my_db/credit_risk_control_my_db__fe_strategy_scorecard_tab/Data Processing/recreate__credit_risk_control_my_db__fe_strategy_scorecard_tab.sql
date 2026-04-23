

    alter table risk.ods__credit_risk_control_my_db__fe_strategy_scorecard_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/fe_strategy_scorecard_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__fe_strategy_scorecard_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__fe_strategy_scorecard_tab;
create external table risk.ods__credit_risk_control_my_db__fe_strategy_scorecard_tab
(
 id                                                                                                   bigint               comment ''
,name                                                                                                 string               comment ''
,description                                                                                          string               comment ''
,return_type                                                                                          bigint               comment ''
,metrics                                                                                              string               comment ''
,version                                                                                              bigint               comment ''
,version_status                                                                                       bigint               comment ''
,status                                                                                               bigint               comment ''
,category                                                                                             bigint               comment ''
,creator                                                                                              string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/fe_strategy_scorecard_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__fe_strategy_scorecard_tab;
