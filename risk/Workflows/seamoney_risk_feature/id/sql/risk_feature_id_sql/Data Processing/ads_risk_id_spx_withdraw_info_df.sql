create external table if not exists ${SCHEMA}.ads_risk_id_spx_withdraw_info_df (
    spx_transaction_id string comment 'spx_transaction_id'
    ,shipping_trace_no_list string comment 'shipping_trace_no_list'
    ,platform_order_id_list string comment 'platform_order_id_list'
    ,platform_user_id_list string comment 'platform_user_id_list'
    ,shop_id_list string comment 'shop_id_list'
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/ads/ads_risk_spx_withdraw_info_df/garss_region=${upper_region}'
;


create or replace temporary view spx_order as (
    select
        a.transaction_id as spx_transaction_id
        ,a.user_id as rider_id
        ,b.order_id as spx_order_id
    from
        spx_mart.shopee_spx_finance_id_db__biz_payment_request_tab__reg_continuous_s0_live a
        left join spx_mart.shopee_spx_finance_id_db__biz_payment_request_order_relation_tab__reg_continuous_s0_live b on a.out_trade_no = b.out_trade_no
    where
        a.payment_status = 2 --可能有一部分不是shopee的订单。
)
;

create or replace temporary view mp_order_logistics as (
    select
        shop_id
        ,order_id as platform_order_id
        ,user_id as platform_user_id
        ,shipping_carrier
        ,actual_carrier
        ,shipping_confirm_time
        ,shipping_traceno as shipping_trace_no
        ,from_unixtime(delivery_time) as delivery_time
        ,pickup_time
        ,from_unixtime(receive_time) as receive_time
    from
        marketplace.shopee_order_of_order_id_db__order_fulfilment_order_tab__reg_continuous_s0_live
    where date(from_unixtime(create_time)) >= current_date - interval '180' day
)
;

insert overwrite table ${SCHEMA}.ads_risk_id_spx_withdraw_info_df partition (grass_date = '${grass_date}')
select
    t1.spx_transaction_id
    ,concat_ws(',', collect_set(t2.shipping_trace_no)) as shipping_trace_no_list
    ,concat_ws(',', collect_set(t2.platform_order_id)) as platform_order_id_list
    ,concat_ws(',', collect_set(t2.platform_user_id)) as platform_user_id_list
    ,concat_ws(',', collect_set(t2.shop_id)) as shop_id_list
from
    spx_order t1
    inner join mp_order_logistics t2 on t1.spx_order_id = t2.shipping_trace_no
group by t1.spx_transaction_id
;