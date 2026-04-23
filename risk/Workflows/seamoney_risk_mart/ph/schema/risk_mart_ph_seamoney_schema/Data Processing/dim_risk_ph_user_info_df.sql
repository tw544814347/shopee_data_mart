drop table if exists ${SCHEMA}.dim_risk_${region}_user_info_df;

create external table if not exists ${SCHEMA}.dim_risk_${region}_user_info_df (
    platform_user_id string comment 'platform_user_id'
    ,is_seller bigint comment 'is_seller'
    ,shopee_age bigint comment 'datediff(format_time(ctime,upper({region})),current_date)'
    ,is_phone_verified bigint comment 'is_phone_verified'
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/dim/dim_risk_aio_user_info_df/garss_region=${upper_region}'
;

msck repair table ${SCHEMA}.dim_risk_${region}_user_info_df
;