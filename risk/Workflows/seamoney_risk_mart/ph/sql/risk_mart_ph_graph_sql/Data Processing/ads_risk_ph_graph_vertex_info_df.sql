DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_ph_graph_vertex_info_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_ph_graph_vertex_info_df
(
    vertex_value      string comment 'vertex_value',
    hash_vertex_value string comment 'hash_vertex_value',
    create_date       string comment 'create_date',
    last_date       string comment 'last_date',
    extend_info       string comment 'vertex extend info'
)
comment 'Risk Graph Data User Edge'
partitioned by
(
    vertex_name string,
    grass_date string
)
stored as parquet tblproperties (
    "parquet.compress" = "zstd",
    "parquet.stripe.size" = "2147483648"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_graph_vertex_info_df/grass_region=PH';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_ph_graph_vertex_info_df;