drop table if exists risk.dws_risk_fs_seamoney_antifraud_device_df;
create table risk.dws_risk_fs_seamoney_antifraud_device_df
(
hash_device_id  string
,no_of_reset_last_30d bigint
) 
partitioned by
(
    grass_region string
    ,grass_date string
)
stored as parquet
location '${HDFS_PATH}/risk_feature/dws/dws_risk_fs_seamoney_antifraud_device_df'
;

msck repair table risk.dws_risk_fs_seamoney_antifraud_device_df
;

