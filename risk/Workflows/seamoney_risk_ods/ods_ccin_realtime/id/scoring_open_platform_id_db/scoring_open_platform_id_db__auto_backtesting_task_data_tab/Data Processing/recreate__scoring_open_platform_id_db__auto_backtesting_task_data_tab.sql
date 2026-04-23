

    alter table risk.ods__scoring_open_platform_id_db__auto_backtesting_task_data_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/scoring_open_platform_xx_db/auto_backtesting_task_data_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__scoring_open_platform_id_db__auto_backtesting_task_data_tab__df;



    drop table if exists risk.ods__scoring_open_platform_id_db__auto_backtesting_task_data_tab;
create external table risk.ods__scoring_open_platform_id_db__auto_backtesting_task_data_tab
(
 id                                                                                                   bigint               comment ''
,task_id                                                                                              string               comment ''
,task_data                                                                                            string               comment ''
,create_time                                                                                          decimal(20,0)        comment ''
,update_time                                                                                          decimal(20,0)        comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/scoring_open_platform_xx_db/auto_backtesting_task_data_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__scoring_open_platform_id_db__auto_backtesting_task_data_tab;
