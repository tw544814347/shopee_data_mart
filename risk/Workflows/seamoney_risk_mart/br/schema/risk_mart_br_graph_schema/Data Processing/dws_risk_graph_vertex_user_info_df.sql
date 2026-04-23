DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_graph_vertex_user_info_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_graph_vertex_user_info_df
(
    vertex_value      string comment 'source vertex',
    hash_vertex_value string comment 'hash source vertex',
    extend_info           string comment 'destination_node extend info'
)
comment 'Risk Graph Data Edge'
partitioned by
(
    grass_region string comment 'region',
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_graph_vertex_user_info_df';
MSCK REPAIR TABLE ${SCHEMA}.dws_risk_graph_vertex_user_info_df;