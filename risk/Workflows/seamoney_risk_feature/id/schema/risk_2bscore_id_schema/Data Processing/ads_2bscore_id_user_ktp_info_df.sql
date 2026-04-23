DROP TABLE IF EXISTS ${SCHEMA}.ads_2bscore_id_user_ktp_info_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_2bscore_id_user_ktp_info_df
(
    ktp_no string
    ,platform_user_id string
    ,is_ktp_matched int
    ,score int
    ,is_blacklist_hit int
    ,list_type int
    ,reason_code int
    ,address_info string
    ,score_v3 int
    ,ktp_no_sha256 string
    ,ktp_no_base64 string
    ,predicted_label_posthoc double
    ,predicted_label double
    ,score_v6 int
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_2bscore_user_ktp_info_df/grass_region=${region}';
MSCK REPAIR TABLE ${SCHEMA}.ads_2bscore_id_user_ktp_info_df;
