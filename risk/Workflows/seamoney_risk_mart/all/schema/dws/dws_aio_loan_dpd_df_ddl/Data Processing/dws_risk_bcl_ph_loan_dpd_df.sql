drop table if exists ${SCHEMA}.dws_risk_${product}_${region}_loan_dpd_df;
create external table if not exists ${SCHEMA}.dws_risk_${product}_${region}_loan_dpd_df
(
loan_id                           string            comment "loan_id"
,dpd_eod                          bigint            comment "dpd_eod"
,prev_month_dpd_eod               bigint            comment "prev_month_dpd_eod"
,loan_tenure                      bigint            comment "loan_tenure 总期数"
,current_bucket                   string            comment "current_bucket"
,prev_month_bucket                string            comment "prev_month_bucket"
,current_principal_os             decimal(30,10)    comment "loan level principal os at current timestamp"
,prev_month_principal_os          decimal(30,10)    comment "pre_month loan level principal os at current timestamp"
)
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
comment 'Tag:risk summary table'
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_aio_loan_dpd_df/garss_region=${upper_region}/product_id=${product_id}';

