--********************************************************************--
-- Author:              huangwei@shopee.com
-- Created Time:        2024-01-09
-- Theme Domain：       risk-feature
-- Description:         risk feature所有贷中的feature合并
-- Data Granularity:    credit_user_id
-- 变更历史：
-- 
--********************************************************************--
insert overwrite ${SCHEMA}.ads_risk_behavior_feature__th partition (grass_date = '${ds}')
select
t1.credit_user_id
--dws_risk_th_user_withdraw_info_df
,if(t2.credit_user_id is not null,1,0) is_user_withdraw_scope
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
--dws_risk_th_user_dpd_df
,if(t3.credit_user_id is not null,1,0) is_user_dpd_scope
,ever_max_dpd_cashloan_core
,last_bill_dpd_cashloan_core
,ever_max_dpd_sellerloan_core
,last_bill_dpd_sellerloan_core
,ever_max_dpd_spl_core
,last_bill_dpd_spl_core
,days_after_first_due_date_spl
,ever_max_dpd_180d_spl
,ever_max_dpd_360d_spl
,days_after_first_due_date_cashloan
,ever_max_dpd_180d_cashloan
,ever_max_dpd_360d_cashloan
,ever_max_dpd_180d_user
,ever_max_dpd_360d_user
,ever_max_dpd_30d_sellerloan
,ever_max_dpd_90d_sellerloan
,ever_max_dpd_180d_sellerloan
,ever_max_dpd_360d_sellerloan
,ever_max_dpd_30d_spl
,ever_max_dpd_90d_spl
,ever_max_dpd_30d_cashloan
,ever_max_dpd_90d_cashloan
from
    (
        select
            credit_user_id
        from credit_mart.dws_bcl_th_user_df
        where grass_date = '${ds}'
        union
        select
            credit_user_id
        from credit_mart.dws_spl_th_user_df
        where grass_date = '${ds}'
        union
        select
            credit_user_id
        from credit_mart.dws_scl_th_user_df
        where grass_date = '${ds}'
    ) t1
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
        from risk.dws_risk_th_user_withdraw_info_df
        where grass_date = '${ds}'
    ) t2 on t1.credit_user_id = t2.credit_user_id
    left join (
        select
            user_id as credit_user_id
            ,ever_max_dpd_cashloan_core
            ,last_bill_dpd_cashloan_core
            ,ever_max_dpd_sellerloan_core
            ,last_bill_dpd_sellerloan_core
            ,ever_max_dpd_spl_core
            ,last_bill_dpd_spl_core
            ,days_after_first_due_date_spl
            ,ever_max_dpd_180d_spl
            ,ever_max_dpd_360d_spl
            ,days_after_first_due_date_cashloan
            ,ever_max_dpd_180d_cashloan
            ,ever_max_dpd_360d_cashloan
            ,ever_max_dpd_180d_user
            ,ever_max_dpd_360d_user
            ,ever_max_dpd_30d_sellerloan
            ,ever_max_dpd_90d_sellerloan
            ,ever_max_dpd_180d_sellerloan
            ,ever_max_dpd_360d_sellerloan
            ,ever_max_dpd_30d_spl
            ,ever_max_dpd_90d_spl
            ,ever_max_dpd_30d_cashloan
            ,ever_max_dpd_90d_cashloan
            ,grass_date
        from risk.dws_risk_th_user_dpd_df
        where grass_date = '${ds}'
    ) t3 on t1.credit_user_id = t3.credit_user_id
;