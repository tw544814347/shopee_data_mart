drop table if exists ${SCHEMA}.dws_risk_user_score_meta_df;
create external table if not exists ${SCHEMA}.dws_risk_user_score_meta_df
(
    biz_type string
    ,model_version string
    ,column_name string
    ,data_type string
)
partitioned by
(
    grass_region string
    ,grass_date string
)
stored as orc
tblproperties
(
    "orc.compress" = "SNAPPY"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_score_meta_df'
;
