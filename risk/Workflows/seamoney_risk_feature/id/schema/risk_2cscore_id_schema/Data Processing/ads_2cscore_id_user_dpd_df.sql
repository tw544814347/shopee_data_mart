DROP TABLE IF EXISTS ${SCHEMA}.ads_2cscore_id_user_dpd_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_2cscore_id_user_dpd_df
(
shopee_userid string
,product_type string
,dpd bigint
)
PARTITIONED BY
(
 grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_2cscore_user_dpd_df/grass_region=${region}';
MSCK REPAIR TABLE ${SCHEMA}.ads_2cscore_id_user_dpd_df;