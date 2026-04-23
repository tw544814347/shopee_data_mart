insert overwrite ${SCHEMA}.ads_my_mp_seller_earliest_pay_time_df partition (grass_date = '${ds}')
select shop_id                                                      as shop_id, 
       min(pay_timestamp)                                           as earliest_pay_timestamp
from mp_order.dwd_order_item_all_ent_df__my_s0_live 
where pay_timestamp is not null
group by shop_id
;