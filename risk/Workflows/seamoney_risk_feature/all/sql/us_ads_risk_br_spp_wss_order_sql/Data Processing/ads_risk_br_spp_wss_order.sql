insert overwrite table ${SCHEMA}.ads_risk_br_spp_wss_order
select concat_ws('_', substr(md5(cast(merchant_id as string)), 0, 2), cast(merchant_id as string),order_type, 'success') as rowkey
       ,cast(count(order_sn) as string) as cnt
       ,cast(sum(amount) as string) as amt
from (
  select order_id
        ,order_sn
        ,merchant_id
        ,order_type
        ,order_status
        ,amount
        ,create_time
        ,update_time
        ,row_number() over(partition by order_sn order by update_time desc) as rn 
  from shopeepay.shopee_shopeepay_wss_order_br_db__merchant_order_tab__reg_continuous_s0_live
  where char_length(order_sn) > 0
      and merchant_id > 0
      and order_type is not null
      and order_status is not null
      and create_time >= unix_timestamp(date_sub('${grass_date}', 30), 'yyyy-MM-dd')
      and update_time > 0
)
where rn = 1
  and order_status in (7)
group by merchant_id,order_type

union all 
select concat_ws('_', substr(md5(cast(merchant_id as string)), 0, 2), cast(merchant_id as string),order_type, 'all') as rowkey
       ,cast(count(order_sn) as string) as cnt
       ,cast(sum(amount) as string) as amt
from (
  select order_id
        ,order_sn
        ,merchant_id
        ,order_type
        ,order_status
        ,amount
        ,create_time
        ,update_time
        ,row_number() over(partition by order_sn order by update_time desc) as rn 
  from shopeepay.shopee_shopeepay_wss_order_br_db__merchant_order_tab__reg_continuous_s0_live
  where char_length(order_sn) > 0
      and merchant_id > 0
      and order_type is not null
      and order_status is not null
      and create_time >= unix_timestamp(date_sub('${grass_date}', 30), 'yyyy-MM-dd')
      and update_time > 0
)
where rn = 1
group by merchant_id,order_type
;





