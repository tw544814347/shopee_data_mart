drop table if exists risk.dwd_risk_my_spl_mission_result_df_s3check;
create external table if not exists risk.dwd_risk_my_spl_mission_result_df_s3check
(
platform_user_id    string comment 'platform_user_id'
,user_mission_id     string comment 'user_mission_id'
,mission_result      string comment 'user_mission_status'
)
-- partitioned by (grass_date string comment "YYYY-MM-DD")
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location 'ofs://oc/credit-sync/sg-credit-sync-feature/MY/live/dwd_risk_my_spl_mission_result_df/${BIZ_DATE}'
TBLPROPERTIES ("skip.header.line.count"="1")
;

-- msck repair table risk.dwd_risk_my_spl_mission_result_df_s3check;

refresh table risk.dwd_risk_my_spl_mission_result_df_s3check;
