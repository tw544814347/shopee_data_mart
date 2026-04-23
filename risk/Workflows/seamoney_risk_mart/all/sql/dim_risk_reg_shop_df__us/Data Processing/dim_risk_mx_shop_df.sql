--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2023-12-05
-- Theme Domain：       商户
-- Description:         商户相关信息
-- Data Granularity:    shop_id
-- 变更历史：
--      update by zongyi.lu@shopee.com, 2023-12-05, 新增备注, 新增字段shop_penalty_point:商家当前penalty分数,penalty_tier 商家当前penalty级别
--      update by huangyue 2025-12-03 新增penalty_tier_90d
--********************************************************************--

-- drop table if exists ${SCHEMA}.dim_risk_shop_df;
create external table if not exists ${SCHEMA}.dim_risk_shop_df
(
    shop_id                      bigint comment "PK unique id of the shop"
    ,user_id                     bigint comment "unique userid of the buyer"
    ,is_cross_border_tag         bigint comment "whether shop is cross border"
    ,is_preferred                bigint comment "prefered shop flag"
    ,is_preferred_plus_shop      bigint comment "if shop_id is preferred+ then this flag is 1, else 0"
    ,is_official_store_tag       bigint comment "official shop flag"
    ,is_b2c                      bigint comment "seller b2c flag"
    ,response_rate               double comment "response rate"
    ,rating_star                 double comment "shop star rating"
    ,holiday_mode_on             string comment "seller holiday flag"
    ,shopee_acct_status          bigint comment "shop status"
    ,main_category               string comment "the key main category of the shop based on the count of live items listed by the shop"
    ,sub_category                string comment "the key sub category of the shop based on the live items listed by the shop"
    ,sku                         bigint comment "the total number of active items (status = 1) listed by the shop"
    ,active_item_with_stock_cnt  bigint comment "the sku of active items (status = 1) listed by the shop"
    ,shop_like_cnt_td            bigint comment "total like count from a shop from users who are active"
    ,is_big_seller               int    comment "is big seller"
    ,is_managed_shop             tinyint comment "whether shop is managed or not"
    ,shop_penalty_point          bigint  comment "penalty points of the shop 商家当前penalty分数"
    ,penalty_tier                bigint  comment "penalty tier of the shop based on the shop's penalty points 商家当前penalty级别"
    ,penalty_tier_90d            bigint  comment "max penalty tier in last 90 days"
)
partitioned by
(
    tz_type         string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string          comment         'partition key, yyyy-MM-dd'
)
comment 'Tag:risk summary table'
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dim/dim_risk_shop_df';
-- msck repair table ${SCHEMA}.dim_risk_shop_df;

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
    ,t9.penalty_tier_90d
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
    from   mp_user.dim_shop__reg_s0_live
    where  grass_date = date('${bizdate}')
    and    (grass_region = '${grass_region}')
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
    and    (grass_region = '${grass_region}')
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
    and    (grass_region = '${grass_region}')
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
    and    (grass_region = '${grass_region}')
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
    where  (grass_region = '${grass_region}')
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
    where  (grass_region = '${grass_region}')
    and grass_date = date('${bizdate}')
    group by user_id
    ,shop_id
    ,grass_region
    ,shop_penalty_point
    ,penalty_tier
) t8 on t1.shop_id = t8.shop_id
and t1.grass_region = t8.grass_region
left join (
    select  user_id
            ,shop_id
            ,grass_region
            ,max(penalty_tier)  as penalty_tier_90d 
    from mp_seller.dim_shop_penalty_results__reg_s0_live 
    where (grass_region = '${grass_region}')
      and tz_type='local' 
      and grass_date >= current_date - interval '90' day
    group by 1, 2, 3
) t9 on t1.shop_id = t9.shop_id
and t1.grass_region = t9.grass_region
;