DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_${region_lower}_credit_behavior_features_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_${region_lower}_credit_behavior_features_df
(
    
    credit_user_id	string
    ,platform_user_id	string
    ,is_whitelisted_scl	Boolean
    ,is_whitelisted_bcl	Boolean
    ,is_whitelisted_spl	Boolean
    ,bscore	DECIMAL(30,10)
    ,bscore_grass_date	string
    ,bscore_overdue_tag	string
    ,antifraud_tag	INT
    ,activated_from_now_bcl	INT
    ,is_activated_bcl	Boolean
    ,is_activated_spl	Boolean
    ,total_limit_utilization_bcl	DECIMAL(30,10)
    ,total_limit_bcl	DECIMAL(30,10)
    ,temperory_limit_bcl	DECIMAL(30,10)
    ,used_limit_bcl	DECIMAL(30,10)
    ,permanent_total_limit_utilization_excluding_frozen_bcl	DECIMAL(30,10)
    ,permanent_general_limit_utilization_spl	DECIMAL(30,10)
    ,permanent_installment_limit_utilization_spl	DECIMAL(30,10)
    ,total_limit_utilization_spl	DECIMAL(30,10)
    ,permanent_total_limit_utilization_excluding_frozen_spl	DECIMAL(30,10)
    ,used_limit_spl	DECIMAL(30,10)
    ,disbursed_cnt_bcl	INT
    ,disbursed_cnt_spl	INT
    ,is_disbursed_spl	Boolean
    ,is_disbursed_bcl	Boolean
    ,average_bill_amt_90d_bcl	DECIMAL(30,10)
    ,average_bill_amt_90d_spl	DECIMAL(30,10)
    ,average_bill_amt_90d_user	DECIMAL(30,10)
    ,first_billed_from_now	INT
    ,first_billed_from_now_bcl	INT
    ,first_billed_from_now_spl	INT
    ,is_billed_bcl	Boolean
    ,is_billed_spl	Boolean
    ,latest_bill_amt_bcl	DECIMAL(30,10)
    ,latest_bill_amt_spl	DECIMAL(30,10)
    ,latest_bill_amt_user	DECIMAL(30,10)
    ,repaid_bills_num_bcl	INT
    ,repaid_bills_num_spl	INT
    ,repaid_bills_num_user	INT
    ,last_repay_from_now	INT
    ,current_dpd_bcl	INT
    ,current_dpd_scl	INT
    ,current_dpd_spl	INT
    ,ever_max_dpd_180d_bcl	INT
    ,ever_max_dpd_180d_spl	INT
    ,ever_max_dpd_360d_bcl	INT
    ,ever_max_dpd_360d_spl	INT
    ,ever_max_dpd_bcl	INT
    ,ever_max_dpd_scl	INT
    ,ever_max_dpd_spl	INT
    ,latest_dpd_bcl	INT
    ,latest_dpd_spl	INT
    ,credit_user_status	INT
    ,user_tag_spl	INT
    ,shopee_account_status	INT
    ,shopee_age	INT
    ,confirmed_gmv_usd_in_180d_user	DECIMAL(30,10)
    ,confirmed_gmv_usd_in_180d_spl	DECIMAL(30,10)
)
PARTITIONED BY
(
  grass_date string comment 'YYYY-MM-dd'
)
comment 'Tag:risk summary table'
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/ads/ads_risk_reg_credit_behavior_features_df/grass_region=${region_upper}';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_${region_lower}_credit_behavior_features_df;