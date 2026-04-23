-- DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_id_user_dpd_df;
-- CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_id_user_dpd_df(
--   user_id                            STRING comment 'credit_user_id',
--   ever_max_dpd_spl_core              BIGINT comment '',
--   ever_max_dpd_spl_lite_core         BIGINT comment '',
--   ever_max_dpd_spl_normal_core       BIGINT comment '',
--   days_after_first_due_date_spl      BIGINT comment '',
--   ever_max_dpd_180d_spl              BIGINT comment '',
--   ever_max_dpd_360d_spl              BIGINT comment '',
--   days_after_first_due_date_cashloan BIGINT comment '',
--   ever_max_dpd_180d_cashloan         BIGINT comment '',
--   ever_max_dpd_360d_cashloan         BIGINT comment '',
--   ever_max_dpd_180d_user             BIGINT comment '',
--   ever_max_dpd_360d_user             BIGINT comment '',
--   ever_max_dpd_cashloan_core         BIGINT comment 'historical_max_dpd',
--   last_bill_dpd_cashloan_core        BIGINT comment 'last_bill_dpd',
--   ever_max_dpd_sellerloan_core       BIGINT comment 'historical_max_dpd',
--   last_bill_dpd_sellerloan_core      BIGINT comment 'last_bill_dpd',
--   ever_max_dpd_30d_sellerloan               BIGINT comment '',
--   ever_max_dpd_90d_sellerloan               BIGINT comment '',
--   ever_max_dpd_180d_sellerloan              BIGINT comment '',
--   ever_max_dpd_360d_sellerloan              BIGINT comment '',
--   ever_max_dpd_30d_spl               BIGINT comment '',
--   ever_max_dpd_90d_spl               BIGINT comment '',
--   ever_max_dpd_30d_cashloan               BIGINT comment '',
--   ever_max_dpd_90d_cashloan               BIGINT comment '',
--   ever_max_dpd_chp	bigint	,
--   ever_max_dpd_chp_180d	bigint	,
--   ever_max_dpd_chp_360d	bigint	,
--   days_after_first_due_date_cashloan_floating bigint,
--   latest_dpd_eod_cashloan bigint,
--   latest_dpd_eod_spl bigint,
--   latest_dpd_eod_chp bigint,
--   ever_max_dpd_30d_chp bigint,
--   ever_max_dpd_180d_chp bigint,
--   latest_dpd_tl bigint,
--   ever_max_dpd_30d_tl bigint,
--   ever_max_dpd_180d_tl bigint,
--   ever_max_dpd_30d_smetl    bigint COMMENT 'ever_max_dpd_30d_smetl'
--   ,ever_max_dpd_90d_smetl    bigint COMMENT 'ever_max_dpd_90d_smetl'
--   ,ever_max_dpd_180d_smetl  bigint COMMENT 'ever_max_dpd_180d_smetl'
--   ,ever_max_dpd_360d_smetl  bigint COMMENT 'ever_max_dpd_360d_smetl'
-- )
-- partitioned by(grass_date string comment 'YYYY-MM-dd')
-- stored as orc tblproperties ("orc.compress"="SNAPPY")
-- LOCATION '${HDFS_PATH}/risk_mart/dws/dws_risk_user_dpd_df/grass_region=ID';
-- MSCK REPAIR TABLE ${SCHEMA}.dws_risk_id_user_dpd_df;

alter table ${SCHEMA}.dws_risk_id_user_dpd_df add columns (
  ever_max_dpd_30d_smetl    bigint COMMENT 'ever_max_dpd_30d_smetl'
  ,ever_max_dpd_90d_smetl    bigint COMMENT 'ever_max_dpd_90d_smetl'
  ,ever_max_dpd_180d_smetl  bigint COMMENT 'ever_max_dpd_180d_smetl'
  ,ever_max_dpd_360d_smetl  bigint COMMENT 'ever_max_dpd_360d_smetl'
)