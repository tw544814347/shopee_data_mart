
--********************************************************************--
-- Author:              jialiang.nie@shopee.com
-- Created Time:        2024-09-09
-- Theme Domain：        risk shopee food feature
-- Description:          
-- Data Granularity:    
-- jira : https://jira.shopee.io/browse/SPFDT-42557 逻辑: https://docs.google.com/spreadsheets/d/1PltFr0KoEUdO89WfbhpeIv2SE-jQVOEPcgCkdEQS6SM/edit?gid=75538526#gid=75538526
-- 变更历史：
--      变更日期：2024-10-11 变更人: jialiang.nie 变更内容：这张表mart_shopeefood_merchant_id_db__store_summary_da数据缺失且有错误, 业务重新给了一版逻辑 Jira: https://jira.shopee.io/browse/SPFDT-44905
--      变更日期：2024-10-22 变更人: jialiang.nie 变更内容：业务提供的逻辑有误，需要把buyer_cnt_l6m除以6，改成avg_buyer_cnt_l6m
--********************************************************************--


-- 卖家商店的交易行为相关feature
-- 用户范围
--      risk.ads_risk_sfood_seller_info_df
-- 字段含义
--      NMV(Net Merchandise Volume) 净交易总额，区别于GMV(Gross Merchandise Volume)
--      txn_days_l6m 最近6个月有过交易的天数
--      num_inactive_4_consec_days 连续4天不活跃的次数
--      avg_order_cnt_l6m 最近6个月的平均单量
--      nmv_l1m 最近一个月的平均单量
--      txn_mth_l12m 最近12个月内, 有过交易的月份数
--      nmv_drop_16 商家过去30天的NMV与150-180天前的NMV的比率


-------------------- User Store Mapping --------------------
with user_tab as (
    select 
        platform_user_id
        ,split(store_id_list, ', ') as store_id_list
    from
        risk.ads_risk_${table_region}_sfood_seller_info_df
    where 
        grass_date = '${ds}'
)

,user_store_map_tab as (
    select 
        platform_user_id
        ,explode(store_id_list) as store_id
    from
        user_tab
)


-------------------- NMV --------------------
,shopeefood_orders_raw as (
    select  cast(store_id as bigint) as store_id
            ,cast(id as string) as order_id
            ,cast(buyer_id as string) as buyer_id
            ,total_amount / 100000 as total_amount 
            ,refund_amount / 100000 as refund_amount
            ,date(from_unixtime(cast(create_time as bigint)/1000)) as create_date -- create_time å­—æ®µå•ä½æ˜¯ ms
    from shopeefood.shopee_foody_order_id_db__order_tab__reg_daily_s0_live 
    where cast(create_time as bigint) > cast(to_unix_timestamp(cast(('${current_grass_date}' - interval '360' day) as timestamp)) as bigint)*1000
        and cast(create_time as bigint) < cast(to_unix_timestamp(cast(('${current_grass_date}' - interval '1' day) as timestamp)) as bigint)*1000
        and (cancel_time=0 and cancel_reason=0 and cancel_source=0)
        and order_status in (440, 800)
        and total_amount > 0
        and settle_to != 0
)

,on_us_orders as (
    select  cast(store_id as bigint) as store_id
            ,cast(as_order_id as string) as order_id
            ,cast(shopeepay_user_id as string) as buyer_id
            ,total_amount*0.99 as total_amount 
            ,0 as refund_amount
            ,cast(create_time as date) as create_date
    from shopeepay_risk.ads_risk_spp_merchant_transaction_user_onus_df__id
    where date(grass_date) = (select max(date(grass_date)) from shopeepay_risk.ads_risk_spp_merchant_transaction_user_onus_df__id) -- å¶å°”ä¼šå°‘ä¸€äº› grass_date çš„è®°å½•
        and transaction_type_name in ('Payment', 'Capture')
        and is_success = 1
        and cast(create_time as date) >= current_date - interval '360' day
        and store_id in (select store_id from user_store_map_tab)
)

,off_us_orders as (
    select  cast(store_id as bigint) as store_id
            ,cast(transaction_id as string) as order_id
            ,cast(user_id as string) as buyer_id
            ,total_amount*0.99 as total_amount
            ,0 as refund_amount 
            ,cast(create_time as date) as create_date
    from shopeepay_risk.ads_risk_spp_merchant_transaction_user_offus_df__id
    where date(grass_date) = (select max(date(grass_date)) from shopeepay_risk.ads_risk_spp_merchant_transaction_user_offus_df__id)
        and merchant_scope_name = 'On_us Merchant' 
        and user_scope_name = 'Off_us User'
        and is_success = 1
        and cast(create_time as date) >= current_date - interval '360' day
        and store_id in (select store_id from user_store_map_tab)
)

,orders_agg_tab as (
    select a.*
    from shopeefood_orders_raw a
    union all
    select b.*
    from on_us_orders b
    union all
    select c.*
    from off_us_orders c
)

,user_orders_tab as (
    select  a.platform_user_id
            ,b.*
            ,datediff('${ds}', create_date) as dt
    from user_store_map_tab a
    left join orders_agg_tab b
    on a.store_id = b.store_id
)

,user_nmv_tab as (
    select  platform_user_id
            -- order count
            ,count(case when ((dt between 1 and 30) and (total_amount > refund_amount)) then order_id else null end) as order_cnt_l1m
            ,count(case when ((dt between 150 and 180) and (total_amount > refund_amount)) then order_id else null end) as order_cnt_l5_l6m
            ,count(case when ((dt between 1 and 180) and (total_amount > refund_amount)) then order_id else null end) as order_cnt_ll6m
            -- nmv
            ,sum(case when dt between 1 and 30 then total_amount - refund_amount else 0 end) as nmv_l1m
            ,sum(case when dt between 31 and 60 then total_amount - refund_amount else 0 end) as nmv_l1_l2m
            ,sum(case when dt between 61 and 90 then total_amount - refund_amount else 0 end) as nmv_l2_l3m
            ,sum(case when dt between 1 and 90 then total_amount - refund_amount else 0 end) as nmv_l3m
            ,sum(case when dt between 91 and 120 then total_amount - refund_amount else 0 end) as nmv_l3_l4m
            ,sum(case when dt between 121 and 150 then total_amount - refund_amount else 0 end) as nmv_l4_l5m
            ,sum(case when dt between 151 and 180 then total_amount - refund_amount else 0 end) as nmv_l5_l6m
            ,sum(case when dt between 1 and 180 then total_amount - refund_amount else 0 end) as nmv_l6m
            ,sum(case when dt between 181 and 210 then total_amount - refund_amount else 0 end) as nmv_l6_l7m
            ,sum(case when dt between 211 and 240 then total_amount - refund_amount else 0 end) as nmv_l7_l8m
            ,sum(case when dt between 241 and 270 then total_amount - refund_amount else 0 end) as nmv_l8_l9m
            ,sum(case when dt between 271 and 300 then total_amount - refund_amount else 0 end) as nmv_l9_l10m
            ,sum(case when dt between 301 and 330 then total_amount - refund_amount else 0 end) as nmv_l10_l11m
            ,sum(case when dt between 331 and 360 then total_amount - refund_amount else 0 end) as nmv_l11_l12m
            -- buyer count
            ,count(distinct case when dt between 1 and 180 then buyer_id else null end) as buyer_cnt_l6m
            -- active days
            ,count(distinct case when ((dt between 1 and 180) and (total_amount > refund_amount)) then dt else null end) as txn_days_l6m
            -- cancel rate
            ,count(case when dt between 1 and 7 then order_id else null end) as place_order_l7d
            ,count(case when ((dt between 1 and 7) and (total_amount = refund_amount)) then order_id else null end) as cancel_order_l7d
            ,count(case when dt between 1 and 15 then order_id else null end) as place_order_l15d
            ,count(case when ((dt between 1 and 15) and (total_amount = refund_amount)) then order_id else null end) as cancel_order_l15d

            -- 新逻辑没覆盖到的字段逻辑，DE补充
            ,sum(case when dt between 1 and 180 then total_amount - refund_amount else 0 end) / 6 as avg_nmv_l6m
    from user_orders_tab
    group by 1 
)

,inactive_base as (
    select *
    from (select platform_user_id from user_tab)
    cross join (
        select explode(sequence(date('${current_grass_date}') - interval '183' day, date('${current_grass_date}') - interval '1' day, interval '1' day)) as obs_date
    )
)

,inactive_join as (
    select  a.platform_user_id
            ,a.obs_date
            ,sum(coalesce(total_amount-refund_amount, 0)) as nmv_daily
    from inactive_base a
    left join user_orders_tab b
    on a.platform_user_id = b.platform_user_id
    and a.obs_date = b.create_date
    group by 1, 2
)

,user_inactive_tab as (
    select platform_user_id
            ,sum(case when nmv_daily = 0 and prev_1_nmv_daily = 0 and prev_2_nmv_daily = 0 and prev_3_nmv_daily = 0 then 1 else 0 end) as num_inactive_4_consec_days
    from (
        select  platform_user_id
                ,obs_date
                ,nmv_daily
                ,lag(nmv_daily, 1) over (partition by platform_user_id order by obs_date) as prev_1_nmv_daily
                ,lag(nmv_daily, 2) over (partition by platform_user_id order by obs_date) as prev_2_nmv_daily
                ,lag(nmv_daily, 3) over (partition by platform_user_id order by obs_date) as prev_3_nmv_daily
        from inactive_join
    )
    group by 1
)

-------------------- Aggregate --------------------

insert overwrite table ${SCHEMA}.ads_risk_${table_region}_sfood_seller_store_info_df partition (grass_date)
select  a.platform_user_id
        ,coalesce(b.txn_days_l6m, 0) as txn_days_l6m
        ,coalesce(c.num_inactive_4_consec_days, 0) as num_inactive_4_consec_days
        ,coalesce(b.order_cnt_ll6m, 0) / 6 as avg_order_cnt_l6m
        ,case when b.nmv_l6m < 0 then 0 else coalesce(b.nmv_l6m, 0) / 6 end as avg_nmv_l6m
        ,case when b.nmv_l1m < 0 then 0 else coalesce(b.nmv_l1m, 0) end as nmv_l1m
        ,case when b.nmv_l3m < 0 then 0 else coalesce(b.nmv_l3m, 0) end as nmv_l3m
        ,case when b.nmv_l5_l6m < 0 then 0 else coalesce(b.nmv_l5_l6m, 0) end as nmv_l5_l6m
        ,case when b.order_cnt_l1m < 0 then 0 else coalesce(b.order_cnt_l1m, 0) end as order_cnt_l1m
        ,case when b.order_cnt_l5_l6m < 0 then 0 else coalesce(b.order_cnt_l5_l6m, 0) end as order_cnt_l5_l6m
        ,case when (coalesce(b.nmv_l1m,0)>0 and coalesce(b.nmv_l1_l2m,0)>0 and coalesce(b.nmv_l2_l3m,0)>0 and coalesce(b.nmv_l3_l4m,0)>0 and coalesce(b.nmv_l4_l5m,0)>0
                    and coalesce(b.nmv_l5_l6m,0)>0 and coalesce(b.nmv_l6_l7m,0)>0 and coalesce(b.nmv_l7_l8m,0)>0 and coalesce(b.nmv_l8_l9m,0)>0 and coalesce(b.nmv_l9_l10m,0)>0
                    and coalesce(b.nmv_l10_l11m,0)>0 and coalesce(b.nmv_l11_l12m,0)>0) then 1 else 0 end as txn_mth_l12m
        ,coalesce(b.buyer_cnt_l6m, 0) / 6 as avg_buyer_cnt_l6m
        ,case when coalesce(b.place_order_l7d,0) = 0 then -9999 else coalesce(b.cancel_order_l7d,0)*1.00 / b.place_order_l7d*1.00 end as cancel_rate_l7d
        ,case when coalesce(b.place_order_l15d,0) = 0 then -9999 else coalesce(b.cancel_order_l15d,0)*1.00 / b.place_order_l15d*1.00 end as cancel_rate_l15d
        ,case when coalesce(b.nmv_l5_l6m,0) <= 0 then -9999 else coalesce(b.nmv_l1m, 0)*1.00/b.nmv_l5_l6m*1.00 end as nmv_drop_16
        ,case when coalesce(b.order_cnt_l5_l6m,0) <= 0 then -9999 else coalesce(b.order_cnt_l1m, 0)*1.00/order_cnt_l5_l6m*1.00 end as order_cnt_drop_16
        ,case when b.nmv_l1_l2m < 0 then 0 else coalesce(b.nmv_l1_l2m, 0) end as nmv_l1_l2m
        ,case when b.nmv_l2_l3m < 0 then 0 else coalesce(b.nmv_l2_l3m, 0) end as nmv_l2_l3m
        ,case when b.nmv_l3_l4m < 0 then 0 else coalesce(b.nmv_l3_l4m, 0) end as nmv_l3_l4m
        ,case when b.nmv_l4_l5m < 0 then 0 else coalesce(b.nmv_l4_l5m, 0) end as nmv_l4_l5m
        ,0.5*(case when b.nmv_l1m < 0 then 0 else coalesce(b.nmv_l1m, 0) end)
        + 0.3*(case when b.nmv_l3m < 0 then 0 else coalesce(b.nmv_l3m, 0) end)/3 
        + 0.2*(case when b.avg_nmv_l6m < 0 then 0 else coalesce(b.avg_nmv_l6m, 0) end) as weighted_avg_nmv
        ,'${ds}' as grass_date
from user_tab a
left join user_nmv_tab b 
on a.platform_user_id = b.platform_user_id
left join user_inactive_tab c 
on a.platform_user_id = c.platform_user_id
;