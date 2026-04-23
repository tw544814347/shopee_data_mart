DROP TABLE IF EXISTS ${SCHEMA}.ads_shopeepay_${region}_txn_order_dim_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_shopeepay_${region}_txn_order_dim_df
(
    rowkey              string,
    payment_channel_id  bigint,
    cnt                 bigint,
    amount              bigint,
    status              int,
    codes               string,
    type                bigint
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as parquet
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_shopeepay_txn_order_dim_df/grass_region=${region}';
MSCK REPAIR TABLE ${SCHEMA}.ads_shopeepay_${region}_txn_order_dim_df;
