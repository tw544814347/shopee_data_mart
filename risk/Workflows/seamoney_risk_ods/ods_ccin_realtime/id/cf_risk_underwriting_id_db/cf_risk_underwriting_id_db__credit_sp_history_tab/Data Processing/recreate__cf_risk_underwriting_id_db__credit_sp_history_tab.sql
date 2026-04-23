

    alter table risk.ods__cf_risk_underwriting_id_db__credit_sp_history_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/cf_risk_underwriting_xx_db/credit_sp_history_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__cf_risk_underwriting_id_db__credit_sp_history_tab__df;



    drop table if exists risk.ods__cf_risk_underwriting_id_db__credit_sp_history_tab;
create external table risk.ods__cf_risk_underwriting_id_db__credit_sp_history_tab
(
 hid                                                                                                  bigint               comment ''
,id                                                                                                   bigint               comment ''
,platform_type                                                                                        bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,base_limit                                                                                           bigint               comment ''
,advanced_limit                                                                                       bigint               comment ''
,spl                                                                                                  bigint               comment ''
,instalment_two_month                                                                                 bigint               comment ''
,instalment_three_month                                                                               bigint               comment ''
,instalment_six_month                                                                                 bigint               comment ''
,event_id                                                                                             string               comment ''
,event_detail                                                                                         string               comment ''
,status                                                                                               bigint               comment ''
,version                                                                                              bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,operator                                                                                             string               comment ''
,currency_units                                                                                       bigint               comment ''
,temporary_limit                                                                                      bigint               comment ''
,temp_limit_start_time                                                                                bigint               comment ''
,temp_limit_end_time                                                                                  bigint               comment ''
,admin_fee_rate                                                                                       bigint               comment ''
,nominal_interest_rate                                                                                bigint               comment 'NIR nominal interest rate'
,buyer_tx_fee_rate                                                                                    bigint               comment ''
,late_charge_rate                                                                                     bigint               comment ''
,penalty_interest_rate                                                                                bigint               comment ''
,sync_status                                                                                          bigint               comment ''
,user_type                                                                                            bigint               comment ''
,source                                                                                               string               comment ''
,sync_tag_status                                                                                      decimal(20,0)        comment ''
,sync_temp_limit_result                                                                               string               comment 'sync temp limit result'
,credit_type                                                                                          bigint               comment '1pre_approved,2realtime'
,installment_limit                                                                                    bigint               comment 'installment limit'
,bnpl_limit                                                                                           bigint               comment 'BNPL limit'
,activation_source                                                                                    bigint               comment 'activation source, 1: pre-approved; 2: realtime; 3: MTA; 4: lite upgrade'
,notes                                                                                                string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/cf_risk_underwriting_xx_db/credit_sp_history_tab__df/grass_region=ID/grass_date=${ods_date_t1}'
;
refresh table risk.ods__cf_risk_underwriting_id_db__credit_sp_history_tab;
