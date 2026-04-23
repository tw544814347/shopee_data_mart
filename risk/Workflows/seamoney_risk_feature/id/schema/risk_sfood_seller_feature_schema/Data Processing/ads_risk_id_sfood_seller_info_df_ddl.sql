-- PRD: https://docs.google.com/spreadsheets/d/1PltFr0KoEUdO89WfbhpeIv2SE-jQVOEPcgCkdEQS6SM/edit?gid=277316402#gid=277316402

--********************************************************************--
-- Author:              jialiang.nie@shopee.com
-- Created Time:        2024-09-09
-- Theme Domain：        risk shopee food feature
-- Description:          
-- Data Granularity:    
-- jira : https://jira.shopee.io/browse/SPFDT-42557 逻辑: https://docs.google.com/spreadsheets/d/1PltFr0KoEUdO89WfbhpeIv2SE-jQVOEPcgCkdEQS6SM/edit?gid=277316402#gid=277316402
-- 变更历史：
--********************************************************************--

-- ^core ID mapping base table logic as shows below (SCL口径全量platform user id):
-- 实现思路：取全量merchant ID，关联有效的nationID，匹配credit UID，检查UC侧用户冻结状态，再在用户维度聚合merchant和Store ID，最终完成全量用户在几个ID实体间的关联逻辑。

-- 卖家的一些基础信息和指标
-- 用户范围
--      merchantservice.mss_merchant_info_id_db__customer_entity_info_relation_tab__reg_daily_s0_live对应的所有未冻结或最新更新的platform_user_id
-- 字段含义
--      national_id: 身份证号
--      merchant_id_list: 卖家名下的所有merchant
--      is_valid_food_merchant: 是否是好卖家, when platform_user_id为null then 0 else when 卖家信息与白名单一致 then 2 else 1
--      avg_merhcant_ktp_change_cnt_7d: 用户身份证号的更改指标(7天内)

drop table if exists ${SCHEMA}.ads_risk_${table_region}_sfood_seller_info_df;
create external table if not exists ${SCHEMA}.ads_risk_${table_region}_sfood_seller_info_df
(
    platform_user_id string	
    ,credit_user_id string	
    ,national_id string	
    ,other_platform_user_id string	
    ,uc_update_time string	
    ,merchant_id_list string
    ,num_mid bigint
    ,store_id_list string
    ,num_sid bigint
    ,is_valid_food_merchant bigint
    ,avg_merhcant_ktp_change_cnt_7d decimal(30,10)
    ,avg_merhcant_ktp_change_cnt_30d decimal(30,10)
    ,wl_merchant_id_list string
)
partitioned by
(
    grass_date string comment 'yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="268435456")
LOCATION '${HDFS_PATH}/ads/ads_risk_sfood_seller_info_df/grass_region=${region}';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_${table_region}_sfood_seller_info_df;

;
