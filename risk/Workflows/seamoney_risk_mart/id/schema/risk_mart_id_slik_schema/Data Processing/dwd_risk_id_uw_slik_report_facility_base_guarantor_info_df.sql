DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_id_uw_slik_report_facility_base_guarantor_info_df_temp;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_id_uw_slik_report_facility_base_guarantor_info_df_temp
(
    credit_facility_info_id string,
    guarantor_address string,
    guarantor_information string,
    guarantor_type string,
    guarantor_code string,
    guarantor_name string,
    guarantor_id string,
    guarantor_create_date string,
    guarantor_update_date string
)
comment 'ID SLIK report guarantor info snapshot table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_id_uw_slik_report_facility_base_guarantor_info_df';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_id_uw_slik_report_facility_base_guarantor_info_df_temp;