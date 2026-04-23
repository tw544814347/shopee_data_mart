
--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2023-12-05
-- Theme Domain：       商户
-- Description:         商户相关信息
-- Data Granularity:    shop_id
-- 变更历史：
-- update by zongyi.lu@shopee.com, 2023-12-05, 新增备注, 新增字段shop_penalty_point:商家当前penalty分数,penalty_tier 商家当前penalty级别
-- update by wei.tao 拆分成 region 并统一模版
-- update by nuo.chen@shopee.com, 2026-02-24, 新增字段 is_fbs https://casement.scredit.io/78703/requirement?jiraKey=SPFDT-60644
-- update by nuo.chen@shopee.com, 2026-02-26, 新增字段 shop_main_category, shop_median_price https://casement.scredit.io/78703/requirement?jiraKey=SPFDT-60500
--********************************************************************--

insert overwrite table ${SCHEMA}.dim_risk_shop_df partition (tz_type='local', grass_region, grass_date)
select
    t1.shop_id
    ,t1.user_id
    ,t1.is_cross_border_tag
    ,t1.is_preferred
    ,t1.is_preferred_plus_shop
    ,t1.is_official_store_tag
    ,t1.is_b2c
    ,t1.response_rate
    ,t1.rating_star
    ,t1.holiday_mode_on
    ,t1.shopee_acct_status
    ,t3.main_category
    ,t3.sub_category
    ,t3.sku
    ,t3.active_item_with_stock_cnt
    ,t5.shop_like_cnt_td
    ,t6.is_big_seller
    ,case when t1.is_managed_shop = 1 and t7.long_tail_tag <> 1 then 1 else 0 end as is_managed_shop
    ,t8.shop_penalty_point
    ,t8.penalty_tier

    ,t1.is_fbs
    ,t9.shop_median_price
    ,t10.shop_main_category
    ,cast(t10.shop_main_category_id as string) as shop_main_category_id
    ,t1.grass_region
    ,t1.grass_date
from
(
    select shop_id,
           user_id,
           is_cb_shop as is_cross_border_tag,
           is_preferred_shop as is_preferred,
           is_preferred_plus_shop,
           is_managed_shop,
           is_official_shop as is_official_store_tag,
           case
               when is_holiday_mode = 1 then 'true'
               else 'false'
           end holiday_mode_on,
           is_b2c, response_rate, rating_star
           ,status as shopee_acct_status
           ,grass_region, grass_date

           ,is_fbs
           
    from   mp_user.dim_shop__reg_s0_live
    where  grass_date = date('${bizdate}')
    and    grass_region = upper('${reg}')
    and shop_id <> 0
) t1
left join
(
    select shop_id,
           shop_level1_global_be_category as main_category,
           shop_level2_global_be_category as sub_category,
           active_item_cnt as sku,
           active_item_with_stock_cnt,
           grass_region
    from   mp_item.dws_shop_listing_td__reg_s0_live
    where  grass_date = date('${bizdate}')
    and    grass_region = upper('${reg}')
) t3
on t1.shop_id = t3.shop_id
and t1.grass_region = t3.grass_region
left join
(
    select shop_id,
           like_cnt_td as shop_like_cnt_td,
           grass_region
    from   mp_user.dws_shop_interaction_td__reg_s0_live
    where  grass_date =  date('${bizdate}')
    and    grass_region = upper('${reg}')
    and    shop_id!=0
) t5
on t1.shop_id = t5.shop_id
and t1.grass_region = t5.grass_region
left join
(
    select shop_id,
           if(shop_tier_id = 56,1,0) as is_big_seller,
           grass_region
    from   mp_seller.dim_shop_ext__reg_s0_live
    where  grass_date =  date('${bizdate}')
    and    grass_region = upper('${reg}')
) t6
on t1.shop_id = t6.shop_id
and t1.grass_region = t6.grass_region
left join
(
    select  shop_id
            ,case   when shop_tier is null or lower(shop_tier) not like '%mid%' and lower(shop_tier) not like '%short%' then 1
                    else 0
             end long_tail_tag
            ,grass_region
    from    mp_seller.dim_managed_shop__reg_s0_live
    where   grass_region = upper('${reg}')
      and   grass_date = date('${bizdate}')
) t7
on t1.shop_id = t7.shop_id
and t1.grass_region = t7.grass_region
left join (
    select 
    user_id
    ,shop_id
    ,grass_region
    ,shop_penalty_point
    ,penalty_tier
    from mp_seller.dim_shop_penalty_results__reg_s0_live
    where  grass_region = upper('${reg}')
    and grass_date = date('${bizdate}')
    group by user_id
    ,shop_id
    ,grass_region
    ,shop_penalty_point
    ,penalty_tier
) t8 on t1.shop_id = t8.shop_id
and t1.grass_region = t8.grass_region
left join (
    select 
        shop_id
        ,grass_region
        ,approx_percentile(price, 0.5) as shop_median_price
    from mp_item.dim_item__reg_s0_live
    where  grass_region = upper('${reg}')
        and grass_date = date('${bizdate}')
    group by shop_id, grass_region
) t9 on t1.shop_id = t9.shop_id
and t1.grass_region = t9.grass_region
left join (
    select 
        shop_id
        ,grass_region
        ,max_by(level1_global_be_category, nmv) as shop_main_category
        ,max_by(level1_global_be_category_id, nmv) as shop_main_category_id
    from(
        select 
            shop_id
            ,level1_global_be_category
            ,level1_global_be_category_id
            ,grass_region
            ,sum(nmv) as nmv
        from mp_order.dwd_order_item_all_ent_df__reg_s0_live
        where grass_region = upper('${reg}')
            and order_be_status_id in (2,4,11,12,13,14,15)
            and from_unixtime(create_timestamp) >= add_months(date('${bizdate}'), -1) 
            and from_unixtime(create_timestamp) < date('${bizdate}')
            and grass_date >= add_months(date('${bizdate}'), -1)  
            and grass_date < date('${bizdate}')
            and nmv > 0
            and tz_type = 'local'
        group by shop_id, level1_global_be_category, level1_global_be_category_id, grass_region
            )
    group by shop_id, grass_region
) t10 on t1.shop_id = t10.shop_id
and t1.grass_region = t10.grass_region
;