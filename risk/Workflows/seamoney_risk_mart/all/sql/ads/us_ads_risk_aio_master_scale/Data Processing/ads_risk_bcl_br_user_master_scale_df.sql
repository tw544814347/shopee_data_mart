--********************************************************************--
-- Author:              lisheng@shopee.com
-- Created Time:        2025-11-12
-- Table Name:          master_scale_user_df
-- Theme Domain:        Risk Mart Master Scale 用户层表（滚动窗口版本）
-- Description:         用户层级 Master Scale 表，用于标准化各市场的风险等级定义
--                      记录用户首笔放款、还款行为及逾期（DPD）表现，观察期为 3 个月
--                      滚动窗口机制：从初始范围（grass_date-4month~grass_date-3month）
--                      的首期还款日开始，每天生成一个观察窗口，直至 grass_date
-- Data Granularity:    user
-- Partition:           grass_date
-- Update:
-- 2026-03-24   chennuo 
--   - 新增 has_loan_txn_in_rolling_1m 字段，用于记录用户在滚动窗口1M内是否存在交易记录
--   - 新增 过滤条件：COALESCE(principal_repayable, 0) - COALESCE(principal_refund, 0) - COALESCE(principal_deduct, 0) > 0
--   - 新增 SPLX(biz_type = 7, MY 地区 biz_type = 16) 和 TL(biz_type = 11)
--********************************************************************--

DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_${product_name}_${region}_user_master_scale_df;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_${product_name}_${region}_user_master_scale_df (
    platform_user_id            STRING          COMMENT 'Platform user ID',
    credit_user_id              STRING          COMMENT 'Credit user ID',
    
    first_disbursement_time     STRING          COMMENT 'Earliest disbursement date within the current rolling window (rolling_start_date ~ rolling_start_date + 1 month), date precision only',
    rolling_start_date          STRING          COMMENT 'Rolling anchor date; part of the primary key; it marks the starting point of the update window.',
    first_instalment_due        STRING          COMMENT 'First instalment due date for the earliest loan inside the rolling window',
    has_loan_txn_in_rolling_1m  INT             COMMENT '1 if any loan_time falls in [rolling_start_date, rolling_start_date + 1 month]; 0 otherwise',

    is_dpdx                     INT             COMMENT 'is_dpdx  = grass_date - {first_instalment_due + 3M} +2D. If is_dpdx=2, then is_dpd1,2 are fully updated for this user',
    is_dpd1                     INT             COMMENT 'Flag for max(dpd_eod) >= 1 day within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd2                     INT             COMMENT 'Flag for max(dpd_eod) >= 2 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd3                     INT             COMMENT 'Flag for max(dpd_eod) >= 3 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd4                     INT             COMMENT 'Flag for max(dpd_eod) >= 4 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd5                     INT             COMMENT 'Flag for max(dpd_eod) >= 5 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd6                     INT             COMMENT 'Flag for max(dpd_eod) >= 6 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd7                     INT             COMMENT 'Flag for max(dpd_eod) >= 7 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd8                     INT             COMMENT 'Flag for max(dpd_eod) >= 8 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd9                     INT             COMMENT 'Flag for max(dpd_eod) >= 9 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd10                    INT             COMMENT 'Flag for max(dpd_eod) >= 10 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd11                    INT             COMMENT 'Flag for max(dpd_eod) >= 11 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd12                    INT             COMMENT 'Flag for max(dpd_eod) >= 12 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd13                    INT             COMMENT 'Flag for max(dpd_eod) >= 13 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd14                    INT             COMMENT 'Flag for max(dpd_eod) >= 14 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd15                    INT             COMMENT 'Flag for max(dpd_eod) >= 15 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd16                    INT             COMMENT 'Flag for max(dpd_eod) >= 16 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd17                    INT             COMMENT 'Flag for max(dpd_eod) >= 17 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd18                    INT             COMMENT 'Flag for max(dpd_eod) >= 18 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd19                    INT             COMMENT 'Flag for max(dpd_eod) >= 19 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd20                    INT             COMMENT 'Flag for max(dpd_eod) >= 20 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd21                    INT             COMMENT 'Flag for max(dpd_eod) >= 21 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd22                    INT             COMMENT 'Flag for max(dpd_eod) >= 22 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd23                    INT             COMMENT 'Flag for max(dpd_eod) >= 23 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd24                    INT             COMMENT 'Flag for max(dpd_eod) >= 24 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd25                    INT             COMMENT 'Flag for max(dpd_eod) >= 25 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd26                    INT             COMMENT 'Flag for max(dpd_eod) >= 26 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd27                    INT             COMMENT 'Flag for max(dpd_eod) >= 27 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd28                    INT             COMMENT 'Flag for max(dpd_eod) >= 28 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd29                    INT             COMMENT 'Flag for max(dpd_eod) >= 29 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd30                    INT             COMMENT 'Flag for max(dpd_eod) >= 30 days within the observation period for each user. If the condition is true, then 1 else 0.',
    is_dpd31                    INT             COMMENT 'Flag for max(dpd_eod) >= 31 days within the observation period for each user. If the condition is true, then 1 else 0.'
)
COMMENT 'risk mart summary table'
PARTITIONED BY (grass_date STRING COMMENT "YYYY-MM-DD")
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_mart/ads/ads_risk_product_reg_user_master_scale_df/region=${upper_region}/product=${product_name}'
;

MSCK REPAIR TABLE ${SCHEMA}.ads_risk_${product_name}_${region}_user_master_scale_df;


-- ====================================================================
-- Step 1: 生成统一的日期序列
-- ====================================================================
SET spark.sql.broadcastTimeout = 600;
CREATE OR REPLACE TEMPORARY VIEW date_series AS
SELECT 
    date_add(add_months(to_date('${grass_date}'), -8), pos) AS rolling_start_date
FROM (
    SELECT explode(
        sequence(
            0, 
            datediff(add_months(to_date('${grass_date}'), -5), add_months(to_date('${grass_date}'), -8))
        )
    ) AS pos
) t
;

-- ====================================================================
-- Step 2: 计算每个滚动窗口的观察基准信息
-- ====================================================================
CACHE TABLE user_obs_info
OPTIONS ('storageLevel' 'MEMORY_AND_DISK') AS
WITH loan_base AS (
    SELECT
        t1.platform_user_id,
        t1.credit_user_id,
        t1.loan_id,
        -- 原始放款时间（用于确定 rolling_start_date）
        IF(t2.original_disburse_time IS NOT NULL, t2.original_disburse_time, t1.disburse_time) AS disbursement_time,
        -- 当前 loan 的放款时间（用于 Step 3 匹配历史分区）
        t1.disburse_time AS current_disburse_time,
        t1.loan_time AS loan_time,
        IF(t2.original_first_instalment_due_time IS NOT NULL, t2.original_first_instalment_due_time, t1.first_instalment_due_time) AS first_instalment_due
    FROM (
        SELECT
            platform_user_id,
            credit_user_id,
            loan_id,
            disburse_time,
            loan_time,
            first_instalment_due_time,
            bnpl_coversion_source_loan_list,
            bnpl_conversion_clear_flag
        FROM credit_mart.dws_${product}_aio_${region}_loan_repayment_df
        WHERE grass_date = '${grass_date}'
          AND (bnpl_conversion_clear_flag IS NULL OR bnpl_conversion_clear_flag = 0)
          AND COALESCE(principal_repayable, 0) - COALESCE(principal_refund, 0) - COALESCE(principal_deduct, 0) > 0
${common} AND biz_type = ${biz_type}
    ) t1
    LEFT JOIN (
        SELECT
            credit_user_id,
            loan_id AS original_loan_id,
            disburse_time AS original_disburse_time,
            first_instalment_due_time AS original_first_instalment_due_time
        FROM credit_mart.dws_${product}_aio_${region}_loan_repayment_df
        WHERE grass_date = '${grass_date}'
          AND bnpl_conversion_clear_flag = 1
${common} AND biz_type = ${biz_type}
    ) t2
      ON t1.credit_user_id = t2.credit_user_id  AND t1.bnpl_coversion_source_loan_list[0] = t2.original_loan_id
),

rolling_loan_time_window AS (
    SELECT
        lb.credit_user_id,
        ds.rolling_start_date,
        1 AS has_loan_txn_in_rolling_1m
    FROM date_series ds
    INNER JOIN loan_base lb
      ON lb.loan_time IS NOT NULL
     AND lb.loan_time >= ds.rolling_start_date
     AND lb.loan_time <= ADD_MONTHS(ds.rolling_start_date, 1)
    GROUP BY
        lb.credit_user_id,
        ds.rolling_start_date
),

rolling_match AS (
    SELECT
        t2.credit_user_id,
        t1.rolling_start_date,
        MIN(
            NAMED_STRUCT(
                'disburse', t2.disbursement_time,
                'current_disburse', t2.current_disburse_time,
                'first_due', t2.first_instalment_due
            )
        ) AS min_row,
        MAX(t2.platform_user_id) AS platform_user_id
    FROM date_series t1
    INNER JOIN loan_base t2
      ON t2.disbursement_time >= t1.rolling_start_date
     AND t2.disbursement_time <= ADD_MONTHS(t1.rolling_start_date, 1)
    GROUP BY
        t2.credit_user_id,
        t1.rolling_start_date
)

SELECT  rm.platform_user_id,
        rm.credit_user_id,
        rm.rolling_start_date,
        rm.min_row.disburse          AS first_disbursement_time,
        rm.min_row.current_disburse  AS current_disburse_time,
        rm.min_row.first_due         AS first_instalment_due,
        COALESCE(ltw.has_loan_txn_in_rolling_1m, 0) AS has_loan_txn_in_rolling_1m,
        IF(date_add(add_months(rm.min_row.first_due, 3), 30) >= '${ds}', '${ds}', date_add(add_months(rm.min_row.first_due, 3), 30)) AS obs_end_date,
        LEAST(GREATEST(DATEDIFF('${ds}', ADD_MONTHS(rm.min_row.first_due, 3)) + 2, 0), 31) AS dpdx_val
FROM rolling_match rm
LEFT JOIN rolling_loan_time_window ltw
  ON rm.credit_user_id = ltw.credit_user_id
 AND rm.rolling_start_date = ltw.rolling_start_date
;

CREATE OR REPLACE TEMPORARY VIEW obs_end_date_list AS
SELECT DISTINCT obs_end_date
FROM user_obs_info
;

-- ====================================================================
-- Step 3: 计算每个用户在观察期内的逾期表现
-- ====================================================================
INSERT OVERWRITE TABLE ${SCHEMA}.ads_risk_${product_name}_${region}_user_master_scale_df PARTITION(grass_date)
SELECT 
    -- 用户标识
    t1.platform_user_id
    ,t1.credit_user_id
    
    -- 放款信息
    ,CAST(t1.first_disbursement_time AS STRING) AS first_disbursement_time
    ,CAST(t1.rolling_start_date AS STRING) AS rolling_start_date
    ,CAST(t1.first_instalment_due AS STRING) AS first_instalment_due
    ,t1.has_loan_txn_in_rolling_1m AS has_loan_txn_in_rolling_1m
    
    -- 逾期信息 - 各期标识
    ,t2.min_dpdx_val AS is_dpdx
    ,CASE WHEN 1 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 1 THEN 1 ELSE 0 END AS is_dpd1
    ,CASE WHEN 2 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 2 THEN 1 ELSE 0 END AS is_dpd2
    ,CASE WHEN 3 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 3 THEN 1 ELSE 0 END AS is_dpd3
    ,CASE WHEN 4 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 4 THEN 1 ELSE 0 END AS is_dpd4
    ,CASE WHEN 5 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 5 THEN 1 ELSE 0 END AS is_dpd5
    ,CASE WHEN 6 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 6 THEN 1 ELSE 0 END AS is_dpd6
    ,CASE WHEN 7 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 7 THEN 1 ELSE 0 END AS is_dpd7
    ,CASE WHEN 8 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 8 THEN 1 ELSE 0 END AS is_dpd8
    ,CASE WHEN 9 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 9 THEN 1 ELSE 0 END AS is_dpd9
    ,CASE WHEN 10 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 10 THEN 1 ELSE 0 END AS is_dpd10
    ,CASE WHEN 11 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 11 THEN 1 ELSE 0 END AS is_dpd11
    ,CASE WHEN 12 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 12 THEN 1 ELSE 0 END AS is_dpd12
    ,CASE WHEN 13 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 13 THEN 1 ELSE 0 END AS is_dpd13
    ,CASE WHEN 14 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 14 THEN 1 ELSE 0 END AS is_dpd14
    ,CASE WHEN 15 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 15 THEN 1 ELSE 0 END AS is_dpd15
    ,CASE WHEN 16 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 16 THEN 1 ELSE 0 END AS is_dpd16
    ,CASE WHEN 17 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 17 THEN 1 ELSE 0 END AS is_dpd17
    ,CASE WHEN 18 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 18 THEN 1 ELSE 0 END AS is_dpd18
    ,CASE WHEN 19 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 19 THEN 1 ELSE 0 END AS is_dpd19
    ,CASE WHEN 20 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 20 THEN 1 ELSE 0 END AS is_dpd20
    ,CASE WHEN 21 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 21 THEN 1 ELSE 0 END AS is_dpd21
    ,CASE WHEN 22 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 22 THEN 1 ELSE 0 END AS is_dpd22
    ,CASE WHEN 23 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 23 THEN 1 ELSE 0 END AS is_dpd23
    ,CASE WHEN 24 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 24 THEN 1 ELSE 0 END AS is_dpd24
    ,CASE WHEN 25 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 25 THEN 1 ELSE 0 END AS is_dpd25
    ,CASE WHEN 26 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 26 THEN 1 ELSE 0 END AS is_dpd26
    ,CASE WHEN 27 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 27 THEN 1 ELSE 0 END AS is_dpd27
    ,CASE WHEN 28 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 28 THEN 1 ELSE 0 END AS is_dpd28
    ,CASE WHEN 29 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 29 THEN 1 ELSE 0 END AS is_dpd29
    ,CASE WHEN 30 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 30 THEN 1 ELSE 0 END AS is_dpd30
    ,CASE WHEN 31 > t2.min_dpdx_val THEN NULL WHEN t2.max_dpd_eod >= 31 THEN 1 ELSE 0 END AS is_dpd31
    
    -- 分区字段
    ,'${grass_date}' AS grass_date
    
FROM user_obs_info AS t1
LEFT JOIN (
    SELECT 
        t3.credit_user_id
        ,t3.rolling_start_date
        ,MAX(t3.platform_user_id) AS platform_user_id
        ,MIN(t3.dpdx_val) AS min_dpdx_val
        ,MAX(COALESCE(t3.max_dpd_eod, 0)) AS max_dpd_eod
    FROM (
        SELECT 
            t7.platform_user_id
            ,t7.credit_user_id
            ,t7.original_disburse_time
            ,t7.grass_date
            ,t5.rolling_start_date
            ,t5.dpdx_val
            ,t7.max_dpd_eod
        FROM (
            -- t7: 对历史分区数据也做 BNPL 转换，获取原始放款时间
            SELECT 
                t4.platform_user_id,
                t4.credit_user_id,
                IF(t6.original_disburse_time IS NOT NULL, t6.original_disburse_time, t4.disburse_time) AS original_disburse_time,
                t4.grass_date,
                t4.max_dpd_eod
            FROM (
                SELECT 
                    platform_user_id,
                    credit_user_id,
                    disburse_time,
                    bnpl_coversion_source_loan_list,
                    max_dpd_eod,
                    grass_date
                FROM credit_mart.dws_${product}_aio_${region}_loan_repayment_df
                LEFT SEMI JOIN (
                    SELECT /*+ BROADCAST(t) */ obs_end_date
                    FROM obs_end_date_list t
                ) obs_dates
                ON grass_date = obs_dates.obs_end_date
                WHERE grass_date >= add_months('${ds}', -8)
                AND (bnpl_conversion_clear_flag IS NULL OR bnpl_conversion_clear_flag = 0)
                AND COALESCE(principal_repayable, 0) - COALESCE(principal_refund, 0) - COALESCE(principal_deduct, 0) > 0
${common}       AND biz_type = ${biz_type}
            ) t4
            LEFT JOIN (
                -- t6: 获取 BNPL 转换前的原始 loan 信息（从最新分区获取即可，disburse_time 不变）
                SELECT 
                    credit_user_id,
                    loan_id AS original_loan_id,
                    disburse_time AS original_disburse_time
                FROM credit_mart.dws_${product}_aio_${region}_loan_repayment_df
                WHERE grass_date = '${ds}'
                AND bnpl_conversion_clear_flag = 1
${common}       AND biz_type = ${biz_type}
            ) t6
            ON t4.credit_user_id = t6.credit_user_id 
            AND t4.bnpl_coversion_source_loan_list[0] = t6.original_loan_id
        ) t7
        INNER JOIN user_obs_info t5
            ON t7.credit_user_id = t5.credit_user_id
            AND t7.original_disburse_time >= t5.rolling_start_date
            AND t7.original_disburse_time <= add_months(t5.rolling_start_date, 1)
            AND t7.grass_date = t5.obs_end_date
    ) t3
    GROUP BY 
        t3.credit_user_id
        ,t3.rolling_start_date
) t2
    ON t1.credit_user_id = t2.credit_user_id
    AND t1.rolling_start_date = t2.rolling_start_date
WHERE t1.first_instalment_due IS NOT NULL
AND t2.min_dpdx_val IS NOT NULL
;
