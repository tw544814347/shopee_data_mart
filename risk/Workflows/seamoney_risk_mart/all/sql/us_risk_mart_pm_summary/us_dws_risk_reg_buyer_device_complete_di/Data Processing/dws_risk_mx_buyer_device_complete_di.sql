insert overwrite table ${SCHEMA}.dws_risk_buyer_device_complete_di partition (tz_type='local', grass_region, grass_date)
select
    buyer_id
    ,checkout_shopee_device_id as shopee_device_id
    ,count(case
        when is_physical_product = 'Y' then order_id end) as complete_physical_product_ord_cnt_1d
    ,min(case
        when is_physical_product = 'Y' then complete_timestamp end) as fas_timestamp_of_complete_physical_product_ord_1d
    ,sz_dfp_device_id
    ,grass_region
    ,date('${bizdate}') as grass_date
from ${SCHEMA}.dwd_risk_order_item_complete_di
where grass_date = date('${bizdate}')
  and checkout_shopee_device_id is not null
  and tz_type = 'local'
  and grass_region = upper('${region}')
  and is_physical_product = 'Y'
group by
    buyer_id
    ,checkout_shopee_device_id
    ,grass_region
    ,sz_dfp_device_id;

create or replace view ${SCHEMA}.dws_risk_${region}_buyer_device_complete_di as
select
    *
from ${SCHEMA}.dws_risk_buyer_device_complete_di
where
    grass_region = upper('${region}')
;