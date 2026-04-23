drop table if exists ${SCHEMA}.dws_risk_my_user_dpd_df;
create external table if not exists ${SCHEMA}.dws_risk_my_user_dpd_df (
    credit_user_id string comment 'credit_user_id'
    ,days_after_first_due_date_spl bigint comment 'days_after_first_due_date_spl, default -9999'
    ,ever_max_dpd_180d_spl bigint comment 'ever_max_dpd_180d_spl, default -9999'
    ,ever_max_dpd_360d_spl bigint comment 'ever_max_dpd_360d_spl, default -9999'
    ,days_after_first_due_date_cashloan bigint comment 'days_after_first_due_date_cashloan, default -9999'
    ,ever_max_dpd_180d_cashloan bigint comment 'ever_max_dpd_180d_cashloan, default -9999'
    ,ever_max_dpd_360d_cashloan bigint comment 'ever_max_dpd_360d_cashloan, default -9999'
    ,ever_max_dpd_180d_user bigint comment 'max(ever_max_dpd_180d_spl,ever_max_dpd_180d_cashloan), default -9999'
    ,ever_max_dpd_360d_user bigint comment 'max(ever_max_dpd_360d_spl,ever_max_dpd_360d_cashloan), default -9999'
    ,ever_max_dpd_cashloan_core bigint comment 'historical_max_dpd, default -9999'
    ,last_bill_dpd_cashloan_core bigint comment 'last_bill_dpd, default -9999'
    ,ever_max_dpd_sellerloan_core bigint comment 'historical_max_dpd, default -9999'
    ,last_bill_dpd_sellerloan_core bigint comment 'last_bill_dpd, default -9999'
    ,repaid_bills_num_cashloan bigint comment 'repaid_bills_num_cashloan, default -9999'
    ,latest_dpd_cashloan bigint comment 'latest_dpd_cashloan, default -9999'
    ,ever_max_dpd_spl_core bigint comment 'ever_max_dpd_spl_core, default -9999'
    ,last_bill_dpd_spl_core bigint comment 'last_bill_dpd_spl_core, default -9999'
    ,ever_max_dpd_30d_sellerloan bigint comment ''
    ,ever_max_dpd_90d_sellerloan bigint comment ''
    ,ever_max_dpd_180d_sellerloan bigint comment ''
    ,ever_max_dpd_360d_sellerloan bigint comment ''
    ,ever_max_dpd_30d_spl bigint comment ''
    ,ever_max_dpd_90d_spl bigint comment ''
    ,ever_max_dpd_30d_cashloan bigint comment ''
    ,ever_max_dpd_90d_cashloan bigint comment ''
    ,ever_max_dpd_180d_bcl bigint comment ''
    ,latest_dpd_eod_spl bigint comment ''
    ,latest_dpd_eod_bcl bigint comment ''
)
COMMENT 'Tag:risk summary table'
partitioned by
    (grass_date string comment 'YYYY-MM-dd') stored as orc tblproperties ("orc.compress" = "SNAPPY") location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_dpd_df/grass_region=MY'
;

msck repair table ${SCHEMA}.dws_risk_my_user_dpd_df
;