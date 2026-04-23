

-- update by zongyi.lu@shopee.com 2024-11-19 marketplace.ods_shopee_seller_marketing_db__hot_sales_plan_tab__reg_s0_live 改成 mp_seller.dim_shop_top_picks__reg_s0_live
create or replace temporary view promotion_discount as
select
    shop_id
    ,max(if(diff_months <=1, 1, null)) as discount_last_1m
    ,max(if(diff_months <=3, 1, null)) as discount_last_3m
from
(
    select
        shop_id
        ,ceil(months_between(date_add('${bizdate}',1), date(from_unixtime(create_timestamp)))) as diff_months
    from mp_promo.dim_seller_discount__reg_live
    where grass_region = upper('${region}')
    and grass_date = '${grass_date}'
    and date(from_unixtime(create_timestamp)) >= date_add('${bizdate}',1) - interval '3' month
    group by 1,2
) t
group by 1
;

create or replace temporary view promotion_voucher as
select
    shop_id
    ,max(if(diff_months <=1, 1, null)) as voucher_last_1m
    ,max(if(diff_months <=3, 1, null)) as voucher_last_3m
from
(
    select
        shop_id
        ,ceil(months_between(date_add('${bizdate}',1), date(from_unixtime(voucher_create_timestamp)))) as diff_months
    from mp_voucher.dim_voucher__reg_live
    where grass_region = upper('${region}')
    and grass_date = '${bizdate}'
    and date(from_unixtime(voucher_create_timestamp)) >= date_add('${bizdate}',1) - interval '3' month
    and (from_json(voucher_combined_extra_info._decoded_extra_info, 'struct<backend_created:string>').backend_created is null or 
         from_json(voucher_combined_extra_info._decoded_extra_info, 'struct<backend_created:string>').backend_created = false)
    group by 1,2
) t
group by 1
;

create or replace temporary view promotion_follower_voucher as
select
    shop_id
    ,max(if(diff_months <=1, 1, null)) as follower_voucher_last_1m
    ,max(if(diff_months <=3, 1, null)) as follower_voucher_last_3m
from
(
    select
        shop_id
        ,ceil(months_between(date_add('${bizdate}',1), date(from_unixtime(create_time)))) as diff_months
    from marketplace.shopee_growth_follow_prize_db__follow_prize_campaign_tab__reg_daily_s0_live
    where date(from_unixtime(create_time)) >= date_add('${bizdate}',1) - interval '3' month
    group by 1,2
) t
group by 1
;

create or replace temporary view promotion_top_picks as
select
    shop_id
    ,max(if(diff_months <=1, 1, null)) as top_picks_last_1m
    ,max(if(diff_months <=3, 1, null)) as top_picks_last_3m
from
(
    select
        shop_id
        ,ceil(months_between(date_add('${bizdate}',1), date(from_unixtime(create_timestamp)))) as diff_months
    from
    (
        select shop_id, create_timestamp from mp_seller.dim_shop_top_picks__reg_s0_live
        where tz_type = 'local'
        and grass_region in ('BR','MX')
        and grass_date = '${bizdate}'
    ) t
    where date(from_unixtime(create_timestamp)) >= date_add('${bizdate}',1) - interval '3' month
    group by 1,2
)
group by 1
;

create or replace temporary view promotion_bundle_deal as
select
    shop_id
    ,max(if(diff_months <=1, 1, null)) as bundle_deal_last_1m
    ,max(if(diff_months <=3, 1, null)) as bundle_deal_last_3m
from
(
    select
        shop_id
        ,ceil(months_between(date_add('${bizdate}',1), date(create_datetime))) as diff_months
    from mp_promo.dim_bundle_deal__reg_live
    where grass_region = upper('${region}')
    and grass_date = '${grass_date}'
    and date(create_datetime) >= date_add('${bizdate}',1) - interval '3' month
    group by 1,2
)
group by 1
;

create or replace temporary view promotion_shipping_fee as
select
    shop_id
    ,max(if(diff_months <=1, 1, null)) as shipping_fee_last_1m
    ,max(if(diff_months <=3, 1, null)) as shipping_fee_last_3m
from
(
    select
        shop_id
        ,ceil(months_between(date_add('${bizdate}',1), date(create_datetime))) as diff_months
    from
    (
        select shop_id,create_datetime from mp_promo.dim_seller_defined_shipping_promo__reg_live
        where grass_region = upper('${region}')
        and grass_date = '${grass_date}'  
    ) t
    where date(create_datetime) >= date_add('${bizdate}',1) - interval '3' month
    group by 1,2
)
group by 1
;

create or replace temporary view promotion_add_on_deal as
select
    shop_id
    ,max(if(diff_months <=1, 1, null)) as add_on_deal_last_1m
    ,max(if(diff_months <=3, 1, null)) as add_on_deal_last_3m
from
(
    select
        shop_id
        ,ceil(months_between(date_add('${bizdate}',1), date(create_datetime))) as diff_months
    from mp_promo.dim_add_on_deal__reg_live
    where grass_region = upper('${region}')
    and grass_date = '${grass_date}'
    and date(create_datetime) >= date_add('${bizdate}',1) - interval '3' month
    and source_id = 1
    group by 1,2
)
group by 1
;

insert overwrite table ${SCHEMA}.dws_risk_shop_promotion_df partition (tz_type='local', grass_region, grass_date)
select
    t1.shop_id
    ,t2.discount_last_1m
    ,t2.discount_last_3m
    ,t3.voucher_last_1m
    ,t3.voucher_last_3m
    ,t4.follower_voucher_last_1m
    ,t4.follower_voucher_last_3m
    ,t5.top_picks_last_1m
    ,t5.top_picks_last_3m
    ,t6.bundle_deal_last_1m
    ,t6.bundle_deal_last_3m
    ,t7.shipping_fee_last_1m
    ,t7.shipping_fee_last_3m
    ,t8.add_on_deal_last_1m
    ,t8.add_on_deal_last_3m
    ,t1.grass_region
    ,t1.grass_date
from
(
    select
    shop_id
    ,grass_region
    ,grass_date
    from
    ${SCHEMA}.dim_risk_shop_df
    where tz_type = 'local'
        and grass_region = upper('${region}')
        and grass_date = date '${bizdate}'
) t1
left join promotion_discount t2
on t1.shop_id = t2.shop_id
left join promotion_voucher t3
on t1.shop_id = t3.shop_id
left join promotion_follower_voucher t4
on t1.shop_id = t4.shop_id
left join promotion_top_picks t5
on t1.shop_id = t5.shop_id
left join promotion_bundle_deal t6
on t1.shop_id = t6.shop_id
left join promotion_shipping_fee t7
on t1.shop_id = t7.shop_id
left join promotion_add_on_deal t8
on t1.shop_id = t8.shop_id
;

create or replace view ${SCHEMA}.dws_risk_${region}_shop_promotion_df as
select
    *
from ${SCHEMA}.dws_risk_shop_promotion_df
where
    grass_region = upper('${region}')
;