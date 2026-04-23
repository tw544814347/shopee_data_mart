DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_id_user_lv1_linked_dpd_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_id_user_lv1_linked_dpd_df(
  platform_user_id STRING,
  total_users BIGINT,
  blacklist_users BIGINT,
  dpd15p_users BIGINT,
  dpd30p_users BIGINT
)
partitioned by(grass_date string comment 'YYYY-MM-dd')
stored as orc tblproperties ("orc.compress"="SNAPPY")
LOCATION '${HDFS_PATH}/risk_mart/dws/dws_risk_id_user_lv1_linked_dpd_df/grass_region=ID';
MSCK REPAIR TABLE ${SCHEMA}.dws_risk_id_user_lv1_linked_dpd_df;


