drop table if exists ${SCHEMA}.dws_risk_user_score_df;
create external table if not exists ${SCHEMA}.dws_risk_user_score_df
(
    platform_user_id string
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
    ,"orc.stripe.size" = "2147483648"
)
location '${HDFS_PATH}/dws/dws_risk_user_score_df'
;
