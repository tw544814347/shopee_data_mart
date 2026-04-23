DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_id_user_status_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_id_user_status_df(
  user_id STRING,
  last_frozen_control_live_days_from_now BIGINT
)
partitioned by(grass_date string comment 'YYYY-MM-dd')
stored as orc tblproperties ("orc.compress"="SNAPPY")
LOCATION '${HDFS_PATH}/risk_mart/dws/dws_risk_user_status_df/grass_region=ID';
MSCK REPAIR TABLE ${SCHEMA}.dws_risk_id_user_status_df;

