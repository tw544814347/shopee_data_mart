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
-- **             修改日期: 2026-01-30  修改人:siyuan.sun    修改内容: 新增BR risk features - DPD EOD of the Latest Due Date within the Past 1/2/3 Months.
-- **             修改日期: 2026-02-04  修改人:siyuan.sun    修改内容: 新增BR risk features - Total Outstanding Loan Amount of Latest DPD EOD (DPD_EOD >= 3/5/7/15/30 days) within the Past 3 Months.  
-- **             修改日期: 2026-02-13  修改人:siyuan.sun    修改内容: 新增BR risk features - Bill to Installment Eligibility flags: is_eligible_for_restructure_1m/2m/3m/6m/9m/12m/18m, 和相应的restructure_interest_rate_1m/2m/3m/6m/9m/12m/18m. 
-- ** @extra_input=xxx
-- ** @extra_input=xxx
-- **************************************************************************


-- drop table if exists ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_behavior_df;

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
${comment}     ,1m_latest_dpd_eod bigint comment 'DPD EOD Based on the Latest Due Date Within the Past 1 Month'
${comment}     ,2m_latest_dpd_eod bigint comment 'DPD EOD Based on the Latest Due Date Within the Past 2 Months'
${comment}     ,3m_latest_dpd_eod bigint comment 'DPD EOD Based on the Latest Due Date Within the Past 3 Months'
${comment}     ,3m_latest_dpd_eod_3d_amt decimal(30,10) comment 'Total Outstanding Loan Amount Corresponding to the Latest Due Date Within the Past 3 Months Where DPD EOD >= 3 Days'
${comment}     ,3m_latest_dpd_eod_5d_amt decimal(30,10) comment 'Total Outstanding Loan Amount Corresponding to the Latest Due Date Within the Past 3 Months Where DPD EOD >= 5 Days'
${comment}     ,3m_latest_dpd_eod_7d_amt decimal(30,10) comment 'Total Outstanding Loan Amount Corresponding to the Latest Due Date Within the Past 3 Months Where DPD EOD >= 7 Days'
${comment}     ,3m_latest_dpd_eod_15d_amt decimal(30,10) comment 'Total Outstanding Loan Amount Corresponding to the Latest Due Date Within the Past 3 Months Where DPD EOD >= 15 Days'
${comment}     ,3m_latest_dpd_eod_30d_amt decimal(30,10) comment 'Total Outstanding Loan Amount Corresponding to the Latest Due Date Within the Past 3 Months Where DPD EOD >= 30 Days'
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
${comment}     ,is_eligible_for_restructure_1m bigint comment 'Eligibility Flag Indicating Whether the User is Eligible For a 1-month Bill-to-Installment Restructure Option'
${comment}     ,is_eligible_for_restructure_2m bigint comment 'Eligibility Flag Indicating Whether the User is Eligible For a 2-month Bill-to-Installment Restructure Option'
${comment}     ,is_eligible_for_restructure_3m bigint comment 'Eligibility Flag Indicating Whether the User is Eligible For a 3-month Bill-to-Installment Restructure Option'
${comment}     ,is_eligible_for_restructure_6m bigint comment 'Eligibility Flag Indicating Whether the User is Eligible For a 6-month Bill-to-Installment Restructure Option'
${comment}     ,is_eligible_for_restructure_9m bigint comment 'Eligibility Flag Indicating Whether the User is Eligible For a 9-month Bill-to-Installment Restructure Option'
${comment}     ,is_eligible_for_restructure_12m bigint comment 'Eligibility Flag Indicating Whether the User is Eligible For a 12-month Bill-to-Installment Restructure Option'
${comment}     ,is_eligible_for_restructure_18m bigint comment 'Eligibility Flag Indicating Whether the User is Eligible For a 18-month Bill-to-Installment Restructure Option'
${comment}     ,restructure_interest_rate_1m decimal(30,10) comment 'Interest Rate for the 1-month Bill-to-Installment Restructure Option'
${comment}     ,restructure_interest_rate_2m decimal(30,10) comment 'Interest Rate for the 2-month Bill-to-Installment Restructure Option'
${comment}     ,restructure_interest_rate_3m decimal(30,10) comment 'Interest Rate for the 3-month Bill-to-Installment Restructure Option'
${comment}     ,restructure_interest_rate_6m decimal(30,10) comment 'Interest Rate for the 6-month Bill-to-Installment Restructure Option'
${comment}     ,restructure_interest_rate_9m decimal(30,10) comment 'Interest Rate for the 9-month Bill-to-Installment Restructure Option'
${comment}     ,restructure_interest_rate_12m decimal(30,10) comment 'Interest Rate for the 12-month Bill-to-Installment Restructure Option'
${comment}     ,restructure_interest_rate_18m decimal(30,10) comment 'Interest Rate for the 18-month Bill-to-Installment Restructure Option'
)
partitioned by
(
    grass_date string comment 'Full Daily Partition'
) 
comment 'credit mart summary table'
stored as orc tblproperties ("orc.compress" = "SNAPPY", "orc.stripe.size" = "64000000") 
location '${HDFS_PATH}/ads/ads_risk_${table_product}_${table_region}_user_behavior_df/grass_region=${region}'
;
-- msck repair table ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_behavior_df; 


uncache table if exists dws_mid_df;
cache table dws_mid_df options ('storageLevel' 'MEMORY_and_DISK')
select /*+ REPARTITION(20000) */ 
    * 
from credit_mart.dws_${table_product}_aio_${table_region}_user_behavior_mid_df
WHERE grass_date = '${ds}' 
and product_id in (${product_id})
;

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
        MIN(month_bill_date) AS first_month_bill_date,
        MAX(month_bill_date) AS last_month_bill_date,
        MIN(month_due_date) AS first_month_due_date,
        MAX(month_due_date) AS last_month_due_date,
        min(loan_disburse_last_process_date) as first_disburse_last_process_date,
        max(loan_disburse_last_process_date) as last_disburse_last_process_date,


        -- 放款指标
        max(is_net_disbursed) as is_ever_disbursed,
        max(is_net_disbursed * is_disbursed_1d) as is_ever_disbursed_1d,
        max(is_net_disbursed * is_disbursed_30d) as is_ever_disbursed_30d,
        max(is_net_disbursed * is_disbursed_90d) as is_ever_disbursed_90d,
        max(is_net_disbursed * is_disbursed_180d) as is_ever_disbursed_180d,
        max(is_net_disbursed * is_disbursed_360d) as is_ever_disbursed_360d,

        ceil(max(datediff(grass_date, loan_disburse_last_process_date))/30) as max_disburse_month_cnt,

        
        -- instalment金额
        SUM(principal_os) AS principal_os,
        sum(if(dpd_eod >= 1, principal_os, 0)) as principal_os_dpd_eod_1,
        sum(if(dpd_eod >= 7, principal_os, 0)) as principal_os_dpd_eod_7,
        sum(if(dpd_eod >= 15, principal_os, 0)) as principal_os_dpd_eod_15,
        sum(if(dpd_eod >= 30, principal_os, 0)) as principal_os_dpd_eod_30,
        sum(if(dpd_eod >= 60, principal_os, 0)) as principal_os_dpd_eod_60,
        sum(if(dpd_eod >= 90, principal_os, 0)) as principal_os_dpd_eod_90,
        sum(if(dpd_eod >= 120, principal_os, 0)) as principal_os_dpd_eod_120,
        sum(if(dpd_eod >= 180, principal_os, 0)) as principal_os_dpd_eod_180,
        sum(if(dpd_eod >= 360, principal_os, 0)) as principal_os_dpd_eod_360,
        SUM(interest_os) AS interest_os,
        
        
        -- 逾期指标 
        
        max(if(max_dpd_eod>0,1,0)) as is_ever_due,

        MAX(dpd_eod) AS current_max_dpd_eod,
        MAX(max_dpd) AS ever_max_dpd,
        MAX(max_dpd_eod) AS ever_max_dpd_eod,
        
        -- dpd_eod的时间窗口：对于已结清的instalment, 看x个月内的结清记录；对于未结清的instalment，直接看dpd_eod。这个计算方法和跨grass_date计算结果一样
        MAX(
            case
                when dpd_eod=0 then if(date(instalment_clear_date) > date('${tomorrow_ds}') - interval '24' month, max_dpd_eod, 0)
                else dpd_eod
            end 
        ) as ever_max_dpd_24m_eod,
        MAX(
            case
                when dpd_eod=0 then if(date(instalment_clear_date) > date('${tomorrow_ds}') - interval '12' month, max_dpd_eod, 0)
                else dpd_eod
            end 
        ) as ever_max_dpd_12m_eod,
        MAX(
            case
                when dpd_eod=0 then if(date(instalment_clear_date) > date('${tomorrow_ds}') - interval '6' month, max_dpd_eod, 0)
                else dpd_eod
            end 
        ) as ever_max_dpd_6m_eod,
        MAX(
            case
                when dpd_eod=0 then if(date(instalment_clear_date) > date('${tomorrow_ds}') - interval '3' month, max_dpd_eod, 0)
                else dpd_eod
            end 
        ) as ever_max_dpd_3m_eod,

        MAX(
            case
                when dpd_eod=0 then if(date(instalment_clear_date) > date('${tomorrow_ds}') - interval '1' month, max_dpd_eod, 0)
                else dpd_eod
            end 
        ) as ever_max_dpd_1m_eod,
        MAX(
            case
                when dpd_eod=0 then if(date(instalment_clear_date) > date('${tomorrow_ds}') - interval '7' day, max_dpd_eod, 0)
                else dpd_eod
            end 
        ) as ever_max_dpd_7d_eod,
        MAX(
            case
                when dpd_eod=0 then if(date(instalment_clear_date) > date('${tomorrow_ds}') - interval '1' day, max_dpd_eod, 0)
                else dpd_eod
            end 
        ) as ever_max_dpd_1d_eod,
        
${comment}         -- DPD EOD of the Latest Due Date within the Past 1/2/3 Months. 
${comment}         -- 1M period: find the latest month_due_date and get its max_dpd_eod
${comment}      max(
${comment}          case
${comment}          when date(month_due_date) >= date('${ds}') - interval '1' month 
${comment}              and date(month_due_date) < date('${ds}')
${comment}                 then named_struct('due_date', month_due_date, 'dpd_eod', max_dpd_eod)
${comment}             end
${comment}          ).dpd_eod as 1m_latest_dpd_eod,
${comment}         -- 2M period: find the latest month_due_date and get its max_dpd_eod
${comment}      max(
${comment}             case
${comment}                 when date(month_due_date) >= date('${ds}') - interval '2' month 
${comment}                      and date(month_due_date) < date('${ds}')
${comment}                 then named_struct('due_date', month_due_date, 'dpd_eod', max_dpd_eod)
${comment}             end
${comment}         ).dpd_eod as 2m_latest_dpd_eod,
${comment}         -- 3M period: find the latest month_due_date and get its max_dpd_eod
${comment}         max(
${comment}            case
${comment}                when date(month_due_date) >= date('${ds}') - interval '3' month 
${comment}                      and date(month_due_date) < date('${ds}')
${comment}               then named_struct('due_date', month_due_date, 'dpd_eod', max_dpd_eod)
${comment}             end
${comment}         ).dpd_eod as 3m_latest_dpd_eod, 

        -- 贷中行为指标
        SUM(if(is_disbursed_1d=1, loan_principal_repayable, 0)) AS sum_principal_repayable_1d,
        SUM(if(is_disbursed_30d=1, loan_principal_repayable, 0)) AS sum_principal_repayable_30d,
        SUM(if(is_disbursed_90d=1, loan_principal_repayable, 0)) AS sum_principal_repayable_90d,
        SUM(if(is_disbursed_180d=1, loan_principal_repayable, 0)) AS sum_principal_repayable_180d,
        SUM(if(is_disbursed_360d=1, loan_principal_repayable, 0)) AS sum_principal_repayable_360d,
        SUM(loan_principal_repayable) AS sum_principal_repayable_td,
        max(if(is_disbursed_1d=1, loan_principal_repayable, 0)) AS max_principal_repayable_1d,
        max(if(is_disbursed_30d=1, loan_principal_repayable, 0)) AS max_principal_repayable_30d,
        max(if(is_disbursed_90d=1, loan_principal_repayable, 0)) AS max_principal_repayable_90d,
        max(if(is_disbursed_180d=1, loan_principal_repayable, 0)) AS max_principal_repayable_180d,
        max(if(is_disbursed_360d=1, loan_principal_repayable, 0)) AS max_principal_repayable_360d,
        max(loan_principal_repayable) AS max_principal_repayable_td,
        min(if(is_disbursed_1d=1, loan_principal_repayable, 0)) AS min_principal_repayable_1d,
        min(if(is_disbursed_30d=1, loan_principal_repayable, 0)) AS min_principal_repayable_30d,
        min(if(is_disbursed_90d=1, loan_principal_repayable, 0)) AS min_principal_repayable_90d,
        min(if(is_disbursed_180d=1, loan_principal_repayable, 0)) AS min_principal_repayable_180d,
        min(if(is_disbursed_360d=1, loan_principal_repayable, 0)) AS min_principal_repayable_360d,
        min(loan_principal_repayable) AS min_principal_repayable_td,
        
        
        -- “有表现的”(grass_date - loan_due_time > 15 这个范围)最新放款loan的max_dpd_eod
        max_by(
            max_dpd_eod
            ,if(grass_date > date_add(loan_disburse_last_process_date, 15), struct(loan_disburse_last_process_date, max_dpd_eod), null)
        ) as latest_disburse_dpd_eod,

        -- 对于writeoff，需要使用loan粒度的dpd_finance，如果有一个instalment writeoff了，就算整笔loan都writeoff
        SUM(if(loan_dpd_finance > 120, principal_os, 0)) AS writeoff_principal_os,

        sum(principal_repaid_1d) as principal_repaid_1d,
        sum(principal_repaid_7d) as principal_repaid_7d,
        sum(principal_repaid_30d) as principal_repaid_30d,
        sum(principal_repaid) as principal_repaid_td,
        sum(interest_repaid_1d) as interest_repaid_1d,
        sum(interest_repaid_7d) as interest_repaid_7d,
        sum(interest_repaid_30d) as interest_repaid_30d,
        sum(interest_repaid) as interest_repaid_td, 

        -- 提前结清口径：有账单，出账日之前算提前结清，没账单，due_date往前推10天算提前结清
        sum(if(is_early_clear_1d=1, principal_repayable, 0)) as early_clear_principal_1d,
        sum(if(is_early_clear_30d=1, principal_repayable, 0)) as early_clear_principal_30d,
        sum(if(is_early_clear_90d=1, principal_repayable, 0)) as early_clear_principal_90d,
        sum(if(is_early_clear_180d=1, principal_repayable, 0)) as early_clear_principal_180d,
        sum(if(is_early_clear_360d=1, principal_repayable, 0)) as early_clear_principal_360d,
        sum(if(is_early_clear_td=1, principal_repayable, 0)) as early_clear_principal_td,
        
        -- 提前结清口径：有账单，出账日之前算提前结清，没账单，due_date往前推10天算提前结清
        sum(if(is_early_clear_1d=1, 1, 0)) as early_clear_instalment_cnt_1d,
        sum(if(is_early_clear_30d=1, 1, 0)) as early_clear_instalment_cnt_30d,
        sum(if(is_early_clear_90d=1, 1, 0)) as early_clear_instalment_cnt_90d,
        sum(if(is_early_clear_180d=1, 1, 0)) as early_clear_instalment_cnt_180d,
        sum(if(is_early_clear_360d=1, 1, 0)) as early_clear_instalment_cnt_360d,
        sum(if(is_early_clear_td=1, 1, 0)) as early_clear_instalment_cnt_td,
        
        -- 一个人如果现在有os，则置0，如果现在没有os, 计算grass_date - max(clear_time)
        if(sum(principal_os) > 0, 0, min(ceil(datediff(grass_date, instalment_clear_date)/30))) as no_os_month_cnt
    from 
    (
        select 
            *,
            -- 预先计算放款日期标记，避免重复判断
            if(loan_disburse_last_process_date = '${ds}', 1, 0) AS is_disbursed_1d,
            if(loan_disburse_last_process_date BETWEEN DATE_ADD('${ds}', -29) AND '${ds}', 1, 0) AS is_disbursed_30d,
            if(loan_disburse_last_process_date BETWEEN DATE_ADD('${ds}', -89) AND '${ds}', 1, 0) AS is_disbursed_90d,
            if(loan_disburse_last_process_date BETWEEN DATE_ADD('${ds}', -179) AND '${ds}', 1, 0) AS is_disbursed_180d,
            if(loan_disburse_last_process_date BETWEEN DATE_ADD('${ds}', -359) AND '${ds}', 1, 0) AS is_disbursed_360d,

            -- 预先计算结清日期标记
            if(loan_clear_status=3 and loan_clear_date = '${ds}', 1, 0) as is_loan_cleared_1d,
            if(loan_clear_status=3 and loan_clear_date between date_add('${ds}', -29) and '${ds}', 1, 0) as is_loan_cleared_30d,
            if(loan_clear_status=3 and loan_clear_date between date_add('${ds}', -89) and '${ds}', 1, 0) as is_loan_cleared_90d,
            if(loan_clear_status=3 and loan_clear_date between date_add('${ds}', -179) and '${ds}', 1, 0) as is_loan_cleared_180d,
            if(loan_clear_status=3 and loan_clear_date between date_add('${ds}', -359) and '${ds}', 1, 0) as is_loan_cleared_360d,
            if(loan_clear_status=3, 1, 0) as is_loan_cleared_td,

            -- 预先计算提前结清标记
            if(date(instalment_clear_date)='${ds}' and date(instalment_clear_date) < coalesce(date(month_bill_date), date_add(date(month_due_date), -11)), 1, 0) as is_early_clear_1d,
            if(date(instalment_clear_date) between date_add('${ds}', -29) and '${ds}' and date(instalment_clear_date) < coalesce(date(month_bill_date), date_add(date(month_due_date), -11)), 1, 0) as is_early_clear_30d,
            if(date(instalment_clear_date) between date_add('${ds}', -89) and '${ds}' and date(instalment_clear_date) < coalesce(date(month_bill_date), date_add(date(month_due_date), -11)), 1, 0) as is_early_clear_90d,
            if(date(instalment_clear_date) between date_add('${ds}', -179) and '${ds}' and date(instalment_clear_date) < coalesce(date(month_bill_date), date_add(date(month_due_date), -11)), 1, 0) as is_early_clear_180d,
            if(date(instalment_clear_date) between date_add('${ds}', -359) and '${ds}' and date(instalment_clear_date) < coalesce(date(month_bill_date), date_add(date(month_due_date), -11)), 1, 0) as is_early_clear_360d,
            if(date(instalment_clear_date) < coalesce(date(month_bill_date), date_add(date(month_due_date), -11)), 1, 0) as is_early_clear_td,

            -- 预先计算净放款标记
            if(principal_repayable - principal_refund > 0, 1, 0) AS is_net_disbursed
        from dws_mid_df
    ) t1 
    GROUP BY grass_date, credit_user_id, biz_type
),

${comment} -- Total Outstanding Loan Amount of Latest DPD EOD (DPD_EOD >= 3/5/7/15/30 days) within the Past 3 Months
${comment} -- For each loan, get latest_month_due_date and ever_max_dpd_eod within the past 3 months 
${comment}  loan_latest_3m as (
${comment}     select
${comment}         credit_user_id,
${comment}         biz_type,
${comment}         loan_id,
${comment}         max(month_due_date) as latest_month_due_date,
${comment}         max(max_dpd_eod)    as ever_max_dpd_eod
${comment}     from dws_mid_df
${comment}     where grass_date = '${ds}'
${comment}       and date(month_due_date) >= date('${ds}') - interval '3' month
${comment}       and date(month_due_date) <  date('${ds}')
${comment}     group by credit_user_id, biz_type, loan_id
${comment} ),
${comment} -- Calculate the target grass_dates based on latest month_due_date 
${comment} loan_dpd_dates as (
${comment}     select
${comment}         credit_user_id,
${comment}         biz_type,
${comment}         loan_id,
${comment}         ever_max_dpd_eod,
${comment}         date_add(latest_month_due_date,  2) as dpd3_date,
${comment}         date_add(latest_month_due_date,  4) as dpd5_date,
${comment}         date_add(latest_month_due_date,  6) as dpd7_date,
${comment}         date_add(latest_month_due_date, 14) as dpd15_date,
${comment}         date_add(latest_month_due_date, 29) as dpd30_date
${comment}     from loan_latest_3m
${comment} ),
${comment} -- Calculate the total_amount_os on exact dpd target date 
${comment} loan_dpd_amt as (
${comment}     select
${comment}         a.credit_user_id,
${comment}         a.biz_type,
${comment}         a.loan_id,
${comment}         sum(case when a.ever_max_dpd_eod >= 3  and b.grass_date = a.dpd3_date  then b.total_amount_os end) as dpd3_amt,
${comment}         sum(case when a.ever_max_dpd_eod >= 5  and b.grass_date = a.dpd5_date  then b.total_amount_os end) as dpd5_amt,
${comment}         sum(case when a.ever_max_dpd_eod >= 7  and b.grass_date = a.dpd7_date  then b.total_amount_os end) as dpd7_amt,
${comment}         sum(case when a.ever_max_dpd_eod >= 15 and b.grass_date = a.dpd15_date then b.total_amount_os end) as dpd15_amt,
${comment}         sum(case when a.ever_max_dpd_eod >= 30 and b.grass_date = a.dpd30_date then b.total_amount_os end) as dpd30_amt
${comment}     from loan_dpd_dates a
${comment}     left join credit_mart.dws_${table_product}_aio_${table_region}_user_behavior_mid_df b
${comment}       on a.loan_id = b.loan_id
${comment}      and b.grass_date in (
${comment}             a.dpd3_date,
${comment}             a.dpd5_date,
${comment}             a.dpd7_date,
${comment}             a.dpd15_date,
${comment}             a.dpd30_date
${comment}        )
${comment}     group by a.credit_user_id, a.biz_type, a.loan_id
${comment} ),
${comment} -- Roll-up to credit_user_id level and aggregate amounts and get the total outstanding laon amount for each DPD EOD threshold 
${comment} user_latest_dpd_eod_amt_metrics as (
${comment}     select
${comment}         credit_user_id,
${comment}         biz_type,
${comment}         '${ds}' as grass_date,
${comment}         sum(coalesce(dpd3_amt,  0)) as 3m_latest_dpd_eod_3d_amt,
${comment}         sum(coalesce(dpd5_amt,  0)) as 3m_latest_dpd_eod_5d_amt,
${comment}         sum(coalesce(dpd7_amt,  0)) as 3m_latest_dpd_eod_7d_amt,
${comment}         sum(coalesce(dpd15_amt, 0)) as 3m_latest_dpd_eod_15d_amt,
${comment}         sum(coalesce(dpd30_amt, 0)) as 3m_latest_dpd_eod_30d_amt
${comment}     from loan_dpd_amt
${comment}     group by credit_user_id, biz_type
${comment} ),

user_loan_behavior_metrics as (
    select 
        credit_user_id,
        biz_type,
        grass_date,
        sum(is_net_disbursed * is_disbursed_1d) as disbursed_loan_cnt_1d,
        sum(is_net_disbursed * is_disbursed_30d) as disbursed_loan_cnt_30d,
        sum(is_net_disbursed * is_disbursed_90d) as disbursed_loan_cnt_90d,
        sum(is_net_disbursed * is_disbursed_180d) as disbursed_loan_cnt_180d,
        sum(is_net_disbursed * is_disbursed_360d) as disbursed_loan_cnt_360d,
        sum(is_loan_cleared_1d) as cleared_loan_cnt_1d,
        sum(is_loan_cleared_30d) as cleared_loan_cnt_30d,
        sum(is_loan_cleared_90d) as cleared_loan_cnt_90d,
        sum(is_loan_cleared_180d) as cleared_loan_cnt_180d,
        sum(is_loan_cleared_360d) as cleared_loan_cnt_360d,
        sum(is_loan_cleared_td) as cleared_loan_cnt_td
    from 
    (
        select 
            loan_id,
            credit_user_id,
            biz_type,
            grass_date,
            -- 预先计算放款日期标记，避免重复判断
            max(if(loan_disburse_last_process_date = '${ds}', 1, 0)) AS is_disbursed_1d,
            max(if(loan_disburse_last_process_date BETWEEN DATE_ADD('${ds}', -29) AND '${ds}', 1, 0)) AS is_disbursed_30d,
            max(if(loan_disburse_last_process_date BETWEEN DATE_ADD('${ds}', -89) AND '${ds}', 1, 0)) AS is_disbursed_90d,
            max(if(loan_disburse_last_process_date BETWEEN DATE_ADD('${ds}', -179) AND '${ds}', 1, 0)) AS is_disbursed_180d,
            max(if(loan_disburse_last_process_date BETWEEN DATE_ADD('${ds}', -359) AND '${ds}', 1, 0)) AS is_disbursed_360d,

            -- 预先计算结清日期标记
            max(if(loan_clear_status=3 and loan_clear_date = '${ds}', 1, 0)) as is_loan_cleared_1d,
            max(if(loan_clear_status=3 and loan_clear_date between date_add('${ds}', -29) and '${ds}', 1, 0)) as is_loan_cleared_30d,
            max(if(loan_clear_status=3 and loan_clear_date between date_add('${ds}', -89) and '${ds}', 1, 0)) as is_loan_cleared_90d,
            max(if(loan_clear_status=3 and loan_clear_date between date_add('${ds}', -179) and '${ds}', 1, 0)) as is_loan_cleared_180d,
            max(if(loan_clear_status=3 and loan_clear_date between date_add('${ds}', -359) and '${ds}', 1, 0)) as is_loan_cleared_360d,
            max(if(loan_clear_status=3, 1, 0)) as is_loan_cleared_td,

            -- 预先计算提前结清标记
            max(if(date(instalment_clear_date)='${ds}' and date(instalment_clear_date) < coalesce(date(month_bill_date), date_add(date(month_due_date), -11)), 1, 0)) as is_early_clear_1d,
            max(if(date(instalment_clear_date) between date_add('${ds}', -29) and '${ds}' and date(instalment_clear_date) < coalesce(date(month_bill_date), date_add(date(month_due_date), -11)), 1, 0)) as is_early_clear_30d,
            max(if(date(instalment_clear_date) between date_add('${ds}', -89) and '${ds}' and date(instalment_clear_date) < coalesce(date(month_bill_date), date_add(date(month_due_date), -11)), 1, 0)) as is_early_clear_90d,
            max(if(date(instalment_clear_date) between date_add('${ds}', -179) and '${ds}' and date(instalment_clear_date) < coalesce(date(month_bill_date), date_add(date(month_due_date), -11)), 1, 0)) as is_early_clear_180d,
            max(if(date(instalment_clear_date) between date_add('${ds}', -359) and '${ds}' and date(instalment_clear_date) < coalesce(date(month_bill_date), date_add(date(month_due_date), -11)), 1, 0)) as is_early_clear_360d,
            max(if(date(instalment_clear_date) < coalesce(date(month_bill_date), date_add(date(month_due_date), -11)), 1, 0)) as is_early_clear_td,

            -- 预先计算净放款标记
            max(if(principal_repayable - principal_refund > 0, 1, 0)) AS is_net_disbursed
        from dws_mid_df
        group by loan_id,
            credit_user_id,
            biz_type,
            grass_date
    ) t1 
    group by credit_user_id,
        biz_type,
        grass_date
),

${comment} -- Bill to Installment Eligibility flags: is_eligible_for_restructure_1m/2m/3m/6m/9m/12m/18m, 和相应的restructure_interest_rate_1m/2m/3m/6m/9m/12m/18m. The flag indicates whether the user is eligible for installment billing. The interest rate fields indicate the corresponding interest rates if applicable. 
${comment} restructure_rates as (
${comment}     select
${comment}         t1.credit_user_id,
${comment}         t1.grass_date,
${comment}         cast(get_json_object(t2.restructure_fee_rate_info, '$.decimal_base') as decimal(30,10)) as decimal_base,
${comment}         case when get_json_object(t2.restructure_fee_rate_info, '$.interest_rate_1m')  is not null then 1 else 0 end as is_eligible_for_restructure_1m,
${comment}         case when get_json_object(t2.restructure_fee_rate_info, '$.interest_rate_2m')  is not null then 1 else 0 end as is_eligible_for_restructure_2m,
${comment}         case when get_json_object(t2.restructure_fee_rate_info, '$.interest_rate_3m')  is not null then 1 else 0 end as is_eligible_for_restructure_3m,
${comment}         case when get_json_object(t2.restructure_fee_rate_info, '$.interest_rate_6m')  is not null then 1 else 0 end as is_eligible_for_restructure_6m,
${comment}         case when get_json_object(t2.restructure_fee_rate_info, '$.interest_rate_9m')  is not null then 1 else 0 end as is_eligible_for_restructure_9m,
${comment}         case when get_json_object(t2.restructure_fee_rate_info, '$.interest_rate_12m') is not null then 1 else 0 end as is_eligible_for_restructure_12m,
${comment}         case when get_json_object(t2.restructure_fee_rate_info, '$.interest_rate_18m') is not null then 1 else 0 end as is_eligible_for_restructure_18m,
${comment}         case when cast(get_json_object(t2.restructure_fee_rate_info, '$.decimal_base') as decimal(30,10)) > 0
${comment}              then cast(get_json_object(t2.restructure_fee_rate_info, '$.interest_rate_1m')  as decimal(30,10)) / cast(get_json_object(t2.restructure_fee_rate_info, '$.decimal_base') as decimal(30,10)) end as restructure_interest_rate_1m,
${comment}         case when cast(get_json_object(t2.restructure_fee_rate_info, '$.decimal_base') as decimal(30,10)) > 0
${comment}              then cast(get_json_object(t2.restructure_fee_rate_info, '$.interest_rate_2m')  as decimal(30,10)) / cast(get_json_object(t2.restructure_fee_rate_info, '$.decimal_base') as decimal(30,10)) end as restructure_interest_rate_2m,
${comment}         case when cast(get_json_object(t2.restructure_fee_rate_info, '$.decimal_base') as decimal(30,10)) > 0
${comment}              then cast(get_json_object(t2.restructure_fee_rate_info, '$.interest_rate_3m')  as decimal(30,10)) / cast(get_json_object(t2.restructure_fee_rate_info, '$.decimal_base') as decimal(30,10)) end as restructure_interest_rate_3m,
${comment}         case when cast(get_json_object(t2.restructure_fee_rate_info, '$.decimal_base') as decimal(30,10)) > 0
${comment}              then cast(get_json_object(t2.restructure_fee_rate_info, '$.interest_rate_6m')  as decimal(30,10)) / cast(get_json_object(t2.restructure_fee_rate_info, '$.decimal_base') as decimal(30,10)) end as restructure_interest_rate_6m,
${comment}         case when cast(get_json_object(t2.restructure_fee_rate_info, '$.decimal_base') as decimal(30,10)) > 0
${comment}              then cast(get_json_object(t2.restructure_fee_rate_info, '$.interest_rate_9m') as decimal(30,10)) / cast(get_json_object(t2.restructure_fee_rate_info, '$.decimal_base') as decimal(30,10)) end as restructure_interest_rate_9m,             
${comment}         case when cast(get_json_object(t2.restructure_fee_rate_info, '$.decimal_base') as decimal(30,10)) > 0
${comment}              then cast(get_json_object(t2.restructure_fee_rate_info, '$.interest_rate_12m') as decimal(30,10)) / cast(get_json_object(t2.restructure_fee_rate_info, '$.decimal_base') as decimal(30,10)) end as restructure_interest_rate_12m,
${comment}         case when cast(get_json_object(t2.restructure_fee_rate_info, '$.decimal_base') as decimal(30,10)) > 0
${comment}              then cast(get_json_object(t2.restructure_fee_rate_info, '$.interest_rate_18m') as decimal(30,10)) / cast(get_json_object(t2.restructure_fee_rate_info, '$.decimal_base') as decimal(30,10)) end as restructure_interest_rate_18m
${comment}     from credit_uc.dwd_uc_${table_region}_user_uc_tag_info_tab_df t1
${comment}     left join credit_mart.dws_${table_product}_aio_${table_region}_account_df t2
${comment}         on t1.credit_user_id = t2.credit_user_id
${comment}        and t1.grass_date = t2.grass_date
${comment}     where t1.grass_date = '${ds}'
${comment}       and t1.tag_type = 290
${comment}       and t1.tag_status in (1, 10, 11)
${comment} ),

user_bill_behavior_metrics as (
    select 
        credit_user_id,
        biz_type,
        grass_date,

        -- === bill数量 ===
        count(1) AS gross_bill_count,
        sum(if(is_net_disbursed=1, 1, 0)) as net_bill_count,
        -- 已还款账单数量：基于bill_clear_status=4
        sum(if(bill_clear_status=4,1,0)) as cleared_bill_count,
        if(sum(bill_total_amount_repayable - bill_total_amount_refund - bill_total_amount_deduct) > 0, 1, 0) AS is_billed
    from 
    (
        select 
            bill_id,
            credit_user_id,
            biz_type,
            grass_date,
            max(bill_total_amount_repayable) as bill_total_amount_repayable,
            max(bill_total_amount_refund) as bill_total_amount_refund,
            max(bill_total_amount_deduct) as bill_total_amount_deduct,
            max(bill_clear_status) as bill_clear_status,
            -- 预先计算净放款标记
            max(if(principal_repayable - principal_refund > 0, 1, 0)) AS is_net_disbursed
        from dws_mid_df
        where bill_id is not null
        group by bill_id,
            credit_user_id,
            biz_type,
            grass_date
    ) t1 
    group by credit_user_id,
        biz_type,
        grass_date
),
user_nxb_behavior_metrics as (
    SELECT 
        grass_date,
        credit_user_id,
        biz_type,

        -- 月份数
        count(distinct month_window) as gross_floating_term_count,
        case 
            when count(month_window) = 0 then null 
            else count(distinct if(net_instal_count_per_floating_term = gross_instal_count_per_floating_term, month_window, null))
        end as net_floating_term_count,
        case 
            when count(month_window) = 0 then null 
            else count(distinct if(cleared_instal_count_per_floating_term = gross_instal_count_per_floating_term, month_window, null))
        end as cleared_floating_term_count,
        
        min_by(max_dpd_eod_per_floating_term, month_window) as latest_floating_term_dpd_eod,
        min_by(if(month_window <= 4, max_dpd_eod_per_floating_term, null), month_window) as latest_floating_term_dpd_4m_eod

    from 
    (
        SELECT
            t1.grass_date
            ,t1.credit_user_id
            ,t1.biz_type
            ,t1.month_window
            ,sum(if(instalment_clear_status in (4,5), 1, 0)) as cleared_instal_count_per_floating_term
            ,count(1) as gross_instal_count_per_floating_term
            ,sum(if(principal_repayable - principal_refund > 0, 1, 0)) as net_instal_count_per_floating_term
            ,max(max_dpd_eod) as max_dpd_eod_per_floating_term
            
        FROM
        (
            select 
                *
                ,case 
                    when month_due_date <= grass_date then 
                        case 
                            when datediff(grass_date, month_due_date) = 0 then 1 
                            else ceil(datediff(grass_date, month_due_date) / 30) 
                        end
                    else null
                end as month_window
            from dws_mid_df
        ) t1
        group by t1.grass_date, t1.credit_user_id, t1.biz_type, t1.month_window
        
    ) t1 
    GROUP BY grass_date, credit_user_id, biz_type
)

INSERT OVERWRITE TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_behavior_df
PARTITION (grass_date)
SELECT 
    um.credit_user_id,
    um.platform_user_id,
    um.biz_type,

    -- === 时间指标 ===
    ubm.first_month_bill_date,
    ubm.last_month_bill_date,
    ubm.first_month_due_date,
    ubm.last_month_due_date,
    ubm.first_disburse_last_process_date,
    ubm.last_disburse_last_process_date,

    -- === floating term 数量 ===
    unbm.gross_floating_term_count,
    unbm.net_floating_term_count,
    unbm.cleared_floating_term_count,
    
    -- === instalment金额 ===
    ubm.principal_os,
    ubm.principal_os_dpd_eod_1,
    ubm.principal_os_dpd_eod_7,
    ubm.principal_os_dpd_eod_15,
    ubm.principal_os_dpd_eod_30,
    ubm.principal_os_dpd_eod_60,
    ubm.principal_os_dpd_eod_90,
    ubm.principal_os_dpd_eod_120,
    ubm.principal_os_dpd_eod_180,
    ubm.principal_os_dpd_eod_360,
    ubm.writeoff_principal_os,
    ubm.interest_os,

    -- === bill 数量 ===
    coalesce(ubbm.gross_bill_count, 0) as gross_bill_count,
    coalesce(ubbm.net_bill_count, 0) as net_bill_count,
    coalesce(ubbm.cleared_bill_count, 0) as cleared_bill_count,

    -- === 逾期指标 ===
    ubm.current_max_dpd_eod,
    ubm.ever_max_dpd,
    ubm.ever_max_dpd_eod,
    ubm.ever_max_dpd_24m_eod,
    ubm.ever_max_dpd_12m_eod,
    ubm.ever_max_dpd_6m_eod,
    ubm.ever_max_dpd_3m_eod,
    ubm.ever_max_dpd_1m_eod,
    ubm.ever_max_dpd_7d_eod,
    ubm.ever_max_dpd_1d_eod,

${comment}    -- === DPD EOD of the Latest Due Date within the Past 1/2/3 Months ===
${comment}    ubm.1m_latest_dpd_eod,
${comment}    ubm.2m_latest_dpd_eod,
${comment}    ubm.3m_latest_dpd_eod,

${comment}     -- === Total Outstanding Loan Amount of Latest DPD EOD (DPD_EOD >= 3/5/7/15/30 days) within the Past 3 Months ===
${comment}     uldam.3m_latest_dpd_eod_3d_amt,
${comment}     uldam.3m_latest_dpd_eod_5d_amt,    
${comment}     uldam.3m_latest_dpd_eod_7d_amt,    
${comment}     uldam.3m_latest_dpd_eod_15d_amt,    
${comment}     uldam.3m_latest_dpd_eod_30d_amt,    

    -- === 逾期指标 ===
    unbm.latest_floating_term_dpd_eod,
    unbm.latest_floating_term_dpd_4m_eod,

    -- === 放款指标 ===
    ubm.is_ever_disbursed,
    ubm.is_ever_disbursed_1d,
    ubm.is_ever_disbursed_30d,
    ubm.is_ever_disbursed_90d,
    ubm.is_ever_disbursed_180d,
    ubm.is_ever_disbursed_360d,
    ubm.max_disburse_month_cnt,

    -- === 放款金额指标 ===
    ubm.sum_principal_repayable_1d,
    ubm.sum_principal_repayable_30d,
    ubm.sum_principal_repayable_90d,
    ubm.sum_principal_repayable_180d,
    ubm.sum_principal_repayable_360d,
    ubm.sum_principal_repayable_td,
    ubm.max_principal_repayable_1d,
    ubm.max_principal_repayable_30d,
    ubm.max_principal_repayable_90d,
    ubm.max_principal_repayable_180d,
    ubm.max_principal_repayable_360d,
    ubm.max_principal_repayable_td,
    ubm.min_principal_repayable_1d,
    ubm.min_principal_repayable_30d,
    ubm.min_principal_repayable_90d,
    ubm.min_principal_repayable_180d,
    ubm.min_principal_repayable_360d,
    ubm.min_principal_repayable_td,

    -- === 放款笔数指标 ===
    ulbm.disbursed_loan_cnt_1d,
    ulbm.disbursed_loan_cnt_30d,
    ulbm.disbursed_loan_cnt_90d,
    ulbm.disbursed_loan_cnt_180d,
    ulbm.disbursed_loan_cnt_360d,

    coalesce(ubbm.is_billed, 0) as is_billed,
    ubm.is_ever_due,

    -- 2025-11-12新增
    ubm.latest_disburse_dpd_eod,
    ubm.principal_repaid_1d,
    ubm.principal_repaid_7d,
    ubm.principal_repaid_30d,
    ubm.principal_repaid_td,
    ubm.interest_repaid_1d,
    ubm.interest_repaid_7d,
    ubm.interest_repaid_30d,
    ubm.interest_repaid_td,
    ulbm.cleared_loan_cnt_1d,
    ulbm.cleared_loan_cnt_30d,
    ulbm.cleared_loan_cnt_90d,
    ulbm.cleared_loan_cnt_180d,
    ulbm.cleared_loan_cnt_360d,
    ulbm.cleared_loan_cnt_td,
    ubm.early_clear_principal_1d,
    ubm.early_clear_principal_30d,
    ubm.early_clear_principal_90d,
    ubm.early_clear_principal_180d,
    ubm.early_clear_principal_360d,
    ubm.early_clear_principal_td,
    ubm.early_clear_instalment_cnt_1d,
    ubm.early_clear_instalment_cnt_30d,
    ubm.early_clear_instalment_cnt_90d,
    ubm.early_clear_instalment_cnt_180d,
    ubm.early_clear_instalment_cnt_360d,
    ubm.early_clear_instalment_cnt_td,
    ubm.no_os_month_cnt,

${comment}     -- === Bill to Installment Eligibility flags and corresponding interest rate. === 
${comment}     rr.is_eligible_for_restructure_1m,
${comment}     rr.is_eligible_for_restructure_2m,
${comment}     rr.is_eligible_for_restructure_3m,
${comment}     rr.is_eligible_for_restructure_6m,
${comment}     rr.is_eligible_for_restructure_9m,
${comment}     rr.is_eligible_for_restructure_12m,
${comment}     rr.is_eligible_for_restructure_18m,
${comment}     rr.restructure_interest_rate_1m,
${comment}     rr.restructure_interest_rate_2m,
${comment}     rr.restructure_interest_rate_3m,
${comment}     rr.restructure_interest_rate_6m,
${comment}     rr.restructure_interest_rate_9m,
${comment}     rr.restructure_interest_rate_12m,
${comment}     rr.restructure_interest_rate_18m,

    um.grass_date as grass_date

FROM user_mapping um
LEFT JOIN user_behavior_metrics ubm 
ON um.credit_user_id = ubm.credit_user_id
and um.biz_type = ubm.biz_type
and um.grass_date = ubm.grass_date
${comment} left join restructure_rates rr
${comment} on um.credit_user_id = rr.credit_user_id
${comment} and um.grass_date = rr.grass_date
left join user_loan_behavior_metrics ulbm
ON um.credit_user_id = ulbm.credit_user_id
and um.biz_type = ulbm.biz_type
and um.grass_date = ulbm.grass_date
left join user_bill_behavior_metrics ubbm
ON um.credit_user_id = ubbm.credit_user_id
and um.biz_type = ubbm.biz_type
and um.grass_date = ubbm.grass_date
left join user_nxb_behavior_metrics unbm
ON um.credit_user_id = unbm.credit_user_id
and um.biz_type = unbm.biz_type
and um.grass_date = unbm.grass_date
${comment} left join user_latest_dpd_eod_amt_metrics uldam
${comment} on um.credit_user_id = uldam.credit_user_id
${comment} and um.biz_type = uldam.biz_type
${comment} and um.grass_date = uldam.grass_date
;