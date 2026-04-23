DROP TABLE IF EXISTS ${SCHEMA}.get_first_3ds_time_by_uid_and_card_my;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.get_first_3ds_time_by_uid_and_card_my
(
    rowkey      string,
    qf          string,  
    version     bigint,
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
MSCK REPAIR TABLE ${SCHEMA}.get_first_3ds_time_by_uid_and_card_my;




