drop table if exists ${SCHEMA}.dws_risk_user_score_df_dqc;
create external table if not exists ${SCHEMA}.dws_risk_user_score_df_dqc
(
    table_name string
    ,rule_name string
    ,dqc_result boolean
)
partitioned by
(
    grass_date string
)
stored as orc
tblproperties
(
    "orc.compress" = "SNAPPY"
)
location '${HDFS_PATH}/risk_mart/ads/dws_risk_user_score_df_dqc'
;
