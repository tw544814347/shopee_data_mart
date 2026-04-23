--********************************************************************--
-- Author:         jiaqi.chen@shopee.com
-- Created Time:   2023-04-12T16:23:08.830Z
-- Description:    buyer订单的数量金额等相关指标
--********************************************************************--

-- Confirmed orders in last n days/GMV USD of confirmed orders in last n days(14/30/60/90/180d)
create or replace temporary view confirmed_order_info as
select
    buyer_id
    ,net__order_cnt_14d
    ,net__order_cnt_30d
    ,net__order_cnt_60d
    ,net__order_cnt_90d
    ,net__order_cnt_180d
    ,nmv_usd_14d
    ,nmv_usd_30d
    ,nmv_usd_60d
    ,nmv_usd_90d
    ,nmv_usd_180d
from mp_order.dws_buyer_net_gmv_nd__reg_s0_live
where tz_type = 'local'
    and grass_region = upper('${region}')
    and grass_date = '${bizdate}'
;

-- Confirmed orders in last n days/GMV USD of confirmed orders in last n days(360d)
create or replace temporary view confirmed_order_info_360d as
select
    buyer_id
    ,net__order_cnt_360d
    ,nmv_usd_360d
    ,if (coalesce(net__order_cnt_360d, 0) <> 0,nmv_usd_360d / net__order_cnt_360d,-9998) as abs_usd_360d
from
    (
        select
            buyer_id
            ,count(distinct order_id) as net__order_cnt_360d
            ,sum(nmv_usd) as nmv_usd_360d
        from mp_order.dwd_order_item_all_ent_df__reg_s0_live
        where
            tz_type = 'local'
            and grass_region = upper('${region}')
            and is_bi_excluded = 0
            and is_net_order = 1
            and grass_date >= (date_add('${bizdate}', 1) - interval '360' day)
            and date(date_format(create_datetime, 'yyyy-MM-dd')) between (date_add('${bizdate}', 1) - interval '360' day) and date_add('${bizdate}', 1)
        group by buyer_id
    )
;

create or replace temporary view confirmed_order_td_info as
select
    buyer_id
    ,net__order_cnt_td
from mp_order.dws_buyer_net_gmv_td__reg_s0_live
where tz_type = 'local'
    and grass_region = upper('${region}')
    and grass_date = '${bizdate}'
;

-- GMV USD of confirmed spl exclued orders in last n days(14/30/60/90/180d/360d)
create or replace temporary view confirmed_order_excluded_spl_info as
select
    buyer_id
    ,sum(if(datediff(date_add('${bizdate}', 1), create_datetime) between 0 and 14, nmv_usd, 0)) as nmv_usd_excluded_spl_14d
    ,sum(if(datediff(date_add('${bizdate}', 1), create_datetime) between 0 and 30, nmv_usd, 0)) as nmv_usd_excluded_spl_30d
    ,sum(if(datediff(date_add('${bizdate}', 1), create_datetime) between 0 and 60, nmv_usd, 0)) as nmv_usd_excluded_spl_60d
    ,sum(if(datediff(date_add('${bizdate}', 1), create_datetime) between 0 and 90, nmv_usd, 0)) as nmv_usd_excluded_spl_90d
    ,sum(if(datediff(date_add('${bizdate}', 1), create_datetime) between 0 and 180, nmv_usd, 0)) as nmv_usd_excluded_spl_180d
    ,sum(if(datediff(date_add('${bizdate}', 1), create_datetime) between 0 and 360, nmv_usd, 0)) as nmv_usd_excluded_spl_360d
from mp_order.dwd_order_item_all_ent_df__reg_s0_live
where tz_type = 'local'
    and grass_region = upper('${region}')
    and is_bi_excluded = 0
    and is_net_order = 1
    and payment_channel not in ('SPayLater', 'ShopeePayLater')
    and grass_date >= (date_add('${bizdate}', 1) - interval '360' day)
    and date(date_format(create_datetime,'yyyy-MM-dd')) between (date_add('${bizdate}', 1) - interval '360' day) and date_add('${bizdate}', 1)
    group by buyer_id
;

-- ABS USD of confirmed order in last n days
create or replace temporary view abs_usd_info as
select
    buyer_id
    ,if(coalesce(net__order_cnt_14d, 0)<>0, nmv_usd_14d/net__order_cnt_14d, -9998) as abs_usd_14d
    ,if(coalesce(net__order_cnt_30d, 0)<>0, nmv_usd_30d/net__order_cnt_30d, -9998) as abs_usd_30d
    ,if(coalesce(net__order_cnt_60d, 0)<>0, nmv_usd_60d/net__order_cnt_60d, -9998) as abs_usd_60d
    ,if(coalesce(net__order_cnt_90d, 0)<>0, nmv_usd_90d/net__order_cnt_90d, -9998) as abs_usd_90d
    ,if(coalesce(net__order_cnt_180d, 0)<>0, nmv_usd_180d/net__order_cnt_180d, -9998) as abs_usd_180d
from mp_order.dws_buyer_net_gmv_nd__reg_s0_live
where tz_type = 'local'
    and grass_region = upper('${region}')
    and grass_date = '${bizdate}'
;

-- ABS USD of confirmed order in lifetime
create or replace temporary view abs_usd_lifetime_info as
select
    buyer_id
    ,if(coalesce(net__order_cnt_td, 0)<>0, nmv_usd_td/net__order_cnt_td, -9998) as abs_usd_td
from mp_order.dws_buyer_net_gmv_td__reg_s0_live
where tz_type = 'local'
    and grass_region = upper('${region}')
    and grass_date = '${bizdate}'
;

-- paid order info (exl lifetime) / dws_buyer_gmv_nd__reg_s0_live
create or replace temporary view paid_order_info as
select buyer_id
        ,paid_order_cnt_14d
        ,paid_order_cnt_30d
        ,paid_order_cnt_60d
        ,paid_order_cnt_90d
        ,paid_order_cnt_180d
from    mp_order.dws_buyer_gmv_nd__reg_s0_live
where tz_type = 'local'
and grass_region = upper('${region}')
and grass_date = '${bizdate}'
;
-- paid order info to date
create or replace temporary view paid_order_info_td as
select buyer_id
        ,paid_order_cnt_td
from    mp_order.dws_buyer_gmv_td__reg_s0_live
where   tz_type = 'local'
and     grass_region = upper('${region}')
and     grass_date = '${bizdate}'
;




-- combine all metrics
insert overwrite table ${SCHEMA}.dws_risk_buyer_txn_df partition (tz_type='local', grass_region, grass_date)
select
    t1.buyer_id
    ,coalesce(t2.net__order_cnt_14d,0) as buyer_confirmed_order_in_14d
    ,coalesce(t2.net__order_cnt_30d,0) as buyer_confirmed_order_in_30d
    ,coalesce(t2.net__order_cnt_60d,0) as buyer_confirmed_order_in_60d
    ,coalesce(t2.net__order_cnt_90d,0) as buyer_confirmed_order_in_90d
    ,coalesce(t2.net__order_cnt_180d,0) as buyer_confirmed_order_in_180d
    ,coalesce(t3.net__order_cnt_360d,0) as buyer_confirmed_order_in_360d
    ,coalesce(t2.nmv_usd_14d,0) as buyer_nmv_usd_in_14d
    ,coalesce(t2.nmv_usd_30d,0) as buyer_nmv_usd_in_30d
    ,coalesce(t2.nmv_usd_60d,0) as buyer_nmv_usd_in_60d
    ,coalesce(t2.nmv_usd_90d,0) as buyer_nmv_usd_in_90d
    ,coalesce(t2.nmv_usd_180d,0) as buyer_nmv_usd_in_180d
    ,coalesce(t3.nmv_usd_360d,0) as buyer_nmv_usd_in_360d
    ,coalesce(t4.nmv_usd_excluded_spl_14d,0) as buyer_spl_exclude_nmv_usd_in_14d
    ,coalesce(t4.nmv_usd_excluded_spl_30d,0) as buyer_spl_exclude_nmv_usd_in_30d
    ,coalesce(t4.nmv_usd_excluded_spl_60d,0) as buyer_spl_exclude_nmv_usd_in_60d
    ,coalesce(t4.nmv_usd_excluded_spl_90d,0) as buyer_spl_exclude_nmv_usd_in_90d
    ,coalesce(t4.nmv_usd_excluded_spl_180d,0) as buyer_spl_exclude_nmv_usd_in_180d
    ,coalesce(t4.nmv_usd_excluded_spl_360d,0) as buyer_spl_exclude_nmv_usd_in_360d
    ,coalesce(t5.abs_usd_14d,0) as buyer_abs_usd_in_14d
    ,coalesce(t5.abs_usd_30d,0) as buyer_abs_usd_in_30d
    ,coalesce(t5.abs_usd_60d,0) as buyer_abs_usd_in_60d
    ,coalesce(t5.abs_usd_90d,0) as buyer_abs_usd_in_90d
    ,coalesce(t5.abs_usd_180d,0) as buyer_abs_usd_in_180d
    ,coalesce(t6.abs_usd_td,0) as buyer_abs_usd_in_lifetime
    ,coalesce(t7.net__order_cnt_td,0) as buyer_confirmed_order_in_lifetime
    ,coalesce(t3.abs_usd_360d,0) as buyer_abs_usd_in_360d
    ,coalesce(t8.paid_order_cnt_14d,0)     as  buyer_paid_order_in_14d
    ,coalesce(t8.paid_order_cnt_30d,0)     as  buyer_paid_order_in_30d
    ,coalesce(t8.paid_order_cnt_60d,0)     as  buyer_paid_order_in_60d
    ,coalesce(t8.paid_order_cnt_90d,0)     as  buyer_paid_order_in_90d
    ,coalesce(t8.paid_order_cnt_180d,0)    as  buyer_paid_order_in_180d
    ,coalesce(t9.paid_order_cnt_td, 0)               as  buyer_paid_order_in_lifetime
    ,t1.grass_region
    ,t1.grass_date
from
(
    select
        user_id as buyer_id
        ,grass_region
        ,grass_date
    from mp_user.dim_user__reg_s0_live
    where tz_type = 'local'
        and grass_region = upper('${region}')
        and grass_date = '${bizdate}'
) t1
left join confirmed_order_info t2
on t1.buyer_id = t2.buyer_id
left join confirmed_order_info_360d t3
on t1.buyer_id = t3.buyer_id
left join confirmed_order_excluded_spl_info t4
on t1.buyer_id = t4.buyer_id
left join abs_usd_info t5
on t1.buyer_id = t5.buyer_id
left join abs_usd_lifetime_info t6
on t1.buyer_id = t6.buyer_id
left join confirmed_order_td_info t7
on t1.buyer_id = t7.buyer_id
left join paid_order_info t8
on t1.buyer_id = t8.buyer_id
left join paid_order_info_td t9
on t1.buyer_id = t9.buyer_id
;

create or replace view ${SCHEMA}.dws_risk_${region}_buyer_txn_df as
select
    *
from ${SCHEMA}.dws_risk_buyer_txn_df
where
    grass_region = upper('${region}')
;