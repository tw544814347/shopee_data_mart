

    alter table risk.ods__ldn_risk_underwriting_id_db__cashloan_limit_history_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/ldn_risk_underwriting_xx_db/cashloan_limit_history_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__ldn_risk_underwriting_id_db__cashloan_limit_history_tab__df;



    drop table if exists risk.ods__ldn_risk_underwriting_id_db__cashloan_limit_history_tab;
create external table risk.ods__ldn_risk_underwriting_id_db__cashloan_limit_history_tab
(
 hid                                                                                                  bigint               comment ''
,id                                                                                                   bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        bigint               comment ''
,total_limit                                                                                          bigint               comment ''
,ceiling_limit                                                                                        bigint               comment ''
,version                                                                                              bigint               comment ''
,currency_units                                                                                       bigint               comment ''
,temporary_limit                                                                                      bigint               comment ''
,temp_limit_start_time                                                                                bigint               comment ''
,temp_limit_end_time                                                                                  bigint               comment ''
,admin_fee_rate                                                                                       bigint               comment ''
,late_charge_rate                                                                                     bigint               comment ''
,penalty_interest_rate                                                                                bigint               comment ''
,sync_credit_status                                                                                   bigint               comment ''
,sync_whitelist_status                                                                                bigint               comment ''
,event_id                                                                                             string               comment ''
,event_detail                                                                                         string               comment ''
,source                                                                                               string               comment ''
,operator                                                                                             string               comment ''
,status                                                                                               bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,credit_type                                                                                          bigint               comment '1pre_approved,2realtime'
,processing_fee_rate                                                                                  bigint               comment 'processing_fee_rate'
,nominal_interest_rate                                                                                bigint               comment 'nominal_interest_rate'
,notes                                                                                                string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/ldn_risk_underwriting_xx_db/cashloan_limit_history_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__ldn_risk_underwriting_id_db__cashloan_limit_history_tab;
