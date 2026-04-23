DROP TABLE IF EXISTS ${SCHEMA}.ads_2cscore_id_user_mission_result_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_2cscore_id_user_mission_result_df
(
shopee_userid           string
,platform_type          bigint
,mission_id	            bigint
,mission_type           bigint
,start_time             bigint
,completion_time        bigint
,start_time_local       string
,completion_time_local  string
,mission_result         bigint
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_2cscore_user_mission_result_df/grass_region=${region}';
MSCK REPAIR TABLE ${SCHEMA}.ads_2cscore_id_user_mission_result_df;