create table if not exists ${SCHEMA}.tmp_dqc_spp_risk_2fa_user_device_verify_detail_${region}
(
    shopeepay_userid string
    ,szdf string 
    ,verify_method string
    ,verify_status string
    ,result bigint
    ,beginTime bigint
    ,endTime bigint
) 
stored as parquet
tblproperties
(
    "parquet.compress" = "SNAPPY"
    ,"parquet.stripe.size" = "2147483648"
)
;