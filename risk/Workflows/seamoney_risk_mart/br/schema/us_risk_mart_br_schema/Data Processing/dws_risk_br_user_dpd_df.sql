DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_br_user_dpd_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_br_user_dpd_df(
  user_id STRING,
  ever_max_dpd_cashloan_core BIGINT,
  last_bill_dpd_cashloan_core BIGINT,
  ever_max_dpd_sellerloan_core BIGINT,
  last_bill_dpd_sellerloan_core BIGINT,
  ever_max_dpd_spl_core BIGINT,
  last_bill_dpd_spl_core BIGINT,
  days_after_first_due_date_spl BIGINT,
  ever_max_dpd_180d_spl BIGINT,
  ever_max_dpd_360d_spl BIGINT,
  days_after_first_due_date_cashloan BIGINT,
  ever_max_dpd_180d_cashloan BIGINT,
  ever_max_dpd_360d_cashloan BIGINT,
  ever_max_dpd_180d_user BIGINT,
  ever_max_dpd_360d_user BIGINT,
  ever_max_dpd_30d_sellerloan               BIGINT comment '',
  ever_max_dpd_90d_sellerloan               BIGINT comment '',
  ever_max_dpd_180d_sellerloan              BIGINT comment '',
  ever_max_dpd_360d_sellerloan              BIGINT comment '',
  ever_max_dpd_30d_spl               BIGINT comment '',
  ever_max_dpd_90d_spl               BIGINT comment '',
  ever_max_dpd_30d_cashloan               BIGINT comment '',
  ever_max_dpd_90d_cashloan               BIGINT comment '',
  current_dpd_spl  BIGINT comment '',
  latest_dpd_spl BIGINT comment '', 
  latest_dpd_eod_cashloan BIGINT comment '',
  current_dpd_eod_bcl bigint comment ''
)
partitioned by(grass_date string comment 'YYYY-MM-dd')
comment 'Tag:risk summary table'
stored as orc tblproperties ("orc.compress"="SNAPPY")
LOCATION '${HDFS_PATH}/risk_mart/dws/dws_risk_user_dpd_df/grass_region=BR';
MSCK REPAIR TABLE ${SCHEMA}.dws_risk_br_user_dpd_df;

