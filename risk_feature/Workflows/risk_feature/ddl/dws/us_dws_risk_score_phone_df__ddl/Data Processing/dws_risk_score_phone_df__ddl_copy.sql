drop table if exists ${SCHEMA}.dws_risk_phone_score_df;
create external table if not exists ${SCHEMA}.dws_risk_phone_score_df
(
    phone_number string
    ,model_version string
    ,model_type string
    ,score string
    ,biz_type string
    ,source_table string
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
location '${HDFS_PATH}/risk_feature/dws/dws_risk_phone_score_df'
;
