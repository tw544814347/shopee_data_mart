drop table if exists ${SCHEMA}.ads_risk_id_seller_data_df
;

create external table if not exists ${SCHEMA}.ads_risk_id_seller_data_df (
    rowkey string
    ,qf string
) partitioned by (
    grass_date string comment 'partition key, yyyy-MM-dd'
) stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY"
    ,"parquet.stripe.size" = "2147483648"
) location '${HDFS_PATH}/risk_mart/ads/ads_risk_id_seller_data_df'
;

msck repair table ${SCHEMA}.ads_risk_id_seller_data_df
;



drop table if exists ${SCHEMA}.ads_risk_id_seller_withdrawal_amt_df
;

create external table if not exists ${SCHEMA}.ads_risk_id_seller_withdrawal_amt_df (
    rowkey string
    ,qf string
) partitioned by (
    grass_date string comment 'partition key, yyyy-MM-dd'
) stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY"
    ,"parquet.stripe.size" = "2147483648"
) location '${HDFS_PATH}/risk_mart/ads/ads_risk_id_seller_withdrawal_amt_df'
;

msck repair table ${SCHEMA}.ads_risk_id_seller_withdrawal_amt_df
;
