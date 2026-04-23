drop table if exists ${SCHEMA}.dim_2cscore_id_complete_condition_df;
create external table if not exists ${SCHEMA}.dim_2cscore_id_complete_condition_df
(
    mission_variable STRING
    ,mission_operation STRING comment 'operation condition for completing this mission'
    ,mission_value STRING comment 'value condition for completing this mission'
    ,mission_id BIGINT comment 'mission id'
    ,mission_name STRING comment 'mission name'
    ,mission_code STRING comment 'mission code'
    ,mission_type BIGINT comment 'mission type'
    ,mission_status BIGINT comment 'mission status -1:invalid,1:valid,2:locked'
)
partitioned by
(
    grass_date string comment 'YYYY-MM-dd'
)
stored as orc
tblproperties
(
    "orc.compress" = "SNAPPY"
)
location '${HDFS_PATH}/risk_feature/dim/dim_2cscore_complete_condition_df/grass_region=${region}'
;

msck repair table ${SCHEMA}.dim_2cscore_id_complete_condition_df
;

