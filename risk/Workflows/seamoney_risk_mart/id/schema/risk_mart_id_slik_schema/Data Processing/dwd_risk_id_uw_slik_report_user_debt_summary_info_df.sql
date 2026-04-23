DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_id_uw_slik_report_user_debt_summary_info_df_temp;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_id_uw_slik_report_user_debt_summary_info_df_temp
(
  id string,
  total_os string,
  lc_limit string,
  gyd_limit string,
  securities_limit string,
  other_limit string,
  total_distursed_amt string,
  credit_facility_balance string,
  lc_balance string,
  gyd_balance string,
  securities_balance string,
  other_balance string,
  total_balance string,
  no_of_bank_fi string,
  number_of_BRP string,
  no_of_nonbank_fi string,
  no_of_other_fi string,
  historical_worst_status string,
  worst_status_record_date string
)
comment 'ID SLIK report user debt summary info snapshot table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_id_uw_slik_report_user_debt_summary_info_df';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_id_uw_slik_report_user_debt_summary_info_df_temp;
