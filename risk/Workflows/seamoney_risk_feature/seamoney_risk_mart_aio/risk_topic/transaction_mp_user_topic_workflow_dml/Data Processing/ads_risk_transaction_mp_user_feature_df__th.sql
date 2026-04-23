--********************************************************************--
-- Author:              huangwei@shopee.com
-- Created Time:        2024-01-29
-- Theme Domain：       risk-feature
-- Description:         risk feature所有交易的用户feature合并
-- Data Granularity:    shopee_user_id
-- 变更历史：
-- 
--********************************************************************--
insert overwrite ${SCHEMA}.ads_risk_transaction_mp_user_feature_df__th partition (grass_date = '${ds}')
select
    t1.shopee_user_id
    --dws_risk_buyer_txn_df
    ,if (t2.buyer_id is not null, 1, 0) is_buyer_txn_scope
    ,t2.buyer_confirmed_order_in_14d
    ,t2.buyer_confirmed_order_in_30d
    ,t2.buyer_confirmed_order_in_60d
    ,t2.buyer_confirmed_order_in_90d
    ,t2.buyer_confirmed_order_in_180d
    ,t2.buyer_confirmed_order_in_360d
    ,t2.buyer_nmv_usd_in_14d
    ,t2.buyer_nmv_usd_in_30d
    ,t2.buyer_nmv_usd_in_60d
    ,t2.buyer_nmv_usd_in_90d
    ,t2.buyer_nmv_usd_in_180d
    ,t2.buyer_nmv_usd_in_360d
    ,t2.buyer_spl_exclude_nmv_usd_in_14d
    ,t2.buyer_spl_exclude_nmv_usd_in_30d
    ,t2.buyer_spl_exclude_nmv_usd_in_60d
    ,t2.buyer_spl_exclude_nmv_usd_in_90d
    ,t2.buyer_spl_exclude_nmv_usd_in_180d
    ,t2.buyer_spl_exclude_nmv_usd_in_360d
    ,t2.buyer_abs_usd_in_14d
    ,t2.buyer_abs_usd_in_30d
    ,t2.buyer_abs_usd_in_60d
    ,t2.buyer_abs_usd_in_90d
    ,t2.buyer_abs_usd_in_180d
    ,t2.buyer_abs_usd_in_lifetime
    --ads_risk_id_seller_feature_df
    ,if (t3.seller_id is not null, 1, 0) is_seller_feature_scope
    ,t3.total_order_count_7d
    ,t3.total_order_count_15d
    ,t3.total_order_count_30d
    ,t3.total_gmv_paid_7d
    ,t3.total_gmv_paid_15d
    ,t3.total_gmv_paid_30d
    ,t3.abs_paid_7d
    ,t3.abs_paid_15d
    ,t3.abs_paid_30d
    ,t3.refund_gmv_paid_7d
    ,t3.refund_gmv_paid_15d
    ,t3.refund_gmv_paid_30d
    ,t3.gmv_refund_rate_7d
    ,t3.gmv_refund_rate_15d
    ,t3.gmv_refund_rate_30d
    ,t3.shop_type
from
    (
        select
            user_id as shopee_user_id
        from mp_user.dim_user__reg_s0_live
        where
            tz_type = 'local'
            and grass_region = 'TH'
            and grass_date = '${ds}'
    ) t1
    left join (
        select
            buyer_id
            ,buyer_confirmed_order_in_14d
            ,buyer_confirmed_order_in_30d
            ,buyer_confirmed_order_in_60d
            ,buyer_confirmed_order_in_90d
            ,buyer_confirmed_order_in_180d
            ,buyer_confirmed_order_in_360d
            ,buyer_nmv_usd_in_14d
            ,buyer_nmv_usd_in_30d
            ,buyer_nmv_usd_in_60d
            ,buyer_nmv_usd_in_90d
            ,buyer_nmv_usd_in_180d
            ,buyer_nmv_usd_in_360d
            ,buyer_spl_exclude_nmv_usd_in_14d
            ,buyer_spl_exclude_nmv_usd_in_30d
            ,buyer_spl_exclude_nmv_usd_in_60d
            ,buyer_spl_exclude_nmv_usd_in_90d
            ,buyer_spl_exclude_nmv_usd_in_180d
            ,buyer_spl_exclude_nmv_usd_in_360d
            ,buyer_abs_usd_in_14d
            ,buyer_abs_usd_in_30d
            ,buyer_abs_usd_in_60d
            ,buyer_abs_usd_in_90d
            ,buyer_abs_usd_in_180d
            ,buyer_abs_usd_in_lifetime
        from risk.dws_risk_buyer_txn_df
        where
            grass_date = '${ds}'
            and grass_region = 'TH'
    ) t2 on t1.shopee_user_id = t2.buyer_id
    left join (
        select
            seller_id
            ,row_key
            ,total_order_count_7d
            ,total_order_count_15d
            ,total_order_count_30d
            ,total_gmv_paid_7d
            ,total_gmv_paid_15d
            ,total_gmv_paid_30d
            ,abs_paid_7d
            ,abs_paid_15d
            ,abs_paid_30d
            ,refund_gmv_paid_7d
            ,refund_gmv_paid_15d
            ,refund_gmv_paid_30d
            ,gmv_refund_rate_7d
            ,gmv_refund_rate_15d
            ,gmv_refund_rate_30d
            ,shop_type
        from risk.ads_risk_th_seller_feature_df
        where grass_date = '${ds}'
    ) t3 on t1.shopee_user_id = t3.seller_id
;