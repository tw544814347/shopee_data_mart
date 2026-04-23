DROP TABLE IF EXISTS ${SCHEMA}.ads_th_mp_seller_earliest_pay_time_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_th_mp_seller_earliest_pay_time_df
(
    shop_id                 bigint comment'shop id',
    earliest_pay_timestamp  bigint comment'shop earliest pay timestamp'
)
PARTITIONED BY
(
    grass_date string comment 'YYYY-MM-dd'
)
comment 'Tag:risk summary table'
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_mp_seller_earliest_pay_time_df/grass_region=TH';
MSCK REPAIR TABLE ${SCHEMA}.ads_th_mp_seller_earliest_pay_time_df;
