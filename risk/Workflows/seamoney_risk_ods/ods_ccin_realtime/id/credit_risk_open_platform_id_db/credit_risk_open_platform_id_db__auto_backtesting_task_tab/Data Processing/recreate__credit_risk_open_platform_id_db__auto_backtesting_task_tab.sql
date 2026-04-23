

    alter table risk.ods__credit_risk_open_platform_id_db__auto_backtesting_task_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_open_platform_xx_db/auto_backtesting_task_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_open_platform_id_db__auto_backtesting_task_tab__df;



    drop table if exists risk.ods__credit_risk_open_platform_id_db__auto_backtesting_task_tab;
create external table risk.ods__credit_risk_open_platform_id_db__auto_backtesting_task_tab
(
 id                                                                                                   bigint               comment ''
,task_id                                                                                              string               comment ''
,company_name                                                                                         string               comment ''
,company_type                                                                                         bigint               comment ''
,service_name_list                                                                                    string               comment ''
,remark                                                                                               string               comment ''
,operator                                                                                             string               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,finish_time                                                                                          bigint               comment ''
,task_status                                                                                          bigint               comment ''
,hash_method                                                                                          string               comment ''
,hash_key                                                                                             string               comment ''
,result_file                                                                                          string               comment ''
,retry_count                                                                                          bigint               comment ''
,failed_reason                                                                                        string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_open_platform_xx_db/auto_backtesting_task_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_open_platform_id_db__auto_backtesting_task_tab;
