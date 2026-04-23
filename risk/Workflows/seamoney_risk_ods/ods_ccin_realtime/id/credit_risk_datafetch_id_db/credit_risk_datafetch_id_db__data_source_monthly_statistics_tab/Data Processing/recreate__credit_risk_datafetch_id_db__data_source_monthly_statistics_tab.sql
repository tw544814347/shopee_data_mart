

    alter table risk.ods__credit_risk_datafetch_id_db__data_source_monthly_statistics_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_datafetch_xx_db/data_source_monthly_statistics_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_datafetch_id_db__data_source_monthly_statistics_tab__df;



    drop table if exists risk.ods__credit_risk_datafetch_id_db__data_source_monthly_statistics_tab;
create external table risk.ods__credit_risk_datafetch_id_db__data_source_monthly_statistics_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,data_source_name                                                                                     string               comment ''
,entity                                                                                               string               comment ''
,total_calls                                                                                          decimal(20,0)        comment ''
,success_calls                                                                                        decimal(20,0)        comment ''
,failed_calls                                                                                         decimal(20,0)        comment ''
,success_rate                                                                                         double               comment ''
,failed_rate                                                                                          double               comment ''
,year_month                                                                                           bigint               comment ''
,update_time                                                                                          bigint               comment ''
,create_time                                                                                          bigint               comment ''
,daily_data                                                                                           string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_datafetch_xx_db/data_source_monthly_statistics_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_datafetch_id_db__data_source_monthly_statistics_tab;
