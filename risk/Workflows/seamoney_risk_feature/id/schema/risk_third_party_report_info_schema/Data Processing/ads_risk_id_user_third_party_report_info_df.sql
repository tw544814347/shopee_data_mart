DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_id_user_third_party_report_info_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_id_user_third_party_report_info_df
(
    id_card_no string comment 'id_card_no'
    ,has_fdc_reported int comment 'has ever fdc reported'
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_risk_user_third_party_report_info_df/grass_region=${grass_region}';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_id_user_third_party_report_info_df;
