DROP VIEW IF EXISTS dwd_risk_ph_uw_cic_loan_cc_df;

CREATE TABLE IF NOT EXISTS risk.dwd_risk_ph_uw_cic_loan_cc_df (
    --grass_date                          STRING COMMENT '数据分区日期',
    trace_id                            STRING COMMENT '请求唯一追踪ID',
    credit_user_id                      STRING COMMENT '信贷用户ID',
    platform_user_id                    STRING COMMENT '平台用户ID',
    flow_no                             STRING COMMENT '流水号',
    request_date                        STRING   COMMENT 'CRIF请求日期',
    request_date_time                   STRING COMMENT 'CRIF请求时间戳',
    contract_code                       STRING COMMENT '合同代码',
    contract_end_date                   STRING COMMENT '合同结束日期',
    contract_phase                      STRING COMMENT '合同阶段代码',
    contract_phase_desc                 STRING COMMENT '合同阶段描述',
    contract_start_date                 STRING COMMENT '合同开始日期',
    contract_type                       STRING COMMENT '合同类型代码',
    contract_type_desc                  STRING COMMENT '合同类型描述',
    currency                           STRING COMMENT '货币代码',
    currency_desc                      STRING COMMENT '货币描述',
    last_update_date                   STRING COMMENT '最后更新日期',
    original_currency                  STRING COMMENT '原始货币代码',
    original_currency_desc            STRING COMMENT '原始货币描述',
    provider_code_encrypted           STRING COMMENT '加密的供应商代码',
    reference_no                       STRING COMMENT '参考编号',
    role                               STRING COMMENT '角色代码',
    role_desc                          STRING COMMENT '角色描述',
    contract_status                    STRING COMMENT '合同状态代码',
    contract_status_desc               STRING COMMENT '合同状态描述',
    credit_limit                       DECIMAL(30,10) COMMENT '信用额度',
    installment_type                   STRING COMMENT '分期类型代码',
    installment_type_desc              STRING COMMENT '分期类型描述',
    last_payment_amount                DECIMAL(30,10) COMMENT '最近一次还款金额',
    last_payment_date                 STRING COMMENT '最近一次还款日期',
    monthly_payment_amount            DECIMAL(30,10) COMMENT '月还款金额',
    next_payment                      STRING COMMENT '下次还款日期',
    outstanding_balance               DECIMAL(30,10) COMMENT '未偿余额',
    outstanding_balance_unbilled     DECIMAL(30,10) COMMENT '未出账单未偿余额',
    overdue_days                      STRING COMMENT '逾期天数',
    overdue_days_desc                 STRING COMMENT '逾期天数描述',
    overdue_payments_amount           DECIMAL(30,10) COMMENT '逾期还款金额',
    overdue_payments_number          DECIMAL(30,10) COMMENT '逾期还款次数',
    payment_method                    STRING COMMENT '支付方式代码',
    payment_method_desc               STRING COMMENT '支付方式描述',
    payment_periodicity               STRING COMMENT '付款周期代码',
    payment_periodicity_desc          STRING COMMENT '付款周期描述',
    reorganized_credit_code           STRING COMMENT '重组信用代码',
    reorganized_credit_code_desc      STRING COMMENT '重组信用描述',
    transaction_type                  STRING COMMENT '交易类型代码',
    transaction_type_desc             STRING COMMENT '交易类型描述'
)

PARTITIONED BY (grass_date STRING COMMENT '分区日期')

stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_ph_uw_cic_loan_cc_df_v0';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_ph_uw_cic_loan_cc_df;