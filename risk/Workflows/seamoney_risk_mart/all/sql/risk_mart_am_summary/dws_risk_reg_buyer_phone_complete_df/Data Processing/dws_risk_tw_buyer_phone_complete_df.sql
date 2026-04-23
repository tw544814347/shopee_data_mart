create or replace temporary view complete_table as
select
    buyer_id
    ,order_id
    ,is_physical_product_order
    ,grass_region
    ,grass_date
from ${SCHEMA}.dwd_risk_order_complete_di
where grass_date <= date('${bizdate}')
  and grass_date > date_sub(date('${bizdate}'), 180)
  and tz_type = 'local'
  and grass_region = upper('${region}');

create or replace temporary view phone_table as
select
    order_id
    ,buyer_id
    ,recipient_phone as shipping_phone
    ,grass_region
from mp_order.dwd_order_all_ent_df__reg_s1_live
where grass_region = upper('${region}')
    and grass_date <= date('${bizdate}')
    and grass_date > date_sub(date('${bizdate}'), 180)
    and coalesce(recipient_phone, '') <> '';

create or replace temporary view combine_table as
select
    a1.buyer_id
    ,a2.shipping_phone
    ,a1.grass_region
    ,a1.order_id
from complete_table a1
join phone_table a2
  on a1.buyer_id = a2.buyer_id
  and a1.order_id = a2.order_id
  and a1.grass_region = a2.grass_region;

insert overwrite table ${SCHEMA}.dws_risk_buyer_phone_complete_df partition (tz_type='local', grass_region, grass_date)
select
    buyer_id
    ,shipping_phone as phone
    ,shipping_phone
    ,count(order_id) as complete_physical_ord_cnt_6m
    ,grass_region
    ,date('${bizdate}') as grass_date
from combine_table
group by
    buyer_id
    ,shipping_phone
    ,grass_region
;

create or replace view ${SCHEMA}.dws_risk_${region}_buyer_phone_complete_df as
select
    *
from ${SCHEMA}.dws_risk_buyer_phone_complete_df
where
    grass_region = upper('${region}')
;