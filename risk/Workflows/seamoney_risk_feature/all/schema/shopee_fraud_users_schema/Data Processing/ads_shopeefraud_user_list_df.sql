DROP TABLE IF EXISTS ${SCHEMA}.ads_shopeefraud_user_list_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_shopeefraud_user_list_df
(
    id bigint ,
    userid bigint,
    status bigint,
    tagid bigint,
    ctime bigint,
    mtime bigint   
)
PARTITIONED BY
(
    grass_region String comment 'region in short code',
	grass_date string comment 'YYYY-MM-dd'
)
stored as parquet
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_shopeefraud_user_list_df';
MSCK REPAIR TABLE ${SCHEMA}.ads_shopeefraud_user_list_df;