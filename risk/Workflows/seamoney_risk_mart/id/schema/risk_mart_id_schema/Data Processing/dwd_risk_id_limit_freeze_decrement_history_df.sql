DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_id_limit_freeze_decrement_history_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_id_limit_freeze_decrement_history_df(
    userid  string
    ,user_id string
    ,product string
    ,action  string
    ,control_test    string
    ,quota_before_spl    decimal(30,10)
    ,quota_after_spl decimal(30,10)
    ,quota_before_bcl    decimal(30,10)
    ,quota_after_bcl decimal(30,10)
    ,description string
    ,operator    string
    ,live_date   string
)
partitioned by(grass_date string comment 'YYYY-MM-dd')
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/dws/dwd_risk_limit_freeze_decrement_history_df/grass_region=ID';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_id_limit_freeze_decrement_history_df;

