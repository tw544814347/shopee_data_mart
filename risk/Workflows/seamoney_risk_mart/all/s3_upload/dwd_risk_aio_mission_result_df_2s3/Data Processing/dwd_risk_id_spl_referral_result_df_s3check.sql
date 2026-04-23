drop table if exists risk.dwd_risk_id_spl_referral_result_df_s3check;
create external table if not exists risk.dwd_risk_id_spl_referral_result_df_s3check
(
platformType    string comment 'platformType'
,platformUserId     string comment 'platformUserId'
,userReferralId      string comment 'userReferralId'
,completedValue      string comment 'completedValue'
)
-- partitioned by (grass_date string comment "YYYY-MM-DD")
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location 'ofs://oc/credit-sync/sg-credit-sync-feature/ID/live/dwd_risk_id_spl_referral_result_df/${BIZ_DATE}'
TBLPROPERTIES ("skip.header.line.count"="1")
;

-- msck repair table risk.dwd_risk_id_spl_referral_result_df_s3check;

refresh table risk.dwd_risk_id_spl_referral_result_df_s3check;
