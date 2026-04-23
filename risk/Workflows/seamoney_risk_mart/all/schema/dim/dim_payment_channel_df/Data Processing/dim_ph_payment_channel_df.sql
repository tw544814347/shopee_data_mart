-- drop table if exists ${SCHEMA}.dim_spm_ph_payment_channel_df;
-- create external table if not exists ${SCHEMA}.dim_spm_ph_payment_channel_df 
-- (
--     rowkey string
--     ,qf    string
-- ) 
-- stored as parquet tblproperties (
--     "parquet.compress" = "SNAPPY",
--     "parquet.stripe.size" = "2147483648"
-- ) 
-- location '${HDFS_PATH}/risk_mart/dim/dim_spm_ph_payment_channel_df';
-- ;


-- drop table if exists ${SCHEMA}.dim_apm_ph_payment_channel_df;
-- create external table if not exists ${SCHEMA}.dim_apm_ph_payment_channel_df 
-- (
--     rowkey string
--     ,qf    string
-- ) 
-- stored as parquet tblproperties (
--     "parquet.compress" = "SNAPPY",
--     "parquet.stripe.size" = "2147483648"
-- ) 
-- location '${HDFS_PATH}/risk_mart/dim/dim_apm_ph_payment_channel_df';
-- ;

drop table if exists ${SCHEMA}.dim_pps_ph_payment_client_channel_df;
create external table if not exists ${SCHEMA}.dim_pps_ph_payment_client_channel_df 
(
    rowkey string
    ,qf    string
) 
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
) 
location '${HDFS_PATH}/risk_mart/dim/dim_pps_ph_payment_client_channel_df';
;