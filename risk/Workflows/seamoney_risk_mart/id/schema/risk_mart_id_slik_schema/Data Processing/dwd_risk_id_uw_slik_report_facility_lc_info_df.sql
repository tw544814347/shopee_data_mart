DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_id_uw_slik_report_facility_lc_info_df_temp;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_id_uw_slik_report_facility_lc_info_df_temp
(
    ktp_request_id string,
    lc_json string
)
comment 'ID SLIK report user ls  facility info snapshot table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_id_uw_slik_report_facility_lc_info_df';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_id_uw_slik_report_facility_lc_info_df_temp;