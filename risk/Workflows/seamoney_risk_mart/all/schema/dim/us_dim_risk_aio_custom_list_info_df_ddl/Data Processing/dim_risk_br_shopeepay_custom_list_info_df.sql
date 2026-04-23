drop table if exists ${SCHEMA}.dim_risk_${region}_${product_line}_custom_list_info_df;
create external table if not exists ${SCHEMA}.dim_risk_${region}_${product_line}_custom_list_info_df
(
list_id               bigint               comment ''
,list_name            string               comment ''
,property             bigint               comment ''
,status               bigint               comment '1-valid'
,data_type            string               comment ''
,list_source          string               comment ''
,actions              string               comment ''
,de_table_name        string               comment ''
,remark               string               comment ''
,description          string               comment ''
,creator              string               comment ''
,create_time          string               comment ''
,update_time          string               comment ''
,category             bigint               comment ''
,version              bigint               comment ''
,total                bigint               comment ''
,data_hash            string               comment ''
,fit_scene            string               comment ''
,scenario_based       bigint               comment ''
,screening_switch     bigint               comment 'the manual audit switch: 1-off, 2-on'  
,de_table_config      string               comment "List {DETableName: table1,NeedScreening: true}"
)
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dim/dim_risk_aio_custom_list_info_df/product_line=${product_line}/garss_region=${upper_region}';

msck repair table ${SCHEMA}.dim_risk_${region}_${product_line}_custom_list_info_df;