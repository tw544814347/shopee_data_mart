-- **************************************************************************
-- ** Theme Domain|所属业务主题: Risk ads
-- ** Functional description|功能描述: Risk feature中间表
-- ** Target table name|目标表名: 
-- ** Create Author|创建人: jialiang.nie
-- ** Create time|创建日期: 2025-08-05
-- ** Modified log|修改日志:
-- **             修改日期: 2025-08-05  修改人:jialiang.nie  设计文档: https://docs.google.com/spreadsheets/d/1PFokkZkXJTx8G3D1jhOG5j7BdE0nT0ZXUi0--3wqj6w/edit?gid=1399006980#gid=1399006980
-- **             修改日期: 2025-11-11  修改人:jialiang.nie  修改内容: 新增BR指标
-- **             修改日期: 2025-11-13  修改人:jialiang.nie  修改内容: 优化逻辑，将nxb逻辑拆分开
-- ** @extra_input=xxx
-- ** @extra_input=xxx
-- **************************************************************************


drop table if exists ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_behavior_df;

create external table if not exists ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_behavior_df 
(
    credit_user_id string comment 'Credit User ID'
    ,platform_user_id string comment 'Platform User ID'
    ,biz_type bigint comment 'Dimension, 1:BCL;2:SCL;3:SPL;4:FES;7:SPLX;8:CPL;11:TL;12:SVL;13:SCF'
    ,first_month_bill_date string comment 'First Monthly Bill Date'
    ,last_month_bill_date string comment 'Last Monthly Bill Date'
    ,first_month_due_date string comment 'First Monthly Due Date'
    ,last_month_due_date string comment 'Last Monthly Due Date'
    ,first_disburse_last_process_date string comment 'First Disburse Last Process Date'
    ,last_disburse_last_process_date string comment 'Last Disburse Last Process Date'
    ,gross_floating_term_count bigint comment 'Gross Floating Term Count'
    ,net_floating_term_count bigint comment 'Net Floating Term Count'
    ,cleared_floating_term_count bigint comment 'Cleared Floating Term Count'
    ,principal_os decimal(30,10) comment 'Principal Outstanding'
    ,principal_os_dpd_eod_1 decimal(30,10) comment 'Principal Outstanding DPD EOD >= 1'
    ,principal_os_dpd_eod_7 decimal(30,10) comment 'Principal Outstanding DPD EOD >= 7'
    ,principal_os_dpd_eod_15 decimal(30,10) comment 'Principal Outstanding DPD EOD >= 15'
    ,principal_os_dpd_eod_30 decimal(30,10) comment 'Principal Outstanding DPD EOD >= 30'
    ,principal_os_dpd_eod_60 decimal(30,10) comment 'Principal Outstanding DPD EOD >= 60'
    ,principal_os_dpd_eod_90 decimal(30,10) comment 'Principal Outstanding DPD EOD >= 90'
    ,principal_os_dpd_eod_120 decimal(30,10) comment 'Principal Outstanding DPD EOD >= 120'
    ,principal_os_dpd_eod_180 decimal(30,10) comment 'Principal Outstanding DPD EOD >= 180'
    ,principal_os_dpd_eod_360 decimal(30,10) comment 'Principal Outstanding DPD EOD >= 360'
    ,writeoff_principal_os decimal(30,10) comment 'Writeoff principal os, if an instalment is writeoff, the entire loan amount is considered writeoff.'
    ,interest_os decimal(30,10) comment 'Interest Outstanding'
    ,gross_bill_count bigint comment 'Gross Bill Count'
    ,net_bill_count bigint comment 'Net Bill Count'
    ,cleared_bill_count bigint comment 'Cleared Bill Count'
    ,current_max_dpd_eod bigint comment 'Current Maximum DPD EOD'
    ,ever_max_dpd bigint comment 'Ever Maximum DPD'
    ,ever_max_dpd_eod bigint comment 'Ever Maximum DPD EOD'
    ,ever_max_dpd_24m_eod bigint comment 'Ever Maximum DPD 24M EOD'
    ,ever_max_dpd_12m_eod bigint comment 'Ever Maximum DPD 12M EOD'
    ,ever_max_dpd_6m_eod bigint comment 'Ever Maximum DPD 6M EOD'
    ,ever_max_dpd_3m_eod bigint comment 'Ever Maximum DPD 3M EOD'
    ,ever_max_dpd_1m_eod bigint comment 'Ever Maximum DPD 1M EOD'
    ,ever_max_dpd_7d_eod bigint comment 'Ever Maximum DPD 7D EOD'
    ,ever_max_dpd_1d_eod bigint comment 'Ever Maximum DPD 1D EOD'
    ,latest_floating_term_dpd_eod bigint comment 'Latest Floating Term DPD EOD'
    ,latest_floating_term_dpd_4m_eod bigint comment 'Latest Floating Term DPD 4M EOD'
    ,is_ever_disbursed bigint comment 'Is Ever Disbursed'
    ,is_ever_disbursed_1d bigint comment 'Is Ever Disbursed 1D'
    ,is_ever_disbursed_30d bigint comment 'Is Ever Disbursed 30D'
    ,is_ever_disbursed_90d bigint comment 'Is Ever Disbursed 90D'
    ,is_ever_disbursed_180d bigint comment 'Is Ever Disbursed 180D'
    ,is_ever_disbursed_360d bigint comment 'Is Ever Disbursed 360D'
    ,max_disburse_month_cnt bigint comment 'Number of months since the earliest loan'
    ,sum_principal_repayable_1d decimal(30,10) comment 'Sum Principal Repayable 1D'
    ,sum_principal_repayable_30d decimal(30,10) comment 'Sum Principal Repayable 30D'
    ,sum_principal_repayable_90d decimal(30,10) comment 'Sum Principal Repayable 90D'
    ,sum_principal_repayable_180d decimal(30,10) comment 'Sum Principal Repayable 180D'
    ,sum_principal_repayable_360d decimal(30,10) comment 'Sum Principal Repayable 360D'
    ,sum_principal_repayable_td decimal(30,10) comment 'Sum Principal Repayable To Date'
    ,max_principal_repayable_1d decimal(30,10) comment 'Max Principal Repayable 1D'
    ,max_principal_repayable_30d decimal(30,10) comment 'Max Principal Repayable 30D'
    ,max_principal_repayable_90d decimal(30,10) comment 'Max Principal Repayable 90D'
    ,max_principal_repayable_180d decimal(30,10) comment 'Max Principal Repayable 180D'
    ,max_principal_repayable_360d decimal(30,10) comment 'Max Principal Repayable 360D'
    ,max_principal_repayable_td decimal(30,10) comment 'Max Principal Repayable To Date'
    ,min_principal_repayable_1d decimal(30,10) comment 'Min Principal Repayable 1D'
    ,min_principal_repayable_30d decimal(30,10) comment 'Min Principal Repayable 30D'
    ,min_principal_repayable_90d decimal(30,10) comment 'Min Principal Repayable 90D'
    ,min_principal_repayable_180d decimal(30,10) comment 'Min Principal Repayable 180D'
    ,min_principal_repayable_360d decimal(30,10) comment 'Min Principal Repayable 360D'
    ,min_principal_repayable_td decimal(30,10) comment 'Min Principal Repayable To Date'
    ,disbursed_loan_cnt_1d bigint comment 'Net Disbursed Loan Count 1D (principal_repayable - principal_refund > 0)'
    ,disbursed_loan_cnt_30d bigint comment 'Net Disbursed Loan Count 30D (principal_repayable - principal_refund > 0)'
    ,disbursed_loan_cnt_90d bigint comment 'Net Disbursed Loan Count 90D (principal_repayable - principal_refund > 0)'
    ,disbursed_loan_cnt_180d bigint comment 'Net Disbursed Loan Count 180D (principal_repayable - principal_refund > 0)'
    ,disbursed_loan_cnt_360d bigint comment 'Net Disbursed Loan Count 360D (principal_repayable - principal_refund > 0)'
    ,is_billed bigint comment 'Is Billed'
    ,is_ever_due bigint comment 'Is Ever Due'
    ,latest_disburse_dpd_eod bigint comment 'Latest loan with "performance (within the range of grass_date - loan_due_time > 15 days)" max_dpd_eod'
    ,principal_repaid_1d decimal(30,10) comment 'Principal repaid in 1 day'
    ,principal_repaid_7d decimal(30,10) comment 'Principal repaid in 7 days'
    ,principal_repaid_30d decimal(30,10) comment 'Principal repaid in 30 days'
    ,principal_repaid_td decimal(30,10) comment 'Principal repaid'
    ,interest_repaid_1d decimal(30,10) comment 'Interest repaid in 1 day'
    ,interest_repaid_7d decimal(30,10) comment 'Interest repaid in 7 days'
    ,interest_repaid_30d decimal(30,10) comment 'Interest repaid in 30 days'
    ,interest_repaid_td decimal(30,10) comment 'Interest repaid'
    ,cleared_loan_cnt_1d bigint comment 'Cleared loan count in 1 day'
    ,cleared_loan_cnt_30d bigint comment 'Cleared loan count in 30 days'
    ,cleared_loan_cnt_90d bigint comment 'Cleared loan count in 90 days'
    ,cleared_loan_cnt_180d bigint comment 'Cleared loan count in 180 days'
    ,cleared_loan_cnt_360d bigint comment 'Cleared loan count in 360 days'
    ,cleared_loan_cnt_td bigint comment 'Cleared loan count'
    ,early_clear_principal_1d decimal(30,10) comment 'The total principal of the early-cleared instalment in 1 day'
    ,early_clear_principal_30d decimal(30,10) comment 'The total principal of the early-cleared instalment in 30 days'
    ,early_clear_principal_90d decimal(30,10) comment 'The total principal of the early-cleared instalment in 90 days'
    ,early_clear_principal_180d decimal(30,10) comment 'The total principal of the early-cleared instalment in 180 days'
    ,early_clear_principal_360d decimal(30,10) comment 'The total principal of the early-cleared instalment in 360 days'
    ,early_clear_principal_td decimal(30,10) comment 'The total principal of the early-cleared instalment'
    ,early_clear_instalment_cnt_1d bigint comment 'The count of early-cleared instalment in 1 day'
    ,early_clear_instalment_cnt_30d bigint comment 'The count of early-cleared instalment in 30 days'
    ,early_clear_instalment_cnt_90d bigint comment 'The count of early-cleared instalment in 90 days'
    ,early_clear_instalment_cnt_180d bigint comment 'The count of early-cleared instalment in 180 days'
    ,early_clear_instalment_cnt_360d bigint comment 'The count of early-cleared instalment in 360 days'
    ,early_clear_instalment_cnt_td bigint comment 'The count of early-cleared instalment'
    ,no_os_month_cnt bigint comment 'No OS Month Count,if principal_os>0, then 0'
)
partitioned by
(
    grass_date string comment 'Full Daily Partition'
) 
comment 'credit mart summary table'
stored as orc tblproperties ("orc.compress" = "SNAPPY", "orc.stripe.size" = "64000000") 
location '${HDFS_PATH}/ads/ads_risk_${table_product}_${table_region}_user_behavior_df/grass_region=${region}'
;
msck repair table ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_behavior_df; 
