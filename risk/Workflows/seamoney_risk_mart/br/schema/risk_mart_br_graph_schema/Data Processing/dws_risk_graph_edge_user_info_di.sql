DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_graph_edge_user_info_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_graph_edge_user_info_di
(
    platform_user_id      string comment 'source vertex',
    hash_platform_user_id string comment 'hash source vertex',
    destination_node      string comment 'destination_vertex',
    hash_destination_node string comment 'hash_destination_vertex',
    create_date      string comment 'create_date',
    last_date       string comment 'last_date',
    extend_info           string comment 'destination_node extend info'
)
comment 'Risk Graph Data Edge'
partitioned by
(
    grass_region string comment 'region',
    edge_name string comment 'edge name, login/register_mail etc.',
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_graph_edge_user_info_di';
MSCK REPAIR TABLE ${SCHEMA}.dws_risk_graph_edge_user_info_di;