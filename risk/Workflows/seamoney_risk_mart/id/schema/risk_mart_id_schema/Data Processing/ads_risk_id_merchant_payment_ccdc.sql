DROP TABLE IF EXISTS ${SCHEMA}.get_merchant_payment_transaction;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.get_merchant_payment_transaction
(
    rowkey      string,
    qf          string,  
    region      string
)
PARTITIONED BY
(
	region  
)
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
)
;
MSCK REPAIR TABLE ${SCHEMA}.get_merchant_payment_transaction;

DROP TABLE IF EXISTS ${SCHEMA}.get_merchant_payment_amt_cnt_by_card;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.get_merchant_payment_amt_cnt_by_card
(
    rowkey      string,
    amount      string,  
    region      string
)
PARTITIONED BY
(
	region  
)
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
)
;
MSCK REPAIR TABLE ${SCHEMA}.get_merchant_payment_amt_cnt_by_card;

DROP TABLE IF EXISTS ${SCHEMA}.get_merchant_payment_amt_cnt_by_card_userid;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.get_merchant_payment_amt_cnt_by_card_userid
(
    rowkey      string,
    amount      string,  
    region      string
)
PARTITIONED BY
(
	region  
)
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
)
;
MSCK REPAIR TABLE ${SCHEMA}.get_merchant_payment_amt_cnt_by_card_userid;

DROP TABLE IF EXISTS ${SCHEMA}.get_merchant_payment_amt_cnt_by_userid;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.get_merchant_payment_amt_cnt_by_userid
(
    rowkey      string,
    amount      string,  
    region      string
)
PARTITIONED BY
(
	region  
)
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
)
;
MSCK REPAIR TABLE ${SCHEMA}.get_merchant_payment_amt_cnt_by_userid;


DROP TABLE IF EXISTS ${SCHEMA}.get_merchant_payment_amt_cnt_by_szdf;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.get_merchant_payment_amt_cnt_by_szdf
(
    rowkey      string,
    amount      string,  
    region      string
)
PARTITIONED BY
(
	region  
)
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
)
;
MSCK REPAIR TABLE ${SCHEMA}.get_merchant_payment_amt_cnt_by_szdf;
