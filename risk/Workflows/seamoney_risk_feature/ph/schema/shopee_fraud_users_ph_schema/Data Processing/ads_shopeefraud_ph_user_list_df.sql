DROP TABLE IF EXISTS ${SCHEMA}.ads_shopeefraud_${region}_user_list_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_shopeefraud_${region}_user_list_df
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
	grass_date string comment 'YYYY-MM-dd'
)
stored as parquet
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_shopeefraud_user_list_df/grass_region=${region}';
MSCK REPAIR TABLE ${SCHEMA}.ads_shopeefraud_${region}_user_list_df;
