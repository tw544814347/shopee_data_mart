

    alter table risk.ods__credit_risk_control_my_db__loan_limit_tab__df add if not exists partition(grass_date='${ods_date_t1}') location 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/loan_limit_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
    ;
    refresh table risk.ods__credit_risk_control_my_db__loan_limit_tab__df;



    drop table if exists risk.ods__credit_risk_control_my_db__loan_limit_tab;
create external table risk.ods__credit_risk_control_my_db__loan_limit_tab
(
 id                                                                                                   bigint               comment ''
,platform_user_id                                                                                     string               comment ''
,platform_type                                                                                        bigint               comment ''
,app_id                                                                                               string               comment ''
,sub_app_id                                                                                           string               comment 'partner loan  partner name'
,total_limit                                                                                          bigint               comment ''
,ceiling_limit                                                                                        bigint               comment ''
,version                                                                                              bigint               comment ''
,currency_units                                                                                       bigint               comment '，1 Rupiah'
,temporary_limit                                                                                      bigint               comment ''
,temp_limit_start_time                                                                                bigint               comment ''
,temp_limit_end_time                                                                                  bigint               comment ''
,admin_fee_rate                                                                                       bigint               comment ''
,late_charge_rate                                                                                     bigint               comment ''
,penalty_interest_rate                                                                                bigint               comment ''
,sync_credit_status                                                                                   bigint               comment ''
,sync_whitelist_status                                                                                bigint               comment ''
,sync_tag_status                                                                                      decimal(20,0)        comment ''
,event_id                                                                                             string               comment ''
,event_detail                                                                                         string               comment ''
,source                                                                                               string               comment 'data source'
,operator                                                                                             string               comment ''
,status                                                                                               bigint               comment ''
,create_time                                                                                          bigint               comment ''
,update_time                                                                                          bigint               comment ''
,customer_level_credit_limit                                                                          bigint               comment 'customer level credit limit'
,spl_eligible                                                                                         bigint               comment 'spl is escrow eligible transaction'
,cod_eligible                                                                                         bigint               comment 'cash on delivery is escrow eligible transaction'
,percentage_sales                                                                                     bigint               comment 'Percentage of Daily eligible Sales'
,prepayment_penalty_rate                                                                              bigint               comment 'prepayment penalty rate'
,scene                                                                                                string               comment ''
,nominal_interest_rate                                                                                bigint               comment 'NIR nominal interest rate'
,sync_temp_limit_result                                                                               string               comment 'sync temp limit result'
,service_fee_rate                                                                                     bigint               comment 'service fee charge'
,shop_id                                                                                              string               comment 'shop id record by req'
,seller_group                                                                                         bigint               comment '0: normal seller, 1:FSS seller, 2:preferred seller'
,is_prefer_seller                                                                                     bigint               comment '1:normal seller, 2:preferred seller'
,is_fss_seller                                                                                        bigint               comment '1:normal seller, 2:FSS seller'
,is_official_seller                                                                                   bigint               comment '1:normal seller, 2:OS seller'
,notes                                                                                                string               comment ''
 
 ,_event string
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/ods/credit_risk_control_xx_db/loan_limit_tab__df/grass_region=MY/grass_date=${ods_date_t1}'
;
refresh table risk.ods__credit_risk_control_my_db__loan_limit_tab;
