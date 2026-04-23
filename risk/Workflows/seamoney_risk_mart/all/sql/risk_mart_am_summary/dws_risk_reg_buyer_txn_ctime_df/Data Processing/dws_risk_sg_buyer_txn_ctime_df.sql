insert overwrite table ${SCHEMA}.dws_risk_buyer_txn_ctime_df partition (tz_type = 'local', grass_region, grass_date)
select  a.buyer_id as buyer_id
        ,if(b.is_official_store_tag + b.is_cross_border_tag + b.is_preferred + b.is_b2c >= 1, 1, 0) as big_shop_flag
        ,sum(a.gmv) as gmv
        ,count(distinct order_id) as order_cnt
        ,SUM(if(a.level1_category_id in (15580)
        or a.level1_global_be_category_id = 100642
        or a.level2_global_be_category_id = 100071
        or a.level3_global_be_category_id in (101393, 101091), a.gmv, 0)) as virtual_gmv
        ,count(distinct if(a.level1_category_id in (15580)
        or a.level1_global_be_category_id = 100642
        or a.level2_global_be_category_id = 100071
        or a.level3_global_be_category_id in (101393, 101091), a.order_id, null)) as virtual_order_cnt
        ,to_date(a.create_datetime) as create_date
        ,a.grass_region as grass_region
        ,'${bizdate}' as grass_date
from    (
    select  *
    from    mp_order.dwd_order_item_all_ent_df__reg_s0_live
    where   tz_type = 'local'
      and   grass_region = upper('${region}')
      and   grass_date >= date_sub('${bizdate}', 180)
      and   to_date(create_datetime) >= date_sub('${bizdate}', 180)
) a
left join (
    select  shop_id
            ,is_official_store_tag
            ,is_cross_border_tag
            ,is_preferred
            ,is_b2c
            ,grass_date
            ,grass_region
    from    ${SCHEMA}.dim_risk_shop_df
    where   tz_type = 'local'
      and   grass_region = upper('${region}')
      and   grass_date = '${bizdate}'
) b
on      a.shop_id = b.shop_id
  and   a.grass_region = b.grass_region
group by a.buyer_id, if(b.is_official_store_tag + b.is_cross_border_tag + b.is_preferred + b.is_b2c >= 1, 1, 0), a.grass_region, to_date(a.create_datetime)
;

create or replace view ${SCHEMA}.dws_risk_${region}_buyer_txn_ctime_df as
select
    *
from ${SCHEMA}.dws_risk_buyer_txn_ctime_df
where
    grass_region = upper('${region}')
;