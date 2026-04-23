create table if not exists ${SCHEMA}.tmp_dqc_spp_risk_2fa_recently_verify_method_${region}
(
    shopeepay_userid string
    ,szdf string
    ,result string
) 
stored as parquet
tblproperties
(
    "parquet.compress" = "SNAPPY"
    ,"parquet.stripe.size" = "2147483648"
)
;