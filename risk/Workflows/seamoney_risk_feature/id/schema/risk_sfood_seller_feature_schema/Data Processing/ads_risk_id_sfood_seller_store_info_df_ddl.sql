
--********************************************************************--
-- Author:              jialiang.nie@shopee.com
-- Created Time:        2024-09-09
-- Theme Domain：        risk shopee food feature
-- Description:          
-- Data Granularity:    
-- jira : https://jira.shopee.io/browse/SPFDT-42557 逻辑: https://docs.google.com/spreadsheets/d/1PltFr0KoEUdO89WfbhpeIv2SE-jQVOEPcgCkdEQS6SM/edit?gid=75538526#gid=75538526
-- 变更历史：
--********************************************************************--


-- 卖家商店的交易相关feature
-- 用户范围
--      smcdrisk_policy.id_foody_merchant_platform_mapping, 风控上传的白名单表, 每月更新一次
-- 字段含义
--      NMV(Net Merchandise Volume) 净交易总额，区别于GMV(Gross Merchandise Volume)
--      txn_days_l6m 最近6个月有过交易的天数
--      num_inactive_4_consec_days 连续4天不活跃的次数
--      avg_order_cnt_l6m 最近6个月的平均单量
--      nmv_l1m 最近一个月的平均单量
--      txn_mth_l12m 最近12个月内, 有过交易的月份数
--      nmv_drop_16 商家过去30天的NMV与150-180天前的NMV的比率




drop table if exists ${SCHEMA}.ads_risk_${table_region}_sfood_seller_store_info_df;
create external table if not exists ${SCHEMA}.ads_risk_${table_region}_sfood_seller_store_info_df
(
    platform_user_id string	
    ,txn_days_l6m bigint	
    ,num_inactive_4_consec_days bigint	
    ,avg_order_cnt_l6m bigint	
    ,avg_nmv_l6m decimal(30,5)	
    ,nmv_l1m decimal(30,5)	
    ,nmv_l3m decimal(30,5)	
    ,nmv_l5_l6m decimal(30,5)	
    ,order_cnt_l1m bigint	
    ,order_cnt_l5_l6m bigint	
    ,txn_mth_l12m bigint	
    ,avg_buyer_cnt_l6m bigint	
    ,cancel_rate_l7d decimal(30,5)	
    ,cancel_rate_l15d decimal(30,5)	
    ,nmv_drop_16 decimal(30,5)	
    ,order_cnt_drop_16 decimal(30,5)	
    ,nmv_l1_l2m decimal(30,5)
    ,nmv_l2_l3m decimal(30,5)
    ,nmv_l3_l4m decimal(30,5)
    ,nmv_l4_l5m decimal(30,5)
    ,weighted_avg_nmv decimal(30,5)
)
partitioned by
(
    grass_date string comment 'yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="268435456")
LOCATION '${HDFS_PATH}/ads/ads_risk_sfood_seller_store_info_df/grass_region=${region}';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_${table_region}_sfood_seller_store_info_df;
