DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_my_user_invest_kyc_info;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_my_user_invest_kyc_info
(
    rowkey string,
    qf string
)
    PARTITIONED BY
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
    stored as parquet tblproperties (
                                        "parquet.compress" = "SNAPPY",
                                        "parquet.stripe.size" = "2147483648"
                                    )
;
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_my_user_invest_kyc_info;