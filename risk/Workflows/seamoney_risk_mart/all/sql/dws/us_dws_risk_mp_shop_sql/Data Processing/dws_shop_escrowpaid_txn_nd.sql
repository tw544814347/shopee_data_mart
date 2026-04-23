create or replace temporary view dws_shop_escrowpaid_txn_base as
select 
shop_id
,grass_region
,shipping_confirm_datetime
,escrow_to_seller_amt_usd
,shipping_confirm_timestamp
,escrow_to_seller_amt
,escrow_paid_datetime
,is_net_order
,gmv
,payment_method_id
from    mp_order.dwd_order_all_ent_df__reg_s0_live
where   grass_date >= date_sub('${grass_date}', 181)
  or    (
                grass_date = DATE '9999-01-01'
            and order_be_status in ('ESCROW_PAID', 'CANCEL_COMPLETED', 'INVALID')
            and date_format(escrow_paid_datetime, 'yyyy-MM-dd') >= date_sub('${grass_date}', 181)
        )
;

create or replace temporary view dws_shop_escrowpaid_txn_pctl as
select  shop_id
        ,grass_region
        ,percentile_approx(daily_escrow_to_seller_amt, 0.75, 10000) as daily_escrow_l6m_75pctl
from
(
  select  shop_id
          ,grass_region
          ,date_format(shipping_confirm_datetime, 'yyyy-MM-dd') as shipping_confirm_date
          ,SUM(escrow_to_seller_amt) daily_escrow_to_seller_amt
  from dws_shop_escrowpaid_txn_base
  where shipping_confirm_timestamp is not null
  and escrow_to_seller_amt > 0
  group by shop_id, grass_region, date_format(shipping_confirm_datetime, 'yyyy-MM-dd')
)
group by shop_id, grass_region
;

create or replace temporary view dws_shop_escrowpaid_nmv_months as
select  shop_id
        ,grass_region
        ,CAST(SUM(CASE WHEN months <= 3 THEN monthly_nmv ELSE NULL END) AS DOUBLE)/3 as avg_escrowpaid_nmv_l3m
        ,CAST(SUM(CASE WHEN months <= 6 THEN monthly_nmv ELSE NULL END) AS DOUBLE)/6 as avg_escrowpaid_nmv_l6m
from
(
  select  shop_id
          ,grass_region
          ,ceil(months_between(CURRENT_DATE, escrow_paid_datetime)) as months
          ,SUM(CASE WHEN is_net_order = 1 THEN gmv ELSE NULL END) monthly_nmv
          ,SUM(CASE WHEN is_net_order = 1 AND payment_method_id IN (14,21,24,15,19) THEN gmv ELSE NULL END) monthly_cc_nmv
  from dws_shop_escrowpaid_txn_base
  group by shop_id, grass_region, ceil(months_between(CURRENT_DATE, escrow_paid_datetime))
)
group by shop_id, grass_region
;


insert overwrite ${SCHEMA}.dws_shop_escrowpaid_txn_nd PARTITION (grass_region,grass_date)
select  t1.shop_id
        ,t2.avg_escrowpaid_nmv_l3m
        ,t2.avg_escrowpaid_nmv_l6m
        ,t3.daily_escrow_l6m_75pctl
        ,t1.grass_region
        ,t1.grass_date
from
(select shop_id,grass_region,grass_date from mp_user.dim_shop__reg_s0_live where grass_date = date '${bizdate}') t1
left join
(select shop_id,grass_region,avg_escrowpaid_nmv_l3m,avg_escrowpaid_nmv_l6m from dws_shop_escrowpaid_nmv_months) t2
on t1.grass_region = t2.grass_region
and t1.shop_id = t2.shop_id
left join
(select shop_id,grass_region,daily_escrow_l6m_75pctl from dws_shop_escrowpaid_txn_pctl) t3
on t1.grass_region = t3.grass_region
and t1.shop_id = t3.shop_id
;


