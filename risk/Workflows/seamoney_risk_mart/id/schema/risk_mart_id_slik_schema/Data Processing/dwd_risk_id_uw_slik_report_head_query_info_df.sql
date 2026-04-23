DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_id_uw_slik_report_head_query_info_df_temp;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_id_uw_slik_report_head_query_info_df_temp
(
  id string,
  shopee_id bigint,
  credit_user_id bigint,
  request_reference_code string,
  report_search_date string,
  request_id string,
  requester_userid string,
  requester_username string,
  requester_ljk_code string,
  requester_branch_code string,
  requester_code string,
  report_request_date string,
  total_section string,
  report_section string,
  report_id string,
  latest_update_date string,
  request_date string,
  name string,
  gender string,
  gender_code string,
  id_no string,
  npwp string,
  birthplace string,
  birthday string
)
comment 'ID SLIK report head query info snapshot table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_id_uw_slik_report_head_query_info_df';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_id_uw_slik_report_head_query_info_df_temp;
