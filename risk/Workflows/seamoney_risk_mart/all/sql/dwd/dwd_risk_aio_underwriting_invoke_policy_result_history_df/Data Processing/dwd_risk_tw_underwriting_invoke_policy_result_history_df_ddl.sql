drop table if exists ${SCHEMA}.dwd_risk_${region}_underwriting_invoke_policy_result_history_df;
create table if not exists ${SCHEMA}.dwd_risk_${region}_underwriting_invoke_policy_result_history_df
(
    id  bigint
    ,flow_no string
    ,req_params  string
    ,rsp string
    ,create_time string
    ,update_time string
    ,app_id  string
    ,scene_id    bigint
    ,platform_user_id    string
    ,platform_type   bigint
    ,pending_start_time  string
    ,pending_finish_time string
    ,result_code bigint
) 
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_aio_underwriting_invoke_policy_result_history_df/grass_region=${grass_region}';
msck repair table ${SCHEMA}.dwd_risk_${region}_underwriting_invoke_policy_result_history_df;
