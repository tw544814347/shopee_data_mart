drop table if exists ${SCHEMA}.dwd_risk_${region}_graph_edge_user_kyc_df;
create external table if not exists ${SCHEMA}.dwd_risk_${region}_graph_edge_user_kyc_df
(
    platform_user_id                string comment 'platform_user_id'
    ,hash_platform_user_id          string comment 'hash_platform_user_id'
    ,destination_node               string comment 'destination_node'
    ,hash_destination_node          string comment 'hash_destination_node'
    ,create_date                    string comment 'create_date'
    ,last_date                      string comment 'last_date'
    ,extend_info                    string comment 'extend_info'
    ,grass_region                   string comment 'grass_region'
    ,edge_name                      string comment 'edge_name'
)
partitioned by
(   grass_date string comment 'grass_date'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_graph_edge_user_kyc_df/grass_region=${upper_region}';
msck repair table ${SCHEMA}.dwd_risk_${region}_graph_edge_user_kyc_df;