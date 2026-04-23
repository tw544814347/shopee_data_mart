--********************************************************************--
-- Author:              huangwei@shopee.com
-- Created Time:        2024-01-09
-- Theme Domain：       risk-feature
-- Description:         risk feature所有贷中的feature合并
-- Data Granularity:    credit_user_id
-- 变更历史：
-- 
--********************************************************************--
insert overwrite ${SCHEMA}.ads_risk_behavior_feature__id partition (grass_date = '${ds}')
select
t1.credit_user_id
--dws_risk_id_user_repayment_df
,if(t2.credit_user_id is not null,1,0) is_user_repayment_scope
,days_to_next_spl_repay
,next_spl_bill_principal_os
,days_to_next_bcl_repay
,next_bcl_bill_principal_os
,avg_weighted_remaining_tenure
--dws_risk_id_user_dpd_df
,if(t3.user_id is not null,1,0) is_user_dpd_scope
,ever_max_dpd_spl_core
,ever_max_dpd_spl_lite_core
,ever_max_dpd_spl_normal_core
,days_after_first_due_date_spl
,ever_max_dpd_180d_spl
,ever_max_dpd_360d_spl
,days_after_first_due_date_cashloan
,ever_max_dpd_180d_cashloan
,ever_max_dpd_360d_cashloan
,ever_max_dpd_180d_user
,ever_max_dpd_360d_user
,ever_max_dpd_cashloan_core
,last_bill_dpd_cashloan_core
,ever_max_dpd_sellerloan_core
,last_bill_dpd_sellerloan_core
,ever_max_dpd_30d_sellerloan
,ever_max_dpd_90d_sellerloan
,ever_max_dpd_180d_sellerloan
,ever_max_dpd_360d_sellerloan
,ever_max_dpd_30d_spl
,ever_max_dpd_90d_spl
,ever_max_dpd_30d_cashloan
,ever_max_dpd_90d_cashloan
,ever_max_dpd_chp
,ever_max_dpd_chp_180d
,ever_max_dpd_chp_360d
--wide_bcl_id_behavior_user_df
,if(t4.credit_user_id is not null,1,0) is_bcl_behavior_user_scope
,is_today_bcl_due_user
--ads_behavior_underwrting_feature_df
,if(t6.credit_user_id is not null,1,0) is_underwrting_feature_scope
,spl_user_tag
,first_billed_from_now_spl
,first_billed_from_now_bcl
,first_billed_from_now
,repaid_bills_num_user
,credit_user_status
,is_limit_decrease_spl
,is_limit_decrease_bcl
,os_spl
,os_bcl
,eir_tenure2_bcl
,eir_tenure3_bcl
,eir_tenure6_bcl
,eir_tenure12_bcl
,eir_tenure1_spl
,eir_tenure2_spl
,eir_tenure3_spl
,eir_tenure6_spl
,eir_tenure12_spl
,eir_tenure18_spl
,eir_tenure24_spl
,repaid_bills_num_cashloan
,latest_dpd_cashloan
,average_limit_utilization_90d_spl
,average_limit_utilization_180d_spl
,max_limit_utilization_90d_spl
,max_limit_utilization_180d_spl
,average_limit_utilization_90d_bcl
,average_limit_utilization_180d_bcl
,max_limit_utilization_90d_bcl
,max_limit_utilization_180d_bcl
--dws_risk_id_user_withdraw_info_df
,if(t7.credit_user_id is not null,1,0) is_user_withdraw_scope
,postloan_reject_cnt_bcl
,postloan_reject_cnt_spl
,preloan_reject_cnt_bcl
,preloan_reject_cnt_spl
,postloan_reject_cnt_90d_bcl
,postloan_reject_cnt_90d_spl
,preloan_reject_cnt_90d_bcl
,preloan_reject_cnt_90d_spl
,postloan_reject_cnt_180d_bcl
,postloan_reject_cnt_180d_spl
,preloan_reject_cnt_180d_bcl
,preloan_reject_cnt_180d_spl
,rejected_num_90d_bcl
--wide_bcl_id_behavior_user_df
,if(t8.credit_user_id is not null,1,0) is_spl_behavior_user_scope
,is_today_spl_due_user
from
    (
        select
            credit_user_id
        from credit_mart.dws_bcl_id_user_df
        where grass_date = '${ds}'
        union
        select
            credit_user_id
        from credit_mart.dws_spl_id_user_df
        where grass_date = '${ds}'
        union
        select
            credit_user_id
        from credit_mart.dws_scl_id_user_df
        where grass_date = '${ds}'
    ) t1
    left join (
        select
            credit_user_id
            ,days_to_next_spl_repay
            ,next_spl_bill_principal_os
            ,days_to_next_bcl_repay
            ,next_bcl_bill_principal_os
            ,avg_weighted_remaining_tenure
            ,grass_date
        from risk.dws_risk_id_user_repayment_df
        where grass_date = '${ds}'
    ) t2 on t1.credit_user_id = t2.credit_user_id
    left join (
        select
            user_id
            ,ever_max_dpd_spl_core
            ,ever_max_dpd_spl_lite_core
            ,ever_max_dpd_spl_normal_core
            ,days_after_first_due_date_spl
            ,ever_max_dpd_180d_spl
            ,ever_max_dpd_360d_spl
            ,days_after_first_due_date_cashloan
            ,ever_max_dpd_180d_cashloan
            ,ever_max_dpd_360d_cashloan
            ,ever_max_dpd_180d_user
            ,ever_max_dpd_360d_user
            ,ever_max_dpd_cashloan_core
            ,last_bill_dpd_cashloan_core
            ,ever_max_dpd_sellerloan_core
            ,last_bill_dpd_sellerloan_core
            ,ever_max_dpd_30d_sellerloan
            ,ever_max_dpd_90d_sellerloan
            ,ever_max_dpd_180d_sellerloan
            ,ever_max_dpd_360d_sellerloan
            ,ever_max_dpd_30d_spl
            ,ever_max_dpd_90d_spl
            ,ever_max_dpd_30d_cashloan
            ,ever_max_dpd_90d_cashloan
            ,ever_max_dpd_chp
            ,ever_max_dpd_chp_180d
            ,ever_max_dpd_chp_360d
            ,grass_date
        from risk.dws_risk_id_user_dpd_df
        where grass_date = '${ds}'
    ) t3 on t1.credit_user_id = t3.user_id
    left join (
        select
            credit_user_id
            ,1 as is_today_bcl_due_user
        from credit_mart.wide_bcl_id_behavior_user_df
        where
            grass_date = '${ds}'
            and bill_due_day = day(date('${ds}'))
    ) t4 on t1.credit_user_id = t4.credit_user_id
    left join (
        select
            credit_user_id
            ,spl_user_tag
            ,first_billed_from_now_spl
            ,first_billed_from_now_bcl
            ,first_billed_from_now
            ,repaid_bills_num_user
            ,credit_user_status
            ,is_limit_decrease_spl
            ,is_limit_decrease_bcl
            ,os_spl
            ,os_bcl
            ,eir_tenure2_bcl
            ,eir_tenure3_bcl
            ,eir_tenure6_bcl
            ,eir_tenure12_bcl
            ,eir_tenure1_spl
            ,eir_tenure2_spl
            ,eir_tenure3_spl
            ,eir_tenure6_spl
            ,eir_tenure12_spl
            ,eir_tenure18_spl
            ,eir_tenure24_spl
            ,repaid_bills_num_cashloan
            ,latest_dpd_cashloan
            ,average_limit_utilization_90d_spl
            ,average_limit_utilization_180d_spl
            ,max_limit_utilization_90d_spl
            ,max_limit_utilization_180d_spl
            ,average_limit_utilization_90d_bcl
            ,average_limit_utilization_180d_bcl
            ,max_limit_utilization_90d_bcl
            ,max_limit_utilization_180d_bcl
            ,grass_region
            ,grass_date
        from risk.ads_behavior_underwrting_feature_df
        where
            grass_region = 'ID'
            and grass_date = '${ds}'
    ) t6 on t1.credit_user_id = t6.credit_user_id
    left join (
        select
            row_key
            ,credit_user_id
            ,postloan_reject_cnt_bcl
            ,postloan_reject_cnt_spl
            ,preloan_reject_cnt_bcl
            ,preloan_reject_cnt_spl
            ,postloan_reject_cnt_90d_bcl
            ,postloan_reject_cnt_90d_spl
            ,preloan_reject_cnt_90d_bcl
            ,preloan_reject_cnt_90d_spl
            ,postloan_reject_cnt_180d_bcl
            ,postloan_reject_cnt_180d_spl
            ,preloan_reject_cnt_180d_bcl
            ,preloan_reject_cnt_180d_spl
            ,rejected_num_90d_bcl
            ,grass_date
        from risk.dws_risk_id_user_withdraw_info_df
        where grass_date = '${ds}'
    ) t7 on t1.credit_user_id = t7.credit_user_id
    left join (
        select
            credit_user_id
            ,1 as is_today_spl_due_user
        from credit_mart.wide_spl_id_behavior_user_df
        where
            grass_date = '${ds}'
            and bill_due_day = day(date('${ds}'))
    ) t8 on t1.credit_user_id = t8.credit_user_id
;

;