-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-01-20
-- Theme Domain:        User Txn Limit Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-20 - chengguo.liu - 初始化
-- =============================================================================


drop table if exists ${SCHEMA}.dws_risk_${region}_shop_escrow_txn_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_shop_escrow_txn_df (
    shop_id                             string comment 'shop id'
    ,shopee_user_id                     string comment 'shopee user id'
    ,days_has_txn_30days                bigint comment 'days has txn in last 30days'
    ,days_has_txn_90days                bigint comment 'days has txn in last 90days'
    ,days_has_txn_180days               bigint comment 'days has txn in last 180days'
    ,days_has_txn_360days               bigint comment 'days has txn in last 360days'
    ,daily_avg_escrow                   decimal(30,10) comment 'average daily escrow amount'
    ,daily_escrow_percentile50          decimal(30,10) comment '50 percentile of daily escrow amount'
    ,daily_escrow_percentile75          decimal(30,10) comment '75 percentile of daily escrow amount'
    ,daily_escrow_percentile90          decimal(30,10) comment '90 percentile of daily escrow amount'
    ,shopee_open_month                  bigint comment 'shopee open month'
)
comment 'table description: dws shop escrow transaction'
partitioned by (grass_date string comment 'YYYY-MM-DD') 
stored as orc tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_shop_escrow_txn_df/grass_region=${grass_region}' 
;
msck repair table ${SCHEMA}.dws_risk_${region}_shop_escrow_txn_df;


create or replace temporary view tmp_dwd_order_info as (
    select  shop_id
            ,order_id
            ,payment_method
            ,is_net_order
            ,gmv_usd
            ,shipping_confirm_datetime
            ,escrow_to_seller_amt_usd
            ,grass_date
            ,order_be_status
            ,escrow_paid_datetime
            ,tz_type
    from    mp_order.dwd_order_all_ent_df__br_s0_live
    where   tz_type = 'local'
    and     grass_region = '${grass_region}'
    and     grass_date >= date_sub('${grass_date}', 720)
)
;

create or replace temporary view dws_shop_escrow_txn_df as (
    select  shop_id 
            ,count(distinct case when date(shipping_confirm_datetime) >= (current_date - interval  '30'  day) then date(shipping_confirm_datetime) else null end)  as days_has_txn_30days
            ,count(distinct case when date(shipping_confirm_datetime) >= (current_date - interval  '90'  day) then date(shipping_confirm_datetime) else null end)  as days_has_txn_90days
            ,count(distinct case when date(shipping_confirm_datetime) >= (current_date - interval  '180'  day) then date(shipping_confirm_datetime) else null end)  as days_has_txn_180days
            ,count(distinct case when date(shipping_confirm_datetime) >= (current_date - interval  '360'  day) then date(shipping_confirm_datetime) else null end)  as days_has_txn_360days            
    from    tmp_dwd_order_info
    where   (grass_date >= current_date - interval  '360'  day or grass_date = date('9999-01-01'))
    and     (grass_date <> date('9999-01-01') OR (grass_date = date('9999-01-01') and order_be_status in ('ESCROW_PAID','CANCEL_COMPLETED','INVALID')))
    and     cast(escrow_paid_datetime as date) between (current_date - interval  '360'  day) and current_date
    group by shop_id
)
;

create or replace temporary view dws_shop_txn_escrow_percentile_df as (
    select  shop_id
            ,avg(daily_escrow_to_seller_usd) as daily_avg_escrow
            ,approx_percentile(daily_escrow_to_seller_usd , 0.5, 10000) as daily_escrow_percentile50
            ,approx_percentile(daily_escrow_to_seller_usd, 0.75, 10000) as daily_escrow_percentile75
            ,approx_percentile(daily_escrow_to_seller_usd, 0.9, 10000) as daily_escrow_percentile90
    from (
        select  shop_id
                ,cast(shipping_confirm_datetime as date) as shipping_confirm_date
                ,sum(escrow_to_seller_amt_usd) daily_escrow_to_seller_usd
        from    tmp_dwd_order_info
        where   (grass_date >= current_date - interval  '181'  day or grass_date = date('9999-01-01'))
        and     (grass_date <> date('9999-01-01') OR (grass_date = date('9999-01-01') and order_be_status in ('ESCROW_PAID','CANCEL_COMPLETED','INVALID')))
        and     cast(escrow_paid_datetime as date) between (current_date - interval  '181'  day) and current_date
        group by shop_id, cast(shipping_confirm_datetime as date)
    )
    group by shop_id
)
;

create temporary view dws_shop_txn_escrow_shopee_open_month_df as
select
    shop_id
    ,datediff(date '${current_grass_date}', first_txn_day) / 30 + 1 as shopee_open_month
from
(
    select
        shop_id
        ,min(to_date(escrow_paid_datetime)) as first_txn_day
    from    tmp_dwd_order_info
    where   tz_type = 'local'
    and     (
                grass_date between date_sub(date '${current_grass_date}', 720) and date '${current_grass_date}'
                or (grass_date = to_date('9999-01-01') and order_be_status in ('ESCROW_PAID', 'CANCEL_COMPLETED', 'INVALID'))
            )
    group by shop_id
)
;


insert overwrite table ${SCHEMA}.dws_risk_${region}_shop_escrow_txn_df partition (grass_date = '${grass_date}')
select
    t1.shop_id
    ,t1.shopee_user_id
    ,t2.days_has_txn_30days
    ,t2.days_has_txn_90days
    ,t2.days_has_txn_180days
    ,t2.days_has_txn_360days
    ,t3.daily_avg_escrow
    ,t3.daily_escrow_percentile50
    ,t3.daily_escrow_percentile75
    ,t3.daily_escrow_percentile90
    ,t4.shopee_open_month
from
(
    select  shop_id
            ,user_id as shopee_user_id
    from    mp_user.dim_shop__reg_s0_live
    where   tz_type = 'local'
    and     grass_region = '${grass_region}'
    and     grass_date = '${grass_date}'
) t1
left join dws_shop_escrow_txn_df t2 on t1.shop_id = t2.shop_id
left join dws_shop_txn_escrow_percentile_df t3 on t1.shop_id = t3.shop_id
left join dws_shop_txn_escrow_shopee_open_month_df t4 on t1.shop_id = t4.shop_id
;

