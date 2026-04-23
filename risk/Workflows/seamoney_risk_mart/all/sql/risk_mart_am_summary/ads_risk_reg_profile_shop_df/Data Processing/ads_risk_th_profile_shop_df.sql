--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2023-12-05
-- Theme Domain：       商户profile
-- Description:         商户相关信息
-- Data Granularity:    shop_id
-- 变更历史：
--      update by zongyi.lu@shopee.com, 2023-12-05, 新增备注, 新增字段shop_penalty_point:商家当前penalty分数,penalty_tier 商家当前penalty级别
--      update by wei.tao 2025-04-14 新增字段 基于Shopee Seller表的Fraud Tag记录，给各地区SME特征表加上fraud_tag_cnt相关字段，并根据severity区分，用于SCL授信业务
--                https://jira.shopee.io/browse/SPFDT-50292 
--      update by nuo.chen@shopee.com, 2026-02-24, 新增字段 is_fbs https://casement.scredit.io/78703/requirement?jiraKey=SPFDT-60644
--      update by nuo.chen@shopee.com, 2026-02-26, 新增字段 shop_main_category, shop_median_price https://casement.scredit.io/78703/requirement?jiraKey=SPFDT-60500
--      update by chengguo.liu@shopee.com, 2026-03-06, 新增字段fbs_program_tier_m_1, https://casement.scredit.io/78703/requirement?jiraKey=SPFDT-60845
--********************************************************************--


insert overwrite table ${SCHEMA}.ads_risk_profile_shop_df partition (tz_type='local', grass_region, grass_date )
select
    t1.shop_id
    ,t1.user_id
    ,t1.is_cross_border_tag
    ,t1.is_preferred
    ,t1.is_official_store_tag
    ,t1.is_b2c
    ,t1.is_big_seller
    ,t1.response_rate
    ,t1.rating_star
    ,if(t1.holiday_mode_on='true',1,0) as holiday_mode_on
    ,t1.shopee_acct_status
    ,t1.main_category
    ,t1.sub_category
    ,t1.sku
    ,t1.active_item_with_stock_cnt
    ,t1.shop_like_cnt_td
    ,t1.is_preferred_plus_shop
    ,t1.is_managed_shop

    ,t1.is_fbs
    ,t1.shop_main_category_id as shop_main_category
    ,t1.shop_median_price

    ,t2.txn_days_in_180d
    ,t2.max_inactivate_days_in_180d
    ,t2.seller_shopee_age
    ,t2.open_more_than_6m
    ,t2.open_more_than_12m
    ,t2.ttl_order_in_3d
    ,t2.seller_confirmed_order_in_30d
    ,t2.seller_confirmed_order_in_31_60d
    ,t2.seller_confirmed_order_in_61_90d
    ,t2.seller_confirmed_order_in_91_120d
    ,t2.seller_confirmed_order_in_121_150d
    ,t2.seller_confirmed_order_in_151_180d
    ,t2.seller_confirmed_order_in_181_210d
    ,t2.seller_confirmed_order_in_211_240d
    ,t2.seller_confirmed_order_in_241_270d
    ,t2.seller_confirmed_order_in_271_300d
    ,t2.seller_confirmed_order_in_301_330d
    ,t2.seller_confirmed_order_in_331_360d
    ,t2.seller_confirmed_order_in_361_390d
    ,t2.gmv_in_3d
    ,t2.gmv_in_7d
    ,t2.gmv_in_8_14d
    ,t2.gmv_in_15_21d
    ,t2.gmv_in_22_28d
    ,t2.nmv_in_3d
    ,t2.nmv_in_7d
    ,t2.nmv_in_8_14d
    ,t2.nmv_in_15_21d
    ,t2.nmv_in_22_28d
    ,t2.nmv_in_30d
    ,t2.nmv_in_31_60d
    ,t2.nmv_in_61_90d
    ,t2.nmv_in_91_120d
    ,t2.nmv_in_121_150d
    ,t2.nmv_in_151_180d
    ,t2.nmv_in_181_210d
    ,t2.nmv_in_211_240d
    ,t2.nmv_in_241_270d
    ,t2.nmv_in_271_300d
    ,t2.nmv_in_301_330d
    ,t2.nmv_in_331_360d
    ,t2.nmv_in_361_390d
    ,t2.avg_nmv_last_12m_tag
    ,t2.avg_nmv_last_6m_tag
    ,t2.avg_nmv_last_3m_tag
    ,t2.min_nmv_last_12m_tag
    ,t2.min_nmv_last_6m_tag
    ,t2.min_nmv_last_3m_tag
    ,t2.has_order_month_last_3m
    ,t2.has_order_month_last_6m
    ,t2.cc_payment_ratio_last_3m
    ,t2.cc_payment_ratio_last_6m
    ,t2.return_order_in_30d
    ,t2.return_order_in_31_60d
    ,t2.return_order_in_61_90d
    ,t2.return_order_in_91_120d
    ,t2.return_order_in_121_150d
    ,t2.return_order_in_151_180d
    ,t2.return_order_in_181_210d
    ,t2.return_order_in_211_240d
    ,t2.return_order_in_241_270d
    ,t2.return_order_in_271_300d
    ,t2.return_order_in_301_330d
    ,t2.return_order_in_331_360d
    ,t2.return_order_in_361_390d
    ,t2.return_gmv_in_30d
    ,t2.return_gmv_31_60d
    ,t2.return_gmv_in_61_90d
    ,t2.return_gmv_in_91_120d
    ,t2.return_gmv_in_121_150d
    ,t2.return_gmv_in_151_180d
    ,t2.return_gmv_in_181_210d
    ,t2.return_gmv_in_211_240d
    ,t2.return_gmv_in_241_270d
    ,t2.return_gmv_in_271_300d
    ,t2.return_gmv_in_301_330d
    ,t2.return_gmv_in_331_360d
    ,t2.return_gmv_in_361_390d
    ,t2.distinct_buyer_in_3d
    ,t2.buyer_in_30d
    ,t2.buyer_in_31_60d
    ,t2.buyer_in_61_90d
    ,t2.buyer_in_91_120d
    ,t2.buyer_in_121_150d
    ,t2.buyer_in_151_180d
    ,t2.buyer_in_181_210d
    ,t2.buyer_in_211_240d
    ,t2.buyer_in_241_270d
    ,t2.buyer_in_271_300d
    ,t2.buyer_in_301_330d
    ,t2.buyer_in_331_360d
    ,t2.buyer_in_361_390d
    ,t2.cancellation_rate_l7d
    ,t2.cancellation_rate_l30d
    ,t3.discount_last_1m
    ,t3.discount_last_3m
    ,t3.voucher_last_1m
    ,t3.voucher_last_3m
    ,t3.follower_voucher_last_1m
    ,t3.follower_voucher_last_3m
    ,t3.top_picks_last_1m
    ,t3.top_picks_last_3m
    ,t3.bundle_deal_last_1m
    ,t3.bundle_deal_last_3m
    ,t3.shipping_fee_last_1m
    ,t3.shipping_fee_last_3m
    ,t3.add_on_deal_last_1m
    ,t3.add_on_deal_last_3m
    ,t2.create_order_cnt_in_15d
    ,t2.create_order_cnt_in_30d
    ,t2.cancelled_order_cnt_in_30d
    ,t1.shop_penalty_point 
    ,t1.penalty_tier   
    ,t4.uniq_servere_fraud_tag_30d    
    ,t4.uniq_servere_fraud_tag_31_60d 
    ,t4.uniq_servere_fraud_tag_61_90d 
    ,t4.uniq_moderate_fraud_tag_30d   
    ,t4.uniq_moderate_fraud_tag_31_60d
    ,t4.uniq_moderate_fraud_tag_61_90d
    ,t5.fbs_program_tier_m_1
    -- ,t1.shop_main_category_id
    ,t1.grass_region
    ,t1.grass_date
from
(select * from ${SCHEMA}.dim_risk_shop_df where tz_type = 'local' and grass_region = upper('${region}') and grass_date = date '${bizdate}') t1
left join
(select * from ${SCHEMA}.dws_risk_shop_txn_df where tz_type = 'local' and grass_region = upper('${region}') and grass_date = date '${bizdate}') t2
on t1.grass_region = t2.grass_region
and t1.shop_id = t2.shop_id
left join
(select * from ${SCHEMA}.dws_risk_shop_promotion_df where tz_type = 'local' and grass_region = upper('${region}') and grass_date = date '${bizdate}') t3
on t1.grass_region = t2.grass_region
and t1.shop_id = t3.shop_id
left join
(
    select 
        shop_id 
        ,grass_region
        ,count(distinct case when days <= 30 and severity = 'SEVERE' and fraud_tag_status = 1 then fraud_tag_id end) as uniq_servere_fraud_tag_30d 
        ,count(distinct case when days > 30 and days <= 60 and severity = 'SEVERE' and fraud_tag_status = 1 then fraud_tag_id end) as uniq_servere_fraud_tag_31_60d 
        ,count(distinct case when days > 60 and days <= 90 and severity = 'SEVERE' and fraud_tag_status = 1 then fraud_tag_id end) as uniq_servere_fraud_tag_61_90d 
        ,count(distinct case when days <= 30 and severity = 'MODERATE' and fraud_tag_status = 1 then fraud_tag_id end) as uniq_moderate_fraud_tag_30d 
        ,count(distinct case when days > 30 and days <= 60 and severity = 'MODERATE' and fraud_tag_status = 1 then fraud_tag_id end) as uniq_moderate_fraud_tag_31_60d 
        ,count(distinct case when days > 60 and days <= 90 and severity = 'MODERATE' and fraud_tag_status = 1 then fraud_tag_id end) as uniq_moderate_fraud_tag_61_90d
    from
        ( 
        SELECT 
            shop_id,
            user_id,
            fraud_tag_id,
            reason,
            fraud_tag_status,
            modify_date,
            days,
            type,
            severity,
            grass_region
        FROM (
            SELECT 
                shop_id,
                user_id,
                fraud_tag_id,
                reason,
                fraud_tag_status,
                date(modify_datetime) AS modify_date,
                datediff(current_date, date(modify_datetime)) AS days,
                type,
                severity,
                grass_region
            FROM antifraud_dw.dim_user_fraud_tag_hf 
            WHERE grass_region = upper('${region}') 
            AND grass_date = date '${bizdate}'
            AND datediff(current_date, date(modify_datetime)) <= 90 
        ) t
        GROUP BY 
            shop_id,
            user_id,
            fraud_tag_id,
            reason,
            fraud_tag_status,
            modify_date,
            days,
            type,
            severity,
            grass_region
        )
    group by 1,2
) t4
on t1.grass_region = t4.grass_region
and t1.shop_id = t4.shop_id
left join
(
    select
        shop_id
        ,fbs_program_tier_m_1
    from
    ${SCHEMA}.dws_risk_${region}_shop_fbs_txn_df
    where grass_date = date '${grass_date}'
) t5
on t1.shop_id = t5.shop_id
;

create or replace view ${SCHEMA}.ads_risk_${region}_profile_shop_df as
select
    *
from ${SCHEMA}.ads_risk_profile_shop_df
where
    grass_region = upper('${region}')
;