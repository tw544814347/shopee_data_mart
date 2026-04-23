drop table if exists ${SCHEMA}.dws_risk_user_behavior_credit_info_df;
create external table if not exists ${SCHEMA}.dws_risk_user_behavior_credit_info_df (
    credit_user_id string
    ,is_spl_disbursed int comment 'is_spl_disbursed'
    ,is_chp_disbursed int comment 'is_chp_disbursed'
) partitioned by (
    grass_region string comment 'grass_region'
    ,grass_date string comment 'YYYY-MM-dd'
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_feature/dws/dws_risk_user_behavior_credit_info_df'
;

msck repair table ${SCHEMA}.dws_risk_user_behavior_credit_info_df
;