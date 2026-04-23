DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_graph_vertex_info_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_graph_vertex_info_df
(
    vertex_value      string comment 'source vertex',
    hash_vertex_value string comment 'hash source vertex',
    create_date      string comment 'create_date',
    last_date       string comment 'last_date',
    extend_info           string comment 'destination_node extend info'
)
comment 'Risk Graph Data Edge'
partitioned by
(
    grass_region string comment 'region',
    vertex_name string comment 'vertex name, login/register_mail etc.',
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as parquet tblproperties (
    "parquet.compress" = "zstd",
    "parquet.stripe.size" = "2147483648"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_graph_vertex_info_df';
MSCK REPAIR TABLE ${SCHEMA}.dws_risk_graph_vertex_info_df;