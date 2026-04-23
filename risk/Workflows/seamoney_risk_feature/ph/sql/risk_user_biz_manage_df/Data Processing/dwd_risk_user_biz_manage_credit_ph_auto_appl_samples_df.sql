-- =============================================================================
-- Author:              wei.tao@shopee.com
-- Created Time:        2026-01-28
-- Theme Domain:        Anti-Fraud
-- Data Granularity:    
-- Description:         业务侧透传表，落切片+DQC
-- Documents:           https://jira.shopee.io/browse/SPFDT-60052
-- =============================================================================

drop table if exists risk.dwd_risk_user_biz_manage_credit_ph_auto_appl_samples_df;
create external table if not exists risk.dwd_risk_user_biz_manage_credit_ph_auto_appl_samples_df (
json_data string
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_feature/dwd/dwd_risk_user_biz_manage_credit_ph_auto_appl_samples_df'
;
msck repair table risk.dwd_risk_user_biz_manage_credit_ph_auto_appl_samples_df;

insert overwrite table risk.dwd_risk_user_biz_manage_credit_ph_auto_appl_samples_df partition(grass_date = '${grass_date}')
select
to_json(struct (*)) as json_data
from smcdrisk_antifraud.credit_ph_auto_appl_samples
;