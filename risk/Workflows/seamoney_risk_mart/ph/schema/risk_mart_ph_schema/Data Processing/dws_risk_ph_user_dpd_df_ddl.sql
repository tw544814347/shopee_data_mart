--********************************************************************--
-- Author:              lisheng@shopee.com
-- Created Time:        2025-09-23
-- Theme Domain：       risk-feature
-- Description:         PH地区DPD风险特征表结构定义
-- 变更历史：
--  v1 原始版本
--  v2 lisheng@shopee.com, 新增特征 jira: https://jira.shopee.io/browse/SPFDT-55607
--********************************************************************--

-- DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_ph_user_dpd_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_ph_user_dpd_df(
    user_id                             STRING,
    ever_max_dpd_cashloan_core          BIGINT,
    ever_max_dpd_sellerloan_core        BIGINT,
    ever_max_dpd_spl_core               BIGINT,
    last_bill_dpd_spl_core              BIGINT,
    days_after_first_due_date_spl       BIGINT,
    ever_max_dpd_180d_spl               BIGINT,
    ever_max_dpd_360d_spl               BIGINT,
    days_after_first_due_date_cashloan  BIGINT,
    ever_max_dpd_180d_cashloan          BIGINT,
    ever_max_dpd_360d_cashloan          BIGINT,
    ever_max_dpd_180d_user              BIGINT,
    ever_max_dpd_360d_user              BIGINT,
    repaid_bills_num_cashloan           BIGINT,
    latest_dpd_cashloan                 BIGINT,
    ever_max_dpd_30d_sellerloan         BIGINT COMMENT '',
    ever_max_dpd_90d_sellerloan         BIGINT COMMENT '',
    ever_max_dpd_180d_sellerloan        BIGINT COMMENT '',
    ever_max_dpd_360d_sellerloan        BIGINT COMMENT '',
    ever_max_dpd_30d_spl                BIGINT COMMENT '',
    ever_max_dpd_90d_spl                BIGINT COMMENT '',
    ever_max_dpd_30d_cashloan           BIGINT COMMENT '',
    ever_max_dpd_90d_cashloan           BIGINT COMMENT '',
    ever_max_dpd_180d_bclx              BIGINT COMMENT 'BCLX产品180天最大逾期天数',
    ever_max_dpd_360d_bclx              BIGINT COMMENT 'BCLX产品360天最大逾期天数',
    latest_dpd_eod_chp                  BIGINT,
    current_dpd_spl                     BIGINT,
    latest_dpd_eod_spl                  BIGINT,
    latest_dpd_eod_bcl                  BIGINT,
    ever_max_dpd_chp                    BIGINT,
    current_dpd_eod_bcl                 BIGINT,
    current_dpd_eod_bclx                BIGINT COMMENT 'BCLX的当前逾期天数',
    current_dpd_eod_chp                 BIGINT,
    current_dpd_eod_user                BIGINT COMMENT '用户维度跨产品当前最大逾期天数',
    latest_dpd_eod_bclx                 BIGINT COMMENT 'BCLX的最近120天最大逾期天数',
    latest_dpd_eod_user                 BIGINT COMMENT '用户维度跨产品最近120天最大逾期天数',
    ever_max_dpd_30d_corploan           BIGINT, 
    ever_max_dpd_90d_corploan           BIGINT, 
    ever_max_dpd_180d_corploan          BIGINT
)
PARTITIONED BY(grass_date STRING COMMENT 'YYYY-MM-dd')
STORED AS ORC TBLPROPERTIES ("orc.compress"="SNAPPY")
LOCATION '${HDFS_PATH}/risk_mart/dws/dws_risk_user_dpd_df/grass_region=PH';
MSCK REPAIR TABLE ${SCHEMA}.dws_risk_ph_user_dpd_df;
