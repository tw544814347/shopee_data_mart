-- drop table if exists ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df;
-- create external table if not exists ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df (
--     credit_user_id                          string          comment 'credit user id'
--     ,platform_user_id                       string          comment 'shopee user id'
--     ,sp_user_id                             string          comment 'shopee user id'
--     ,spp_user_id                            string          comment 'shopeepay user id'
--     ,product_id                             string          comment 'product id'
--     ,user_status                            string          comment 'user status'
--     ,is_limit_expired                       int             comment 'Whether limit is expired'
--     ,has_valid_activated                    int             comment 'Whether has valid activated'
--     ,first_activation_time                  string          comment 'First activation time'
--     ,new_activation_time                    string          comment 'New activation time'
--     ,month_since_activation                 int             comment 'Month since activation'
--     ,is_activated_l1d                       int             comment 'Whether activated in last 1 day'
--     ,is_activated_l30d                      int             comment 'Whether activated in last 30 days'
--     ,is_activated_l90d                      int             comment 'Whether activated in last 90 days'
--     ,is_activated_l180d                     int             comment 'Whether activated in last 180 days'
--     ,is_activated_l360d                     int             comment 'Whether activated in last 360 days'
--     ,first_application_time                 string          comment 'First application time'
--     ,last_application_time                  string          comment 'Last application time'
--     ,is_whitelist                           int             comment 'Whether user is in whitelist'
--     ,whitelist_time                         string          comment 'Whitelist time'
--     ,common_perm_credit_limit               decimal(30, 10) comment 'Common permanent credit limit'
--     ,common_perm_frozen_credit_amount       decimal(30, 10) comment 'Common permanent frozen credit amount'
--     ,common_perm_used_credit_amount         decimal(30, 10) comment 'Common permanent used credit amount'
--     ,common_perm_available_credit_amount    decimal(30, 10) comment 'base - frozen - used'
--     ,common_temp_credit_limit               decimal(30, 10) comment 'Common temporary credit limit'
--     ,common_temp_frozen_credit_amount       decimal(30, 10) comment 'Common temporary frozen credit amount'
--     ,common_temp_used_credit_amount         decimal(30, 10) comment 'Common temporary used credit amount'
--     ,common_temp_available_credit_amount    decimal(30, 10) comment 'base - frozen - used'
--     ,campaign_temp_credit_limit             decimal(30, 10) comment 'Campaign temporary credit limit'
--     ,campaign_temp_frozen_credit_amount     decimal(30, 10) comment 'Campaign temporary frozen credit amount'
--     ,campaign_temp_used_credit_amount       decimal(30, 10) comment 'Campaign temporary used credit amount'
--     ,campaign_temp_available_credit_amount  decimal(30, 10) comment 'base - frozen - used'
--     ,total_credit_limit                     decimal(30, 10) comment 'Total credit limit'
--     ,total_used_credit_amount               decimal(30, 10) comment 'Total used credit amount'
--     ,total_frozen_credit_amount             decimal(30, 10) comment 'Total frozen credit amount'
--     ,common_perm_credit_limit_utilization   decimal(30, 10) comment 'Common permanent credit limit utilization rate'
--     ,common_temp_credit_limit_utilization   decimal(30, 10) comment 'Common temporary credit limit utilization rate'
--     ,campaign_temp_credit_limit_utilization decimal(30, 10) comment 'Campaign temporary credit limit utilization rate'
--     ,total_credit_amount_utilization        decimal(30, 10) comment 'Total credit amount utilization rate'
--     ,is_eligible_for_1m                     int             comment 'Whether eligible for 1 month tenure'
--     ,is_eligible_for_2m                     int             comment 'Whether eligible for 2 month tenure'
--     ,is_eligible_for_3m                     int             comment 'Whether eligible for 3 month tenure'
--     ,is_eligible_for_6m                     int             comment 'Whether eligible for 6 month tenure'
--     ,is_eligible_for_9m                     int             comment 'Whether eligible for 9 month tenure'
--     ,is_eligible_for_12m                    int             comment 'Whether eligible for 12 month tenure'
--     ,is_eligible_for_18m                    int             comment 'Whether eligible for 18 month tenure'
--     ,is_eligible_for_24m                    int             comment 'Whether eligible for 24 month tenure'
--     ,interest_rate_1m                       decimal(30, 10) comment 'eir for 1 month tenure'
--     ,interest_rate_2m                       decimal(30, 10) comment 'eir for 2 month tenure'
--     ,interest_rate_3m                       decimal(30, 10) comment 'eir for 3 month tenure'
--     ,interest_rate_6m                       decimal(30, 10) comment 'eir for 6 month tenure'
--     ,interest_rate_9m                       decimal(30, 10) comment 'eir for 9 month tenure'
--     ,interest_rate_12m                      decimal(30, 10) comment 'eir for 12 month tenure'
--     ,interest_rate_18m                      decimal(30, 10) comment 'eir for 18 month tenure'
--     ,interest_rate_24m                      decimal(30, 10) comment 'eir for 24 month tenure'
--     ,is_post_kyc_freeze                     int             comment 'Whether post kyc freeze'
--     ,is_post_fraud_freeze                   int             comment 'Whether post fraud freeze'
--     ,is_overdue_freeze                      int             comment 'Whether overdue freeze'
--     ,is_restructure_freeze                  int             comment 'Whether restructure freeze'
--     ,is_dpd_freeze                          int             comment 'Whether dpd freeze'
--     ,is_underwriting_freeze                 int             comment 'Whether underwriting freeze'
--     ,is_acc_closure_freeze                  int             comment 'Whether acc closure freeze'
--     ,is_shopee_freeze                       int             comment 'Whether shopee freeze'
--     ,is_limit_expired_freeze                int             comment 'Whether limit expired freeze'
--     ,is_payment_reject_freeze               int             comment 'Whether payment reject freeze'
--     ,max_common_perm_credit_limit_utilization_30d decimal(30, 10) comment 'Max common permanent credit limit utilization in last 30 days'
--     ,max_common_temp_credit_limit_utilization_30d  decimal(30, 10) comment 'Max common temporary credit limit utilization in last 30 days'
--     ,max_campaign_temp_credit_limit_utilization_30d decimal(30, 10) comment 'Max campaign temporary credit limit utilization in last 30 days'
--     ,max_total_credit_amount_utilization_30d decimal(30, 10) comment 'Max total credit amount utilization in last 30 days'
--     ,min_common_perm_credit_limit_utilization_30d decimal(30, 10) comment 'Min common permanent credit limit utilization in last 30 days'
--     ,min_common_temp_credit_limit_utilization_30d decimal(30, 10) comment 'Min common temporary credit limit utilization in last 30 days'
--     ,min_campaign_temp_credit_limit_utilization_30d decimal(30, 10) comment 'Min campaign temporary credit limit utilization in last 30 days'
--     ,min_total_credit_amount_utilization_30d decimal(30, 10) comment 'Min total credit amount utilization in last 30 days'
--     ,avg_common_perm_credit_limit_utilization_30d decimal(30, 10) comment 'Avg common permanent credit limit utilization in last 30 days'
--     ,avg_common_temp_credit_limit_utilization_30d decimal(30, 10) comment 'Avg common temporary credit limit utilization in last 30 days'
--     ,avg_campaign_temp_credit_limit_utilization_30d decimal(30, 10) comment 'Avg campaign temporary credit limit utilization in last 30 days'
--     ,avg_total_credit_amount_utilization_30d decimal(30, 10) comment 'Avg total credit amount utilization in last 30 days'
--     ,med_common_perm_credit_limit_utilization_30d decimal(30, 10) comment 'Median common permanent credit limit utilization in last 30 days'
--     ,med_common_temp_credit_limit_utilization_30d decimal(30, 10) comment 'Median common temporary credit limit utilization in last 30 days'
--     ,med_campaign_temp_credit_limit_utilization_30d decimal(30, 10) comment 'Median campaign temporary credit limit utilization in last 30 days'
--     ,med_total_credit_amount_utilization_30d decimal(30, 10) comment 'Median total credit amount utilization in last 30 days'
--     ,max_common_perm_credit_limit_utilization_90d decimal(30, 10) comment 'Max common permanent credit limit utilization in last 90 days'
--     ,max_common_temp_credit_limit_utilization_90d decimal(30, 10) comment 'Max common temporary credit limit utilization in last 90 days'
--     ,max_campaign_temp_credit_limit_utilization_90d decimal(30, 10) comment 'Max campaign temporary credit limit utilization in last 90 days'
--     ,max_total_credit_amount_utilization_90d decimal(30, 10) comment 'Max total credit amount utilization in last 90 days'
--     ,min_common_perm_credit_limit_utilization_90d decimal(30, 10) comment 'Min common permanent credit limit utilization in last 90 days'
--     ,min_common_temp_credit_limit_utilization_90d decimal(30, 10) comment 'Min common temporary credit limit utilization in last 90 days'
--     ,min_campaign_temp_credit_limit_utilization_90d decimal(30, 10) comment 'Min campaign temporary credit limit utilization in last 90 days'
--     ,min_total_credit_amount_utilization_90d decimal(30, 10) comment 'Min total credit amount utilization in last 90 days'
--     ,avg_common_perm_credit_limit_utilization_90d decimal(30, 10) comment 'Avg common permanent credit limit utilization in last 90 days'
--     ,avg_common_temp_credit_limit_utilization_90d decimal(30, 10) comment 'Avg common temporary credit limit utilization in last 90 days'
--     ,avg_campaign_temp_credit_limit_utilization_90d decimal(30, 10) comment 'Avg campaign temporary credit limit utilization in last 90 days'
--     ,avg_total_credit_amount_utilization_90d decimal(30, 10) comment 'Avg total credit amount utilization in last 90 days'
--     ,med_common_perm_credit_limit_utilization_90d decimal(30, 10) comment 'Median common permanent credit limit utilization in last 90 days'
--     ,med_common_temp_credit_limit_utilization_90d decimal(30, 10) comment 'Median common temporary credit limit utilization in last 90 days'
--     ,med_campaign_temp_credit_limit_utilization_90d decimal(30, 10) comment 'Median campaign temporary credit limit utilization in last 90 days'
--     ,med_total_credit_amount_utilization_90d decimal(30, 10) comment 'Median total credit amount utilization in last 90 days'
--     ,max_common_perm_credit_limit_utilization_180d decimal(30, 10) comment 'Max common permanent credit limit utilization in last 180 days'
--     ,max_common_temp_credit_limit_utilization_180d decimal(30, 10) comment 'Max common temporary credit limit utilization in last 180 days'
--     ,max_campaign_temp_credit_limit_utilization_180d decimal(30, 10) comment 'Max campaign temporary credit limit utilization in last 180 days'
--     ,max_total_credit_amount_utilization_180d decimal(30, 10) comment 'Max total credit amount utilization in last 180 days'
--     ,min_common_perm_credit_limit_utilization_180d decimal(30, 10) comment 'Min common permanent credit limit utilization in last 180 days'
--     ,min_common_temp_credit_limit_utilization_180d decimal(30, 10) comment 'Min common temporary credit limit utilization in last 180 days'
--     ,min_campaign_temp_credit_limit_utilization_180d decimal(30, 10) comment 'Min campaign temporary credit limit utilization in last 180 days'
--     ,min_total_credit_amount_utilization_180d decimal(30, 10) comment 'Min total credit amount utilization in last 180 days'
--     ,avg_common_perm_credit_limit_utilization_180d decimal(30, 10) comment 'Avg common permanent credit limit utilization in last 180 days'
--     ,avg_common_temp_credit_limit_utilization_180d decimal(30, 10) comment 'Avg common temporary credit limit utilization in last 180 days'
--     ,avg_campaign_temp_credit_limit_utilization_180d decimal(30, 10) comment 'Avg campaign temporary credit limit utilization in last 180 days'
--     ,avg_total_credit_amount_utilization_180d decimal(30, 10) comment 'Avg total credit amount utilization in last 180 days'
--     ,med_common_perm_credit_limit_utilization_180d decimal(30, 10) comment 'Median common permanent credit limit utilization in last 180 days'
--     ,med_common_temp_credit_limit_utilization_180d decimal(30, 10) comment 'Median common temporary credit limit utilization in last 180 days'
--     ,med_campaign_temp_credit_limit_utilization_180d decimal(30, 10) comment 'Median campaign temporary credit limit utilization in last 180 days'
--     ,med_total_credit_amount_utilization_180d decimal(30, 10) comment 'Median total credit amount utilization in last 180 days'
--     ,max_common_perm_credit_limit_utilization_360d decimal(30, 10) comment 'Max common permanent credit limit utilization in last 360 days'
--     ,max_common_temp_credit_limit_utilization_360d decimal(30, 10) comment 'Max common temporary credit limit utilization in last 360 days'
--     ,max_campaign_temp_credit_limit_utilization_360d decimal(30, 10) comment 'Max campaign temporary credit limit utilization in last 360 days'
--     ,max_total_credit_amount_utilization_360d decimal(30, 10) comment 'Max total credit amount utilization in last 360 days'
--     ,min_common_perm_credit_limit_utilization_360d decimal(30, 10) comment 'Min common permanent credit limit utilization in last 360 days'
--     ,min_common_temp_credit_limit_utilization_360d decimal(30, 10) comment 'Min common temporary credit limit utilization in last 360 days'
--     ,min_campaign_temp_credit_limit_utilization_360d decimal(30, 10) comment 'Min campaign temporary credit limit utilization in last 360 days'
--     ,min_total_credit_amount_utilization_360d decimal(30, 10) comment 'Min total credit amount utilization in last 360 days'
--     ,avg_common_perm_credit_limit_utilization_360d decimal(30, 10) comment 'Avg common permanent credit limit utilization in last 360 days'
--     ,avg_common_temp_credit_limit_utilization_360d decimal(30, 10) comment 'Avg common temporary credit limit utilization in last 360 days'
--     ,avg_campaign_temp_credit_limit_utilization_360d decimal(30, 10) comment 'Avg campaign temporary credit limit utilization in last 360 days'
--     ,avg_total_credit_amount_utilization_360d decimal(30, 10) comment 'Avg total credit amount utilization in last 360 days'
--     ,med_common_perm_credit_limit_utilization_360d decimal(30, 10) comment 'Median common permanent credit limit utilization in last 360 days'
--     ,med_common_temp_credit_limit_utilization_360d decimal(30, 10) comment 'Median common temporary credit limit utilization in last 360 days'
--     ,med_campaign_temp_credit_limit_utilization_360d decimal(30, 10) comment 'Median campaign temporary credit limit utilization in last 360 days'
--     ,med_total_credit_amount_utilization_360d decimal(30, 10) comment 'Median total credit amount utilization in last 360 days'
--     -- amount/interest rate when latest activated
--     ,activate_common_credit_limit decimal(30, 10) comment 'Common credit limit at latest activation'
--     ,activate_campaign_credit_limit decimal(30, 10) comment 'Campaign credit limit at latest activation'
--     ,activate_interest_rate_1m decimal(30, 10) comment 'Interest rate for 1 month tenure at latest activation'
--     ,activate_interest_rate_2m decimal(30, 10) comment 'Interest rate for 2 month tenure at latest activation'
--     ,activate_interest_rate_3m decimal(30, 10) comment 'Interest rate for 3 month tenure at latest activation'
--     ,activate_interest_rate_6m decimal(30, 10) comment 'Interest rate for 6 month tenure at latest activation'
--     ,activate_interest_rate_9m decimal(30, 10) comment 'Interest rate for 9 month tenure at latest activation'
--     ,activate_interest_rate_12m decimal(30, 10) comment 'Interest rate for 12 month tenure at latest activation'
--     ,activate_interest_rate_18m decimal(30, 10) comment 'Interest rate for 18 month tenure at latest activation'
--     ,activate_interest_rate_24m decimal(30, 10) comment 'Interest rate for 24 month tenure at latest activation'
-- )
-- partitioned by (
--     grass_date string 
-- ) 
-- stored as orc 
-- comment 'risk user base summary table'
-- tblproperties
-- (
--     "orc.compress" = "zstd"
--     ,"orc.stripe.size" = "268635456"
-- )
-- location '${HDFS_PATH}/risk_feature/ads/ads_risk_${table_product}_${table_region}_user_df/grass_region=${region}'
-- ;
-- msck repair table ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df
-- ;


ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN month_since_activation month_since_activation int COMMENT 'Month since activation';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN first_application_time first_application_time string COMMENT 'First application time';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN last_application_time last_application_time string COMMENT 'Last application time';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN is_whitelist is_whitelist int COMMENT 'Whether user is in whitelist';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN whitelist_time whitelist_time string COMMENT 'Whitelist time';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN common_perm_credit_limit common_perm_credit_limit decimal(30, 10) COMMENT 'Common permanent credit limit';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN common_perm_frozen_credit_amount common_perm_frozen_credit_amount decimal(30, 10) COMMENT 'Common permanent frozen credit amount';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN common_perm_used_credit_amount common_perm_used_credit_amount decimal(30, 10) COMMENT 'Common permanent used credit amount';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN common_perm_available_credit_amount common_perm_available_credit_amount decimal(30, 10) COMMENT 'base - frozen - used';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN common_temp_credit_limit common_temp_credit_limit decimal(30, 10) COMMENT 'Common temporary credit limit';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN common_temp_frozen_credit_amount common_temp_frozen_credit_amount decimal(30, 10) COMMENT 'Common temporary frozen credit amount';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN common_temp_used_credit_amount common_temp_used_credit_amount decimal(30, 10) COMMENT 'Common temporary used credit amount';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN common_temp_available_credit_amount common_temp_available_credit_amount decimal(30, 10) COMMENT 'base - frozen - used';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN campaign_temp_credit_limit campaign_temp_credit_limit decimal(30, 10) COMMENT 'Campaign temporary credit limit';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN campaign_temp_frozen_credit_amount campaign_temp_frozen_credit_amount decimal(30, 10) COMMENT 'Campaign temporary frozen credit amount';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN campaign_temp_used_credit_amount campaign_temp_used_credit_amount decimal(30, 10) COMMENT 'Campaign temporary used credit amount';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN campaign_temp_available_credit_amount campaign_temp_available_credit_amount decimal(30, 10) COMMENT 'base - frozen - used';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN total_credit_limit total_credit_limit decimal(30, 10) COMMENT 'Total credit limit';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN total_used_credit_amount total_used_credit_amount decimal(30, 10) COMMENT 'Total used credit amount';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN total_frozen_credit_amount total_frozen_credit_amount decimal(30, 10) COMMENT 'Total frozen credit amount';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN common_perm_credit_limit_utilization common_perm_credit_limit_utilization decimal(30, 10) COMMENT 'Common permanent credit limit utilization rate';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN common_temp_credit_limit_utilization common_temp_credit_limit_utilization decimal(30, 10) COMMENT 'Common temporary credit limit utilization rate';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN campaign_temp_credit_limit_utilization campaign_temp_credit_limit_utilization decimal(30, 10) COMMENT 'Campaign temporary credit limit utilization rate';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN total_credit_amount_utilization total_credit_amount_utilization decimal(30, 10) COMMENT 'Total credit amount utilization rate';

ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN max_common_perm_credit_limit_utilization_30d max_common_perm_credit_limit_utilization_30d decimal(30, 10) COMMENT 'Max common permanent credit limit utilization in last 30 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN max_common_temp_credit_limit_utilization_30d max_common_temp_credit_limit_utilization_30d decimal(30, 10) COMMENT 'Max common temporary credit limit utilization in last 30 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN max_campaign_temp_credit_limit_utilization_30d max_campaign_temp_credit_limit_utilization_30d decimal(30, 10) COMMENT 'Max campaign temporary credit limit utilization in last 30 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN max_total_credit_amount_utilization_30d max_total_credit_amount_utilization_30d decimal(30, 10) COMMENT 'Max total credit amount utilization in last 30 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN min_common_perm_credit_limit_utilization_30d min_common_perm_credit_limit_utilization_30d decimal(30, 10) COMMENT 'Min common permanent credit limit utilization in last 30 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN min_common_temp_credit_limit_utilization_30d min_common_temp_credit_limit_utilization_30d decimal(30, 10) COMMENT 'Min common temporary credit limit utilization in last 30 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN min_campaign_temp_credit_limit_utilization_30d min_campaign_temp_credit_limit_utilization_30d decimal(30, 10) COMMENT 'Min campaign temporary credit limit utilization in last 30 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN min_total_credit_amount_utilization_30d min_total_credit_amount_utilization_30d decimal(30, 10) COMMENT 'Min total credit amount utilization in last 30 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN avg_common_perm_credit_limit_utilization_30d avg_common_perm_credit_limit_utilization_30d decimal(30, 10) COMMENT 'Avg common permanent credit limit utilization in last 30 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN avg_common_temp_credit_limit_utilization_30d avg_common_temp_credit_limit_utilization_30d decimal(30, 10) COMMENT 'Avg common temporary credit limit utilization in last 30 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN avg_campaign_temp_credit_limit_utilization_30d avg_campaign_temp_credit_limit_utilization_30d decimal(30, 10) COMMENT 'Avg campaign temporary credit limit utilization in last 30 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN avg_total_credit_amount_utilization_30d avg_total_credit_amount_utilization_30d decimal(30, 10) COMMENT 'Avg total credit amount utilization in last 30 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN med_common_perm_credit_limit_utilization_30d med_common_perm_credit_limit_utilization_30d decimal(30, 10) COMMENT 'Median common permanent credit limit utilization in last 30 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN med_common_temp_credit_limit_utilization_30d med_common_temp_credit_limit_utilization_30d decimal(30, 10) COMMENT 'Median common temporary credit limit utilization in last 30 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN med_campaign_temp_credit_limit_utilization_30d med_campaign_temp_credit_limit_utilization_30d decimal(30, 10) COMMENT 'Median campaign temporary credit limit utilization in last 30 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN med_total_credit_amount_utilization_30d med_total_credit_amount_utilization_30d decimal(30, 10) COMMENT 'Median total credit amount utilization in last 30 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN max_common_perm_credit_limit_utilization_90d max_common_perm_credit_limit_utilization_90d decimal(30, 10) COMMENT 'Max common permanent credit limit utilization in last 90 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN max_common_temp_credit_limit_utilization_90d max_common_temp_credit_limit_utilization_90d decimal(30, 10) COMMENT 'Max common temporary credit limit utilization in last 90 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN max_campaign_temp_credit_limit_utilization_90d max_campaign_temp_credit_limit_utilization_90d decimal(30, 10) COMMENT 'Max campaign temporary credit limit utilization in last 90 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN max_total_credit_amount_utilization_90d max_total_credit_amount_utilization_90d decimal(30, 10) COMMENT 'Max total credit amount utilization in last 90 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN min_common_perm_credit_limit_utilization_90d min_common_perm_credit_limit_utilization_90d decimal(30, 10) COMMENT 'Min common permanent credit limit utilization in last 90 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN min_common_temp_credit_limit_utilization_90d min_common_temp_credit_limit_utilization_90d decimal(30, 10) COMMENT 'Min common temporary credit limit utilization in last 90 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN min_campaign_temp_credit_limit_utilization_90d min_campaign_temp_credit_limit_utilization_90d decimal(30, 10) COMMENT 'Min campaign temporary credit limit utilization in last 90 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN min_total_credit_amount_utilization_90d min_total_credit_amount_utilization_90d decimal(30, 10) COMMENT 'Min total credit amount utilization in last 90 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN avg_common_perm_credit_limit_utilization_90d avg_common_perm_credit_limit_utilization_90d decimal(30, 10) COMMENT 'Avg common permanent credit limit utilization in last 90 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN avg_common_temp_credit_limit_utilization_90d avg_common_temp_credit_limit_utilization_90d decimal(30, 10) COMMENT 'Avg common temporary credit limit utilization in last 90 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN avg_campaign_temp_credit_limit_utilization_90d avg_campaign_temp_credit_limit_utilization_90d decimal(30, 10) COMMENT 'Avg campaign temporary credit limit utilization in last 90 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN avg_total_credit_amount_utilization_90d avg_total_credit_amount_utilization_90d decimal(30, 10) COMMENT 'Avg total credit amount utilization in last 90 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN med_common_perm_credit_limit_utilization_90d med_common_perm_credit_limit_utilization_90d decimal(30, 10) COMMENT 'Median common permanent credit limit utilization in last 90 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN med_common_temp_credit_limit_utilization_90d med_common_temp_credit_limit_utilization_90d decimal(30, 10) COMMENT 'Median common temporary credit limit utilization in last 90 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN med_campaign_temp_credit_limit_utilization_90d med_campaign_temp_credit_limit_utilization_90d decimal(30, 10) COMMENT 'Median campaign temporary credit limit utilization in last 90 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN med_total_credit_amount_utilization_90d med_total_credit_amount_utilization_90d decimal(30, 10) COMMENT 'Median total credit amount utilization in last 90 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN max_common_perm_credit_limit_utilization_180d max_common_perm_credit_limit_utilization_180d decimal(30, 10) COMMENT 'Max common permanent credit limit utilization in last 180 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN max_common_temp_credit_limit_utilization_180d max_common_temp_credit_limit_utilization_180d decimal(30, 10) COMMENT 'Max common temporary credit limit utilization in last 180 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN max_campaign_temp_credit_limit_utilization_180d max_campaign_temp_credit_limit_utilization_180d decimal(30, 10) COMMENT 'Max campaign temporary credit limit utilization in last 180 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN max_total_credit_amount_utilization_180d max_total_credit_amount_utilization_180d decimal(30, 10) COMMENT 'Max total credit amount utilization in last 180 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN min_common_perm_credit_limit_utilization_180d min_common_perm_credit_limit_utilization_180d decimal(30, 10) COMMENT 'Min common permanent credit limit utilization in last 180 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN min_common_temp_credit_limit_utilization_180d min_common_temp_credit_limit_utilization_180d decimal(30, 10) COMMENT 'Min common temporary credit limit utilization in last 180 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN min_campaign_temp_credit_limit_utilization_180d min_campaign_temp_credit_limit_utilization_180d decimal(30, 10) COMMENT 'Min campaign temporary credit limit utilization in last 180 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN min_total_credit_amount_utilization_180d min_total_credit_amount_utilization_180d decimal(30, 10) COMMENT 'Min total credit amount utilization in last 180 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN avg_common_perm_credit_limit_utilization_180d avg_common_perm_credit_limit_utilization_180d decimal(30, 10) COMMENT 'Avg common permanent credit limit utilization in last 180 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN avg_common_temp_credit_limit_utilization_180d avg_common_temp_credit_limit_utilization_180d decimal(30, 10) COMMENT 'Avg common temporary credit limit utilization in last 180 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN avg_campaign_temp_credit_limit_utilization_180d avg_campaign_temp_credit_limit_utilization_180d decimal(30, 10) COMMENT 'Avg campaign temporary credit limit utilization in last 180 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN avg_total_credit_amount_utilization_180d avg_total_credit_amount_utilization_180d decimal(30, 10) COMMENT 'Avg total credit amount utilization in last 180 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN med_common_perm_credit_limit_utilization_180d med_common_perm_credit_limit_utilization_180d decimal(30, 10) COMMENT 'Median common permanent credit limit utilization in last 180 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN med_common_temp_credit_limit_utilization_180d med_common_temp_credit_limit_utilization_180d decimal(30, 10) COMMENT 'Median common temporary credit limit utilization in last 180 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN med_campaign_temp_credit_limit_utilization_180d med_campaign_temp_credit_limit_utilization_180d decimal(30, 10) COMMENT 'Median campaign temporary credit limit utilization in last 180 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN med_total_credit_amount_utilization_180d med_total_credit_amount_utilization_180d decimal(30, 10) COMMENT 'Median total credit amount utilization in last 180 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN max_common_perm_credit_limit_utilization_360d max_common_perm_credit_limit_utilization_360d decimal(30, 10) COMMENT 'Max common permanent credit limit utilization in last 360 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN max_common_temp_credit_limit_utilization_360d max_common_temp_credit_limit_utilization_360d decimal(30, 10) COMMENT 'Max common temporary credit limit utilization in last 360 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN max_campaign_temp_credit_limit_utilization_360d max_campaign_temp_credit_limit_utilization_360d decimal(30, 10) COMMENT 'Max campaign temporary credit limit utilization in last 360 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN max_total_credit_amount_utilization_360d max_total_credit_amount_utilization_360d decimal(30, 10) COMMENT 'Max total credit amount utilization in last 360 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN min_common_perm_credit_limit_utilization_360d min_common_perm_credit_limit_utilization_360d decimal(30, 10) COMMENT 'Min common permanent credit limit utilization in last 360 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN min_common_temp_credit_limit_utilization_360d min_common_temp_credit_limit_utilization_360d decimal(30, 10) COMMENT 'Min common temporary credit limit utilization in last 360 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN min_campaign_temp_credit_limit_utilization_360d min_campaign_temp_credit_limit_utilization_360d decimal(30, 10) COMMENT 'Min campaign temporary credit limit utilization in last 360 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN min_total_credit_amount_utilization_360d min_total_credit_amount_utilization_360d decimal(30, 10) COMMENT 'Min total credit amount utilization in last 360 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN avg_common_perm_credit_limit_utilization_360d avg_common_perm_credit_limit_utilization_360d decimal(30, 10) COMMENT 'Avg common permanent credit limit utilization in last 360 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN avg_common_temp_credit_limit_utilization_360d avg_common_temp_credit_limit_utilization_360d decimal(30, 10) COMMENT 'Avg common temporary credit limit utilization in last 360 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN avg_campaign_temp_credit_limit_utilization_360d avg_campaign_temp_credit_limit_utilization_360d decimal(30, 10) COMMENT 'Avg campaign temporary credit limit utilization in last 360 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN avg_total_credit_amount_utilization_360d avg_total_credit_amount_utilization_360d decimal(30, 10) COMMENT 'Avg total credit amount utilization in last 360 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN med_common_perm_credit_limit_utilization_360d med_common_perm_credit_limit_utilization_360d decimal(30, 10) COMMENT 'Median common permanent credit limit utilization in last 360 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN med_common_temp_credit_limit_utilization_360d med_common_temp_credit_limit_utilization_360d decimal(30, 10) COMMENT 'Median common temporary credit limit utilization in last 360 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN med_campaign_temp_credit_limit_utilization_360d med_campaign_temp_credit_limit_utilization_360d decimal(30, 10) COMMENT 'Median campaign temporary credit limit utilization in last 360 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN med_total_credit_amount_utilization_360d med_total_credit_amount_utilization_360d decimal(30, 10) COMMENT 'Median total credit amount utilization in last 360 days';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN activate_common_credit_limit activate_common_credit_limit decimal(30, 10) COMMENT 'Common credit limit at latest activation';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN activate_campaign_credit_limit activate_campaign_credit_limit decimal(30, 10) COMMENT 'Campaign credit limit at latest activation';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN activate_interest_rate_1m activate_interest_rate_1m decimal(30, 10) COMMENT 'Interest rate for 1 month tenure at latest activation';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN activate_interest_rate_2m activate_interest_rate_2m decimal(30, 10) COMMENT 'Interest rate for 2 month tenure at latest activation';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN activate_interest_rate_3m activate_interest_rate_3m decimal(30, 10) COMMENT 'Interest rate for 3 month tenure at latest activation';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN activate_interest_rate_6m activate_interest_rate_6m decimal(30, 10) COMMENT 'Interest rate for 6 month tenure at latest activation';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN activate_interest_rate_9m activate_interest_rate_9m decimal(30, 10) COMMENT 'Interest rate for 9 month tenure at latest activation';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN activate_interest_rate_12m activate_interest_rate_12m decimal(30, 10) COMMENT 'Interest rate for 12 month tenure at latest activation';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN activate_interest_rate_18m activate_interest_rate_18m decimal(30, 10) COMMENT 'Interest rate for 18 month tenure at latest activation';
ALTER TABLE ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df CHANGE COLUMN activate_interest_rate_24m activate_interest_rate_24m decimal(30, 10) COMMENT 'Interest rate for 24 month tenure at latest activation';