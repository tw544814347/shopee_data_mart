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
--      update by wei.tao@shopee.com 新增 7 * feature   Jira: https://jira.shopee.io/browse/SPFDT-55061
--      update by wei.tao@shopee.com 修改旧逻辑 +  新增 2 * feature   Jira: https://jira.shopee.io/browse/SPFDT-57085
--      update by huangyue 2025-12-03 新增penalty_tier_90d
--      update by chenyingying 2026-01-14 新增nmv_usd_l2m_pay, nmv_usd_l3m_pay, place_order_cnt_1m, cancel_cnt_1m, pay_cnt_1m_pay, pay_cancel_1m_pay, pay_gmv_7d_pay, pay_gmv_1m_pay, escrow_paid_return_cnt_1m_esc, pay_cnt_1m_esc, escrow_paid_return_cnt_7d_esc, pay_cnt_7d_esc
--      update by wei.tao 2026-03-30 旧表下线，迁移到新表 dwd_shop_kyb_all_ent_df__reg_live
--********************************************************************--

-- drop table if exists ${SCHEMA}.ads_risk_profile_shop_df;
create external table if not exists ${SCHEMA}.ads_risk_profile_shop_df
(
    shop_id bigint comment 'PK unique id of the shop'
    ,user_id bigint comment 'unique userid of the buyer'
    ,is_cross_border_tag bigint comment 'whether shop is cross border'
    ,is_preferred bigint comment 'prefered shop flag'
    ,is_official_store_tag bigint comment 'official shop flag'
    ,is_b2c bigint comment 'seller b2c flag'
    ,is_big_seller int comment 'is big seller'
    ,response_rate double comment 'response rate'
    ,rating_star double comment 'shop star rating'
    ,holiday_mode_on string comment 'seller holiday flag'
    ,shopee_acct_status bigint comment 'shop status'
    ,main_category string comment 'the key main category of the shop based on the count of live items listed by the shop'
    ,sub_category string comment 'the key sub category of the shop based on the live items listed by the shop'
    ,sku bigint comment 'the total number of active items (status = 1) listed by the shop'
    ,active_item_with_stock_cnt bigint comment 'the sku of active items (status = 1) listed by the shop'
    ,shop_like_cnt_td bigint comment 'total like count from a shop from users who are active'
    ,is_preferred_plus_shop tinyint comment 'if shop_id is preferred+ then this flag is 1, else 0'
    ,is_managed_shop tinyint comment 'whether shop is managed or not'
    ,txn_days_in_180d bigint comment 'number of days in last 180 days that the shop has transactions'
    ,max_inactivate_days_in_180d bigint comment 'the shop maximum inactive days in last 180 days'
    ,seller_shopee_age bigint comment 'The number of days since the merchant placed the first order'
    ,open_more_than_6m bigint comment 'Whether the shop has opened for more than 6 month'
    ,open_more_than_12m bigint comment 'Whether the shop has opened for more than 1 year'
    ,ttl_order_in_3d bigint comment 'total number of order in last 3 days'
    ,seller_confirmed_order_in_30d bigint comment 'number of confirmed order in 30 days'
    ,seller_confirmed_order_in_31_60d bigint comment 'number of confirmed order in 31_60 days'
    ,seller_confirmed_order_in_61_90d bigint comment 'number of confirmed order in 61_90 days'
    ,seller_confirmed_order_in_91_120d bigint comment 'number of confirmed order in 91_120 days'
    ,seller_confirmed_order_in_121_150d bigint comment 'number of confirmed order in 121_150 days'
    ,seller_confirmed_order_in_151_180d bigint comment 'number of confirmed order in 151_180 days'
    ,seller_confirmed_order_in_181_210d bigint comment 'number of confirmed order in 181_210 days'
    ,seller_confirmed_order_in_211_240d bigint comment 'number of confirmed order in 211_240 days'
    ,seller_confirmed_order_in_241_270d bigint comment 'number of confirmed order in 241_270 days'
    ,seller_confirmed_order_in_271_300d bigint comment 'number of confirmed order in 271_300 days'
    ,seller_confirmed_order_in_301_330d bigint comment 'number of confirmed order in 301_330 days'
    ,seller_confirmed_order_in_331_360d bigint comment 'number of confirmed order in 331_360 days'
    ,seller_confirmed_order_in_361_390d bigint comment 'number of confirmed order in 361_390 days'
    ,gmv_in_3d decimal(30,10) comment 'gmv in last 3 days'
    ,gmv_in_7d decimal(30,10) comment 'gmv in recent 7 days'
    ,gmv_in_8_14d decimal(30,10) comment 'gmv in last 8-14 days'
    ,gmv_in_15_21d decimal(30,10) comment 'gmv in last 15-21 days'
    ,gmv_in_22_28d decimal(30,10) comment 'gmv in last 22-28 days'
    ,gmv_usd_in_7d_pay decimal(30,10) comment 'gmv_usd in last 7 pay datetime days'

    ,nmv_in_3d decimal(30,10) comment 'nmv in last 3 days'
    ,nmv_in_7d decimal(30,10) comment 'nmv in recent 7 days'
    ,nmv_in_8_14d decimal(30,10) comment 'nmv in last 8-14 days'
    ,nmv_in_15_21d decimal(30,10) comment 'nmv in last 15-21 days'
    ,nmv_in_22_28d decimal(30,10) comment 'nmv in last 22-28 days'
    ,nmv_in_30d decimal(30,10) comment 'nmv in recent 30days'
    ,nmv_in_31_60d decimal(30,10) comment 'nmv in recent 31_60 days'
    ,nmv_in_61_90d decimal(30,10) comment 'nmv in recent 61_90 days'
    ,nmv_in_91_120d decimal(30,10) comment 'nmv in recent 91_120 days'
    ,nmv_in_121_150d decimal(30,10) comment 'nmv in recent 121_150 days'
    ,nmv_in_151_180d decimal(30,10) comment 'nmv in recent 151_180 days'
    ,nmv_in_181_210d decimal(30,10) comment 'nmv in recent 181_210 days'
    ,nmv_in_211_240d decimal(30,10) comment 'nmv in recent 211_240 days'
    ,nmv_in_241_270d decimal(30,10) comment 'nmv in recent 241_270 days'
    ,nmv_in_271_300d decimal(30,10) comment 'nmv in recent 271_300 days'
    ,nmv_in_301_330d decimal(30,10) comment 'nmv in recent 301 - 330 days'
    ,nmv_in_331_360d decimal(30,10) comment 'nmv in recent 331 - 360days'
    ,nmv_in_361_390d decimal(30,10) comment 'nmv in recent 361 - 390 days'

    ,nmv_usd_in_7d_pay   decimal(30,10) comment 'nmv_usd in recent 7 pay days'
    ,nmv_usd_in_30d_pay  decimal(30,10) comment 'nmv_usd in recent 1month pay days'
    ,nmv_usd_in_60d_pay  decimal(30,10) comment 'nmv_usd in recent 2month pay days'
    ,nmv_usd_in_90d_pay  decimal(30,10) comment 'nmv_usd in recent 3month pay days'
    ,nmv_usd_in_180d_pay decimal(30,10) comment 'nmv_usd in recent 6month pay days'

    ,avg_nmv_last_12m_tag decimal(30,10) comment 'average monthly nmv in last 12 month'
    ,avg_nmv_last_6m_tag decimal(30,10) comment 'average monthly nmv in last 6 month'
    ,avg_nmv_last_3m_tag decimal(30,10) comment 'average monthly nmv in last 3 month'
    ,min_nmv_last_12m_tag decimal(30,10) comment 'minimum monthly nmv in last 12 month'
    ,min_nmv_last_6m_tag decimal(30,10) comment 'minimum monthly nmv in last 6 month'
    ,min_nmv_last_3m_tag decimal(30,10) comment 'minimum monthly nmv in last 3 month'
    ,has_order_month_last_3m bigint comment 'number of month that has txn in last 3 month'
    ,has_order_month_last_6m bigint comment 'number of month that has txn in last 6 month'
    ,cc_payment_ratio_last_3m decimal(30,10) comment 'percentage of txns that paid by credit payment method in last 3 month'
    ,cc_payment_ratio_last_6m decimal(30,10) comment 'percentage of txns that paid by credit payment method in last 6 month'
    ,return_order_in_30d bigint comment 'number of return order in 30 days'
    ,return_order_in_31_60d bigint comment 'number of return order in 31_60 days'
    ,return_order_in_61_90d bigint comment 'number of return order in 61_90 days'
    ,return_order_in_91_120d bigint comment 'number of return order in 91_120 days'
    ,return_order_in_121_150d bigint comment 'number of return order in 121_150 days'
    ,return_order_in_151_180d bigint comment 'number of return order in 151_180 days'
    ,return_order_in_181_210d bigint comment 'number of return order in 181_210 days'
    ,return_order_in_211_240d bigint comment 'number of return order in 211_240 days'
    ,return_order_in_241_270d bigint comment 'number of return order in 241_270 days'
    ,return_order_in_271_300d bigint comment 'number of return order in 271_300 days'
    ,return_order_in_301_330d bigint comment 'number of return order in 301_330 days'
    ,return_order_in_331_360d bigint comment 'number of return order in 331_360 days'
    ,return_order_in_361_390d bigint comment 'number of return order in 361_390 days'
    ,return_gmv_in_30d decimal(30,10) comment 'gmv of return order in 30 days'
    ,return_gmv_31_60d decimal(30,10) comment 'gmv of return order in 31_60 days'
    ,return_gmv_in_61_90d decimal(30,10) comment 'gmv of return order in 61_90 days'
    ,return_gmv_in_91_120d decimal(30,10) comment 'gmv of return order in 91_120 days'
    ,return_gmv_in_121_150d decimal(30,10) comment 'gmv of return order in 121_150 days'
    ,return_gmv_in_151_180d decimal(30,10) comment 'gmv of return order in 151_180 days'
    ,return_gmv_in_181_210d decimal(30,10) comment 'gmv of return order in 181_210 days'
    ,return_gmv_in_211_240d decimal(30,10) comment 'gmv of return order in 211_240 days'
    ,return_gmv_in_241_270d decimal(30,10) comment 'gmv of return order in 241_270 days'
    ,return_gmv_in_271_300d decimal(30,10) comment 'gmv of return order in 271_300 days'
    ,return_gmv_in_301_330d decimal(30,10) comment 'gmv of return order in 301_330 days'
    ,return_gmv_in_331_360d decimal(30,10) comment 'gmv of return order in 331_360 days'
    ,return_gmv_in_361_390d decimal(30,10) comment 'gmv of return order in 361_390 days'
    ,distinct_buyer_in_3d bigint comment 'total number of unique buyer in last 3 days'
    ,buyer_in_30d bigint comment 'number of distinct buyer in 30 days'
    ,buyer_in_31_60d bigint comment 'number of distinct buyer in 31_60 days'
    ,buyer_in_61_90d bigint comment 'number of distinct buyer in 61_90 days'
    ,buyer_in_91_120d bigint comment 'number of distinct buyer in 91_120 days'
    ,buyer_in_121_150d bigint comment 'number of distinct buyer in 121_150 days'
    ,buyer_in_151_180d bigint comment 'number of distinct buyer in 151_180 days'
    ,buyer_in_181_210d bigint comment 'number of distinct buyer in 181_210 days'
    ,buyer_in_211_240d bigint comment 'number of distinct buyer in 211_240 days'
    ,buyer_in_241_270d bigint comment 'number of distinct buyer in 241_270 days'
    ,buyer_in_271_300d bigint comment 'number of distinct buyer in 271_300 days'
    ,buyer_in_301_330d bigint comment 'number of distinct buyer in 301_330 days'
    ,buyer_in_331_360d bigint comment 'number of distinct buyer in 331_360 days'
    ,buyer_in_361_390d bigint comment 'number of distinct buyer in 361_390 days'
    ,cancellation_rate_l7d decimal(10,4) comment 'The seller order cancellation rate in the last 7 days'
    ,cancellation_rate_l30d decimal(10,4) comment 'The seller order cancellation rate in the last 30 days'
    ,discount_last_1m bigint comment 'whether use discount in last 1 month'
    ,discount_last_3m bigint comment 'whether use discount in last 3 month'
    ,voucher_last_1m bigint comment 'whether use voucher in last 1 month'
    ,voucher_last_3m bigint comment 'whether use voucher in last 3 month'
    ,follower_voucher_last_1m bigint comment 'whether use follower voucher in last 1 month'
    ,follower_voucher_last_3m bigint comment 'whether use follower voucher in last 3 month'
    ,top_picks_last_1m bigint comment 'whether use top picks in last 1 month'
    ,top_picks_last_3m bigint comment 'whether use top picks in last 3 month'
    ,bundle_deal_last_1m bigint comment 'whether use buddle deal in last 1 month'
    ,bundle_deal_last_3m bigint comment 'whether use buddle deal in last 3 month'
    ,shipping_fee_last_1m bigint comment 'whether use free shipping in last 1 month'
    ,shipping_fee_last_3m bigint comment 'whether use free shipping in last 3 month'
    ,add_on_deal_last_1m bigint comment 'whether use add on deal in last 1 month'
    ,add_on_deal_last_3m bigint comment 'whether use free shipping in last 3 month'
    ,create_order_cnt_in_15d       bigint  comment 'number of create order in 15days'    
    ,create_order_cnt_in_30d       bigint  comment 'number of create order in 30days'  
    ,cancelled_order_cnt_in_30d    bigint  comment 'number of cancel order in 30days'
    ,shop_penalty_point            bigint  comment "penalty points of the shop 商家当前penalty分数"
    ,penalty_tier                  bigint  comment "penalty tier of the shop based on the shop's penalty points 商家当前penalty级别"
    ,penalty_tier_90d              bigint  comment "max penalty tier in last 90 days"
 
    ,uniq_servere_fraud_tag_30d             bigint comment 'uniq_servere_fraud_tag_30d' 
    ,uniq_servere_fraud_tag_31_60d          bigint comment 'uniq_servere_fraud_tag_31_60d' 
    ,uniq_servere_fraud_tag_61_90d          bigint comment 'uniq_servere_fraud_tag_61_90d' 
    ,uniq_moderate_fraud_tag_30d            bigint comment 'uniq_moderate_fraud_tag_30d'
    ,uniq_moderate_fraud_tag_31_60d         bigint comment 'uniq_moderate_fraud_tag_31_60d'
    ,uniq_moderate_fraud_tag_61_90d         bigint comment 'uniq_moderate_fraud_tag_61_90d'

    ,seller_type                    string comment 'seller_type' 
    ,cpf_chg_30d                    bigint comment 'cpf_chg_30d' 
    ,cpf_chg_15d                    bigint comment 'cpf_chg_15d' 
    ,last_chg_old_cpf                   string comment 'last_chg_old_cpf' 
    ,last_chg_new_cpf                   string comment 'last_chg_new_cpf' 
    ,last_chg_date                  string comment 'last_chg_date'  
    ,cnpj_chg_30d                   bigint comment 'cnpj_chg_30d'  
    ,cnpj_chg_15d                   bigint comment 'cnpj_chg_15d' 
    
    ,last_chg_old_cnpj                   string comment 'last_chg_old_cnpj' 
    ,last_chg_new_cnpj                  string comment 'last_chg_new_cnpj' 
    ,last_cnpj_chg_date                  string comment 'last_cnpj_chg_date'  
    ,last_cpf_chg_date                  string comment 'last_cpf_chg_date' 
    ,has_cpf_cnpj_chg_30d               int comment 'has_cpf_cnpj_chg_30d' 
    ,has_cnpj_cpf_chg_30d               int comment 'has_cnpj_cpf_chg_30d' 
    
    ,nmv_usd_l2m_pay                    decimal(30,10)  comment 'nmv pay last 2 month(usd)'
    ,nmv_usd_l3m_pay                    decimal(30,10)  comment 'nmv pay last 3 month(usd)'
    ,place_order_cnt_1m                 bigint  comment 'place order cnt 1 month'
    ,cancel_cnt_1m                      bigint  comment 'cancel cnt 1 month'
    ,pay_cnt_1m_pay                     bigint  comment 'pay cnt 1 month'
    ,pay_cancel_1m_pay                  bigint  comment 'pay cancel 1 month'
    ,pay_gmv_7d_pay                     decimal(30,10)  comment 'gmv pay last 7 day(usd)'
    ,pay_gmv_1m_pay                     decimal(30,10)  comment 'gmv pay last 1 month(usd)' 
    ,escrow_paid_return_cnt_1m_esc      bigint  comment 'escrow paid return cnt 1 month'
    ,pay_cnt_1m_esc                     bigint  comment 'pay cnt 1 month'
    ,escrow_paid_return_cnt_7d_esc      bigint  comment 'escrow paid return cnt 7 day'
    ,pay_cnt_7d_esc                     bigint  comment 'pay cnt 7d'
)
partitioned by
(
     tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
comment 'Tag:risk summary table'
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_profile_shop_df';
-- msck repair table ${SCHEMA}.ads_risk_profile_shop_df;

create or replace temporary view full_seller_order as (
    select  seller_id as user_id
            ,shop_id
            ,cast(datediff('${ds}', date(pay_datetime))/30 as bigint) + 1 AS month_pay
            ,cast(datediff('${ds}', date(create_datetime))/30 as bigint) + 1 AS month_tran
            ,cast(datediff('${ds}', date(escrow_paid_datetime)) /30 as bigint) + 1 AS month_esc
            ,cast(datediff('${ds}', date(create_datetime)) /7 as bigint) + 1 AS week_tran
            ,cast(datediff('${ds}', date(pay_datetime))/7 as bigint) + 1 AS week_pay
            ,cast(datediff('${ds}', date(escrow_paid_datetime)) / 7 as bigint) + 1 AS week_esc
            ,grass_region
            ,SUM(nmv) AS nmv_rm
            ,SUM(nmv_usd) AS nmv
            ,sum(gmv_usd) as gmv
            ,SUM(1) AS place_order_cnt      
            ,sum(case when pay_datetime is not null then 1 else 0 end ) as pay_cnt
            ,sum(case when cancel_datetime is not null then 1 else 0 end) as cancel_cnt
            ,sum(case when pay_datetime is not null and cancel_datetime is not null then 1 else 0 end ) as pay_cancel_cnt
            ,sum(case when escrow_paid_datetime is not null then 1 else 0 end) as escrow_paid_cnt
            ,sum(case when escrow_paid_datetime is not null and nmv = 0  then 1 else 0 end) as escrow_paid_return_cnt
    from    mp_order.dwd_order_all_ent_df__reg_s0_live
    where grass_region = upper('${region}') 
    and tz_type = 'local'
    and is_bi_excluded = 0
    and order_be_status in ('ESCROW_PAID','CANCEL_COMPLETED','INVALID')
    and (grass_date between date('${tomorrow_ds}') - interval '460' day and date('${tomorrow_ds}') or grass_date = date('9999-01-01'))
    and date(create_datetime) >= date('${tomorrow_ds}') - interval'460' day
    GROUP BY 1,2,3,4,5,6,7,8,9
)
;

create or replace temporary view seller_pay_cancel_esc_feature as (
    select  user_id
            ,shop_id
            ,grass_region

            ,COALESCE(SUM(CASE WHEN month_pay in (1,2) and  escrow_paid_cnt=1 THEN nmv ELSE 0 END), 0) AS nmv_usd_l2m_pay
            ,COALESCE(SUM(CASE WHEN month_pay in (1,2,3) and  escrow_paid_cnt=1 THEN nmv ELSE 0 END), 0) AS nmv_usd_l3m_pay
            ,sum(case when month_tran<=1 then place_order_cnt else 0 end ) as place_order_cnt_1m
            ,sum(case when month_tran<=1 then cancel_cnt else 0 end ) as cancel_cnt_1m
            ,sum(case when month_pay<=1 then pay_cnt else 0 end ) as pay_cnt_1m_pay
            ,sum(case when month_pay<=1 then gmv else 0 end ) as pay_gmv_1m_pay
            ,sum(case when month_pay<=1 then pay_cancel_cnt else 0 end ) as pay_cancel_1m_pay
            ,sum(case when week_pay<=1 then gmv else 0 end ) as pay_gmv_7d_pay
            ,sum(case when month_esc<=1 then pay_cnt else 0 end ) as pay_cnt_1m_esc
            ,sum(case when month_esc<=1 then escrow_paid_return_cnt else 0 end ) as escrow_paid_return_cnt_1m_esc
            ,sum(case when week_esc<=1 then pay_cnt else 0 end ) as pay_cnt_7d_esc
            ,sum(case when week_esc<=1 then escrow_paid_return_cnt else 0 end ) as escrow_paid_return_cnt_7d_esc
    from full_seller_order
    group by 1,2,3
)
;


with full_seller_hist as (
    SELECT
        shop_id,
        get_json_object(raw_data, '$.seller_type') AS seller_type,
        get_json_object(raw_data, '$.tax_id') AS tax_id,
        CAST(get_json_object(raw_data, '$.tax_type') AS INT) AS tax_type,
        modify_datetime AS update_datetime,
        DENSE_RANK() OVER (
            PARTITION BY shop_id 
            ORDER BY modify_datetime DESC
        ) AS rn
    FROM mp_seller.dwd_shop_kyb_all_ent_df__reg_live
    WHERE grass_region = upper('${region}')
        AND status_id = 7 -- KYC Validated
        AND get_json_object(raw_data, '$.tax_id') IS NOT NULL
        AND CAST(get_json_object(raw_data, '$.tax_type') AS INT) IN (1, 2)
    GROUP BY 
        shop_id,
        get_json_object(raw_data, '$.seller_type'),
        get_json_object(raw_data, '$.tax_id'),
        CAST(get_json_object(raw_data, '$.tax_type') AS INT),
        modify_datetime
)
,full_hist_lagged as (  
    select  
        shop_id
        ,seller_type
        ,tax_id as new_tax_id
        ,tax_type as new_tax_type
        ,update_datetime
        ,to_date(update_datetime) as update_date
        ,lag(tax_id) over (partition by shop_id, tax_type order by update_datetime) as old_tax_id
        ,lag(tax_type) over (partition by shop_id order by update_datetime) as old_tax_type  
    from full_seller_hist  
)  
,l30d_changes as (  
    select  
        *
        ,case 
            when new_tax_id <> old_tax_id and old_tax_id is not null then 1 
            else 0 
        end as is_changed  
    from full_hist_lagged  
    where update_date >= date_sub('${ods_date_t0}', 30) -- ods_date_t0： t-0天
)  
,agg_by_type as (  
    select  
        shop_id
        ,new_tax_type as tax_type 
        ,count(case 
            when is_changed = 1 and old_tax_type = new_tax_type 
            then 1 
        end) as chg_30d
        ,count(case 
            when is_changed = 1 and old_tax_type = new_tax_type 
                and update_date >= date_sub('${ods_date_t0}', 15)
            then 1 
        end) as chg_15d  
        ,max_by(old_tax_id, update_datetime) filter (where is_changed = 1) as last_chg_old_tax  
        ,max_by(new_tax_id, update_datetime) filter (where is_changed = 1) as last_chg_new_tax  
        ,max_by(update_date, update_datetime) filter (where is_changed = 1) as last_chg_date  
        ,max_by(seller_type, update_datetime) as last_seller_type  
    from l30d_changes  
    group by shop_id, new_tax_type
),
${region}_final_tab as (
    select  
    a.shop_id
    ,max_by(l.seller_type, l.update_datetime) as seller_type  
    ,coalesce(
        max(case when l.old_tax_type = 1 and l.new_tax_type = 2 then 1 else 0 end), 
        0
    ) as has_cpf_cnpj_chg_30d
    ,coalesce(
        max(case when l.old_tax_type = 2 and l.new_tax_type = 1 then 1 else 0 end), 
        0
    ) as has_cnpj_cpf_chg_30d
    ,coalesce(max(case when a.tax_type = 1 then a.chg_30d end), 0) as cpf_chg_30d
    ,coalesce(max(case when a.tax_type = 1 then a.chg_15d end), 0) as cpf_chg_15d  
    ,max(case when a.tax_type = 1 then a.last_chg_old_tax end) as last_chg_old_cpf  
    ,max(case when a.tax_type = 1 then a.last_chg_new_tax end) as last_chg_new_cpf  
    ,max(case when a.tax_type = 1 then a.last_chg_date end) as last_cpf_chg_date 
    ,coalesce(max(case when a.tax_type = 2 then a.chg_30d end), 0) as cnpj_chg_30d
    ,coalesce(max(case when a.tax_type = 2 then a.chg_15d end), 0) as cnpj_chg_15d  
    ,max(case when a.tax_type = 2 then a.last_chg_old_tax end) as last_chg_old_cnpj
    ,max(case when a.tax_type = 2 then a.last_chg_new_tax end) as last_chg_new_cnpj  
    ,max(case when a.tax_type = 2 then a.last_chg_date end) as last_cnpj_chg_date
    ,'BR' as grass_region  
from agg_by_type a  
left join l30d_changes l on a.shop_id = l.shop_id  
group by a.shop_id
)  

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

    ,t2.gmv_usd_in_7d_pay

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

    ,t2.nmv_usd_in_7d_pay  
    ,t2.nmv_usd_in_30d_pay 
    ,t2.nmv_usd_in_60d_pay 
    ,t2.nmv_usd_in_90d_pay 
    ,t2.nmv_usd_in_180d_pay

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
    ,t1.penalty_tier_90d
    ,t4.uniq_servere_fraud_tag_30d    
    ,t4.uniq_servere_fraud_tag_31_60d 
    ,t4.uniq_servere_fraud_tag_61_90d 
    ,t4.uniq_moderate_fraud_tag_30d   
    ,t4.uniq_moderate_fraud_tag_31_60d
    ,t4.uniq_moderate_fraud_tag_61_90d
    ,cast(t5.seller_type as string) as seller_type
    ,coalesce(cast(t5.cpf_chg_30d as bigint),0) as cpf_chg_30d
    ,coalesce(cast(t5.cpf_chg_15d as bigint),0) as cpf_chg_15d
    ,if(coalesce(cast(t5.cpf_chg_30d as bigint),0) = 0, null, cast(t5.last_chg_old_cpf as string)) as last_chg_old_cpf
    ,if(coalesce(cast(t5.cpf_chg_30d as bigint),0) = 0, null, cast(t5.last_chg_new_cpf as string)) as last_chg_new_cpf
    ,if(coalesce(cast(t5.cpf_chg_30d as bigint),0) = 0, null, cast(t5.last_cpf_chg_date as string)) as last_chg_date
    ,coalesce(cast(t5.cnpj_chg_30d as bigint),0) as cnpj_chg_30d
    ,coalesce(cast(t5.cnpj_chg_15d as bigint),0) as cnpj_chg_15d
    ,if(coalesce(cast(t5.cnpj_chg_30d as bigint),0) = 0, null, cast(t5.last_chg_old_cnpj as string)) as last_chg_old_cnpj
    ,if(coalesce(cast(t5.cnpj_chg_30d as bigint),0) = 0, null, cast(t5.last_chg_new_cnpj as string)) as last_chg_new_cnpj
    ,if(coalesce(cast(t5.cnpj_chg_30d as bigint),0) = 0, null, cast(t5.last_cnpj_chg_date as string)) as last_cnpj_chg_date
    ,if(coalesce(cast(t5.cpf_chg_30d as bigint),0) = 0, null, cast(t5.last_cpf_chg_date as string)) as last_cpf_chg_date
    ,t5.has_cpf_cnpj_chg_30d
    ,t5.has_cnpj_cpf_chg_30d

    ,t6.nmv_usd_l2m_pay
    ,t6.nmv_usd_l3m_pay
    ,t6.place_order_cnt_1m
    ,t6.cancel_cnt_1m
    ,t6.pay_cnt_1m_pay
    ,t6.pay_cancel_1m_pay
    ,t6.pay_gmv_7d_pay
    ,t6.pay_gmv_1m_pay
    ,t6.escrow_paid_return_cnt_1m_esc
    ,t6.pay_cnt_1m_esc
    ,t6.escrow_paid_return_cnt_7d_esc
    ,t6.pay_cnt_7d_esc
    ,t1.grass_region
    ,t1.grass_date
from
(select * from ${SCHEMA}.dim_risk_shop_df where tz_type = 'local' and grass_region = upper('${region}')and grass_date = date '${bizdate}') t1
left join
(select * from ${SCHEMA}.dws_risk_shop_txn_df where tz_type = 'local' and grass_region = upper('${region}')and grass_date = date '${bizdate}') t2
on t1.grass_region = t2.grass_region
and t1.shop_id = t2.shop_id
left join
(select * from ${SCHEMA}.dws_risk_shop_promotion_df where tz_type = 'local' and grass_region = upper('${region}')and grass_date = date '${bizdate}') t3
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
                datediff(date('${ods_date_t0}'), date(modify_datetime)) AS days,
                type,
                severity,
                grass_region
            FROM antifraud_dw.dim_user_fraud_tag_hf 
            WHERE grass_region = upper('${region}')
            AND grass_date = date '${bizdate}'
            AND date(modify_datetime) >= date_sub('${ods_date_t0}', 90)
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
left join ${region}_final_tab t5 
on t1.shop_id = t5.shop_id
and t1.grass_region = t5.grass_region
left join seller_pay_cancel_esc_feature t6
on t1.shop_id = t6.shop_id
and t1.grass_region = t6.grass_region
;


create or replace view ${SCHEMA}.ads_risk_${region}_profile_shop_df as
select
    shop_id,
    user_id,
    is_cross_border_tag,
    is_preferred,
    is_official_store_tag,
    is_b2c,
    is_big_seller,
    response_rate,
    rating_star,
    holiday_mode_on,
    shopee_acct_status,
    main_category,
    sub_category,
    sku,
    active_item_with_stock_cnt,
    shop_like_cnt_td,
    is_preferred_plus_shop,
    is_managed_shop,
    txn_days_in_180d,
    max_inactivate_days_in_180d,
    seller_shopee_age,
    open_more_than_6m,
    open_more_than_12m,
    ttl_order_in_3d,
    seller_confirmed_order_in_30d,
    seller_confirmed_order_in_31_60d,
    seller_confirmed_order_in_61_90d,
    seller_confirmed_order_in_91_120d,
    seller_confirmed_order_in_121_150d,
    seller_confirmed_order_in_151_180d,
    seller_confirmed_order_in_181_210d,
    seller_confirmed_order_in_211_240d,
    seller_confirmed_order_in_241_270d,
    seller_confirmed_order_in_271_300d,
    seller_confirmed_order_in_301_330d,
    seller_confirmed_order_in_331_360d,
    seller_confirmed_order_in_361_390d,
    gmv_in_3d,
    gmv_in_7d,
    gmv_in_8_14d,
    gmv_in_15_21d,
    gmv_in_22_28d,
    gmv_usd_in_7d_pay,

    nmv_in_3d,
    nmv_in_7d,
    nmv_in_8_14d,
    nmv_in_15_21d,
    nmv_in_22_28d,
    nmv_in_30d,
    nmv_in_31_60d,
    nmv_in_61_90d,
    nmv_in_91_120d,
    nmv_in_121_150d,
    nmv_in_151_180d,
    nmv_in_181_210d,
    nmv_in_211_240d,
    nmv_in_241_270d,
    nmv_in_271_300d,
    nmv_in_301_330d,
    nmv_in_331_360d,
    nmv_in_361_390d,

    nmv_usd_in_7d_pay,   
    nmv_usd_in_30d_pay,  
    nmv_usd_in_60d_pay,  
    nmv_usd_in_90d_pay,  
    nmv_usd_in_180d_pay, 

    avg_nmv_last_12m_tag,
    avg_nmv_last_6m_tag,
    avg_nmv_last_3m_tag,
    min_nmv_last_12m_tag,
    min_nmv_last_6m_tag,
    min_nmv_last_3m_tag,
    has_order_month_last_3m,
    has_order_month_last_6m,
    cc_payment_ratio_last_3m,
    cc_payment_ratio_last_6m,
    return_order_in_30d,
    return_order_in_31_60d,
    return_order_in_61_90d,
    return_order_in_91_120d,
    return_order_in_121_150d,
    return_order_in_151_180d,
    return_order_in_181_210d,
    return_order_in_211_240d,
    return_order_in_241_270d,
    return_order_in_271_300d,
    return_order_in_301_330d,
    return_order_in_331_360d,
    return_order_in_361_390d,
    return_gmv_in_30d,
    return_gmv_31_60d,
    return_gmv_in_61_90d,
    return_gmv_in_91_120d,
    return_gmv_in_121_150d,
    return_gmv_in_151_180d,
    return_gmv_in_181_210d,
    return_gmv_in_211_240d,
    return_gmv_in_241_270d,
    return_gmv_in_271_300d,
    return_gmv_in_301_330d,
    return_gmv_in_331_360d,
    return_gmv_in_361_390d,
    distinct_buyer_in_3d,
    buyer_in_30d,
    buyer_in_31_60d,
    buyer_in_61_90d,
    buyer_in_91_120d,
    buyer_in_121_150d,
    buyer_in_151_180d,
    buyer_in_181_210d,
    buyer_in_211_240d,
    buyer_in_241_270d,
    buyer_in_271_300d,
    buyer_in_301_330d,
    buyer_in_331_360d,
    buyer_in_361_390d,
    cancellation_rate_l7d,
    cancellation_rate_l30d,
    discount_last_1m,
    discount_last_3m,
    voucher_last_1m,
    voucher_last_3m,
    follower_voucher_last_1m,
    follower_voucher_last_3m,
    top_picks_last_1m,
    top_picks_last_3m,
    bundle_deal_last_1m,
    bundle_deal_last_3m,
    shipping_fee_last_1m,
    shipping_fee_last_3m,
    add_on_deal_last_1m,
    add_on_deal_last_3m,
    create_order_cnt_in_15d,
    create_order_cnt_in_30d,
    cancelled_order_cnt_in_30d,
    shop_penalty_point,
    penalty_tier,
    penalty_tier_90d,
    uniq_servere_fraud_tag_30d,
    uniq_servere_fraud_tag_31_60d,
    uniq_servere_fraud_tag_61_90d,
    uniq_moderate_fraud_tag_30d,
    uniq_moderate_fraud_tag_31_60d,
    uniq_moderate_fraud_tag_61_90d,
    seller_type,
    cpf_chg_30d,
    cpf_chg_15d,
    last_chg_old_cpf,
    last_chg_new_cpf,
    last_chg_date as last_cpf_chg_date,
    cnpj_chg_30d,
    cnpj_chg_15d,
    last_chg_old_cnpj,
    last_chg_new_cnpj,
    last_cnpj_chg_date as last_cnpj_chg_date,
    has_cpf_cnpj_chg_30d,
    has_cnpj_cpf_chg_30d
    ${br_only_column},nmv_usd_l2m_pay
    ${br_only_column},nmv_usd_l3m_pay
    ${br_only_column},place_order_cnt_1m
    ${br_only_column},cancel_cnt_1m
    ${br_only_column},pay_cnt_1m_pay
    ${br_only_column},pay_cancel_1m_pay
    ${br_only_column},pay_gmv_7d_pay
    ${br_only_column},pay_gmv_1m_pay
    ${br_only_column},escrow_paid_return_cnt_1m_esc
    ${br_only_column},pay_cnt_1m_esc
    ${br_only_column},escrow_paid_return_cnt_7d_esc
    ${br_only_column},pay_cnt_7d_esc
    ,tz_type,
    grass_region,
    grass_date
from ${SCHEMA}.ads_risk_profile_shop_df
where
    grass_region = upper('${region}')
    and grass_date = '${grass_date}'
;