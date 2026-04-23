drop table if exists risk.ads_risk_id_spl_mission_result_df_dqc;
create external table if not exists risk.ads_risk_id_spl_mission_result_df_dqc
(
mission_id           string comment 'mission_id'
,user_mission_id     string comment 'user_mission_id'
,mission_name        string comment 'mission_name'
,mission_type        string comment 'mission_type'
,dqc_type            string comment 'criteria_dqc or mission_result_dqc'
,dqc_result          string comment 'dqc_result 1-异常 0-正常'
)
partitioned by (
biz_name        string comment 'biz_name '
,grass_date     string   comment "YYYY-MM-DD")
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_id_spl_mission_result_df_dqc/grass_region=ID';
;

msck repair table risk.ads_risk_id_spl_mission_result_df_dqc;
