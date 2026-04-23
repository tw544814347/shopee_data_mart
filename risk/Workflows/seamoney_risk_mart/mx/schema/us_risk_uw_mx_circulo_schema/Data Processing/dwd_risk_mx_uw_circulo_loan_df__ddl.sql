drop table if exists ${SCHEMA}.dwd_risk_mx_uw_circulo_loan_df;

create external table if not exists ${SCHEMA}.dwd_risk_mx_uw_circulo_loan_df(
    flow_no string comment ''
    ,user_id string comment ''
    ,request_date   string comment ''
    ,request_datetime   string comment ''
    ,request_id     string comment ''
    ,message_type   string comment ''
    ,message_description    string comment ''
    ,update_date    string comment ''
    ,contested_record       decimal(30,10) comment ''
    ,grantor_code   string comment ''
    ,grantor_name       string comment ''
    ,account_number      string comment ''
    ,liability_type    string comment ''
    ,account_type string comment ''
    ,loan_type   string comment ''
    ,currency       string comment ''
    ,asset_value decimal(30,10) comment ''
    ,number_of_payments  bigint comment ''
    ,payment_frequency  string comment ''
    ,amount_due decimal(30,10) comment ''
    ,account_opening_date   string comment ''
    ,last_payment_date string comment ''
    ,last_purchase_date string comment ''
    ,account_closing_date   string comment ''
    ,report_date string comment ''
    ,last_zero_balance_date string comment ''
    ,collateral string comment ''
    ,maximum_loan  decimal(30, 10) comment '' 
    ,current_balance    decimal(30,10) comment ''
    ,credit_limit   decimal(30, 10) comment ''
    ,balance_due    decimal(30, 10) comment ''
    ,number_of_payments_due bigint comment ''
    ,current_payment string comment ''
    ,payment_history string comment ''
    ,last_payment_history_date string comment ''
    ,first_payment_history_date string comment ''
    ,observation_code   string comment ''
    ,total_payment_reported bigint comment ''
    ,worst_arrears decimal(30,10) comment ''
    ,worst_arrears_date string comment ''
    ,balance_due_of_worst_arrears decimal(30, 10) comment ''
    ,last_payment_amount    decimal(30, 10) comment ''
    ,address_id     string comment ''
    ,services       string comment ''
    ,can_id         string comment ''
    ,initial_priority   string comment ''
    ,current_priority   string comment ''
    ,can_opening_date   string comment ''
    ,can_cancellation_date  string comment ''
    ,can_history            string comment ''
    ,last_can_date          string comment ''
    ,first_can_date         string comment ''
)
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd","orc.stripe.size"="268435456"
)
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_uw_circulo_loan_df/grass_region=MX';
msck repair table ${SCHEMA}.dwd_risk_mx_uw_circulo_loan_df;


