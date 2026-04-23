DROP TABLE IF EXISTS ${SCHEMA}.ads_shopeepay_${region}_txn_order_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_shopeepay_${region}_txn_order_df
(
    rowkey  string,
    cnt     bigint,
    amount  bigint,
    status  int
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as parquet
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_shopeepay_txn_order_df/grass_region=${region}';
MSCK REPAIR TABLE ${SCHEMA}.ads_shopeepay_${region}_txn_order_df;
