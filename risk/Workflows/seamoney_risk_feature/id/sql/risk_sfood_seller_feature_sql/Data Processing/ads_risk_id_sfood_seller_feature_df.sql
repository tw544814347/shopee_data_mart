
--********************************************************************--
-- Author:              jialiang.nie@shopee.com
-- Created Time:        2024-09-09
-- Theme Domain：        risk shopee food feature
-- Description:          
-- Data Granularity:    
-- jira : https://jira.shopee.io/browse/SPFDT-42557 逻辑: https://docs.google.com/spreadsheets/d/1PltFr0KoEUdO89WfbhpeIv2SE-jQVOEPcgCkdEQS6SM/edit?gid=0#gid=0
-- 变更历史：
--      变更日期：2024-10-22 变更人: jialiang.nie 变更内容：业务提供的逻辑有误，需要把buyer_cnt_l6m，改成avg_buyer_cnt_l6m
--********************************************************************--
-- feature整合，提供结果表到datos

insert overwrite table ${SCHEMA}.ads_risk_${table_region}_sfood_seller_feature_df partition (grass_date)
select 
    t1.platform_user_id
    ,t1.credit_user_id
    ,t1.national_id as food_national_id
    ,t1.other_platform_user_id as food_other_platform_user_id
    ,t1.uc_update_time as food_uc_update_time
    ,t1.merchant_id_list as full_merchant_list
    ,t1.num_mid as food_num_mid
    ,t1.store_id_list as full_store_list
    ,t1.num_sid as food_num_sid
    ,t1.is_valid_food_merchant
    ,t1.avg_merhcant_ktp_change_cnt_7d as avg_merchant_ktp_chg_7d
    ,t1.avg_merhcant_ktp_change_cnt_30d as avg_merchant_ktp_chg_30d
    ,t1.wl_merchant_id_list as white_merchant_list
    ,coalesce(t2.txn_days_l6m, 0) as food_txn_days_l6m
    ,coalesce(t2.num_inactive_4_consec_days, 0) as food_inactive_4_days
    ,coalesce(t2.avg_order_cnt_l6m, 0) as food_avg_order_cnt_l6m
    ,coalesce(t2.avg_nmv_l6m, 0) as food_avg_nmv_l6m
    ,coalesce(t2.nmv_l1m, 0) as food_nmv_l1m
    ,coalesce(t2.nmv_l3m, 0) as food_nmv_l3m
    ,coalesce(t2.nmv_l5_l6m, 0) as food_nmv_l5_l6m
    ,coalesce(t2.order_cnt_l1m, 0) as food_order_cnt_l1m
    ,coalesce(t2.order_cnt_l5_l6m, 0) as food_order_cnt_l5_l6m
    ,coalesce(t2.txn_mth_l12m, 0) as food_txn_mth_l12m
    ,coalesce(t2.avg_buyer_cnt_l6m, 0) as food_avg_buyer_cnt_l6m
    ,coalesce(t2.cancel_rate_l7d, 0) as food_cancel_rate_l7d
    ,coalesce(t2.cancel_rate_l15d, 0) as food_cancel_rate_l15d
    ,coalesce(t2.nmv_drop_16, 0) as food_nmv_drop_16
    ,coalesce(t2.order_cnt_drop_16, 0) as food_order_cnt_drop_16
    ,coalesce(t2.nmv_l1_l2m, 0) as food_nmv_l1_l2m
    ,coalesce(t2.nmv_l2_l3m, 0) as food_nmv_l2_l3m
    ,coalesce(t2.nmv_l3_l4m, 0) as food_nmv_l3_l4m
    ,coalesce(t2.nmv_l4_l5m, 0) as food_nmv_l4_l5m
    ,coalesce(t2.weighted_avg_nmv, 0) as food_weighted_avg_nmv
    ,t1.grass_date
from 
(
    select 
        platform_user_id
        ,credit_user_id
        ,national_id
        ,other_platform_user_id
        ,uc_update_time
        ,merchant_id_list
        ,num_mid
        ,store_id_list
        ,num_sid
        ,is_valid_food_merchant
        ,avg_merhcant_ktp_change_cnt_7d
        ,avg_merhcant_ktp_change_cnt_30d
        ,wl_merchant_id_list
        ,grass_date
    from ${SCHEMA}.ads_risk_${table_region}_sfood_seller_info_df
    where grass_date = '${ds}'
) t1 
left join 
(
    select 
        platform_user_id
        ,txn_days_l6m
        ,num_inactive_4_consec_days
        ,avg_order_cnt_l6m
        ,avg_nmv_l6m
        ,nmv_l1m
        ,nmv_l3m
        ,nmv_l5_l6m
        ,order_cnt_l1m
        ,order_cnt_l5_l6m
        ,txn_mth_l12m
        ,avg_buyer_cnt_l6m
        ,cancel_rate_l7d
        ,cancel_rate_l15d
        ,nmv_drop_16
        ,order_cnt_drop_16
        ,nmv_l1_l2m
        ,nmv_l2_l3m
        ,nmv_l3_l4m
        ,nmv_l4_l5m
        ,weighted_avg_nmv
        ,grass_date
    from ${SCHEMA}.ads_risk_${table_region}_sfood_seller_store_info_df
    where grass_date = '${ds}'
) t2 
on t1.platform_user_id = t2.platform_user_id 
and t1.grass_date = t2.grass_date
;