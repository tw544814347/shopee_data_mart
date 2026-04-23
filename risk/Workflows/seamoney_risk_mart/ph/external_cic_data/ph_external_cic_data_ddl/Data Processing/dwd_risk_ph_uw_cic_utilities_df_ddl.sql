-- 删除已有表（若存在）
DROP VIEW IF EXISTS risk.dwd_risk_ph_uw_cic_utilities_df;

CREATE TABLE IF NOT EXISTS risk.dwd_risk_ph_uw_cic_utilities_df (
    -- grass_date STRING,
    trace_id STRING,
    credit_user_id STRING,
    platform_user_id STRING,
    flow_no STRING,
    request_date STRING,
    request_date_time STRING,
    contract_code STRING,
    contract_phase STRING,
    contract_phase_desc STRING,
    contract_start_date STRING,
    contract_type STRING,
    contract_type_desc STRING,
    currency STRING,
    currency_desc STRING,
    last_update_date STRING,
    original_currency STRING,
    original_currency_desc STRING,
    provider_code_encrypted STRING,
    reference_no STRING,
    role STRING,
    role_desc STRING,
    profile STRING,
    billed_amount DOUBLE,
    last_payment_date STRING,
    next_payment_date STRING,
    outstanding_balance DOUBLE,
    overdue_days STRING,
    overdue_days_desc STRING,
    overdue_payments_amount DOUBLE,
    overdue_payments_number DOUBLE,
    payment_method STRING,
    payment_method_desc STRING,
    payment_periodicity STRING,
    payment_periodicity_desc STRING
)

PARTITIONED BY (grass_date STRING COMMENT '分区日期')

stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_ph_uw_cic_utilities_df_v0';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_ph_uw_cic_utilities_df;