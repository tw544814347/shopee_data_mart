DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_ph_graph_edge_user_info_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_ph_graph_edge_user_info_di
(
    platform_user_id      string comment 'platform_user_id',
    hash_platform_user_id string comment 'hash_platform_user_id',
    destination_node      string comment 'destination_vertex',
    hash_destination_node string comment 'hash_destination_vertex',
    create_date      string comment 'create_timestamp',
    last_date       string comment 'create_datetime',
    extend_info           string comment 'destination_node extend info'
)
comment 'Risk Graph Data User Edge'
partitioned by
(
    edge_name    string comment 'partition key, edge_name',
    grass_date   string comment 'partition key, yyyy-MM-dd'
)
stored as parquet tblproperties (
    "parquet.compress" = "zstd",
    "parquet.stripe.size" = "2147483648"
)location '${HDFS_PATH}/risk_mart/dws/dws_risk_graph_edge_user_info_di/grass_region=PH';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_ph_graph_edge_user_info_di;