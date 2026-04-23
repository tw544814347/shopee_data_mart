DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_th_buyer_shipping_address_zipcode_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_th_buyer_shipping_address_zipcode_df
(
    platform_user_id                    string  comment 'platform_user_id'
    ,buyer_shipping_address_zipcode     string  comment 'Zip codes from payer’s completed orders’ receive addresses'
)
PARTITIONED BY
(
    grass_date string comment 'YYYY-MM-dd'
)
stored as parquet
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_risk_aio_buyer_shipping_address_zipcode_df/grass_region=TH';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_th_buyer_shipping_address_zipcode_df;