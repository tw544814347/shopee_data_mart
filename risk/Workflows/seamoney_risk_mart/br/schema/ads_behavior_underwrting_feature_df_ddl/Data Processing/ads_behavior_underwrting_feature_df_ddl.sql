DROP TABLE IF EXISTS ${SCHEMA}.ads_behavior_underwrting_feature_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_behavior_underwrting_feature_df
(
    credit_user_id STRING,
    latest_dpd_eod_cashloan INT COMMENT 'latest dpd IN CL',
    postloan_reject_cnt_bcl INT COMMENT 'Post-loan reject count in BCL',
    postloan_reject_cnt_spl INT COMMENT 'Post-loan reject count in SPL',
    preloan_reject_cnt_bcl INT COMMENT 'Pre-loan reject count in BCL',
    preloan_reject_cnt_spl INT COMMENT 'Pre-loan reject count in SPL',
    postloan_reject_cnt_90d_bcl INT COMMENT 'Post-loan reject count in BCL within 90 days',
    postloan_reject_cnt_90d_spl INT COMMENT 'Post-loan reject count in SPL within 90 days',
    preloan_reject_cnt_90d_bcl INT COMMENT 'Pre-loan reject count in BCL within 90 days',
    preloan_reject_cnt_90d_spl INT COMMENT 'Pre-loan reject count in SPL within 90 days',
    postloan_reject_cnt_180d_bcl INT COMMENT 'Post-loan reject count in BCL within 180 days',
    postloan_reject_cnt_180d_spl INT COMMENT 'Post-loan reject count in SPL within 180 days',
    preloan_reject_cnt_180d_bcl INT COMMENT 'Pre-loan reject count in BCL within 180 days',
    preloan_reject_cnt_180d_spl INT COMMENT 'Pre-loan reject count in SPL within 180 days',
    average_limit_utilization_90d_spl DECIMAL(30,5) COMMENT 'SPL 90 days avg limit utilization',
    average_limit_utilization_180d_spl DECIMAL(30,5) COMMENT 'SPL 180 days avg limit utilization',
    max_limit_utilization_90d_spl DECIMAL(30,5) COMMENT 'SPL 90 days max limit utilization',
    max_limit_utilization_180d_spl DECIMAL(30,5) COMMENT 'SPL 180 days max limit utilization',

    average_limit_utilization_30d_spl DECIMAL(30,5) COMMENT 'SPL x days avg limit utilization',
    average_limit_utilization_360d_spl DECIMAL(30,5) COMMENT 'SPL x days avg limit utilization',
    max_limit_utilization_30d_spl DECIMAL(30,5) COMMENT 'SPL x days max limit utilization',
    max_limit_utilization_360d_spl DECIMAL(30,5) COMMENT 'SPL x days max limit utilization'


)
partitioned by
(
    grass_region string comment 'BR',
	grass_date   string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_behavior_underwrting_feature_df';
MSCK REPAIR TABLE ${SCHEMA}.ads_behavior_underwrting_feature_df;
