WITH 
-- 用户ID映射关系
user_mapping AS (
    SELECT DISTINCT 
        credit_user_id,
        platform_user_id,
        biz_type,
        grass_date
    FROM credit_mart.dws_${table_product}_${table_region}_account_df 
    WHERE grass_date = '${ds}' 
      AND platform_type = 1
      AND credit_user_id IS NOT NULL 
      AND platform_user_id IS NOT NULL
),

-- 从原子指标表聚合用户行为数据
user_behavior_metrics AS (
    SELECT 
        grass_date,
        credit_user_id,
        biz_type,
        
        -- 时间维度汇总
        MIN(loan_disburse_date) AS first_loan_disburse_date,
        MAX(loan_disburse_date) AS last_loan_disburse_date,
        MIN(month_bill_date) AS first_month_bill_date,
        MAX(month_bill_date) AS last_month_bill_date,
        MIN(month_due_date) AS first_month_due_date,
        MAX(month_due_date) AS last_month_due_date,
        
        -- === instalment数量 ===
        SUM(instalment_count) AS grass_instalment_count,
        sum(if(principal_repayable - principal_refund > 0, instalment_count, 0)) as net_instalment_count,
        SUM(CASE WHEN instalment_clear_status in (4,5) THEN instalment_count ELSE 0 END) AS cleared_instalment_count,
        SUM(CASE WHEN max_dpd > 0 THEN instalment_count END) AS overdue_instalment_count,
        SUM(CASE WHEN max_dpd_eod > 0 THEN instalment_count END) AS overdue_instalment_count_eod,
        SUM(CASE WHEN max_dpd >= 30 THEN instalment_count END) AS dpd_30_instalment_count,
        SUM(CASE WHEN max_dpd_eod >= 30 THEN instalment_count END) AS dpd_30_instalment_count_eod,

        -- === loan数量 ===
        SUM(loan_count) AS grass_loan_count,
        sum(if(principal_repayable - principal_refund > 0, loan_count, 0)) as net_loan_count,
        -- 已结清贷款数量：基于loan_clear_status=3和loan_count
        SUM(CASE WHEN loan_clear_status = 3 THEN loan_count ELSE 0 END) AS cleared_loan_count,
        SUM(CASE WHEN max_dpd > 0 THEN loan_count END) AS overdue_loan_count,
        SUM(CASE WHEN max_dpd_eod > 0 THEN loan_count END) AS overdue_loan_count_eod,
        SUM(CASE WHEN max_dpd >= 30 THEN loan_count END) AS dpd_30_loan_count,
        SUM(CASE WHEN max_dpd_eod >= 30 THEN loan_count END) AS dpd_30_loan_count_eod,

        -- instalment金额
        SUM(principal_repayable) AS principal_repayable,
        SUM(interest_repayable) AS interest_repayable,
        SUM(late_charge_repayable) AS late_charge_repayable,
        SUM(total_amount_repayable) AS total_amount_repayable,
        SUM(principal_repaid) AS principal_repaid,
        SUM(interest_repaid) AS interest_repaid,
        SUM(late_charge_repaid) AS late_charge_repaid,
        SUM(total_amount_repaid) AS total_amount_repaid,
        SUM(principal_refund) AS principal_refund,
        SUM(interest_refund) AS interest_refund,
        SUM(late_charge_refund) AS late_charge_refund,
        SUM(total_amount_refund) AS total_amount_refund,
        SUM(principal_deduct) AS principal_deduct,
        SUM(interest_deduct) AS interest_deduct,
        SUM(late_charge_deduct) AS late_charge_deduct,
        SUM(total_amount_deduct) AS total_amount_deduct,
        SUM(principal_os) AS principal_os,
        SUM(interest_os) AS interest_os,
        SUM(late_charge_os) AS late_charge_os,
        SUM(total_amount_os) AS total_amount_os,

        
        -- === bill数量 ===
        SUM(bill_count) AS grass_bill_count,
        sum(if(principal_repayable - principal_refund > 0, bill_count, 0)) as net_bill_count,
        -- 已还款账单数量：基于bill_clear_status=4
        SUM(CASE WHEN bill_clear_status = 4 THEN bill_count ELSE 0 END) AS cleared_bill_count,
        SUM(CASE WHEN max_dpd > 0 THEN bill_count END) AS overdue_bill_count,
        SUM(CASE WHEN max_dpd_eod > 0 THEN bill_count END) AS overdue_bill_count_eod,
        SUM(CASE WHEN max_dpd >= 30 THEN bill_count END) AS dpd_30_bill_count,
        SUM(CASE WHEN max_dpd_eod >= 30 THEN bill_count END) AS dpd_30_bill_count_eod,
        SUM(CASE WHEN max_dpd >= 30 THEN month(month_due_date) END) AS dpd_30_month_count,
        SUM(CASE WHEN max_dpd_eod >= 30 THEN month(month_due_date) END) AS dpd_30_month_count_eod,

        -- bill金额
        SUM(bill_principal_repayable) AS bill_principal_repayable,
        SUM(bill_interest_repayable) AS bill_interest_repayable,
        SUM(bill_late_charge_repayable) AS bill_late_charge_repayable,
        SUM(bill_total_amount_repayable) AS bill_total_amount_repayable,
        SUM(bill_principal_repaid) AS bill_principal_repaid,
        SUM(bill_interest_repaid) AS bill_interest_repaid,
        SUM(bill_late_charge_repaid) AS bill_late_charge_repaid,
        SUM(bill_total_amount_repaid) AS bill_total_amount_repaid,
        SUM(bill_principal_refund) AS bill_principal_refund,
        SUM(bill_interest_refund) AS bill_interest_refund,
        SUM(bill_late_charge_refund) AS bill_late_charge_refund,
        SUM(bill_total_amount_refund) AS bill_total_amount_refund,
        SUM(bill_principal_deduct) AS bill_principal_deduct,
        SUM(bill_interest_deduct) AS bill_interest_deduct,
        SUM(bill_late_charge_deduct) AS bill_late_charge_deduct,
        SUM(bill_total_amount_deduct) AS bill_total_amount_deduct,
        SUM(bill_principal_os) AS bill_principal_os,
        SUM(bill_interest_os) AS bill_interest_os,
        SUM(bill_late_charge_os) AS bill_late_charge_os,
        SUM(bill_total_amount_os) AS bill_total_amount_os,
        
        -- 逾期指标 
        MAX(dpd_finance) AS current_max_dpd_finance,
        MAX(dpd_eod) AS current_max_dpd_eod,
        MAX(max_dpd) AS ever_max_dpd,
        MAX(max_dpd_eod) AS ever_max_dpd_eod,
        MAX(
            case
                -- 对于已结清的instalment, 看x个月内的结清记录；对于未结清的instalment，直接看dpd_eod。这个计算方法和跨grass_date计算结果一样
                when dpd_eod=0 then if(date(instalment_clear_date) >= date('${tomorrow_ds}') - interval '12' month, max_dpd_eod, 0)
                else dpd_eod
            end 
        ) as ever_max_dpd_12m_eod,
        MAX(
            case
                -- 对于已结清的instalment, 看x个月内的结清记录；对于未结清的instalment，直接看dpd_eod。这个计算方法和跨grass_date计算结果一样
                when dpd_eod=0 then if(date(instalment_clear_date) >= date('${tomorrow_ds}') - interval '6' month, max_dpd_eod, 0)
                else dpd_eod
            end 
        ) as ever_max_dpd_6m_eod,
        MAX(
            case
                -- 对于已结清的instalment, 看x个月内的结清记录；对于未结清的instalment，直接看dpd_eod。这个计算方法和跨grass_date计算结果一样
                when dpd_eod=0 then if(date(instalment_clear_date) >= date('${tomorrow_ds}') - interval '3' month, max_dpd_eod, 0)
                else dpd_eod
            end 
        ) as ever_max_dpd_3m_eod

    FROM credit_mart.dws_${table_product}_${table_region}_user_behavior_mid_df
    WHERE grass_date = '${ds}' 
    GROUP BY grass_date, credit_user_id, biz_type
)
INSERT OVERWRITE TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_behavior_df
PARTITION (grass_date)
SELECT 
    um.credit_user_id,
    um.platform_user_id,
    um.biz_type,

    -- === 时间指标 ===
    ubm.first_loan_disburse_date,
    ubm.last_loan_disburse_date,
    ubm.first_month_bill_date,
    ubm.last_month_bill_date,
    ubm.first_month_due_date,
    ubm.last_month_due_date,

    -- === instalment数量 ===
    COALESCE(ubm.grass_instalment_count, 0) AS grass_instalment_count,
    COALESCE(ubm.net_instalment_count, 0) AS net_instalment_count,
    COALESCE(ubm.cleared_instalment_count, 0) AS cleared_instalment_count,
    COALESCE(ubm.overdue_instalment_count, 0) AS overdue_instalment_count,
    COALESCE(ubm.overdue_instalment_count_eod, 0) AS overdue_instalment_count_eod,
    COALESCE(ubm.dpd_30_instalment_count, 0) AS dpd_30_instalment_count,
    COALESCE(ubm.dpd_30_instalment_count_eod, 0) AS dpd_30_instalment_count_eod,

    -- === loan数量 ===
    COALESCE(ubm.grass_loan_count, 0) AS grass_loan_count,
    COALESCE(ubm.net_loan_count, 0) AS net_loan_count,
    COALESCE(ubm.cleared_loan_count, 0) AS cleared_loan_count,
    COALESCE(ubm.overdue_loan_count, 0) AS overdue_loan_count,
    COALESCE(ubm.overdue_loan_count_eod, 0) AS overdue_loan_count_eod,
    COALESCE(ubm.dpd_30_loan_count, 0) AS dpd_30_loan_count,
    COALESCE(ubm.dpd_30_loan_count_eod, 0) AS dpd_30_loan_count_eod,
    

    -- === instalment金额 ===
    COALESCE(ubm.principal_repayable, 0) AS principal_repayable,
    COALESCE(ubm.interest_repayable, 0) AS interest_repayable,
    COALESCE(ubm.late_charge_repayable, 0) AS late_charge_repayable,
    COALESCE(ubm.total_amount_repayable, 0) AS total_amount_repayable,
    COALESCE(ubm.principal_repaid, 0) AS principal_repaid,
    COALESCE(ubm.interest_repaid, 0) AS interest_repaid,
    COALESCE(ubm.late_charge_repaid, 0) AS late_charge_repaid,
    COALESCE(ubm.total_amount_repaid, 0) AS total_amount_repaid,
    COALESCE(ubm.principal_refund, 0) AS principal_refund,
    COALESCE(ubm.interest_refund, 0) AS interest_refund,
    COALESCE(ubm.late_charge_refund, 0) AS late_charge_refund,
    COALESCE(ubm.total_amount_refund, 0) AS total_amount_refund,
    COALESCE(ubm.principal_deduct, 0) AS principal_deduct,
    COALESCE(ubm.interest_deduct, 0) AS interest_deduct,
    COALESCE(ubm.late_charge_deduct, 0) AS late_charge_deduct,
    COALESCE(ubm.total_amount_deduct, 0) AS total_amount_deduct,
    COALESCE(ubm.principal_os, 0) AS principal_os,
    COALESCE(ubm.interest_os, 0) AS interest_os,
    COALESCE(ubm.late_charge_os, 0) AS late_charge_os,
    COALESCE(ubm.total_amount_os, 0) AS total_amount_os,

    -- === bill/month数量 ===
    COALESCE(ubm.grass_bill_count, 0) AS grass_bill_count,
    COALESCE(ubm.net_bill_count, 0) AS net_bill_count,
    COALESCE(ubm.cleared_bill_count, 0) AS cleared_bill_count,
    COALESCE(ubm.overdue_bill_count, 0) AS overdue_bill_count,
    COALESCE(ubm.overdue_bill_count_eod, 0) AS overdue_bill_count_eod,
    COALESCE(ubm.dpd_30_bill_count, 0) AS dpd_30_bill_count,
    COALESCE(ubm.dpd_30_bill_count_eod, 0) AS dpd_30_bill_count_eod,
    COALESCE(ubm.dpd_30_month_count, 0) AS dpd_30_month_count,
    COALESCE(ubm.dpd_30_month_count_eod, 0) AS dpd_30_month_count_eod,

    -- === bill金额 ===
    COALESCE(ubm.bill_principal_repayable, 0) AS bill_principal_repayable,
    COALESCE(ubm.bill_interest_repayable, 0) AS bill_interest_repayable,
    COALESCE(ubm.bill_late_charge_repayable, 0) AS bill_late_charge_repayable,
    COALESCE(ubm.bill_total_amount_repayable, 0) AS bill_total_amount_repayable,
    COALESCE(ubm.bill_principal_repaid, 0) AS bill_principal_repaid,
    COALESCE(ubm.bill_interest_repaid, 0) AS bill_interest_repaid,
    COALESCE(ubm.bill_late_charge_repaid, 0) AS bill_late_charge_repaid,
    COALESCE(ubm.bill_total_amount_repaid, 0) AS bill_total_amount_repaid,
    COALESCE(ubm.bill_principal_refund, 0) AS bill_principal_refund,
    COALESCE(ubm.bill_interest_refund, 0) AS bill_interest_refund,
    COALESCE(ubm.bill_late_charge_refund, 0) AS bill_late_charge_refund,
    COALESCE(ubm.bill_total_amount_refund, 0) AS bill_total_amount_refund,
    COALESCE(ubm.bill_principal_deduct, 0) AS bill_principal_deduct,
    COALESCE(ubm.bill_interest_deduct, 0) AS bill_interest_deduct,
    COALESCE(ubm.bill_late_charge_deduct, 0) AS bill_late_charge_deduct,
    COALESCE(ubm.bill_total_amount_deduct, 0) AS bill_total_amount_deduct,
    COALESCE(ubm.bill_principal_os, 0) AS bill_principal_os,
    COALESCE(ubm.bill_interest_os, 0) AS bill_interest_os,
    COALESCE(ubm.bill_late_charge_os, 0) AS bill_late_charge_os,
    COALESCE(ubm.bill_total_amount_os, 0) AS bill_total_amount_os,

    -- 逾期指标 
    COALESCE(ubm.current_max_dpd_finance, 0) AS current_max_dpd_finance,
    COALESCE(ubm.current_max_dpd_eod, 0) AS current_max_dpd_eod,
    COALESCE(ubm.ever_max_dpd, 0) AS ever_max_dpd,
    COALESCE(ubm.ever_max_dpd_eod, 0) AS ever_max_dpd_eod,
    COALESCE(ubm.ever_max_dpd_12m_eod, 0) AS ever_max_dpd_12m_eod,
    COALESCE(ubm.ever_max_dpd_6m_eod, 0) AS ever_max_dpd_6m_eod,
    COALESCE(ubm.ever_max_dpd_3m_eod, 0) AS ever_max_dpd_3m_eod,

    -- 是否曾经有贷款
    if(ubm.net_loan_count > 0, 1, 0) as is_ever_disbursed,
    if(ubm.overdue_loan_count > 0, 1, 0) as is_ever_due,

    um.grass_date as grass_date

FROM user_mapping um
LEFT JOIN user_behavior_metrics ubm 
ON um.credit_user_id = ubm.credit_user_id
and um.biz_type = ubm.biz_type
and um.grass_date = ubm.grass_date
;