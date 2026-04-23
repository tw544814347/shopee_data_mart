DROP TABLE IF EXISTS ${SCHEMA}.ads_behavior_th_underwrting_feature_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_behavior_th_underwrting_feature_df
(
     credit_user_id                                      string 
    ,shopee_account_status                              int            comment '0-ACCOUNT_DELETE,1-ACCOUNT_NORMAL,2-ACCOUNT_BANNED,3-ACCOUNT_FROZEN'    
    ,average_limit_utilization_in_30d_spl               decimal(30,10) comment 'average_spl_limit_utilization_in_30d_spl'
    ,average_limit_utilization_in_90d_spl               decimal(30,10) comment 'average_spl_limit_utilization_in_90d_spl'
    ,average_limit_utilization_in_180d_spl              decimal(30,10) comment 'average_spl_limit_utilization_in_180d_spl'
    ,max_limit_utilization_in_30d_spl                   decimal(30,10) comment 'max_spl_limit_utilization_in_30d_spl'
    ,max_limit_utilization_in_90d_spl                   decimal(30,10) comment 'max_spl_limit_utilization_in_90d_spl'
    ,max_limit_utilization_in_180d_spl                  decimal(30,10) comment 'max_spl_limit_utilization_in_180d_spl'
    ,average_limit_utilization_in_30d_bcl               decimal(30,10) comment 'average_bcl_limit_utilization_in_30d_bcl'
    ,average_limit_utilization_in_90d_bcl               decimal(30,10) comment 'average_bcl_limit_utilization_in_90d_bcl'
    ,average_limit_utilization_in_180d_bcl              decimal(30,10) comment 'average_bcl_limit_utilization_in_180d_bcl'
    ,max_limit_utilization_in_30d_bcl                   decimal(30,10) comment 'max_bcl_limit_utilization_in_30d_bcl'
    ,max_limit_utilization_in_90d_bcl                   decimal(30,10) comment 'max_bcl_limit_utilization_in_90d_bcl'
    ,max_limit_utilization_in_180d_bcl                  decimal(30,10) comment 'max_bcl_limit_utilization_in_180d_bcl'
    ,average_limit_utilization_in_30d_chp               decimal(30,10) comment 'average_spl_extra_limit_utilization_in_30d_chp'
    ,average_limit_utilization_in_90d_chp               decimal(30,10) comment 'average_spl_extra_limit_utilization_in_90d_chp'
    ,average_limit_utilization_in_180d_chp              decimal(30,10) comment 'average_spl_extra_limit_utilization_in_180d_chp'
    ,max_limit_utilization_in_30d_chp                   decimal(30,10) comment 'max_spl_extra_limit_utilization_in_30d_chp'
    ,max_limit_utilization_in_90d_chp                   decimal(30,10) comment 'max_spl_extra_limit_utilization_in_90d_chp'
    ,max_limit_utilization_in_180d_chp                  decimal(30,10) comment 'max_spl_extra_limit_utilization_in_180d_chp'
    ,ever_max_dpd_chp                                   bigint         comment 'ever_max_dpd_chp'
    ,preloan_reject_cnt_chp                             bigint         comment 'preloan_reject_cnt_chp'
    ,preloan_reject_cnt_90d_chp                         bigint         comment 'preloan_reject_cnt_90d_chp'
    ,preloan_reject_cnt_180d_chp                        bigint         comment 'preloan_reject_cnt_180d_chp'
    ,days_after_first_due_date_chp                      bigint         comment 'days_after_first_due_date_chp'
    ,ever_max_dpd_180d_chp                              bigint         comment 'ever_max_dpd_180d_chp'
    ,ever_max_dpd_360d_chp                              bigint         comment 'ever_max_dpd_360d_chp'
    ,first_postloan_reject_date_chp                     string         comment 'first_postloan_reject_date_chp'
    ,average_limit_utilization_in_30d_tl                decimal(30,10) comment 'average_limit_utilization_in_30d_tl'
    ,average_limit_utilization_in_90d_tl                decimal(30,10) comment 'average_limit_utilization_in_90d_tl'
    ,average_limit_utilization_in_180d_tl               decimal(30,10) comment 'average_limit_utilization_in_180d_tl'
    ,average_limit_utilization_in_360d_tl               decimal(30,10) comment 'average_limit_utilization_in_360d_tl'
    ,max_limit_utilization_in_30d_tl                    decimal(30,10) comment 'max_limit_utilization_in_30d_tl'
    ,max_limit_utilization_in_90d_tl                    decimal(30,10) comment 'max_limit_utilization_in_90d_tl'
    ,max_limit_utilization_in_180d_tl                   decimal(30,10) comment 'max_limit_utilization_in_180d_tl'
    ,max_limit_utilization_in_360d_tl                   decimal(30,10) comment 'max_limit_utilization_in_360d_tl'
)
partitioned by
(
	grass_date   string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_behavior_underwrting_feature_df/grass_region=TH';
MSCK REPAIR TABLE ${SCHEMA}.ads_behavior_th_underwrting_feature_df;