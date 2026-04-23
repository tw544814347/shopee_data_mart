
--********************************************************************--
-- Author:              jialiang.nie@shopee.com
-- Created Time:        2024-09-09
-- Theme Domain：        risk shopee food feature
-- Description:          
-- Data Granularity:    
-- jira : https://jira.shopee.io/browse/SPFDT-42557 逻辑: https://docs.google.com/spreadsheets/d/1PltFr0KoEUdO89WfbhpeIv2SE-jQVOEPcgCkdEQS6SM/edit?gid=0#gid=0
-- 变更历史：
--********************************************************************--
-- feature整合，提供结果表到datos

drop table if exists ${SCHEMA}.ads_risk_${table_region}_sfood_seller_feature_df;
create external table if not exists ${SCHEMA}.ads_risk_${table_region}_sfood_seller_feature_df
(
    platform_user_id string	
    ,credit_user_id string	
    ,food_national_id string	
    ,food_other_platform_user_id string	
    ,food_uc_update_time string	
    ,full_merchant_list string
    ,food_num_mid bigint
    ,full_store_list string
    ,food_num_sid bigint
    ,is_valid_food_merchant bigint
    ,avg_merchant_ktp_chg_7d decimal(30,5)
    ,avg_merchant_ktp_chg_30d decimal(30,5)
    ,white_merchant_list string	
    ,food_txn_days_l6m bigint	
    ,food_inactive_4_days bigint	
    ,food_avg_order_cnt_l6m decimal(30,5)	
    ,food_avg_nmv_l6m decimal(30,5)	
    ,food_nmv_l1m decimal(30,5)	
    ,food_nmv_l3m decimal(30,5)	
    ,food_nmv_l5_l6m decimal(30,5)
    ,food_order_cnt_l1m bigint	
    ,food_order_cnt_l5_l6m bigint	
    ,food_txn_mth_l12m bigint	
    ,food_avg_buyer_cnt_l6m decimal(30,5)	
    ,food_cancel_rate_l7d decimal(30,5)	
    ,food_cancel_rate_l15d decimal(30,5)	
    ,food_nmv_drop_16 decimal(30,5)	
    ,food_order_cnt_drop_16 decimal(30,5)
    ,food_nmv_l1_l2m decimal(30,5)
    ,food_nmv_l2_l3m decimal(30,5)
    ,food_nmv_l3_l4m decimal(30,5)
    ,food_nmv_l4_l5m decimal(30,5)
    ,food_weighted_avg_nmv decimal(30,5)
)
partitioned by
(
    grass_date string comment 'yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="268435456")
LOCATION '${HDFS_PATH}/ads/ads_risk_sfood_seller_feature_df/grass_region=${region}';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_${table_region}_sfood_seller_feature_df;
;
