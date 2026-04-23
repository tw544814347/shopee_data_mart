--********************************************************************--
-- Author:              lisheng@shopee.com
-- Created Time:        2025-09-23
-- Theme Domain：       risk-feature
-- Description:         PH地区DPD风险特征
-- 变更历史：
--  v1 
--  v2 lihseng@shopee.com, 新增特征 jira: https://jira.shopee.io/browse/SPFDT-55607
--********************************************************************--
-- DDL
-- DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_ph_user_dpd_df;
-- CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_ph_user_dpd_df(
--     user_id                             STRING,
--     ever_max_dpd_cashloan_core          BIGINT,
--     ever_max_dpd_sellerloan_core        BIGINT,
--     ever_max_dpd_spl_core               BIGINT,
--     last_bill_dpd_spl_core              BIGINT,
--     days_after_first_due_date_spl       BIGINT,
--     ever_max_dpd_180d_spl               BIGINT,
--     ever_max_dpd_360d_spl               BIGINT,
--     days_after_first_due_date_cashloan  BIGINT,
--     ever_max_dpd_180d_cashloan          BIGINT,
--     ever_max_dpd_360d_cashloan          BIGINT,
--     ever_max_dpd_180d_user              BIGINT,
--     ever_max_dpd_360d_user              BIGINT,
--     repaid_bills_num_cashloan           BIGINT,
--     latest_dpd_cashloan                 BIGINT,
--     ever_max_dpd_30d_sellerloan         BIGINT COMMENT '',
--     ever_max_dpd_90d_sellerloan         BIGINT COMMENT '',
--     ever_max_dpd_180d_sellerloan        BIGINT COMMENT '',
--     ever_max_dpd_360d_sellerloan        BIGINT COMMENT '',
--     ever_max_dpd_30d_spl                BIGINT COMMENT '',
--     ever_max_dpd_90d_spl                BIGINT COMMENT '',
--     ever_max_dpd_30d_cashloan           BIGINT COMMENT '',
--     ever_max_dpd_90d_cashloan           BIGINT COMMENT '',
--     ever_max_dpd_180d_bclx              BIGINT COMMENT 'BCLX产品180天最大逾期天数',
--     ever_max_dpd_360d_bclx              BIGINT COMMENT 'BCLX产品360天最大逾期天数',
--     latest_dpd_eod_chp                  BIGINT,
--     current_dpd_spl                     BIGINT,
--     latest_dpd_eod_spl                  BIGINT,
--     latest_dpd_eod_bcl                  BIGINT,
--     ever_max_dpd_chp                    BIGINT,
--     current_dpd_eod_bcl                 BIGINT,
--     current_dpd_eod_bclx                BIGINT COMMENT 'BCLX的当前逾期天数',
--     current_dpd_eod_chp                 BIGINT,
--     current_dpd_eod_user                BIGINT COMMENT '用户维度跨产品当前最大逾期天数',
--     latest_dpd_eod_bclx                 BIGINT COMMENT 'BCLX的最近120天最大逾期天数',
--     latest_dpd_eod_user                 BIGINT COMMENT '用户维度跨产品最近120天最大逾期天数',
--     ever_max_dpd_30d_corploan           BIGINT, 
--     ever_max_dpd_90d_corploan           BIGINT, 
--     ever_max_dpd_180d_corploan          BIGINT
-- )
-- PARTITIONED BY(grass_date STRING COMMENT 'YYYY-MM-dd')
-- STORED AS ORC TBLPROPERTIES ("orc.compress"="SNAPPY")
-- LOCATION '${HDFS_PATH}/risk_mart/dws/dws_risk_user_dpd_df/grass_region=PH';
-- MSCK REPAIR TABLE ${SCHEMA}.dws_risk_ph_user_dpd_df;




-- DML
INSERT OVERWRITE TABLE ${SCHEMA}.dws_risk_ph_user_dpd_df PARTITION (grass_date)
SELECT
    t1.user_id
    ,COALESCE(t2.historical_max_dpd_eod,-9999)                      AS ever_max_dpd_cashloan_core
    ,COALESCE(t3.historical_max_dpd_eod,-9999)                      AS ever_max_dpd_sellerloan_core
    ,COALESCE(t4.historical_max_dpd_eod,-9999)                      AS ever_max_dpd_spl_core
    ,COALESCE(t4.last_bill_dpd,-9999)                               AS last_bill_dpd_spl_core
    ,COALESCE(t4.days_after_first_due_date, -9999)                  AS days_after_first_due_date_spl
    ,COALESCE(t4.ever_max_dpd_180d, -9999)                          AS ever_max_dpd_180d_spl
    ,COALESCE(t4.ever_max_dpd_360d, -9999)                          AS ever_max_dpd_360d_spl
    ,COALESCE(t2.days_after_first_due_date, -9999)                  AS days_after_first_due_date_cashloan
    ,COALESCE(t2.ever_max_dpd_180d, -9999)                          AS ever_max_dpd_180d_cashloan
    ,COALESCE(t2.ever_max_dpd_360d, -9999)                          AS ever_max_dpd_360d_cashloan
    ,GREATEST(t2.ever_max_dpd_180d,t4.ever_max_dpd_180d,t6.ever_max_dpd_chp_180d,COALESCE(t2.ever_max_dpd_180d_bclx,-9999)) AS ever_max_dpd_180d_user  --new 
    ,GREATEST(t2.ever_max_dpd_360d,t4.ever_max_dpd_360d,t6.ever_max_dpd_chp_360d,COALESCE(t2.ever_max_dpd_360d_bclx,-9999)) AS ever_max_dpd_360d_user  --new 
    ,COALESCE(t5.repaid_bills_num, -9999)                           AS repaid_bills_num_cashloan
    ,COALESCE(t5.lastest_bill_max_dpd_120d, -9999)                  AS latest_dpd_cashloan
    ,COALESCE(t3.ever_max_dpd_30d ,-9999)                           AS ever_max_dpd_30d_sellerloan
    ,COALESCE(t3.ever_max_dpd_90d ,-9999)                           AS ever_max_dpd_90d_sellerloan
    ,COALESCE(t3.ever_max_dpd_180d,-9999)                           AS ever_max_dpd_180d_sellerloan
    ,COALESCE(t3.ever_max_dpd_360d,-9999)                           AS ever_max_dpd_360d_sellerloan
    ,COALESCE(t4.ever_max_dpd_30d ,-9999)                           AS ever_max_dpd_30d_spl
    ,COALESCE(t4.ever_max_dpd_90d ,-9999)                           AS ever_max_dpd_90d_spl
    ,COALESCE(t2.ever_max_dpd_30d ,-9999)                           AS ever_max_dpd_30d_cashloan
    ,COALESCE(t2.ever_max_dpd_90d ,-9999)                           AS ever_max_dpd_90d_cashloan
    ,COALESCE(t2.ever_max_dpd_180d_bclx, -9999)                     AS ever_max_dpd_180d_bclx  --new
    ,COALESCE(t2.ever_max_dpd_360d_bclx, -9999)                     AS ever_max_dpd_360d_bclx  --new
    ,COALESCE(t6.lastest_max_dpd_eod_120d_chp ,-9999)               AS latest_dpd_eod_chp
    ,COALESCE(t4.current_dpd_eod ,-9999)                            AS current_dpd_spl
    ,COALESCE(t6.lastest_max_dpd_eod_120d_spl ,-9999)               AS latest_dpd_eod_spl
    ,COALESCE(t7.lastest_max_dpd_eod_120d ,-9999)                   AS latest_dpd_eod_bcl
    ,COALESCE(t6.ever_max_dpd_chp ,-9999)                           AS ever_max_dpd_chp
    ,t2.current_dpd_eod_bcl
    ,COALESCE(t2.current_dpd_eod_bclx, -9999)                       AS current_dpd_eod_bclx  --new 
    ,t6.current_dpd_eod_chp
    ,COALESCE(
        GREATEST(
            COALESCE(t2.current_dpd_eod_bclx, -9999),  
            COALESCE(t4.current_dpd_eod, -9999),
            COALESCE(t2.current_dpd_eod_bcl, -9999),
            COALESCE(t6.current_dpd_eod_chp, -9999)
        ), 
        -9999
    )                                                               AS current_dpd_eod_user  --new
    ,COALESCE(t7.lastest_max_dpd_eod_120d_bclx, -9999)              AS latest_dpd_eod_bclx   --new
    ,GREATEST(
        COALESCE(t6.lastest_max_dpd_eod_120d_spl, -9999),    -- latest_dpd_eod_spl
        COALESCE(t6.lastest_max_dpd_eod_120d_chp, -9999),    -- latest_dpd_eod_chp  
        COALESCE(t7.lastest_max_dpd_eod_120d, -9999),        -- latest_dpd_eod_bcl
        COALESCE(t7.lastest_max_dpd_eod_120d_bclx, -9999)    -- latest_dpd_eod_bclx
    )                                                               AS latest_dpd_eod_user  --new
    ,COALESCE(t8.ever_max_dpd_30d_corploan, -9999)                  AS ever_max_dpd_30d_corploan
    ,COALESCE(t8.ever_max_dpd_90d_corploan, -9999)                  AS ever_max_dpd_90d_corploan
    ,COALESCE(t8.ever_max_dpd_180d_corploan, -9999)                  AS ever_max_dpd_180d_corploan
    ,t1.grass_date
FROM
(
    SELECT
        credit_user_id AS user_id 
        ,grass_date
    FROM credit_uc.dws_aio_ph_uc_user_df
    WHERE grass_date = '${grass_date}'
        AND credit_user_id <> ''
    GROUP BY credit_user_id, grass_date
) t1
LEFT JOIN
(
    SELECT
        credit_user_id AS user_id
        ,historical_max_dpd_eod
        ,days_after_first_due_date
        ,ever_max_dpd_30d
        ,ever_max_dpd_90d
        ,ever_max_dpd_180d
        ,ever_max_dpd_360d
        ,current_dpd_eod AS current_dpd_eod_bcl
        ,-9999 AS current_dpd_eod_bclx  --new 等上游加上biz_type后更改为CASE WHEN biz_type=11 THEN current_dpd_eod ELSE -9999 END
        ,-9999 AS ever_max_dpd_180d_bclx  --new 等上游加上biz_type后更改为CASE WHEN biz_type=11 THEN ever_max_dpd_180d ELSE -9999 END
        ,-9999 AS ever_max_dpd_360d_bclx  --new 等上游加上biz_type后更改为CASE WHEN biz_type=11 THEN ever_max_dpd_360d ELSE -9999 END
        ,grass_date
    FROM credit_mart.dws_bcl_ph_user_df
    WHERE grass_date BETWEEN '${begin_ds}' AND '${ds}'
) t2
    ON t1.user_id = t2.user_id
        AND t1.grass_date = t2.grass_date
LEFT JOIN
(
    SELECT
        credit_user_id AS user_id
        ,ever_max_dpd_30d
        ,ever_max_dpd_90d
        ,ever_max_dpd_180d
        ,ever_max_dpd_360d
        ,historical_max_dpd_eod
        ,grass_date
    FROM credit_mart.dws_scl_ph_user_df
    WHERE grass_date BETWEEN '${begin_ds}' AND '${ds}'
) t3
    ON t1.user_id = t3.user_id
        AND t1.grass_date = t3.grass_date
LEFT JOIN
(
    SELECT DISTINCT
        credit_user_id
        ,historical_max_dpd_eod
        ,last_bill_dpd
        ,days_after_first_due_date
        ,ever_max_dpd_30d
        ,ever_max_dpd_90d
        ,ever_max_dpd_180d
        ,ever_max_dpd_360d
        ,current_dpd_eod
        ,grass_date
    FROM credit_mart.dws_spl_ph_user_df
    WHERE grass_date BETWEEN '${begin_ds}' AND '${ds}'
) t4
    ON t1.user_id = t4.credit_user_id
        AND t1.grass_date = t4.grass_date
LEFT JOIN 
(
    SELECT 
        credit_user_id
        ,repaid_bills_num
        ,lastest_bill_max_dpd_120d
        ,grass_date
    FROM credit_mart.wide_bcl_ph_behavior_user_df
    WHERE grass_date BETWEEN '${begin_ds}' AND '${ds}'
) t5 
    ON t1.user_id = t5.credit_user_id
        AND t1.grass_date = t5.grass_date
LEFT JOIN 
(
    SELECT
        credit_user_id
        ,lastest_max_dpd_eod_120d_chp
        ,lastest_max_dpd_eod_120d_spl
        ,ever_max_dpd_chp
        ,current_dpd_eod_spl
        ,current_dpd_eod_chp
        ,ever_max_dpd_chp_180d
        ,ever_max_dpd_chp_360d
    FROM credit_mart.dws_spl_ph_user_risk_df
    WHERE grass_date BETWEEN '${begin_ds}' AND '${ds}'
) t6
    ON t1.user_id = t6.credit_user_id
LEFT JOIN 
(
    SELECT
        credit_user_id
        ,lastest_max_dpd_eod_120d
        ,-9999 AS lastest_max_dpd_eod_120d_bclx  --new 等上游加上biz_type后更改为CASE WHEN biz_type=11 THEN lastest_max_dpd_eod_120d ELSE -9999 END
    FROM credit_mart.dws_bcl_ph_user_risk_df
    WHERE grass_date BETWEEN '${begin_ds}' AND '${ds}'
) t7
    ON t1.user_id = t7.credit_user_id
LEFT JOIN 
(
    SELECT 
        credit_user_id
        ,ever_max_dpd_30d as ever_max_dpd_30d_corploan
        ,ever_max_dpd_90d as ever_max_dpd_90d_corploan
        ,ever_max_dpd_180d as ever_max_dpd_180d_corploan
    FROM credit_mart.dws_cpl_ph_user_df
    WHERE grass_date BETWEEN '${begin_ds}' AND '${ds}'
)t8
    ON t1.user_id = t8.credit_user_id
;
MSCK REPAIR TABLE risk.dws_risk_ph_user_dpd_df;
