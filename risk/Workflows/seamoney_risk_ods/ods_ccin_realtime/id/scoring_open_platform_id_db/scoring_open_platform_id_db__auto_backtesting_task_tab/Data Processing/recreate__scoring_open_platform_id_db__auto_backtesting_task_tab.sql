

    alter table risk.ods__scoring_open_platform_id_db__auto_backtesting_task_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/scoring_open_platform_xx_db/auto_backtesting_task_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__scoring_open_platform_id_db__auto_backtesting_task_tab__df;



    drop table if exists risk.ods__scoring_open_platform_id_db__auto_backtesting_task_tab;
create external table risk.ods__scoring_open_platform_id_db__auto_backtesting_task_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,task_id                                                                                              string               comment ''
,company_name                                                                                         string               comment ''
,company_type                                                                                         bigint               comment ''
,service_name_list                                                                                    string               comment ''
,remark                                                                                               string               comment ''
,operator                                                                                             string               comment ''
,create_time                                                                                          decimal(20,0)        comment ''
,update_time                                                                                          decimal(20,0)        comment ''
,finish_time                                                                                          decimal(20,0)        comment ''
,task_status                                                                                          bigint               comment ''
,hash_method                                                                                          string               comment ''
,hash_key                                                                                             string               comment ''
,result_file                                                                                          string               comment ''
,retry_count                                                                                          bigint               comment ''
,failed_reason                                                                                        string               comment ''
,enter_processing_time                                                                                decimal(20,0)        comment ''
,checking_file                                                                                        string               comment ''
,checking_retry_count                                                                                 bigint               comment ''
,enter_data_checking_time                                                                             decimal(20,0)        comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/scoring_open_platform_xx_db/auto_backtesting_task_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__scoring_open_platform_id_db__auto_backtesting_task_tab;
