drop table if exists ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df;
create external table if not exists ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df (
    credit_user_id                          string          comment 'credit user id'
    ,platform_user_id                       string          comment 'shopee user id'
    ,sp_user_id                             string          comment 'shopee user id'
    ,spp_user_id                            string          comment 'shopeepay user id'
    ,product_id                             string          comment 'product id'
    ,user_status                            string          comment 'user status'
    ,is_limit_expired                       int             comment 'Whether limit is expired'
    ,has_valid_activated                    int             comment 'Whether has valid activated'
    ,first_activation_time                  string          comment 'First activation time'
    ,new_activation_time                    string          comment 'New activation time'
    ,month_since_activation                 int             comment 'Month since activation'
    ,is_activated_l1d                       int             comment 'Whether activated in last 1 day'
    ,is_activated_l30d                      int             comment 'Whether activated in last 30 days'
    ,is_activated_l90d                      int             comment 'Whether activated in last 90 days'
    ,is_activated_l180d                     int             comment 'Whether activated in last 180 days'
    ,is_activated_l360d                     int             comment 'Whether activated in last 360 days'
    ,first_application_time                 string          comment 'First application time'
    ,last_application_time                  string          comment 'Last application time'
    ,is_whitelist                           int             comment 'Whether user is in whitelist'
    ,whitelist_time                         string          comment 'Whitelist time'
    ,common_perm_credit_limit               decimal(30, 10) comment 'Common permanent credit limit'
    ,common_perm_frozen_credit_amount       decimal(30, 10) comment 'Common permanent frozen credit amount'
    ,common_perm_used_credit_amount         decimal(30, 10) comment 'Common permanent used credit amount'
    ,common_perm_available_credit_amount    decimal(30, 10) comment 'base - frozen - used'
    ,common_temp_credit_limit               decimal(30, 10) comment 'Common temporary credit limit'
    ,common_temp_frozen_credit_amount       decimal(30, 10) comment 'Common temporary frozen credit amount'
    ,common_temp_used_credit_amount         decimal(30, 10) comment 'Common temporary used credit amount'
    ,common_temp_available_credit_amount    decimal(30, 10) comment 'base - frozen - used'
    ,campaign_temp_credit_limit             decimal(30, 10) comment 'Campaign temporary credit limit'
    ,campaign_temp_frozen_credit_amount     decimal(30, 10) comment 'Campaign temporary frozen credit amount'
    ,campaign_temp_used_credit_amount       decimal(30, 10) comment 'Campaign temporary used credit amount'
    ,campaign_temp_available_credit_amount    decimal(30, 10) comment 'base - frozen - used'
    ,total_credit_limit                     decimal(30, 10) comment 'Total credit limit'
    ,total_used_credit_amount               decimal(30, 10) comment 'Total used credit amount'
    ,total_frozen_credit_amount             decimal(30, 10) comment 'Total frozen credit amount'
    ,common_perm_credit_limit_utilization   decimal(30, 10) comment 'Common permanent credit limit utilization rate'
    ,common_temp_credit_limit_utilization   decimal(30, 10) comment 'Common temporary credit limit utilization rate'
    ,campaign_temp_credit_limit_utilization decimal(30, 10) comment 'Campaign temporary credit limit utilization rate'
    ,total_credit_amount_utilization        decimal(30, 10) comment 'Total credit amount utilization rate'
    ,is_eligible_for_1m                     int             comment 'Whether eligible for 1 month tenure'
    ,is_eligible_for_2m                     int             comment 'Whether eligible for 2 month tenure'
    ,is_eligible_for_3m                     int             comment 'Whether eligible for 3 month tenure'
    ,is_eligible_for_6m                     int             comment 'Whether eligible for 6 month tenure'
    ,is_eligible_for_9m                     int             comment 'Whether eligible for 9 month tenure'
    ,is_eligible_for_12m                    int             comment 'Whether eligible for 12 month tenure'
    ,is_eligible_for_18m                    int             comment 'Whether eligible for 18 month tenure'
    ,is_eligible_for_24m                    int             comment 'Whether eligible for 24 month tenure'
    ,interest_rate_1m                       decimal(30, 10) comment 'eir for 1 month tenure'
    ,interest_rate_2m                       decimal(30, 10) comment 'eir for 2 month tenure'
    ,interest_rate_3m                       decimal(30, 10) comment 'eir for 3 month tenure'
    ,interest_rate_6m                       decimal(30, 10) comment 'eir for 6 month tenure'
    ,interest_rate_9m                       decimal(30, 10) comment 'eir for 9 month tenure'
    ,interest_rate_12m                      decimal(30, 10) comment 'eir for 12 month tenure'
    ,interest_rate_18m                      decimal(30, 10) comment 'eir for 18 month tenure'
    ,interest_rate_24m                      decimal(30, 10) comment 'eir for 24 month tenure'
    ,is_post_kyc_freeze                     int             comment 'Whether post kyc freeze'
    ,is_post_fraud_freeze                   int             comment 'Whether post fraud freeze'
    ,is_overdue_freeze                      int             comment 'Whether overdue freeze'
    ,is_restructure_freeze                  int             comment 'Whether restructure freeze'
    ,is_dpd_freeze                          int             comment 'Whether dpd freeze'
    ,is_underwriting_freeze                 int             comment 'Whether underwriting freeze'
    ,is_acc_closure_freeze                  int             comment 'Whether acc closure freeze'
    ,is_shopee_freeze                       int             comment 'Whether shopee freeze'
    ,is_limit_expired_freeze                int             comment 'Whether limit expired freeze'
    ,is_payment_reject_freeze               int             comment 'Whether payment reject freeze'
    ,max_common_perm_credit_limit_utilization_30d decimal(30, 10)
    ,max_common_temp_credit_limit_utilization_30d  decimal(30, 10)
    ,max_campaign_temp_credit_limit_utilization_30d decimal(30, 10)
    ,max_total_credit_amount_utilization_30d decimal(30, 10)
    ,min_common_perm_credit_limit_utilization_30d decimal(30, 10)
    ,min_common_temp_credit_limit_utilization_30d decimal(30, 10)
    ,min_campaign_temp_credit_limit_utilization_30d decimal(30, 10)
    ,min_total_credit_amount_utilization_30d decimal(30, 10)
    ,avg_common_perm_credit_limit_utilization_30d decimal(30, 10)
    ,avg_common_temp_credit_limit_utilization_30d decimal(30, 10)
    ,avg_campaign_temp_credit_limit_utilization_30d decimal(30, 10)
    ,avg_total_credit_amount_utilization_30d decimal(30, 10)
    ,med_common_perm_credit_limit_utilization_30d decimal(30, 10)
    ,med_common_temp_credit_limit_utilization_30d decimal(30, 10)
    ,med_campaign_temp_credit_limit_utilization_30d decimal(30, 10)
    ,med_total_credit_amount_utilization_30d decimal(30, 10)
    ,max_common_perm_credit_limit_utilization_90d decimal(30, 10)
    ,max_common_temp_credit_limit_utilization_90d decimal(30, 10)
    ,max_campaign_temp_credit_limit_utilization_90d decimal(30, 10)
    ,max_total_credit_amount_utilization_90d decimal(30, 10)
    ,min_common_perm_credit_limit_utilization_90d decimal(30, 10)
    ,min_common_temp_credit_limit_utilization_90d decimal(30, 10)
    ,min_campaign_temp_credit_limit_utilization_90d decimal(30, 10)
    ,min_total_credit_amount_utilization_90d decimal(30, 10)
    ,avg_common_perm_credit_limit_utilization_90d decimal(30, 10)
    ,avg_common_temp_credit_limit_utilization_90d decimal(30, 10)
    ,avg_campaign_temp_credit_limit_utilization_90d decimal(30, 10)
    ,avg_total_credit_amount_utilization_90d decimal(30, 10)
    ,med_common_perm_credit_limit_utilization_90d decimal(30, 10)
    ,med_common_temp_credit_limit_utilization_90d decimal(30, 10)
    ,med_campaign_temp_credit_limit_utilization_90d decimal(30, 10)
    ,med_total_credit_amount_utilization_90d decimal(30, 10)
    ,max_common_perm_credit_limit_utilization_180d decimal(30, 10)
    ,max_common_temp_credit_limit_utilization_180d decimal(30, 10)
    ,max_campaign_temp_credit_limit_utilization_180d decimal(30, 10)
    ,max_total_credit_amount_utilization_180d decimal(30, 10)
    ,min_common_perm_credit_limit_utilization_180d decimal(30, 10)
    ,min_common_temp_credit_limit_utilization_180d decimal(30, 10)
    ,min_campaign_temp_credit_limit_utilization_180d decimal(30, 10)
    ,min_total_credit_amount_utilization_180d decimal(30, 10)
    ,avg_common_perm_credit_limit_utilization_180d decimal(30, 10)
    ,avg_common_temp_credit_limit_utilization_180d decimal(30, 10)
    ,avg_campaign_temp_credit_limit_utilization_180d decimal(30, 10)
    ,avg_total_credit_amount_utilization_180d decimal(30, 10)
    ,med_common_perm_credit_limit_utilization_180d decimal(30, 10)
    ,med_common_temp_credit_limit_utilization_180d decimal(30, 10)
    ,med_campaign_temp_credit_limit_utilization_180d decimal(30, 10)
    ,med_total_credit_amount_utilization_180d decimal(30, 10)
    ,max_common_perm_credit_limit_utilization_360d decimal(30, 10)
    ,max_common_temp_credit_limit_utilization_360d decimal(30, 10)
    ,max_campaign_temp_credit_limit_utilization_360d decimal(30, 10)
    ,max_total_credit_amount_utilization_360d decimal(30, 10)
    ,min_common_perm_credit_limit_utilization_360d decimal(30, 10)
    ,min_common_temp_credit_limit_utilization_360d decimal(30, 10)
    ,min_campaign_temp_credit_limit_utilization_360d decimal(30, 10)
    ,min_total_credit_amount_utilization_360d decimal(30, 10)
    ,avg_common_perm_credit_limit_utilization_360d decimal(30, 10)
    ,avg_common_temp_credit_limit_utilization_360d decimal(30, 10)
    ,avg_campaign_temp_credit_limit_utilization_360d decimal(30, 10)
    ,avg_total_credit_amount_utilization_360d decimal(30, 10)
    ,med_common_perm_credit_limit_utilization_360d decimal(30, 10)
    ,med_common_temp_credit_limit_utilization_360d decimal(30, 10)
    ,med_campaign_temp_credit_limit_utilization_360d decimal(30, 10)
    ,med_total_credit_amount_utilization_360d decimal(30, 10)
    -- amount/interest rate when latest activated
    ,activate_common_credit_limit decimal(30, 10)
    ,activate_campaign_credit_limit decimal(30, 10)
    ,activate_interest_rate_1m decimal(30, 10)
    ,activate_interest_rate_2m decimal(30, 10)
    ,activate_interest_rate_3m decimal(30, 10)
    ,activate_interest_rate_6m decimal(30, 10)
    ,activate_interest_rate_9m decimal(30, 10)
    ,activate_interest_rate_12m decimal(30, 10)
    ,activate_interest_rate_18m decimal(30, 10)
    ,activate_interest_rate_24m decimal(30, 10)
)
partitioned by (
    grass_date string 
) 
stored as orc 
comment 'risk user base summary table'
tblproperties
(
    "orc.compress" = "zstd"
    ,"orc.stripe.size" = "268635456"
)
location '${HDFS_PATH}/risk_feature/ads/ads_risk_${table_product}_${table_region}_user_df/grass_region=${region}'
;
msck repair table ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df
; 

create or replace view ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_feature_df 
comment 'credit uc summary table'
as 
select 
    credit_user_id
    ,platform_user_id
    ,sp_user_id
    ,spp_user_id
    ,product_id
    ,user_status
    ,is_limit_expired
    ,has_valid_activated
    ,first_activation_time
    ,new_activation_time
    ,month_since_activation
    ,is_activated_l1d
    ,is_activated_l30d
    ,is_activated_l90d
    ,is_activated_l180d
    ,is_activated_l360d
    ,first_application_time
    ,last_application_time
    -- ,is_whitelist
    -- ,whitelist_time
    ,common_perm_credit_limit
    ,common_perm_frozen_credit_amount
    ,common_perm_used_credit_amount
    ,common_perm_available_credit_amount
    ,common_temp_credit_limit
    ,common_temp_frozen_credit_amount
    ,common_temp_used_credit_amount
    ,common_temp_available_credit_amount
    ,campaign_temp_credit_limit
    ,campaign_temp_frozen_credit_amount
    ,campaign_temp_used_credit_amount
    ,campaign_temp_available_credit_amount
    ,total_credit_limit
    ,total_used_credit_amount
    ,total_frozen_credit_amount
    ,common_perm_credit_limit_utilization
    ,common_temp_credit_limit_utilization
    ,campaign_temp_credit_limit_utilization
    ,total_credit_amount_utilization
    ,is_eligible_for_1m
    ,is_eligible_for_2m
    ,is_eligible_for_3m
    ,is_eligible_for_6m
    ,is_eligible_for_9m
    ,is_eligible_for_12m
    ,is_eligible_for_18m
    ,is_eligible_for_24m
    ,interest_rate_1m
    ,interest_rate_2m
    ,interest_rate_3m
    ,interest_rate_6m
    ,interest_rate_9m
    ,interest_rate_12m
    ,interest_rate_18m
    ,interest_rate_24m
    -- ,is_post_kyc_freeze
    -- ,is_post_fraud_freeze
    -- ,is_overdue_freeze 
    -- ,is_restructure_freeze
    -- ,is_dpd_freeze
    ,is_underwriting_freeze
    ,is_acc_closure_freeze
    ,is_shopee_freeze
    ,is_limit_expired_freeze
    ,is_payment_reject_freeze
    ,max_common_perm_credit_limit_utilization_30d
    ,max_common_temp_credit_limit_utilization_30d
    ,max_campaign_temp_credit_limit_utilization_30d
    ,max_total_credit_amount_utilization_30d
    ,min_common_perm_credit_limit_utilization_30d
    ,min_common_temp_credit_limit_utilization_30d
    ,min_campaign_temp_credit_limit_utilization_30d
    ,min_total_credit_amount_utilization_30d
    ,avg_common_perm_credit_limit_utilization_30d
    ,avg_common_temp_credit_limit_utilization_30d
    ,avg_campaign_temp_credit_limit_utilization_30d
    ,avg_total_credit_amount_utilization_30d
    ,med_common_perm_credit_limit_utilization_30d
    ,med_common_temp_credit_limit_utilization_30d
    ,med_campaign_temp_credit_limit_utilization_30d
    ,med_total_credit_amount_utilization_30d
    ,max_common_perm_credit_limit_utilization_90d
    ,max_common_temp_credit_limit_utilization_90d
    ,max_campaign_temp_credit_limit_utilization_90d
    ,max_total_credit_amount_utilization_90d
    ,min_common_perm_credit_limit_utilization_90d
    ,min_common_temp_credit_limit_utilization_90d
    ,min_campaign_temp_credit_limit_utilization_90d
    ,min_total_credit_amount_utilization_90d
    ,avg_common_perm_credit_limit_utilization_90d
    ,avg_common_temp_credit_limit_utilization_90d
    ,avg_campaign_temp_credit_limit_utilization_90d
    ,avg_total_credit_amount_utilization_90d
    ,med_common_perm_credit_limit_utilization_90d
    ,med_common_temp_credit_limit_utilization_90d
    ,med_campaign_temp_credit_limit_utilization_90d
    ,med_total_credit_amount_utilization_90d
    ,max_common_perm_credit_limit_utilization_180d
    ,max_common_temp_credit_limit_utilization_180d
    ,max_campaign_temp_credit_limit_utilization_180d
    ,max_total_credit_amount_utilization_180d
    ,min_common_perm_credit_limit_utilization_180d
    ,min_common_temp_credit_limit_utilization_180d
    ,min_campaign_temp_credit_limit_utilization_180d
    ,min_total_credit_amount_utilization_180d
    ,avg_common_perm_credit_limit_utilization_180d
    ,avg_common_temp_credit_limit_utilization_180d
    ,avg_campaign_temp_credit_limit_utilization_180d
    ,avg_total_credit_amount_utilization_180d
    ,med_common_perm_credit_limit_utilization_180d
    ,med_common_temp_credit_limit_utilization_180d
    ,med_campaign_temp_credit_limit_utilization_180d
    ,med_total_credit_amount_utilization_180d
    ,max_common_perm_credit_limit_utilization_360d
    ,max_common_temp_credit_limit_utilization_360d
    ,max_campaign_temp_credit_limit_utilization_360d
    ,max_total_credit_amount_utilization_360d
    ,min_common_perm_credit_limit_utilization_360d
    ,min_common_temp_credit_limit_utilization_360d
    ,min_campaign_temp_credit_limit_utilization_360d
    ,min_total_credit_amount_utilization_360d
    ,avg_common_perm_credit_limit_utilization_360d
    ,avg_common_temp_credit_limit_utilization_360d
    ,avg_campaign_temp_credit_limit_utilization_360d
    ,avg_total_credit_amount_utilization_360d
    ,med_common_perm_credit_limit_utilization_360d
    ,med_common_temp_credit_limit_utilization_360d
    ,med_campaign_temp_credit_limit_utilization_360d
    ,med_total_credit_amount_utilization_360d
    ,activate_common_credit_limit
    ,activate_campaign_credit_limit
    ,activate_interest_rate_1m
    ,activate_interest_rate_2m
    ,activate_interest_rate_3m
    ,activate_interest_rate_6m
    ,activate_interest_rate_9m
    ,activate_interest_rate_12m
    ,activate_interest_rate_18m
    ,activate_interest_rate_24m
    ,grass_date
from ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_df
;
