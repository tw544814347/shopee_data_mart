-- drop table if exists ${SCHEMA}.dim_id_user_fraud_tag_df;
-- create external table if not exists ${SCHEMA}.dim_id_user_fraud_tag_df 
-- (
--     rowkey string
--     ,qf    string
-- ) 
-- stored as parquet tblproperties (
--     "parquet.compress" = "SNAPPY",
--     "parquet.stripe.size" = "2147483648"
-- ) 
-- location '${HDFS_PATH}/risk_mart/dim/dim_id_user_fraud_tag_df';
-- ;


drop table if exists ${SCHEMA}.dim_my_user_fraud_tag_df;
create external table if not exists ${SCHEMA}.dim_my_user_fraud_tag_df 
(
    rowkey string
    ,qf    string
) 
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
) 
location '${HDFS_PATH}/risk_mart/dim/dim_my_user_fraud_tag_df';
;


drop table if exists ${SCHEMA}.dim_th_user_fraud_tag_df;
create external table if not exists ${SCHEMA}.dim_th_user_fraud_tag_df 
(
    rowkey string
    ,qf    string
) 
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
) 
location '${HDFS_PATH}/risk_mart/dim/dim_th_user_fraud_tag_df';
;


drop table if exists ${SCHEMA}.dim_vn_user_fraud_tag_df;
create external table if not exists ${SCHEMA}.dim_vn_user_fraud_tag_df 
(
    rowkey string
    ,qf    string
) 
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
) 
location '${HDFS_PATH}/risk_mart/dim/dim_vn_user_fraud_tag_df';
;
