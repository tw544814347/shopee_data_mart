------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-04-26
-- Description:         订单完成时的明细数据
-- Data Granularity:    
-- PRD:             

-- Update：
-- v1, dwd_order_item_place_pay_complete_di__reg_s0_live表里的checkout_device_id变为空了，改用mp_order.dwd_checkout_all_ent_snapshot_df__reg_live表(pk: checkout_id)
------------------------------------------------------------------------

create or replace temporary view order_item_complete_di_spdf as
select
    a1.buyer_id                                                             as buyer_id
    ,a1.order_id                                                            as order_id
    ,a1.checkout_id                                                         as checkout_id
    ,a1.item_id                                                             as item_id
    ,coalesce(a2.is_physical_product, 'N')                                  as is_physical_product
    ,a1_1.device_id                                                         as checkout_shopee_device_id
    ,a1.complete_timestamp                                                  as complete_timestamp
    ,coalesce(tongdun.tongdun_device_id, tongdun_history.tongdun_device_id) as tongdun_device_id
    ,a1.grass_region                                                        as grass_region
    ,date('${bizdate}')                                                     as grass_date
    ,a1.create_timestamp                                                    as create_timestamp
    ,to_date(a1.complete_datetime)                                          as complete_date
    ,a1.complete_timestamp - a1.create_timestamp                            as complete_duration
    ,a1.shop_id                                                             as shop_id
    ,if(nvl(a4.is_official_store_tag,0)
        + nvl(a4.is_cross_border_tag,0)
        + nvl(a4.is_preferred,0)
        + nvl(a4.is_b2c,0) >= 1, 1, 0)                                      as big_shop_flag
from (
    select
        *
    from mp_order.dwd_order_item_place_pay_complete_di__reg_s0_live
    where grass_date = date('${bizdate}')
      and is_completed = 1
      and grass_region = '${grass_region}'
) a1
left outer join (
  select
      checkout_id
      ,device_id
      ,grass_region
  from mp_order.dwd_checkout_all_ent_snapshot_df__reg_live
  where tz_type = 'local'
  and grass_region = '${grass_region}'
  and grass_date = '${bizdate}'
) a1_1 on a1.grass_region = a1_1.grass_region
and a1.checkout_id = a1_1.checkout_id
left outer join (
    select
        item_id
        ,is_physical_product
        ,grass_region
    from ${SCHEMA}.dim_risk_item_df
    where grass_date = date('${bizdate}')
      and grass_region = '${grass_region}'
) a2
  on a1.item_id = a2.item_id
    and a1.grass_region = a2.grass_region
left outer join (
    select
        tongdun_device_id
        ,hash_shopee_df
        ,grass_region
    from ${SCHEMA}.dim_risk_tongdun_device_mapping_tab
    where tz_type='local'
      and grass_region = '${grass_region}'
) tongdun
  on a1.grass_region = tongdun.grass_region and a1.checkout_device_id = tongdun.hash_shopee_df
left outer join (
    select
        tongdun_device_id
        ,hash_shopee_df
    from ${SCHEMA}.dim_risk_tongdun_device_mapping_history_df
    where tz_type='local'
) tongdun_history
  on tongdun.tongdun_device_id is null and a1.checkout_device_id = tongdun_history.hash_shopee_df
left outer join (
    select
      shop_id
      ,is_official_store_tag
      ,is_cross_border_tag
      ,is_preferred
      ,is_b2c
      ,grass_region
    from ${SCHEMA}.dim_risk_shop_df
    where grass_date= date('${bizdate}')
      and tz_type='local'
      and grass_region = '${grass_region}'
) a4 on a1.shop_id = a4.shop_id and a1.grass_region = a4.grass_region
;

insert overwrite table ${SCHEMA}.dwd_risk_order_item_complete_di partition (tz_type='local', grass_region, grass_date)
select
     t1.buyer_id                                                             as buyer_id
    ,t1.order_id                                                             as order_id
    ,t1.checkout_id                                                          as checkout_id
    ,t1.item_id                                                              as item_id
    ,t1.is_physical_product                                                  as is_physical_product
    ,t1.checkout_shopee_device_id                                            as checkout_shopee_device_id
    ,t1.complete_timestamp                                                   as complete_timestamp
    ,t1.tongdun_device_id                                                    as tongdun_device_id
    ,coalesce(t2.sz_dfp_device_id, t3.sz_dfp_device_id, t4.sz_dfp_device_id) as sz_dfp_device_id
    ,t1.create_timestamp                                                     as create_timestamp
    ,t1.complete_date                                                        as complete_date
    ,t1.complete_duration                                                    as complete_duration
    ,t1.shop_id                                                              as shop_id
    ,t1.big_shop_flag                                                        as big_shop_flag
    ,t1.grass_region                                                         as grass_region
    ,t1.grass_date                                                           as grass_date
from order_item_complete_di_spdf t1
left join
(
    select
        checkout_id
        ,grass_region
        ,first(dfpinfosz__securitydeviceid) as sz_dfp_device_id
    from
        (
            select
                checkout_ids
                ,dfpinfosz__securitydeviceid
                ,grass_region
            from antifraud_dw.dwd_evt_mp_checkout_di
            where grass_region = '${grass_region}'
                and grass_date >= date_sub('${bizdate}',30)
        ) lateral view explode(checkout_ids) ids as checkout_id
    group by checkout_id, grass_region
) t2
on t1.grass_region = t2.grass_region
  and t1.checkout_id = t2.checkout_id
left join
(
    select
        device_type
        ,device_id
        ,sz_dfp_device_id
        ,grass_region
    from ${SCHEMA}.dim_risk_sz_dfp_device_mapping_df
    where tz_type='local'
      and grass_date = date('${bizdate}')
      and grass_region = '${grass_region}'
      and device_type = 'tddf'
) t3
on t1.grass_region = t3.grass_region
  and t1.tongdun_device_id = t3.device_id
left join
(
    select
        device_type
        ,device_id
        ,sz_dfp_device_id
        ,grass_region
    from ${SCHEMA}.dim_risk_sz_dfp_device_mapping_df
    where tz_type='local'
      and grass_date = date('${bizdate}')
      and grass_region = '${grass_region}'
      and device_type = 'spdf'
) t4
on t1.grass_region = t4.grass_region
  and t1.checkout_shopee_device_id = t4.device_id
;