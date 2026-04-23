DROP VIEW IF EXISTS dwd_risk_ph_uw_cic_loan_non_instalm_df;

CREATE TABLE IF NOT EXISTS risk.dwd_risk_ph_uw_cic_loan_non_instalm_df (
    --grass_date                  STRING COMMENT '数据分区日期',
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
    contract_status             STRING COMMENT '合同状态代码',
    contract_status_desc        STRING COMMENT '合同状态描述',
    
    -- GrantedNonInstallment 结构
    credit_limit               DECIMAL(30,10) COMMENT '信用额度',
    last_payment_date           STRING COMMENT '最后还款日期',
    overall_credit_limit        DECIMAL(30,10) COMMENT '总信用额度',
    overdue_payments_amount     DECIMAL(30,10) COMMENT '逾期金额',
    transaction_type            STRING COMMENT '交易类型代码',
    transaction_type_desc       STRING COMMENT '交易类型描述',
    utilization                DECIMAL(30,10) COMMENT '使用率',
    
    -- Guarantee 结构
    text                        STRING COMMENT '担保文本描述',
    guaranteed_amount          DECIMAL(30,10) COMMENT '担保金额',
    guarantor_name              STRING COMMENT '担保人姓名',
    provider_guarantee_no       STRING COMMENT '担保编号',
    validity_end_date           STRING COMMENT '担保有效期截止日',
    validity_start_date         STRING COMMENT '担保有效期起始日',
    real_text                   STRING COMMENT '实物担保描述',
    real_guarantee_code         STRING COMMENT '实物担保代码',
    real_guarantee_code_desc    STRING COMMENT '实物担保描述'
)


PARTITIONED BY (grass_date STRING COMMENT '分区日期')

stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_ph_uw_cic_loan_non_instalm_df_v0';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_ph_uw_cic_loan_non_instalm_df;