-- drop table if exists ${SCHEMA}.ads_risk_${table_region}_mp_user_df;

-- create external table if not exists ${SCHEMA}.ads_risk_${table_region}_mp_user_df (
--     platform_user_id string comment 'shopee user id'
--     ,is_whitelist_spl int comment 'Whether user is in whitelist'
--     ,whitelist_time_spl string comment 'Whitelist time'
--     ,is_whitelist_bcl int comment 'Whether user is in whitelist'
--     ,whitelist_time_bcl string comment 'Whitelist time'
--     ,is_whitelist_splx int comment 'Whether user is in whitelist'
--     ,whitelist_time_splx  string comment 'Whitelist time'
--     ,is_post_kyc_freeze                     int             comment 'Whether post kyc freeze'
--     ,is_post_fraud_freeze                   int             comment 'Whether post fraud freeze'
--     ,is_overdue_freeze                   int             comment 'Whether overdue freeze'
--     ,is_restructure_freeze                         int             comment 'Whether under restructure program'
--     ,is_dpd_freeze                         int             comment 'Whether ALL DPD 60 Freeze'
-- )
-- partitioned by (
--     grass_date string 
-- ) 
-- stored as orc 
-- comment 'whitelist & user level info of mp user summary table'
-- tblproperties
-- (
--     "orc.compress" = "zstd"
--     ,"orc.stripe.size" = "268635456"
-- )
-- location '${HDFS_PATH}/risk_feature/ads/ads_risk_${table_region}_mp_user_df/grass_region=${region}';

-- msck repair table ${SCHEMA}.ads_risk_${table_region}_mp_user_df;

-- 修改列注释
ALTER TABLE ${SCHEMA}.ads_risk_${table_region}_mp_user_df CHANGE COLUMN platform_user_id platform_user_id string COMMENT 'shopee user id';

ALTER TABLE ${SCHEMA}.ads_risk_${table_region}_mp_user_df CHANGE COLUMN is_whitelist_spl is_whitelist_spl int COMMENT 'Whether user is in whitelist';

ALTER TABLE ${SCHEMA}.ads_risk_${table_region}_mp_user_df CHANGE COLUMN whitelist_time_spl whitelist_time_spl string COMMENT 'Whitelist time';

ALTER TABLE ${SCHEMA}.ads_risk_${table_region}_mp_user_df CHANGE COLUMN is_whitelist_bcl is_whitelist_bcl int COMMENT 'Whether user is in whitelist';

ALTER TABLE ${SCHEMA}.ads_risk_${table_region}_mp_user_df CHANGE COLUMN whitelist_time_bcl whitelist_time_bcl string COMMENT 'Whitelist time';

ALTER TABLE ${SCHEMA}.ads_risk_${table_region}_mp_user_df CHANGE COLUMN is_whitelist_splx is_whitelist_splx int COMMENT 'Whether user is in whitelist';

ALTER TABLE ${SCHEMA}.ads_risk_${table_region}_mp_user_df CHANGE COLUMN whitelist_time_splx whitelist_time_splx string COMMENT 'Whitelist time';