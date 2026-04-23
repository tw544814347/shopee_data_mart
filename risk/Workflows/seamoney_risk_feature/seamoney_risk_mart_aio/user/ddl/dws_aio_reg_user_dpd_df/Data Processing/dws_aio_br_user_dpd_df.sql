DROP TABLE IF EXISTS ${SCHEMA}.dws_aio_${region_lower}_user_dpd_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_aio_${region_lower}_user_dpd_df
(
    credit_user_id string
    ,latest_dpd_spl int
    ,latest_dpd_bcl int
)
PARTITIONED BY
(
  grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/dws/dws_aio_${region_lower}_user_dpd_df/grass_region=${region_upper}';
MSCK REPAIR TABLE ${SCHEMA}.dws_aio_${region_lower}_user_dpd_df;