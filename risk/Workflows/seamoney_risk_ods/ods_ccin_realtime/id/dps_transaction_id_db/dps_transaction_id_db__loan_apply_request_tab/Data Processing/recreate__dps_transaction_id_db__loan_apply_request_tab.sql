

    alter table risk.ods__dps_transaction_id_db__loan_apply_request_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/dps_transaction_xx_db/loan_apply_request_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__dps_transaction_id_db__loan_apply_request_tab__df;



    alter table risk.ods__dps_transaction_id_db__loan_apply_request_tab__df add if not exists partition(grass_date='${ods_date_t0}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/dps_transaction_xx_db/loan_apply_request_tab__df/grass_region=ID/grass_date=${ods_date_t0}'
    ;
    refresh table risk.ods__dps_transaction_id_db__loan_apply_request_tab__df;



    drop table if exists risk.ods__dps_transaction_id_db__loan_apply_request_tab;
create external table risk.ods__dps_transaction_id_db__loan_apply_request_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,app_id                                                                                               string               comment ''
,product_type                                                                                         string               comment ''
,user_id                                                                                              string               comment ''
,channel_user_id                                                                                      string               comment ''
,channel_loan_id                                                                                      string               comment ''
,loan_id                                                                                              string               comment ''
,apply_id                                                                                             string               comment ''
,apply_time                                                                                           string               comment ''
,request_time                                                                                         string               comment ''
,total_term                                                                                           bigint               comment ''
,total_principal                                                                                      decimal(30,10)       comment ''
,total_interest                                                                                       decimal(30,10)       comment ''
,monthly_interest_rate                                                                                decimal(30,10)       comment ''
,match_status                                                                                         bigint               comment ''
,success_time                                                                                         string               comment ''
,data_version                                                                                         bigint               comment ''
,create_time                                                                                          string               comment ''
,update_time                                                                                          string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/dps_transaction_xx_db/loan_apply_request_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__dps_transaction_id_db__loan_apply_request_tab;
