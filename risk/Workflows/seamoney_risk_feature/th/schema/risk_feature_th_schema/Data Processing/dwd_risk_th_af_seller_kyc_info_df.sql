DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_th_af_seller_kyc_info_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_th_af_seller_kyc_info_df
(
    platform_user_id  string,
    id_card_no     string
)
PARTITIONED BY
(
    grass_date string comment 'YYYY-MM-dd'
)
stored as parquet
LOCATION '${HDFS_PATH}/risk_feature/ads/dwd_risk_af_seller_kyc_info_df/grass_region=TH';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_th_af_seller_kyc_info_df;