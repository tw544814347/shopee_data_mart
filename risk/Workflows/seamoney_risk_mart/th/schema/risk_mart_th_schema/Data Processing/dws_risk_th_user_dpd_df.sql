drop table if exists ${SCHEMA}.dws_risk_th_user_dpd_df;
create external table if not exists ${SCHEMA}.dws_risk_th_user_dpd_df (
    user_id string
    ,ever_max_dpd_cashloan_core bigint
    ,last_bill_dpd_cashloan_core bigint
    ,ever_max_dpd_sellerloan_core bigint
    ,last_bill_dpd_sellerloan_core bigint
    ,ever_max_dpd_spl_core bigint
    ,last_bill_dpd_spl_core bigint
    ,days_after_first_due_date_spl bigint
    ,ever_max_dpd_180d_spl bigint
    ,ever_max_dpd_360d_spl bigint
    ,days_after_first_due_date_cashloan bigint
    ,ever_max_dpd_180d_cashloan bigint
    ,ever_max_dpd_360d_cashloan bigint
    ,ever_max_dpd_180d_user bigint
    ,ever_max_dpd_360d_user bigint
    ,ever_max_dpd_30d_sellerloan bigint comment ''
    ,ever_max_dpd_90d_sellerloan bigint comment ''
    ,ever_max_dpd_180d_sellerloan bigint comment ''
    ,ever_max_dpd_360d_sellerloan bigint comment ''
    ,ever_max_dpd_30d_spl bigint comment ''
    ,ever_max_dpd_90d_spl bigint comment ''
    ,ever_max_dpd_30d_cashloan bigint comment ''
    ,ever_max_dpd_90d_cashloan bigint comment ''
    ,days_after_first_due_date_cashloan_floating bigint
    ,days_after_first_due_date_spl_floating bigint
    ,latest_dpd_eod_cashloan bigint
    ,latest_dpd_eod_spl bigint
    ,ever_max_dpd_chp bigint  
    ,days_after_first_due_date_chp bigint
    ,ever_max_dpd_30d_chp bigint
    ,ever_max_dpd_90d_chp bigint
    ,ever_max_dpd_180d_chp bigint
    ,ever_max_dpd_360d_chp bigint
    ,ever_max_dpd_30d_user bigint
    ,ever_max_dpd_90d_user bigint
    ,ever_max_dpd_30d_tl bigint
    ,ever_max_dpd_90d_tl bigint
    ,ever_max_dpd_180d_tl bigint
    ,ever_max_dpd_360d_tl bigint
    ,ever_max_dpd_tl bigint
)
partitioned by
    (grass_date string comment 'YYYY-MM-dd') stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_dpd_df/grass_region=TH'
;

msck repair table ${SCHEMA}.dws_risk_th_user_dpd_df
;