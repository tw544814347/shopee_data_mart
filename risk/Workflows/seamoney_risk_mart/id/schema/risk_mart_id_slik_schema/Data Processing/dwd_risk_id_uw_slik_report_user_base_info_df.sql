DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_id_uw_slik_report_user_base_info_df_temp;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_id_uw_slik_report_user_base_info_df_temp
(
  qid string,
  debtor_name string,
  debtor_identity_type string,
  debtor_ktp string,
  debtor_Address string,
  debtor_gender string,
  debtor_gender_code string,
  npwp string,
  debtor_birthplace string,
  debtor_birthday string,
  grantor string,
  grantor_code string,
  debtor_info_create_date string,
  debtor_info_update_date string,
  village string,
  district string,
  city_code string,
  city string,
  postal_code string,
  country_code string,
  country string,
  occupation_code string,
  occupation string,
  working_location string,
  industry_code string,
  industry string,
  debtor_degree_code string,
  debtor_degree_status string
)
comment 'ID SLIK report user base info snapshot table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_id_uw_slik_report_user_base_info_df';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_id_uw_slik_report_user_base_info_df_temp;
