--********************************************************************--
-- Author:              lisheng@shopee.com
-- Created Time:        2025-11-12
-- Table Name:          ads_risk_${region}_user_master_scale_df
-- Theme Domain:        Risk Mart Master Scale 用户层表（滚动窗口版本 - 合并产品）
-- Description:         用户层级 Master Scale 表，合并 SPL 和 BCL 两个产品的数据
--                      对于同一用户同一滚动窗口，is_dpd1~30 取两个产品的最大值
--                      记录用户首笔放款、还款行为及逾期（DPD）表现，观察期为 3 个月
--                      滚动窗口机制：从初始范围（grass_date-4month~grass_date-3month）
--                      的首期还款日开始，每天生成一个观察窗口，直至 grass_date
-- Data Granularity:    user
-- Partition:           grass_date
--********************************************************************--

drop table if exists ${SCHEMA}.ads_risk_${region}_user_master_scale_df;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_${region}_user_master_scale_df (
    platform_user_id            STRING          COMMENT 'Platform user ID; part of the composite primary key; maps 1:1 to credit_user_id',
    credit_user_id              STRING          COMMENT 'Credit user ID; part of the composite primary key; maps 1:1 to platform_user_id',
    
    first_disbursement_time     STRING          COMMENT 'Earliest disbursement date within the current rolling window (rolling_start_date + 30 days), date precision only',
    rolling_start_date          STRING          COMMENT 'Rolling anchor date; part of the primary key; generated daily from the earliest first_instalment_due in the initial range through grass_date',
    first_instalment_due        STRING          COMMENT 'First instalment due date for the earliest loan inside the rolling window',
    
    is_dpd1                     INT             COMMENT 'Flag for DPD >= 1 day within the observation period (max of spl and bcl)',
    is_dpd2                     INT             COMMENT 'Flag for DPD >= 2 days within the observation period (max of spl and bcl)',
    is_dpd3                     INT             COMMENT 'Flag for DPD >= 3 days within the observation period (max of spl and bcl)',
    is_dpd4                     INT             COMMENT 'Flag for DPD >= 4 days within the observation period (max of spl and bcl)',
    is_dpd5                     INT             COMMENT 'Flag for DPD >= 5 days within the observation period (max of spl and bcl)',
    is_dpd6                     INT             COMMENT 'Flag for DPD >= 6 days within the observation period (max of spl and bcl)',
    is_dpd7                     INT             COMMENT 'Flag for DPD >= 7 days within the observation period (max of spl and bcl)',
    is_dpd8                     INT             COMMENT 'Flag for DPD >= 8 days within the observation period (max of spl and bcl)',
    is_dpd9                     INT             COMMENT 'Flag for DPD >= 9 days within the observation period (max of spl and bcl)',
    is_dpd10                    INT             COMMENT 'Flag for DPD >= 10 days within the observation period (max of spl and bcl)',
    is_dpd11                    INT             COMMENT 'Flag for DPD >= 11 days within the observation period (max of spl and bcl)',
    is_dpd12                    INT             COMMENT 'Flag for DPD >= 12 days within the observation period (max of spl and bcl)',
    is_dpd13                    INT             COMMENT 'Flag for DPD >= 13 days within the observation period (max of spl and bcl)',
    is_dpd14                    INT             COMMENT 'Flag for DPD >= 14 days within the observation period (max of spl and bcl)',
    is_dpd15                    INT             COMMENT 'Flag for DPD >= 15 days within the observation period (max of spl and bcl)',
    is_dpd16                    INT             COMMENT 'Flag for DPD >= 16 days within the observation period (max of spl and bcl)',
    is_dpd17                    INT             COMMENT 'Flag for DPD >= 17 days within the observation period (max of spl and bcl)',
    is_dpd18                    INT             COMMENT 'Flag for DPD >= 18 days within the observation period (max of spl and bcl)',
    is_dpd19                    INT             COMMENT 'Flag for DPD >= 19 days within the observation period (max of spl and bcl)',
    is_dpd20                    INT             COMMENT 'Flag for DPD >= 20 days within the observation period (max of spl and bcl)',
    is_dpd21                    INT             COMMENT 'Flag for DPD >= 21 days within the observation period (max of spl and bcl)',
    is_dpd22                    INT             COMMENT 'Flag for DPD >= 22 days within the observation period (max of spl and bcl)',
    is_dpd23                    INT             COMMENT 'Flag for DPD >= 23 days within the observation period (max of spl and bcl)',
    is_dpd24                    INT             COMMENT 'Flag for DPD >= 24 days within the observation period (max of spl and bcl)',
    is_dpd25                    INT             COMMENT 'Flag for DPD >= 25 days within the observation period (max of spl and bcl)',
    is_dpd26                    INT             COMMENT 'Flag for DPD >= 26 days within the observation period (max of spl and bcl)',
    is_dpd27                    INT             COMMENT 'Flag for DPD >= 27 days within the observation period (max of spl and bcl)',
    is_dpd28                    INT             COMMENT 'Flag for DPD >= 28 days within the observation period (max of spl and bcl)',
    is_dpd29                    INT             COMMENT 'Flag for DPD >= 29 days within the observation period (max of spl and bcl)',
    is_dpd30                    INT             COMMENT 'Flag for DPD >= 30 days within the observation period (max of spl and bcl)'
)
COMMENT 'risk mart summary table'
PARTITIONED BY (grass_date STRING COMMENT "YYYY-MM-DD")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_mart/ads/ads_risk_reg_user_master_scale_df/region=${upper_region}'
;

-- ====================================================================
-- Step 1: 生成统一的日期序列（从 grass_date-3month 滚动到 grass_date）
-- ====================================================================
CREATE OR REPLACE TEMPORARY VIEW date_series AS
SELECT 
    date_add(add_months(to_date('${grass_date}'), -3), pos) AS rolling_start_date
FROM (
    SELECT explode(
        sequence(
            0, 
            datediff('${grass_date}', add_months(to_date('${grass_date}'), -3))
        )
    ) AS pos
) t
;


-- ====================================================================
-- Step 2: 合并 SPL 和 BCL 的贷款数据 （MY/TH 地区 多合并 TL 的贷款数据）
-- ====================================================================
CREATE OR REPLACE TEMPORARY VIEW merged_loan_data AS
SELECT 
    platform_user_id,
    credit_user_id,
    loan_id,
    disburse_time,
    first_instalment_due_time,
    dpd_eod,
    grass_date,
    'spl' AS product
FROM credit_mart.dws_spl_${region}_loan_repayment_df
WHERE grass_date = '${grass_date}'

UNION ALL

SELECT 
    platform_user_id,
    credit_user_id,
    loan_id,
    disburse_time,
    first_instalment_due_time,
    dpd_eod,
    grass_date,
    'bcl' AS product
FROM credit_mart.dws_bcl_${region}_loan_repayment_df
WHERE grass_date = '${grass_date}'
;


-- ====================================================================
-- Step 3: 计算每个滚动窗口的观察基准信息（合并两个产品）
-- ====================================================================
-- 说明：找到每个窗口内最早放款的 loan（跨 SPL 和 BCL）
CREATE OR REPLACE TEMPORARY VIEW user_obs_info AS
SELECT 
    platform_user_id
    ,credit_user_id
    ,rolling_start_date
    ,first_disbursement_time
    ,first_instalment_due
FROM (
    SELECT 
        b.platform_user_id
        ,b.credit_user_id
        ,a.rolling_start_date
        ,TO_DATE(b.disburse_time) AS first_disbursement_time
        ,TO_DATE(b.first_instalment_due_time) AS first_instalment_due
        ,ROW_NUMBER() OVER (
            PARTITION BY b.credit_user_id, a.rolling_start_date 
            ORDER BY b.disburse_time ASC, b.loan_id ASC
        ) AS rn
    FROM date_series a, merged_loan_data b
    WHERE b.disburse_time >= a.rolling_start_date 
    AND b.disburse_time <= date_add(a.rolling_start_date, 30)
) t
WHERE rn = 1
;


-- ====================================================================
-- Step 4: 计算每个用户在观察期内的逾期表现（合并两个产品，取最大值）
-- ====================================================================
-- 说明：is_dpdN 表示用户是否逾期 >= N 天（SPL 和 BCL 取最大值）
CREATE OR REPLACE TEMPORARY VIEW user_dpd_by_period AS
SELECT 
    MAX(a.platform_user_id) AS platform_user_id
    ,a.credit_user_id
    ,b.rolling_start_date
    
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 1 THEN 1 ELSE 0 END AS is_dpd1
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 2 THEN 1 ELSE 0 END AS is_dpd2
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 3 THEN 1 ELSE 0 END AS is_dpd3
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 4 THEN 1 ELSE 0 END AS is_dpd4
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 5 THEN 1 ELSE 0 END AS is_dpd5
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 6 THEN 1 ELSE 0 END AS is_dpd6
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 7 THEN 1 ELSE 0 END AS is_dpd7
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 8 THEN 1 ELSE 0 END AS is_dpd8
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 9 THEN 1 ELSE 0 END AS is_dpd9
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 10 THEN 1 ELSE 0 END AS is_dpd10
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 11 THEN 1 ELSE 0 END AS is_dpd11
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 12 THEN 1 ELSE 0 END AS is_dpd12
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 13 THEN 1 ELSE 0 END AS is_dpd13
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 14 THEN 1 ELSE 0 END AS is_dpd14
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 15 THEN 1 ELSE 0 END AS is_dpd15
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 16 THEN 1 ELSE 0 END AS is_dpd16
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 17 THEN 1 ELSE 0 END AS is_dpd17
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 18 THEN 1 ELSE 0 END AS is_dpd18
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 19 THEN 1 ELSE 0 END AS is_dpd19
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 20 THEN 1 ELSE 0 END AS is_dpd20
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 21 THEN 1 ELSE 0 END AS is_dpd21
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 22 THEN 1 ELSE 0 END AS is_dpd22
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 23 THEN 1 ELSE 0 END AS is_dpd23
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 24 THEN 1 ELSE 0 END AS is_dpd24
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 25 THEN 1 ELSE 0 END AS is_dpd25
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 26 THEN 1 ELSE 0 END AS is_dpd26
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 27 THEN 1 ELSE 0 END AS is_dpd27
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 28 THEN 1 ELSE 0 END AS is_dpd28
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 29 THEN 1 ELSE 0 END AS is_dpd29
    ,CASE WHEN COALESCE(MAX(a.dpd_eod), 0) >= 30 THEN 1 ELSE 0 END AS is_dpd30
FROM merged_loan_data a
INNER JOIN user_obs_info b
    ON a.platform_user_id = b.platform_user_id
    AND a.credit_user_id = b.credit_user_id
WHERE a.disburse_time >= b.rolling_start_date
AND a.disburse_time <= date_add(b.rolling_start_date, 30)
AND a.grass_date = '${grass_date}'
GROUP BY 
    a.credit_user_id
    ,b.rolling_start_date
;


-- ====================================================================
-- Step 5: 最终结果合并（滚动窗口版本 - 合并产品）
-- ====================================================================
INSERT OVERWRITE TABLE ${SCHEMA}.ads_risk_${region}_user_master_scale_df PARTITION(grass_date)
SELECT 
    -- 用户标识
    a.platform_user_id
    ,a.credit_user_id
    
    -- 放款信息
    ,a.first_disbursement_time
    ,a.rolling_start_date
    ,a.first_instalment_due
    
    -- 逾期信息 - 各期标识（已经通过 MAX 聚合取了两个产品的最大值）
    ,COALESCE(b.is_dpd1, 0)  AS is_dpd1
    ,COALESCE(b.is_dpd2, 0)  AS is_dpd2
    ,COALESCE(b.is_dpd3, 0)  AS is_dpd3
    ,COALESCE(b.is_dpd4, 0)  AS is_dpd4
    ,COALESCE(b.is_dpd5, 0)  AS is_dpd5
    ,COALESCE(b.is_dpd6, 0)  AS is_dpd6
    ,COALESCE(b.is_dpd7, 0)  AS is_dpd7
    ,COALESCE(b.is_dpd8, 0)  AS is_dpd8
    ,COALESCE(b.is_dpd9, 0)  AS is_dpd9
    ,COALESCE(b.is_dpd10, 0) AS is_dpd10
    ,COALESCE(b.is_dpd11, 0) AS is_dpd11
    ,COALESCE(b.is_dpd12, 0) AS is_dpd12
    ,COALESCE(b.is_dpd13, 0) AS is_dpd13
    ,COALESCE(b.is_dpd14, 0) AS is_dpd14
    ,COALESCE(b.is_dpd15, 0) AS is_dpd15
    ,COALESCE(b.is_dpd16, 0) AS is_dpd16
    ,COALESCE(b.is_dpd17, 0) AS is_dpd17
    ,COALESCE(b.is_dpd18, 0) AS is_dpd18
    ,COALESCE(b.is_dpd19, 0) AS is_dpd19
    ,COALESCE(b.is_dpd20, 0) AS is_dpd20
    ,COALESCE(b.is_dpd21, 0) AS is_dpd21
    ,COALESCE(b.is_dpd22, 0) AS is_dpd22
    ,COALESCE(b.is_dpd23, 0) AS is_dpd23
    ,COALESCE(b.is_dpd24, 0) AS is_dpd24
    ,COALESCE(b.is_dpd25, 0) AS is_dpd25
    ,COALESCE(b.is_dpd26, 0) AS is_dpd26
    ,COALESCE(b.is_dpd27, 0) AS is_dpd27
    ,COALESCE(b.is_dpd28, 0) AS is_dpd28
    ,COALESCE(b.is_dpd29, 0) AS is_dpd29
    ,COALESCE(b.is_dpd30, 0) AS is_dpd30
    
    -- 分区字段
    ,'${grass_date}' AS grass_date
    
FROM user_obs_info a
LEFT JOIN user_dpd_by_period b 
    ON a.credit_user_id = b.credit_user_id
    AND a.rolling_start_date = b.rolling_start_date
WHERE a.first_instalment_due IS NOT NULL
;

MSCK REPAIR TABLE ${SCHEMA}.ads_risk_${region}_user_master_scale_df;

