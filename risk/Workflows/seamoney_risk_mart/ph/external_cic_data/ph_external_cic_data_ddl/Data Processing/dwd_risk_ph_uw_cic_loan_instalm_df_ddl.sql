DROP VIEW IF EXISTS dwd_risk_ph_uw_cic_loan_instalm_df;

CREATE TABLE IF NOT EXISTS risk.dwd_risk_ph_uw_cic_loan_instalm_df (
    -- grass_date                  STRING COMMENT '数据分区日期',
    trace_id                    STRING COMMENT '请求追踪ID',
    credit_user_id              STRING COMMENT '信贷用户ID',
    platform_user_id            STRING COMMENT '平台用户ID',
    flow_no                     STRING COMMENT '流水号',
    request_date                STRING COMMENT '请求日期',
    request_date_time           STRING COMMENT '请求时间戳',
    
    -- GrantedContract 结构
    contract_code               STRING COMMENT '合同编号',
    contract_end_date           STRING COMMENT '合同结束日期',
    contract_phase              STRING COMMENT '合同阶段代码',
    contract_phase_desc         STRING COMMENT '合同阶段描述',
    contract_start_date         STRING COMMENT '合同开始日期',
    contract_type               STRING COMMENT '合同类型代码',
    contract_type_desc          STRING COMMENT '合同类型描述',
    currency                    STRING COMMENT '货币代码',
    currency_desc               STRING COMMENT '货币描述',
    last_update_date            STRING COMMENT '最后更新日期',
    original_currency           STRING COMMENT '原始货币代码',
    original_currency_desc      STRING COMMENT '原始货币描述',
    provider_code_encrypted     STRING COMMENT '加密的供应商代码',
    reference_no                STRING COMMENT '参考编号',
    role                        STRING COMMENT '角色代码',
    role_desc                   STRING COMMENT '角色描述',
    
    -- GrantedInstallment 结构
    credit_purpose              STRING COMMENT '贷款用途代码',
    credit_purpose_desc         STRING COMMENT '贷款用途描述',
    financial_amount            DECIMAL(30,10) COMMENT '融资金额',
    installments_number         BIGINT COMMENT '分期期数',
    last_payment_amount        DECIMAL(30,10) COMMENT '最近还款金额',
    monthly_payment_amount      DECIMAL(30,10) COMMENT '月还款额',
    outstanding_balance         DECIMAL(30,10) COMMENT '未偿余额',
    outstanding_payments_number BIGINT COMMENT '未结清还款数',
    overdue_days                STRING COMMENT '逾期天数',
    overdue_days_desc           STRING COMMENT '逾期天数描述',
    overdue_payments_amount     DECIMAL(30,10) COMMENT '逾期金额',
    overdue_payments_number     BIGINT COMMENT '逾期次数',
    payment_method              STRING COMMENT '付款方式代码',
    payment_method_desc         STRING COMMENT '付款方式描述',
    payment_periodicity         STRING COMMENT '付款周期代码',
    payment_periodicity_desc    STRING COMMENT '付款周期描述',
    transaction_type            STRING COMMENT '交易类型代码',
    transaction_type_desc       STRING COMMENT '交易类型描述',
    last_payment_date           STRING COMMENT '最后还款日期',
    
    -- Leasing 结构
    good_brand                  STRING COMMENT '商品品牌',
    good_type                   STRING COMMENT '商品类型代码',
    good_type_desc              STRING COMMENT '商品类型描述',
    good_value                  DECIMAL(30,10) COMMENT '商品价值',
    manufacturing_date          STRING COMMENT '生产日期',
    new_used_code               STRING COMMENT '新旧程度代码',
    new_used_code_desc          STRING COMMENT '新旧程度描述',
    registration_number         STRING COMMENT '登记编号'
)


PARTITIONED BY (grass_date STRING COMMENT '分区日期')

stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_ph_uw_cic_loan_instalm_df_v0';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_ph_uw_cic_loan_instalm_df;