DROP TABLE IF EXISTS ${SCHEMA}.ads_2bscore_sg_user_phone_info_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_2bscore_sg_user_phone_info_df
(
    phone_no string
    ,platform_user_id string
    ,is_phone_matched int
    ,score int
    ,is_blacklist_hit int
    ,list_type int
    ,reason_code int
    ,score_v3 int
    ,reason_code_list string
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_2bscore_user_phone_info_df/grass_region=${region}';
MSCK REPAIR TABLE ${SCHEMA}.ads_2bscore_sg_user_phone_info_df;
