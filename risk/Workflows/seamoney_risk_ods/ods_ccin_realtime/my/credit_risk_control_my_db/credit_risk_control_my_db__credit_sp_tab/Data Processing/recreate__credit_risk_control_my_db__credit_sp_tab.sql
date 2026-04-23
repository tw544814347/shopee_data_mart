
    
    alter table risk.ods__credit_risk_control_my_db__credit_sp_tab__df add if not exists partition(grass_date='${grass_date}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/credit_sp_tab__df/grass_region=MY/grass_date=${grass_date}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__credit_sp_tab__df;

    


    drop table if exists risk.ods__credit_risk_control_my_db__credit_sp_tab;

    create external table risk.ods__credit_risk_control_my_db__credit_sp_tab
    (
     id                                                                                                   bigint               comment ''
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
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,version                                                                                              bigint               comment ''
,platform_type                                                                                        bigint               comment ''
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
,sync_tag_status                                                                                      bigint               comment ''
,sync_temp_limit_result                                                                               string               comment 'sync temp limit result'
,credit_type                                                                                          bigint               comment '1pre_approved,2realtime'
,installment_limit                                                                                    bigint               comment 'installment limit'
,bnpl_limit                                                                                           bigint               comment 'BNPL limit'
,activation_source                                                                                    bigint               comment 'activation source, 1: pre-approved; 2: realtime; 3: MTA; 4: lite upgrade'
,notes                                                                                                string               comment ''

     ,_event string
    )
    stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
    LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/credit_sp_tab__df/grass_region=MY/grass_date=${grass_date}'
    ;


    refresh table risk.ods__credit_risk_control_my_db__credit_sp_tab;

    