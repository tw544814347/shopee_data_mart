drop table if exists ${SCHEMA}.ads_risk_behavior_feature__id
;

create external table if not exists ${SCHEMA}.ads_risk_behavior_feature__id (
    credit_user_id string comment 'credit_user_id'
    --dws_risk_id_user_repayment_df
    ,is_user_repayment_scope int 
    ,days_to_next_spl_repay bigint
    ,next_spl_bill_principal_os decimal(30, 10)
    ,days_to_next_bcl_repay bigint
    ,next_bcl_bill_principal_os decimal(30, 10)
    ,avg_weighted_remaining_tenure decimal(30, 10) comment '用户名下SPL,BCL,HPL所有产品未结清loan的平均remaining tenure:'
    --dws_risk_id_user_dpd_df
    ,is_user_dpd_scope int 
    ,ever_max_dpd_spl_core bigint comment ''
    ,ever_max_dpd_spl_lite_core bigint comment ''
    ,ever_max_dpd_spl_normal_core bigint comment ''
    ,days_after_first_due_date_spl bigint comment ''
    ,ever_max_dpd_180d_spl bigint comment ''
    ,ever_max_dpd_360d_spl bigint comment ''
    ,days_after_first_due_date_cashloan bigint comment ''
    ,ever_max_dpd_180d_cashloan bigint comment ''
    ,ever_max_dpd_360d_cashloan bigint comment ''
    ,ever_max_dpd_180d_user bigint comment ''
    ,ever_max_dpd_360d_user bigint comment ''
    ,ever_max_dpd_cashloan_core bigint comment 'historical_max_dpd'
    ,last_bill_dpd_cashloan_core bigint comment 'last_bill_dpd'
    ,ever_max_dpd_sellerloan_core bigint comment 'historical_max_dpd'
    ,last_bill_dpd_sellerloan_core bigint comment 'last_bill_dpd'
    ,ever_max_dpd_30d_sellerloan bigint comment ''
    ,ever_max_dpd_90d_sellerloan bigint comment ''
    ,ever_max_dpd_180d_sellerloan bigint comment ''
    ,ever_max_dpd_360d_sellerloan bigint comment ''
    ,ever_max_dpd_30d_spl bigint comment ''
    ,ever_max_dpd_90d_spl bigint comment ''
    ,ever_max_dpd_30d_cashloan bigint comment ''
    ,ever_max_dpd_90d_cashloan bigint comment ''
    ,ever_max_dpd_chp bigint
    ,ever_max_dpd_chp_180d bigint
    ,ever_max_dpd_chp_360d bigint
    --wide_bcl_id_behavior_user_df
    ,is_bcl_behavior_user_scope int 
    ,is_today_bcl_due_user int
    --ads_behavior_underwrting_feature_df
    ,is_underwrting_feature_scope int 
    ,spl_user_tag int comment 'spl status'
    ,first_billed_from_now_spl int comment 'spl The number of months from bill term'
    ,first_billed_from_now_bcl int comment 'bcl The number of months from bill term'
    ,first_billed_from_now int comment 'max(bcl/bcl The number of months from bill term)'
    ,repaid_bills_num_user int comment 'repaid bills'
    ,credit_user_status int comment 'user status'
    ,is_limit_decrease_spl int comment 'limit decrease tag in spl'
    ,is_limit_decrease_bcl int comment 'limit decrease tag in bcl'
    ,os_spl int comment 'spl quota'
    ,os_bcl int comment 'bcl quota'
    ,eir_tenure2_bcl decimal comment 'User tenure2 EIR In bcl'
    ,eir_tenure3_bcl decimal comment 'User tenure3 EIR In bcl'
    ,eir_tenure6_bcl decimal comment 'User tenure6 EIR In bcl'
    ,eir_tenure12_bcl decimal comment 'User tenure12 EIR In bcl'
    ,eir_tenure1_spl decimal comment 'User tenure1 EIR In spl'
    ,eir_tenure2_spl decimal comment 'User tenure2 EIR In spl'
    ,eir_tenure3_spl decimal comment 'User tenure3 EIR In spl'
    ,eir_tenure6_spl decimal comment 'User tenure6 EIR In spl'
    ,eir_tenure12_spl decimal comment 'User tenure12 EIR In spl'
    ,eir_tenure18_spl decimal comment 'User tenure18 EIR In spl'
    ,eir_tenure24_spl decimal comment 'User tenure24 EIR In spl'
    ,repaid_bills_num_cashloan int comment 'repaid bill num IN CL'
    ,latest_dpd_cashloan int comment 'latest dpd IN CL'
    ,average_limit_utilization_90d_spl decimal(30, 5) comment 'spl 90days avg limit_utilization'
    ,average_limit_utilization_180d_spl decimal(30, 5) comment 'spl 180days avg limit_utilization'
    ,max_limit_utilization_90d_spl decimal(30, 5) comment 'spl 90days max limit_utilization'
    ,max_limit_utilization_180d_spl decimal(30, 5) comment 'spl 180days max limit_utilization'
    ,average_limit_utilization_90d_bcl decimal(30, 5) comment 'bcl 90days avg limit_utilization'
    ,average_limit_utilization_180d_bcl decimal(30, 5) comment 'bcl 180days avg limit_utilization'
    ,max_limit_utilization_90d_bcl decimal(30, 5) comment 'bcl 90days max limit_utilization'
    ,max_limit_utilization_180d_bcl decimal(30, 5) comment 'bcl 180days max limit_utilization'
    --dws_risk_id_user_withdraw_feature
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
    --wide_bcl_id_behavior_user_df
    ,is_spl_behavior_user_scope int
    ,is_today_spl_due_user int
) partitioned by (
    grass_date string comment 'YYYY-MM-dd'
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/ads/ads_risk_behavior_feature__id'
;

msck repair table ${SCHEMA}.ads_risk_behavior_feature__id
;