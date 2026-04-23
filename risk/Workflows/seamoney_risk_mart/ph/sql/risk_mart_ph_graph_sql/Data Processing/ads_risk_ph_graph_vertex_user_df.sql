DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_ph_graph_vertex_user_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_ph_graph_vertex_user_df
(
    vertex_value      string comment 'vertex_value',
    hash_vertex_value string comment 'hash_vertex_value',
    extend_info       string comment 'vertex extend info'
)
comment 'Risk Graph Data User Edge'
partitioned by
(
    grass_date string
)
stored as parquet tblproperties (
    "parquet.compress" = "zstd",
    "parquet.stripe.size" = "2147483648"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_graph_vertex_user_info_df/grass_region=PH';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_ph_graph_vertex_user_df;