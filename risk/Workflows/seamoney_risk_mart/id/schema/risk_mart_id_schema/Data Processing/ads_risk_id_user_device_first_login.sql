DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_id_user_device_first_login;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_id_user_device_first_login
(
    device_user_rowkey string,
    user_device_rowkey string,
    loginTime bigint,
    ts bigint,
    device string,
    grass_region string,
    login_channel string,
    login_type string,
    user_id string
)
    PARTITIONED BY
(
    grass_date string comment 'partition key, yyyy-MM-dd',
    key string 
)
    stored as parquet tblproperties (
                                        "parquet.compress" = "SNAPPY",
                                        "parquet.stripe.size" = "2147483648"
                                    )
;
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_id_user_device_first_login;