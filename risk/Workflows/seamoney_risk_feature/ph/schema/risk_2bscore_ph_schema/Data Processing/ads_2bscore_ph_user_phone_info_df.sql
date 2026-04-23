DROP TABLE IF EXISTS ${SCHEMA}.ads_2bscore_ph_user_phone_info_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_2bscore_ph_user_phone_info_df
(
    phone_no string
    ,platform_user_id string
    ,is_phone_matched int
    ,score int
    ,is_blacklist_hit int
    ,list_type int
    ,reason_code int
    ,phone_no_sha256 string
    ,phone_no_base64 string
    ,address_info string
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_2bscore_user_phone_info_df/grass_region=${region}';
MSCK REPAIR TABLE ${SCHEMA}.ads_2bscore_ph_user_phone_info_df;
