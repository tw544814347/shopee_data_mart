DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_br_spp_wss_order;

create external table if not exists ${SCHEMA}.ads_risk_br_spp_wss_order
(
     rowkey string
    ,cnt string
    ,amt string
)
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
) location '${HDFS_PATH}/risk_mart/ads/ads_risk_br_spp_wss_order'
;

