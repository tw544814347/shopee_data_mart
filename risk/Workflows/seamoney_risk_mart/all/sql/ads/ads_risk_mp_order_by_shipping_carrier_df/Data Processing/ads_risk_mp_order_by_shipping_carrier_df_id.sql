insert overwrite table ${SCHEMA}.ads_risk_mp_order_by_shipping_carrier_df partition(grass_region,grass_date)
select concat_ws('_', substr(md5(cast(buyer_id as string)), 0, 2), cast(buyer_id as string), 'virtual', 'completed',
                 'shopeepay', create_timestamp, order_id) as rowkey
     , cast(gmv as string)                                as qf
     , grass_region
     , grass_date
from mp_order.dwd_order_item_all_ent_df__reg_s0_live
where lower(fulfilment_shipping_carrier) like '%virtual%'
  and order_fe_status_id = 3
  and (payment_method like '%PAY_SHOPEE_WALLET_V2%' or payment_method like '%PAY_SHOPEE_WALLET%')
  and grass_date >= date_sub('${grass_date}', 30)
  and grass_region = 'ID'
union all
select concat_ws('_', substr(md5(cast(buyer_id as string)), 0, 2), cast(buyer_id as string), 'own', 'completed',
                 'shopeepay', create_timestamp, order_id) as rowkey
     , cast(gmv as string)                                as qf
     , grass_region
     , grass_date
from mp_order.dwd_order_item_all_ent_df__reg_s0_live
where lower(fulfilment_shipping_carrier) like '%own%'
  and order_fe_status_id = 3
  and (payment_method like '%PAY_SHOPEE_WALLET_V2%' or payment_method like '%PAY_SHOPEE_WALLET%')
  and grass_date >= date_sub('${grass_date}', 30)
  and grass_region = 'ID'
union all
select concat_ws('_', substr(md5(cast(buyer_id as string)), 0, 2), cast(buyer_id as string), 'virtual', 'all',
                 'shopeepay', create_timestamp, order_id) as rowkey
     , cast(gmv as string)                                as qf
     , grass_region
     , grass_date
from mp_order.dwd_order_item_all_ent_df__reg_s0_live
where lower(fulfilment_shipping_carrier) like '%virtual%'
  and (payment_method like '%PAY_SHOPEE_WALLET_V2%' or payment_method like '%PAY_SHOPEE_WALLET%')
  and grass_date >= date_sub('${grass_date}', 30)
  and grass_region = 'ID'
union all
select concat_ws('_', substr(md5(cast(buyer_id as string)), 0, 2), cast(buyer_id as string), 'own', 'all',
                 'shopeepay', create_timestamp, order_id) as rowkey
     , cast(gmv as string)                                as qf
     , grass_region
     , grass_date
from mp_order.dwd_order_item_all_ent_df__reg_s0_live
where lower(fulfilment_shipping_carrier) like '%own%'
  and (payment_method like '%PAY_SHOPEE_WALLET_V2%' or payment_method like '%PAY_SHOPEE_WALLET%')
  and grass_date >= date_sub('${grass_date}', 30)
  and grass_region = 'ID'



union all
select concat_ws('_', substr(md5(cast(buyer_id as string)), 0, 2), cast(buyer_id as string), 'virtual', 'completed',
                 'all', create_timestamp, order_id) as rowkey
     , cast(gmv as string)                                as qf
     , grass_region
     , grass_date
from mp_order.dwd_order_item_all_ent_df__reg_s0_live
where lower(fulfilment_shipping_carrier) like '%virtual%'
  and order_fe_status_id = 3
  and grass_date >= date_sub('${grass_date}', 30)
  and grass_region = 'ID'
union all
select concat_ws('_', substr(md5(cast(buyer_id as string)), 0, 2), cast(buyer_id as string), 'own', 'completed',
                 'all', create_timestamp, order_id) as rowkey
     , cast(gmv as string)                                as qf
     , grass_region
     , grass_date
from mp_order.dwd_order_item_all_ent_df__reg_s0_live
where lower(fulfilment_shipping_carrier) like '%own%'
  and order_fe_status_id = 3
  and grass_date >= date_sub('${grass_date}', 30)
  and grass_region = 'ID'
union all
select concat_ws('_', substr(md5(cast(buyer_id as string)), 0, 2), cast(buyer_id as string), 'virtual', 'all',
                 'all', create_timestamp, order_id) as rowkey
     , cast(gmv as string)                                as qf
     , grass_region
     , grass_date
from mp_order.dwd_order_item_all_ent_df__reg_s0_live
where lower(fulfilment_shipping_carrier) like '%virtual%'
  and grass_date >= date_sub('${grass_date}', 30)
  and grass_region = 'ID'
union all
select concat_ws('_', substr(md5(cast(buyer_id as string)), 0, 2), cast(buyer_id as string), 'own', 'all',
                 'all', create_timestamp, order_id) as rowkey
     , cast(gmv as string)                                as qf
     , grass_region
     , grass_date
from mp_order.dwd_order_item_all_ent_df__reg_s0_live
where lower(fulfilment_shipping_carrier) like '%own%'
  and grass_date >= date_sub('${grass_date}', 30)
  and grass_region = 'ID'
;
