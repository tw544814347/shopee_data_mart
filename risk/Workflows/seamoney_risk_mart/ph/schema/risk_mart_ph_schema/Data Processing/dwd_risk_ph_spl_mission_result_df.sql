-- add by dongbo.yu 2025-02-27 新增任务完成的领奖条件reward_rank和奖励的物品action_id
drop table if exists risk.dwd_risk_${region}_${biz_name}_mission_result_df;
create external table if not exists risk.dwd_risk_${region}_${biz_name}_mission_result_df
(
mission_id           string comment 'mission_id'
,mission_name        string comment 'mission_name'
,mission_type        string comment 'mission_type'
,biz_type            string comment '1-bcl,2-scl,3-spl'
,complete_duration   bigint comment 'complete_duration'
,reward_duration     bigint comment 'reward_duration'
,user_mission_id     string comment 'user_mission_id'
,platform_user_id    string comment 'platform_user_id'
,credit_user_id      string comment 'credit_user_id'
,start_time          string comment 'user mission start_time(local time)'
,complete_time       string comment 'user mission complete_time(local time)'
,reward_time         string comment 'reward_time'
,complete_value      string comment 'complete_value'
,mission_result      string comment 'mission_result'
,create_time         string comment 'create_time local time'
,reward_rank         bigint comment 'mission reward limit condition value'
,action_id           string comment 'mission reward item id'
,user_mission_status bigint comment 'user_mission_status,3 is already reward'
)
partitioned by (
biz_name        string comment 'biz_name '
,grass_date     string   comment "YYYY-MM-DD")
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_aio_mission_result_df/grass_region=${upper_region}';
;