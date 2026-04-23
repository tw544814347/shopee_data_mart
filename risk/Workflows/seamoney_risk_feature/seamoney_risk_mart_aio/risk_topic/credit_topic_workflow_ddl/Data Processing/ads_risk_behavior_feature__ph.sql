drop table if exists ${SCHEMA}.ads_risk_behavior_feature__ph
;

create external table if not exists ${SCHEMA}.ads_risk_behavior_feature__ph (
    credit_user_id string comment 'credit_user_id'
    --dws_risk_ph_user_withdraw_feature
    ,is_user_withdraw_scope int 
    ,`postloan_reject_cnt_bcl` bigint
    ,`postloan_reject_cnt_spl` bigint
    ,`preloan_reject_cnt_bcl` bigint
    ,`preloan_reject_cnt_spl` bigint
    ,`postloan_reject_cnt_90d_bcl` bigint
    ,`postloan_reject_cnt_90d_spl` bigint
    ,`preloan_reject_cnt_90d_bcl` bigint
    ,`preloan_reject_cnt_90d_spl` bigint
    ,`postloan_reject_cnt_180d_bcl` bigint
    ,`postloan_reject_cnt_180d_spl` bigint
    ,`preloan_reject_cnt_180d_bcl` bigint
    ,`preloan_reject_cnt_180d_spl` bigint
    ,`rejected_num_90d_bcl` bigint
    --dws_risk_ph_user_dpd_df
    ,is_user_dpd_scope int
    ,ever_max_dpd_cashloan_core bigint
    ,ever_max_dpd_sellerloan_core bigint
    ,ever_max_dpd_spl_core bigint
    ,last_bill_dpd_spl_core bigint
    ,days_after_first_due_date_spl bigint
    ,ever_max_dpd_180d_spl bigint
    ,ever_max_dpd_360d_spl bigint
    ,days_after_first_due_date_cashloan bigint
    ,ever_max_dpd_180d_cashloan bigint
    ,ever_max_dpd_360d_cashloan bigint
    ,ever_max_dpd_180d_user bigint
    ,ever_max_dpd_360d_user bigint
    ,repaid_bills_num_cashloan bigint
    ,latest_dpd_cashloan bigint
    ,ever_max_dpd_30d_sellerloan bigint comment ''
    ,ever_max_dpd_90d_sellerloan bigint comment ''
    ,ever_max_dpd_180d_sellerloan bigint comment ''
    ,ever_max_dpd_360d_sellerloan bigint comment ''
    ,ever_max_dpd_30d_spl bigint comment ''
    ,ever_max_dpd_90d_spl bigint comment ''
    ,ever_max_dpd_30d_cashloan bigint comment ''
    ,ever_max_dpd_90d_cashloan bigint comment ''
) partitioned by (
    grass_date string comment 'YYYY-MM-dd'
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/ads/ads_risk_behavior_feature__ph'
;

msck repair table ${SCHEMA}.ads_risk_behavior_feature__ph
;