-- --********************************************************************--
-- -- Author:              wei.tao@shopee.com
-- -- Created Time:        2025-04-17
-- -- Theme Domain：       risk-feature
-- -- Description:         Shopee FSG DataSPFDT-51004[VN][SME X SFood]VN SFood Offline Feature * 20
--                         -- https://jira.shopee.io/browse/SPFDT-51004
-- -- Data Granularity:    platform_user_id
-- -- 变更历史：
-- --      
-- --********************************************************************--

-- drop table if exists ${SCHEMA}.ads_risk_vn_sfood_seller_feature_df;
-- create table if not exists ${SCHEMA}.ads_risk_vn_sfood_seller_feature_df
-- (
--     platform_user_id string
--     ,credit_user_id string
--     ,full_merchant_list string
--     ,food_num_mid bigint
--     ,full_store_list string
--     ,food_num_sid bigint
--     ,full_restaurant_list string
--     ,food_num_rid bigint
--     ,is_valid_food_merchant bigint 
--     ,avg_merchant_ktp_chg_7d decimal(20,5) 
--     ,avg_merchant_ktp_chg_30d decimal(20,5) 
--     ,white_merchant_list string
--     ,food_txn_days_l6m bigint 
--     ,food_inactive_4_days bigint 
--     ,food_max_inactive_days_l6m bigint 
--     ,food_txn_mth_l12m bigint 
--     ,food_avg_order_cnt_l6m decimal(20,5) 
--     ,food_avg_nmv_l6m decimal(20,5) 
--     ,food_nmv_l1m decimal(20,5) 
--     ,food_nmv_l3m decimal(20,5) 
--     ,food_nmv_l6m decimal(20,5) 
--     ,food_nmv_l5_l6m decimal(20,5) 
--     ,food_nmv_drop_16 decimal(20,5) 
--     ,food_order_cnt_l1m bigint 
--     ,food_order_cnt_l3m bigint 
--     ,food_order_cnt_l6m bigint 
--     ,food_order_cnt_l5_l6m bigint
--     ,food_avg_buyer_cnt_l6m decimal(20,5) 
--     ,food_order_cnt_drop_16 decimal(20,5) 
--     ,food_nmv_l1_l2m decimal(20,5) 
--     ,food_nmv_l2_l3m decimal(20,5) 
--     ,food_nmv_l3_l4m decimal(20,5) 
--     ,food_nmv_l4_l5m decimal(20,5) 
--     ,food_weighted_avg_nmv decimal(20,5) 
-- )
-- partitioned by
-- (
--     grass_date string comment 'yyyy-MM-dd'
-- )
-- stored as orc tblproperties ("orc.compress"="zstd")
-- LOCATION '${HDFS_PATH}/ads_risk_vn_sfood_seller_feature_df';
-- MSCK REPAIR TABLE ${SCHEMA}.ads_risk_vn_sfood_seller_feature_df;

insert overwrite table ${SCHEMA}.ads_risk_${table_region}_sfood_seller_feature_df partition (grass_date = '${ds}')
select 
    t1.platform_user_id
    ,t1.credit_user_id
    ,t1.merchant_id_list as full_merchant_list
    ,t1.num_mid as food_num_mid
    ,t1.store_id_list as full_store_list
    ,t1.num_sid as food_num_sid
    ,t1.restaurant_id_list as full_restaurant_list
    ,t1.num_rid as food_num_rid
    ,t1.is_valid_food_merchant
    ,t1.avg_merchant_ktp_change_cnt_7d as avg_merchant_ktp_chg_7d
    ,t1.avg_merchant_ktp_change_cnt_30d as avg_merchant_ktp_chg_30d
    ,t1.wl_merchant_id_list as white_merchant_list
    ,coalesce(t2.txn_days_l6m, 0) as food_txn_days_l6m
    ,coalesce(t2.num_inactive_4_consec_days, 0) as food_inactive_4_days
    ,coalesce(t2.max_inactive_days_l6m, 0) as food_max_inactive_days_l6m  -- VN新增
    ,coalesce(t2.txn_mth_l12m, 0) as food_txn_mth_l12m  -- 是否12个月都有交易，0/1型
    ,coalesce(t2.avg_order_cnt_l6m, 0) as food_avg_order_cnt_l6m
    ,coalesce(t2.avg_nmv_l6m, 0) as food_avg_nmv_l6m
    ,coalesce(t2.nmv_l1m, 0) as food_nmv_l1m
    ,coalesce(t2.nmv_l3m, 0) as food_nmv_l3m
    ,coalesce(t2.nmv_l6m, 0) as food_nmv_l6m --added
    ,coalesce(t2.nmv_l5_l6m, 0) as food_nmv_l5_l6m
    ,coalesce(t2.nmv_drop_16, 0) as food_nmv_drop_16
    ,coalesce(t2.order_cnt_l1m, 0) as food_order_cnt_l1m
    ,coalesce(t2.order_cnt_l3m, 0) as food_order_cnt_l3m
    ,coalesce(t2.order_cnt_l6m, 0) as food_order_cnt_l6m --added
    ,coalesce(t2.order_cnt_l5_l6m, 0) as food_order_cnt_l5_l6m
    ,coalesce(t2.avg_buyer_cnt_l6m, 0) as food_avg_buyer_cnt_l6m
    ,coalesce(t2.order_cnt_drop_16, 0) as food_order_cnt_drop_16
    ,coalesce(t2.nmv_l1_l2m, 0) as food_nmv_l1_l2m
    ,coalesce(t2.nmv_l2_l3m, 0) as food_nmv_l2_l3m
    ,coalesce(t2.nmv_l3_l4m, 0) as food_nmv_l3_l4m
    ,coalesce(t2.nmv_l4_l5m, 0) as food_nmv_l4_l5m
    ,coalesce(t2.weighted_avg_nmv, 0) as food_weighted_avg_nmv
from 
(
    select 
        platform_user_id
        ,credit_user_id
        ,merchant_id_list
        ,num_mid
        ,store_id_list
        ,num_sid
        ,restaurant_id_list
        ,num_rid
        ,is_valid_food_merchant
        ,avg_merchant_ktp_change_cnt_7d
        ,avg_merchant_ktp_change_cnt_30d
        ,wl_merchant_id_list
        ,wl_restaurant_id_list
        ,wl_store_id_list
        -- ,grass_date
    from risk.ads_risk_vn_sfood_seller_info_df
    where grass_date = '${ds}'
) t1 
left join 
(
    select 
        platform_user_id
        ,txn_days_l6m
        ,num_inactive_4_consec_days
        ,max_inactive_days_180d as max_inactive_days_l6m
        ,txn_mth_l12m
        ,avg_order_cnt_l6m
        ,avg_nmv_l6m
        ,nmv_l1m
        ,nmv_l3m
        ,nmv_l6m --added
        ,nmv_l5_l6m
        ,order_cnt_l1m
        ,order_cnt_l3m
        ,order_cnt_l6m
        ,order_cnt_l5_l6m
        ,avg_buyer_cnt_l6m
        ,nmv_drop_16
        ,order_cnt_drop_16
        ,nmv_l1_l2m
        ,nmv_l2_l3m
        ,nmv_l3_l4m
        ,nmv_l4_l5m
        ,weighted_avg_nmv
        -- ,grass_date
    from risk.ads_risk_vn_sfood_seller_store_info_df
    where grass_date = '${ds}'
) t2 
on t1.platform_user_id = t2.platform_user_id 
-- and t1.grass_date = t2.grass_date
;