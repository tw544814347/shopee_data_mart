DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_id_device_dpd_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_id_device_dpd_df(
  device_id string,
  dpd30p_users bigint,
  device_type string
)
partitioned by(grass_date string comment 'YYYY-MM-dd')
stored as orc tblproperties ("orc.compress"="SNAPPY")
LOCATION '${HDFS_PATH}/risk_mart/dws/dws_risk_device_dpd_df/grass_region=ID';
MSCK REPAIR TABLE ${SCHEMA}.dws_risk_id_device_dpd_df;