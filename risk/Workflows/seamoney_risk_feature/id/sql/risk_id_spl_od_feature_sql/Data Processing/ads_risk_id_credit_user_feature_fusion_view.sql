drop view if exists ${SCHEMA}.ads_risk_id_credit_user_feature_fusion_view;
create view if not exists ${SCHEMA}.ads_risk_id_credit_user_feature_fusion_view as
select
    t1.credit_user_id
    ,t2.last_chp_disburse_time
    ,t2.first_spl_disburse_time
    ,coalesce(t2.is_bcl_disbursed, -9999) as is_bcl_disbursed
    ,coalesce(t2.repaid_bills_num_bcl, -9999) as repaid_bills_num_bcl
    ,coalesce(t2.repaid_bills_num_chp, -9999) as repaid_bills_num_chp
    ,coalesce(t2.repaid_bills_num_spl, -9999) as repaid_bills_num_spl
    ,coalesce(t2.is_spl_disbursed, -9999) as is_spl_disbursed
    ,coalesce(t2.is_chp_disbursed, -9999) as is_chp_disbursed
    ,coalesce(t3.latest_dpd_eod_spl, -9999) as latest_dpd_eod_spl
    ,coalesce(t3.latest_dpd_eod_cashloan, -9999) as latest_dpd_eod_cashloan
    ,coalesce(t3.latest_dpd_eod_chp, -9999) as latest_dpd_eod_chp
    ,coalesce(t3.ever_max_dpd_180d_cashloan, -9999) as ever_max_dpd_180d_cashloan
    ,coalesce(t3.ever_max_dpd_180d_spl, -9999) as ever_max_dpd_180d_spl
    ,coalesce(t3.ever_max_dpd_30d_cashloan, -9999) as ever_max_dpd_30d_cashloan
    ,coalesce(t3.ever_max_dpd_30d_spl, -9999) as ever_max_dpd_30d_spl
    ,coalesce(t3.ever_max_dpd_30d_chp, -9999) as ever_max_dpd_30d_chp
    ,coalesce(t3.ever_max_dpd_180d_chp, -9999) as ever_max_dpd_180d_chp
from
    (
        select
            credit_user_id
        from credit_uc.dwd_aio_id_uc_user_df
        where grass_date = '${grass_date}'
        group by credit_user_id
    ) t1
    left join (
        select
            credit_user_id
            ,last_chp_disburse_time
            ,first_spl_disburse_time
            ,is_bcl_disbursed
            ,repaid_bills_num_bcl
            ,repaid_bills_num_chp
            ,repaid_bills_num_spl
            ,is_spl_disbursed
            ,is_chp_disbursed
        from ${SCHEMA}.ads_behavior_underwrting_feature_df
        where grass_date = '${grass_date}'
    ) t2 on t1.credit_user_id = t2.credit_user_id
    left join (
        select
            user_id as credit_user_id
            ,latest_dpd_eod_spl
            ,latest_dpd_eod_cashloan
            ,latest_dpd_eod_chp
            ,ever_max_dpd_180d_cashloan
            ,ever_max_dpd_180d_spl
            ,ever_max_dpd_30d_cashloan
            ,ever_max_dpd_30d_spl
            ,ever_max_dpd_30d_chp
            ,ever_max_dpd_180d_chp
        from risk.dws_risk_id_user_dpd_df
        where grass_date = '${grass_date}'
    ) t3 on t1.credit_user_id = t3.credit_user_id
;

