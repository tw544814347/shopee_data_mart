DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_ph_af_imei_price_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_ph_af_imei_price_df
(
     imei_sub               string comment 'first 8 digits of  IMEI'
    ,max_loanamount         bigint comment 'max_price'
    ,medium_loanamount      bigint comment 'medium price'
    ,min_loanamount         bigint comment 'min price'
    ,cnt_req                bigint comment 'req cnt'
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_risk_af_imei_price_df/grass_region=PH';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_ph_af_imei_price_df;
