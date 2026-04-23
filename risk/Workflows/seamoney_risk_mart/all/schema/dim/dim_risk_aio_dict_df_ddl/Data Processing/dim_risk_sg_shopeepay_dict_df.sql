drop table if exists ${SCHEMA}.dim_risk_${region}_${product_line}_dict_df;
create external table if not exists ${SCHEMA}.dim_risk_${region}_${product_line}_dict_df
(
dict_key         string   comment "dict_key"
,dict_name        string   comment "dict_name"
,dict_value       string   comment "dict_value"
,parent_dict_key  string   comment "parent_dict_key"
,leaf_node        string   comment "leaf_node"
,description      string   comment "description"
,status           string   comment "status"
,creator          string   comment "creator"
,create_time      string   comment "create_time"
,update_time      string   comment "update_time"
)
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dim/dim_risk_aio_dict_df/product_line=${product_line}/garss_region=${upper_region}';

msck repair table ${SCHEMA}.dim_risk_${region}_${product_line}_dict_df;