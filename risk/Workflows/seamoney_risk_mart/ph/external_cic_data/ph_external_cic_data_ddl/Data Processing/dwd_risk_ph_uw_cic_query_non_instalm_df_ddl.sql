-- 删除已有表（若存在）
DROP VIEW IF EXISTS risk.dwd_risk_ph_uw_cic_query_non_instalm_df;


CREATE TABLE IF NOT EXISTS risk.dwd_risk_ph_uw_cic_query_non_instalm_df (
    --grass_date STRING,
    trace_id STRING,
    credit_user_id STRING,
    platform_user_id STRING,
    flow_no STRING,
    request_date STRING,
    request_date_time STRING,
    contract_code STRING,
    contract_phase STRING,
    contract_phase_desc STRING,
    contract_request_date STRING,
    contract_type STRING,
    contract_type_desc STRING,
    last_update_date STRING,
    provider_code_encrypted STRING,
    reference_no STRING,
    role STRING,
    role_desc STRING,
    credit_limit DOUBLE
)


PARTITIONED BY (grass_date STRING COMMENT '分区日期')

stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_ph_uw_cic_query_non_instalm_df_v0';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_ph_uw_cic_query_non_instalm_df;