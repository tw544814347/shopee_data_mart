-- 删除已有表（若存在）
DROP VIEW IF EXISTS risk.dwd_risk_ph_uw_cic_query_cc_df;

-- 创建表结构
CREATE TABLE risk.dwd_risk_ph_uw_cic_query_cc_df (
    -- grass_date STRING COMMENT '数据分区日期',
    trace_id STRING COMMENT '请求追踪ID',
    credit_user_id STRING COMMENT '信贷用户ID',
    platform_user_id STRING COMMENT '平台用户ID',
    flow_no STRING COMMENT '流水号',
    request_date STRING COMMENT '请求日期 (格式: yyyy-MM-dd)',
    request_date_time STRING COMMENT '请求时间戳 (原始字符串格式)',
    contract_code STRING COMMENT '合同编号',
    contract_phase STRING COMMENT '合同阶段代码',
    contract_phase_desc STRING COMMENT '合同阶段描述',
    contract_request_date STRING COMMENT '合同申请日期',
    contract_type STRING COMMENT '合同类型代码',
    contract_type_desc STRING COMMENT '合同类型描述',
    last_update_date STRING COMMENT '最后更新日期',
    provider_code_encrypted STRING COMMENT '加密供应商代码',
    provider_contract_no STRING COMMENT '供应商合同编号',
    reference_no STRING COMMENT '参考编号',
    role STRING COMMENT '角色代码',
    role_desc STRING COMMENT '角色描述',
    credit_limit DECIMAL(30,10) COMMENT '信用额度',
    payment_periodicity STRING COMMENT '付款周期代码',
    payment_periodicity_desc STRING COMMENT '付款周期描述'

)


PARTITIONED BY (grass_date STRING COMMENT '分区日期')

stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_ph_uw_cic_query_cc_df_v0';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_ph_uw_cic_query_cc_df;