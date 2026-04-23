-- **************************************************************************
-- ** Theme Domain|所属业务主题: Risk ads
-- ** Functional description|功能描述: Risk feature中间表
-- ** Target table name|目标表名: 
-- ** Create Author|创建人: jialiang.nie
-- ** Create time|创建日期: 2025-08-05
-- ** Modified log|修改日志:
-- **             修改日期: 2025-08-05  修改人:jialiang.nie  设计文档: https://docs.google.com/spreadsheets/d/1PFokkZkXJTx8G3D1jhOG5j7BdE0nT0ZXUi0--3wqj6w/edit?gid=1399006980#gid=1399006980
-- **             修改日期: 2025-11-11  修改人:jialiang.nie  修改内容: 新增BR指标
-- **             修改日期: 2025-11-14  修改人:jialiang.nie  修改内容: 拆分 feature 视图，基于基础指标做个性化的转换
-- **             修改日期: 2025-11-27  修改人:chenyingying  修改内容: 新增transaction payment method相关feature
-- **             修改日期: 2026-03-05  修改人:siyuan.sun    修改内容: 新增BR risk features - DPD EOD of the Latest Due Date within the Past 1/2/3 Months.
-- **             修改日期: 2026-03-05  修改人:siyuan.sun    修改内容: 新增BR risk features - Total Outstanding Loan Amount of Latest DPD EOD (DPD_EOD >= 3/5/7/15/30 days) within the Past 3 Months.  
-- **             修改日期: 2026-03-05  修改人:siyuan.sun    修改内容: 新增BR risk features - Bill to Installment Eligibility flags: is_eligible_for_1m/2m/3m/6m/9m/12m/18m, 和相应的interest_rate_1m/2m/3m/6m/9m/12m/18m. 
-- ** @extra_input=xxx
-- ** @extra_input=xxx
-- **************************************************************************

create or replace view ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_behavior_feature_df 
comment 'credit mart summary table'
as 
select 
    t1.credit_user_id
    ,t1.platform_user_id
    ,t1.biz_type
    ,t1.current_max_dpd_eod
    ,t1.ever_max_dpd_6m_eod
    ,t1.ever_max_dpd_eod
    ,t1.latest_floating_term_dpd_4m_eod as latest_dpd
    ,t1.cleared_bill_count as repaid_bills
    ,t1.cleared_floating_term_count as repaid_months
    ,t1.is_billed
    ,t1.is_ever_disbursed as is_disbursed

    -- 2025-11-11新增
    ,t1.is_ever_disbursed_1d
    ,t1.is_ever_disbursed_30d
    ,t1.is_ever_disbursed_90d
    ,t1.is_ever_disbursed_180d
    ,t1.is_ever_disbursed_360d
    ,t1.is_ever_due
    ,t1.first_disburse_last_process_date
    ,t1.max_disburse_month_cnt
    ,t1.latest_disburse_dpd_eod
    ,t1.ever_max_dpd_24m_eod
    ,t1.ever_max_dpd_12m_eod
    ,t1.ever_max_dpd_3m_eod
    ,t1.ever_max_dpd_1m_eod
    ,t1.ever_max_dpd_7d_eod
    ,t1.ever_max_dpd_1d_eod

${comment}     -- 2026-03-05新增 BR Offline Feature Requests 
${comment}     ,t1.1m_latest_dpd_eod
${comment}     ,t1.2m_latest_dpd_eod 
${comment}     ,t1.3m_latest_dpd_eod
${comment}     ,t1.3m_latest_dpd_eod_3d_amt 
${comment}     ,t1.3m_latest_dpd_eod_5d_amt 
${comment}     ,t1.3m_latest_dpd_eod_7d_amt 
${comment}     ,t1.3m_latest_dpd_eod_15d_amt
${comment}     ,t1.3m_latest_dpd_eod_30d_amt 

    ,t1.principal_os
    ,t1.principal_os_dpd_eod_1
    ,t1.principal_os_dpd_eod_7
    ,t1.principal_os_dpd_eod_15
    ,t1.principal_os_dpd_eod_30
    ,t1.principal_os_dpd_eod_60
    ,t1.principal_os_dpd_eod_90
    ,t1.principal_os_dpd_eod_120
    ,t1.principal_os_dpd_eod_180
    ,t1.principal_os_dpd_eod_360
    ,t1.interest_os
    ,t1.writeoff_principal_os
    ,t1.sum_principal_repayable_1d
    ,t1.sum_principal_repayable_30d
    ,t1.sum_principal_repayable_90d
    ,t1.sum_principal_repayable_180d
    ,t1.sum_principal_repayable_360d
    ,t1.sum_principal_repayable_td
    ,t1.max_principal_repayable_1d
    ,t1.max_principal_repayable_30d
    ,t1.max_principal_repayable_90d
    ,t1.max_principal_repayable_180d
    ,t1.max_principal_repayable_360d
    ,t1.max_principal_repayable_td
    ,t1.min_principal_repayable_1d
    ,t1.min_principal_repayable_30d
    ,t1.min_principal_repayable_90d
    ,t1.min_principal_repayable_180d
    ,t1.min_principal_repayable_360d
    ,t1.min_principal_repayable_td
    ,t1.disbursed_loan_cnt_1d
    ,t1.disbursed_loan_cnt_30d
    ,t1.disbursed_loan_cnt_90d
    ,t1.disbursed_loan_cnt_180d
    ,t1.disbursed_loan_cnt_360d
    ,t1.principal_repaid_1d
    ,t1.principal_repaid_7d
    ,t1.principal_repaid_30d
    ,t1.principal_repaid_td
    ,t1.interest_repaid_1d
    ,t1.interest_repaid_7d
    ,t1.interest_repaid_30d
    ,t1.interest_repaid_td
    ,t1.cleared_loan_cnt_1d
    ,t1.cleared_loan_cnt_30d
    ,t1.cleared_loan_cnt_90d
    ,t1.cleared_loan_cnt_180d
    ,t1.cleared_loan_cnt_360d
    ,t1.cleared_loan_cnt_td
    ,t1.early_clear_principal_1d
    ,t1.early_clear_principal_30d
    ,t1.early_clear_principal_90d
    ,t1.early_clear_principal_180d
    ,t1.early_clear_principal_360d
    ,t1.early_clear_principal_td
    ,t1.early_clear_instalment_cnt_1d
    ,t1.early_clear_instalment_cnt_30d
    ,t1.early_clear_instalment_cnt_90d
    ,t1.early_clear_instalment_cnt_180d
    ,t1.early_clear_instalment_cnt_360d
    ,t1.early_clear_instalment_cnt_td
    ,t1.no_os_month_cnt 

${comment}     -- 2026-03-05新增 BR Offline Feature Requests 
${comment}     -- === Bill to Installment Eligibility flags and corresponding interest rate. === 
${comment}     ,t1.is_eligible_for_restructure_1m 
${comment}     ,t1.is_eligible_for_restructure_2m
${comment}     ,t1.is_eligible_for_restructure_3m
${comment}     ,t1.is_eligible_for_restructure_6m
${comment}     ,t1.is_eligible_for_restructure_9m
${comment}     ,t1.is_eligible_for_restructure_12m
${comment}     ,t1.is_eligible_for_restructure_18m
${comment}     ,t1.restructure_interest_rate_1m
${comment}     ,t1.restructure_interest_rate_2m
${comment}     ,t1.restructure_interest_rate_3m
${comment}     ,t1.restructure_interest_rate_6m
${comment}     ,t1.restructure_interest_rate_9m
${comment}     ,t1.restructure_interest_rate_12m
${comment}     ,t1.restructure_interest_rate_18m

    -- 2025-11-27 新增
    ${comment},coalesce(t2.combine_payment_cnt_td, 0)                       combine_payment_cnt_td             
    ${comment},coalesce(t2.combine_payment_amount_td, 0)                    combine_payment_amount_td          
    ${comment},coalesce(t2.combine_payment_spl_amount_td, 0)                combine_payment_spl_amount_td          
    ${comment},coalesce(t2.combine_payment_cci_amount_td, 0)                combine_payment_cci_amount_td          
    ${comment},coalesce(t2.combine_payment_pix_amount_td, 0)                combine_payment_pix_amount_td      
    ${comment},coalesce(t2.combine_payment_wallet_amount_td, 0)             combine_payment_wallet_amount_td           
    ${comment},coalesce(t2.combine_payment_cnt_30d, 0)                      combine_payment_cnt_30d                
    ${comment},coalesce(t2.combine_payment_amount_30d, 0)                   combine_payment_amount_30d             
    ${comment},coalesce(t2.combine_payment_spl_amount_30d, 0)               combine_payment_spl_amount_30d     
    ${comment},coalesce(t2.combine_payment_cci_amount_30d, 0)               combine_payment_cci_amount_30d     
    ${comment},coalesce(t2.combine_payment_pix_amount_30d, 0)               combine_payment_pix_amount_30d     
    ${comment},coalesce(t2.combine_payment_wallet_amount_30d, 0)            combine_payment_wallet_amount_30d  
    ${comment},coalesce(t2.combine_payment_cnt_90d, 0)                      combine_payment_cnt_90d            
    ${comment},coalesce(t2.combine_payment_amount_90d, 0)                   combine_payment_amount_90d         
    ${comment},coalesce(t2.combine_payment_spl_amount_90d, 0)               combine_payment_spl_amount_90d     
    ${comment},coalesce(t2.combine_payment_cci_amount_90d, 0)               combine_payment_cci_amount_90d     
    ${comment},coalesce(t2.combine_payment_pix_amount_90d, 0)               combine_payment_pix_amount_90d     
    ${comment},coalesce(t2.combine_payment_wallet_amount_90d, 0)            combine_payment_wallet_amount_90d  
    ${comment},coalesce(t2.combine_payment_cnt_180d, 0)                     combine_payment_cnt_180d           
    ${comment},coalesce(t2.combine_payment_amount_180d, 0)                  combine_payment_amount_180d        
    ${comment},coalesce(t2.combine_payment_spl_amount_180d, 0)              combine_payment_spl_amount_180d    
    ${comment},coalesce(t2.combine_payment_cci_amount_180d, 0)              combine_payment_cci_amount_180d    
    ${comment},coalesce(t2.combine_payment_pix_amount_180d , 0)             combine_payment_pix_amount_180d    
    ${comment},coalesce(t2.combine_payment_wallet_amount_180d, 0)           combine_payment_wallet_amount_180d 
    ${comment},coalesce(t2.combine_payment_cnt_360d, 0)                     combine_payment_cnt_360d           
    ${comment},coalesce(t2.combine_payment_amount_360d, 0)                  combine_payment_amount_360d        
    ${comment},coalesce(t2.combine_payment_spl_amount_360d, 0)              combine_payment_spl_amount_360d    
    ${comment},coalesce(t2.combine_payment_cci_amount_360d, 0)              combine_payment_cci_amount_360d    
    ${comment},coalesce(t2.combine_payment_pix_amount_360d, 0)              combine_payment_pix_amount_360d    
    ${comment},coalesce(t2.combine_payment_wallet_amount_360d, 0)           combine_payment_wallet_amount_360d 
    ,t1.grass_date
from (
    select *
    from ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_behavior_df
) t1
${comment} left join (
${comment}     select *
${comment}     from ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_transaction_df
${comment} ) t2
${comment} on t1.credit_user_id = t2.credit_user_id
${comment} and t1.grass_date = t2.grass_date
${comment} and t1.biz_type = t2.biz_type
;
