drop table if exists ${SCHEMA}.dws_risk_shop_score_df;
create external table if not exists ${SCHEMA}.dws_risk_shop_score_df
(
    shop_id string
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
location '${HDFS_PATH}/risk_mart/dws/dws_risk_shop_score_df'
;
