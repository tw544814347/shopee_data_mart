DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_${region_lower}_user_bill_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_${region_lower}_user_bill_df
(
    credit_user_id string
    ,average_bill_amt_90d_bcl decimal(30,10)
    ,average_bill_amt_90d_spl decimal(30,10)
    ,average_bill_amt_90d_user decimal(30,10)
    ,latest_bill_amt_user decimal(30,10)
    ,repaid_bills_num_user int
)
PARTITIONED BY
(
  grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/dws/dws_risk_reg_user_bill_df/grass_region=${region_upper}';
MSCK REPAIR TABLE ${SCHEMA}.dws_risk_${region_lower}_user_bill_df;