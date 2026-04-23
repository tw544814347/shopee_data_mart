DROP TABLE IF EXISTS ${SCHEMA}.get_th_payment_amt_cnt_by_card_fingerprint;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.get_th_payment_amt_cnt_by_card_fingerprint
(
    rowkey      string,
    amount      string,
    grass_date      string
)
    PARTITIONED BY
(
    grass_date
)
    stored as parquet tblproperties (
                                        "parquet.compress" = "SNAPPY",
                                        "parquet.stripe.size" = "2147483648"
                                    )
;
MSCK REPAIR TABLE ${SCHEMA}.get_th_payment_amt_cnt_by_card_fingerprint;


DROP TABLE IF EXISTS ${SCHEMA}.get_th_payment_userid_cnt_by_card_fingerprint;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.get_th_payment_userid_cnt_by_card_fingerprint
(
    rowkey      string,
    amount      string,
    grass_date      string
)
    PARTITIONED BY
(
    grass_date
)
    stored as parquet tblproperties (
                                        "parquet.compress" = "SNAPPY",
                                        "parquet.stripe.size" = "2147483648"
                                    )
;
MSCK REPAIR TABLE ${SCHEMA}.get_th_payment_userid_cnt_by_card_fingerprint;


DROP TABLE IF EXISTS ${SCHEMA}.get_th_payment_device_cnt_by_card_fingerprint;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.get_th_payment_device_cnt_by_card_fingerprint
(
    rowkey      string,
    amount      string,
    grass_date      string
)
    PARTITIONED BY
(
    grass_date
)
    stored as parquet tblproperties (
                                        "parquet.compress" = "SNAPPY",
                                        "parquet.stripe.size" = "2147483648"
                                    )
;
MSCK REPAIR TABLE ${SCHEMA}.get_th_payment_device_cnt_by_card_fingerprint;



DROP TABLE IF EXISTS ${SCHEMA}.get_th_payment_amt_cnt_by_card_and_device_fingerprint;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.get_th_payment_amt_cnt_by_card_and_device_fingerprint
(
    rowkey      string,
    amount      string,
    grass_date      string
)
    PARTITIONED BY
(
    grass_date
)
    stored as parquet tblproperties (
                                        "parquet.compress" = "SNAPPY",
                                        "parquet.stripe.size" = "2147483648"
                                    )
;
MSCK REPAIR TABLE ${SCHEMA}.get_th_payment_amt_cnt_by_card_and_device_fingerprint;