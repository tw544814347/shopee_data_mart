--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-09-25
-- Theme Domain：       user mission
-- Description:         user mission, 只取  mission_type in (2,3) 1：KYC任务 2：SPL订单量任务 3：SPL GMV任务
-- Data Granularity:    user_mission_id
-- change logs
/* 
    1. 所有地区整合为模版开发
    2. br 和 mx 地区 s3 路径和 sg 地区有差异，先剥离模板调试
*/
--********************************************************************--

drop table if exists risk.dwd_risk_${reg}_spl_mission_result_df_s3check;
create external table if not exists risk.dwd_risk_${reg}_spl_mission_result_df_s3check
(
platform_user_id    string comment 'platform_user_id'
,user_mission_id     string comment 'user_mission_id'
,mission_result      string comment 'user_mission_status'
)
-- partitioned by (grass_date string comment "YYYY-MM-DD")
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location 'ofs://oc-asb/s3v/${bucket_name}/${upper_region}/live/dwd_risk_${reg}_spl_mission_result_df/${BIZ_DATE}'
TBLPROPERTIES ("skip.header.line.count"="1")
;

-- msck repair table risk.dwd_risk_${reg}_spl_mission_result_df_s3check;

refresh table risk.dwd_risk_${reg}_spl_mission_result_df_s3check;
