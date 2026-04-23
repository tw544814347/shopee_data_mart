

    alter table risk.ods__dps_transaction_id_db__loan_repay_flow_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/dps_transaction_xx_db/loan_repay_flow_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__dps_transaction_id_db__loan_repay_flow_tab__df;



    alter table risk.ods__dps_transaction_id_db__loan_repay_flow_tab__df add if not exists partition(grass_date='${ods_date_t0}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/dps_transaction_xx_db/loan_repay_flow_tab__df/grass_region=ID/grass_date=${ods_date_t0}'
    ;
    refresh table risk.ods__dps_transaction_id_db__loan_repay_flow_tab__df;



    drop table if exists risk.ods__dps_transaction_id_db__loan_repay_flow_tab;
create external table risk.ods__dps_transaction_id_db__loan_repay_flow_tab
(
 id                                                                                                   decimal(20,0)        comment ''
,repay_id                                                                                             string               comment ''
,flow_no                                                                                              string               comment ''
,product_type                                                                                         string               comment ''
,user_id                                                                                              string               comment ''
,loan_id                                                                                              string               comment ''
,principal                                                                                            decimal(30,10)       comment ''
,interest                                                                                             decimal(30,10)       comment ''
,cur_term                                                                                             bigint               comment ''
,create_time                                                                                          string               comment ''
,update_time                                                                                          string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/dps_transaction_xx_db/loan_repay_flow_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__dps_transaction_id_db__loan_repay_flow_tab;
