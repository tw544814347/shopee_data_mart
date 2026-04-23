DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_id_bill_repayment_user_list_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_id_bill_repayment_user_list_df(
  credit_user_id STRING
)
partitioned by(grass_date string comment 'YYYY-MM-dd')
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/dws/dwd_risk_bill_repayment_user_list_df/grass_region=ID';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_id_bill_repayment_user_list_df;

