DROP TABLE IF EXISTS ${SCHEMA}.dwd_id_af_flow_no_tag_di;
CREATE TABLE IF NOT EXISTS ${SCHEMA}.dwd_id_af_flow_no_tag_di
(   
    flow_no         string
)partitioned by (
    app_id          string,
    scene_id        string,
    grass_date      string
)
stored as parquet tblproperties ("orc.compress"="ZSTD")
location '${HDFS_PATH}/risk_mart/dwd/dwd_af_flow_no_tag_di/grass_region=ID';
msck repair table ${SCHEMA}.dwd_id_af_flow_no_tag_di;