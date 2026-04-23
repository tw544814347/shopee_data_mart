DROP TABLE IF EXISTS ${SCHEMA}.ads_2cscore_id_user_score_list_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_2cscore_id_user_score_list_df
(
    shopee_userid string
    ,id_card_number string
    ,score_list string
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_2cscore_user_score_list_df/grass_region=${region}';
MSCK REPAIR TABLE ${SCHEMA}.ads_2cscore_id_user_score_list_df;
