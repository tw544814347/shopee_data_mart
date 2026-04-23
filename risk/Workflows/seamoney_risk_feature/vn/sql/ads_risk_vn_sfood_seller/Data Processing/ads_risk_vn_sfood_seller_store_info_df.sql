-- drop table if exists ${SCHEMA}.ads_risk_vn_sfood_seller_store_info_df;
-- create table if not exists ${SCHEMA}.ads_risk_vn_sfood_seller_store_info_df
-- (
--     platform_user_id string
--     ,txn_days_l6m bigint
--     ,max_inactive_days_180d bigint
--     ,num_inactive_4_consec_days bigint

--     ,nmv_l1m decimal(30,10)
--     ,nmv_l1_l2m decimal(30,10)
--     ,nmv_l2_l3m decimal(30,10)
--     ,nmv_l3m decimal(30,10)
--     ,nmv_l3_l4m decimal(30,10)
--     ,nmv_l4_l5m decimal(30,10)
--     ,nmv_l5_l6m decimal(30,10)
--     ,nmv_l6m decimal(30,10)
--     ,avg_nmv_l6m decimal(30,10)
--     ,nmv_l6_l7m decimal(30,10)
--     ,nmv_l7_l8m decimal(30,10)
--     ,nmv_l8_l9m decimal(30,10)
--     ,nmv_l9_l10m decimal(30,10)
--     ,nmv_l10_l11m decimal(30,10)
--     ,nmv_l11_l12m decimal(30,10)

--     ,order_cnt_l1m bigint
--     ,order_cnt_l1_l2m bigint
--     ,order_cnt_l2_l3m bigint
--     ,order_cnt_l3m bigint
--     ,order_cnt_l3_l4m bigint
--     ,order_cnt_l4_l5m bigint
--     ,order_cnt_l5_l6m bigint
--     ,order_cnt_l6m bigint
--     ,avg_order_cnt_l6m decimal(30,10)
--     ,order_cnt_l6_l7m bigint
--     ,order_cnt_l7_l8m bigint
--     ,order_cnt_l8_l9m bigint
--     ,order_cnt_l9_l10m bigint
--     ,order_cnt_l10_l11m bigint
--     ,order_cnt_l11_l12m bigint

--     ,nmv_drop_16 decimal(30,10)
--     ,order_cnt_drop_16 decimal(30,10)

--     ,txn_mth_l12m bigint
--     ,avg_buyer_cnt_l6m decimal(30,10)

--     ,weighted_avg_nmv decimal(30,10)
-- )
-- partitioned by
-- (
--     grass_date string comment 'yyyy-MM-dd'
-- )
-- stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="268435456")
-- LOCATION '${HDFS_PATH}/ads/ads_risk_vn_sfood_seller_store_info_df';
-- MSCK REPAIR TABLE ${SCHEMA}.ads_risk_vn_sfood_seller_store_info_df;
 
-- -- -- 卖家商店的交易行为相关feature
-- -- -- 用户范围
-- -- --      risk.ads_risk_sfood_seller_info_df
-- -- -- 字段含义
-- -- --      NMV(Net Merchandise Volume) 净交易总额，区别于GMV(Gross Merchandise Volume)，Local currency
-- -- --      txn_days_l6m 最近6个月有过交易的天数
-- -- --      max_inactive_days_180d 最近180天最大连续不活跃天数
-- -- --      num_inactive_4_consec_days 连续4天不活跃的次数
-- -- --      avg_order_cnt_l6m 最近6个月的平均单量
-- -- --      nmv_l1m 最近一个月的平均单量
-- -- --      txn_mth_l12m 是否最近12个月内, 每个月都有交易量

-------------------- User Store Mapping --------------------
with user_tab as (
    select 
        platform_user_id
        ,split(restaurant_id_list, ', ') as restaurant_id_list
    from
        risk.ads_risk_vn_sfood_seller_info_df
    where 
        grass_date = '${ds}'
)

-- VN地区订单的主键是restaurant_id，和ID有所差异（ID订单最细粒度是store_id）
,user_store_map_tab as (
    select 
        platform_user_id
        ,explode(restaurant_id_list) as restaurant_id
    from
        user_tab
)
-- select * from user_store_map_tab

-------------------- NMV --------------------
-- 订单创建口径
,shopeefood_orders_raw as (
    select  restaurant_id
            ,order_id
            ,cast(user_id as string) as buyer_id
            ,app_type -- VN新增，now(shopeefood),shopee,foody,web 
            ,coalesce(gmv, 0) as gmv
            ,coalesce(refund_amount, 0) as refund_amount
            ,status -- DRAFT=1, RECEIVED=2, PROCESSING=3, VERIFIED=4, ASSIGNED=5, PICKED=6, DELIVERED=7, CANCEL=8, QUIT=9, REASSIGNED=10, ...
            ,paid_status -- NOT_PAID=1, PAID=2, DEBT=3, WAIT=4, NEED_REFUND=5, REFUNDED=6
            ,is_cancel
            ,is_delivered
            ,payment_method -- COD=1, PAYNOW_CREDIT=2, BANK_TRANSFER=3, CYBER_SOURCE=4, NAPAS=5, TOPPAY(AIRPAY 旧名称)=6, MOMO=7, VNPAY=8, FDC=9, PN_CREDIT_CODE=10, ...
            ,submit_time
            ,dt
    from shopeefood.shopeefood_mart_dws_vn_order_di 
    where dt >= current_date - interval '360' day
        and is_delivered = 1
        and is_cancel = 0 
        and status = 7
        and paid_status = 2
)

,user_orders_tab as (
    select  a.platform_user_id
            ,b.*
            ,datediff('${ds}', dt) as day_diff
    from user_store_map_tab a
    left join shopeefood_orders_raw b
    on a.restaurant_id = b.restaurant_id
)

-- SFood Sales NMV统一为Local currency
,user_nmv_tab as (
    select  platform_user_id
            -- order count
            ,count(case when ((day_diff between 1 and 30) and (gmv > refund_amount)) then order_id else null end) as order_cnt_l1m
            ,count(case when (day_diff between 31 and 60) and (gmv > refund_amount) then order_id else null end) as order_cnt_l1_l2m
            ,count(case when ((day_diff between 61 and 90) and (gmv > refund_amount)) then order_id else null end) as order_cnt_l2_l3m
            ,count(case when ((day_diff between 1 and 90) and (gmv > refund_amount)) then order_id else null end) as order_cnt_l3m
            ,count(case when ((day_diff between 91 and 120) and (gmv > refund_amount)) then order_id else null end) as order_cnt_l3_l4m 
            ,count(case when ((day_diff between 121 and 150) and (gmv > refund_amount)) then order_id else null end) as order_cnt_l4_l5m
            ,count(case when ((day_diff between 150 and 180) and (gmv > refund_amount)) then order_id else null end) as order_cnt_l5_l6m
            ,count(case when ((day_diff between 1 and 180) and (gmv > refund_amount)) then order_id else null end) as order_cnt_l6m
            ,count(case when ((day_diff between 1 and 180) and (gmv > refund_amount)) then order_id else null end) / 6 as avg_order_cnt_l6m
            ,count(case when ((day_diff between 181 and 210) and (gmv > refund_amount)) then order_id else null end) as order_cnt_l6_l7m
            ,count(case when ((day_diff between 211 and 240) and (gmv > refund_amount)) then order_id else null end) as order_cnt_l7_l8m
            ,count(case when ((day_diff between 241 and 270) and (gmv > refund_amount)) then order_id else null end) as order_cnt_l8_l9m
            ,count(case when ((day_diff between 271 and 300) and (gmv > refund_amount)) then order_id else null end) as order_cnt_l9_l10m
            ,count(case when ((day_diff between 301 and 330) and (gmv > refund_amount)) then order_id else null end) as order_cnt_l10_l11m
            ,count(case when ((day_diff between 331 and 360) and (gmv > refund_amount)) then order_id else null end) as order_cnt_l11_l12m
            -- nmv
            ,sum(case when day_diff between 1 and 30 then gmv - refund_amount else 0 end) as nmv_l1m
            ,sum(case when day_diff between 31 and 60 then gmv - refund_amount else 0 end) as nmv_l1_l2m
            ,sum(case when day_diff between 61 and 90 then gmv - refund_amount else 0 end) as nmv_l2_l3m
            ,sum(case when day_diff between 1 and 90 then gmv - refund_amount else 0 end) as nmv_l3m
            ,sum(case when day_diff between 91 and 120 then gmv - refund_amount else 0 end) as nmv_l3_l4m
            ,sum(case when day_diff between 121 and 150 then gmv - refund_amount else 0 end) as nmv_l4_l5m
            ,sum(case when day_diff between 151 and 180 then gmv - refund_amount else 0 end) as nmv_l5_l6m
            ,sum(case when day_diff between 1 and 180 then gmv - refund_amount else 0 end) as nmv_l6m
            ,sum(case when day_diff between 1 and 180 then gmv - refund_amount else 0 end) / 6 as avg_nmv_l6m
            ,sum(case when day_diff between 181 and 210 then gmv - refund_amount else 0 end) as nmv_l6_l7m
            ,sum(case when day_diff between 211 and 240 then gmv - refund_amount else 0 end) as nmv_l7_l8m
            ,sum(case when day_diff between 241 and 270 then gmv - refund_amount else 0 end) as nmv_l8_l9m
            ,sum(case when day_diff between 271 and 300 then gmv - refund_amount else 0 end) as nmv_l9_l10m
            ,sum(case when day_diff between 301 and 330 then gmv - refund_amount else 0 end) as nmv_l10_l11m
            ,sum(case when day_diff between 331 and 360 then gmv - refund_amount else 0 end) as nmv_l11_l12m
            -- buyer count
            ,count(distinct case when day_diff between 1 and 180 then buyer_id else null end) as buyer_cnt_l6m
            -- active days
            ,count(distinct case when ((day_diff between 1 and 180) and (gmv > refund_amount)) then day_diff else null end) as txn_days_l6m
    from user_orders_tab
    group by 1 
)

-------------------- Inactive Days --------------------
,inactive_join as (
    select 
        a.platform_user_id
        ,b.obs_date
        ,sum(coalesce(gmv - refund_amount, 0)) as nmv_daily
    from (
        -- inactive_base
        select platform_user_id from user_tab 
    ) a
    cross join (
        select explode(sequence(date('${current_grass_date}') - interval '183' day, date('${current_grass_date}') - interval '1' day, interval '1' day)) as obs_date
    ) b
    left join user_orders_tab c
    on a.platform_user_id = c.platform_user_id
    and b.obs_date = c.dt
    group by 1, 2
)

,inactive_streak as (
    select 
        platform_user_id
        ,nmv_daily
        ,lag(nmv_daily, 1) over (partition by platform_user_id order by obs_date) as prev_1_nmv_daily
        ,lag(nmv_daily, 2) over (partition by platform_user_id order by obs_date) as prev_2_nmv_daily
        ,lag(nmv_daily, 3) over (partition by platform_user_id order by obs_date) as prev_3_nmv_daily
        -- ,sum(case when nmv_daily = 0 then 1 else 0 end) 
        --     over (partition by platform_user_id order by obs_date rows between unbounded preceding and current row) as inactive_streak
    from inactive_join
)

------------------------------------------------------------------------------------------------------------------------
,consecutive_180days as (
    SELECT
        platform_user_id,
        MAX(consecutive_days_count) AS max_consecutive_days
    FROM (
        select 
            platform_user_id,
            gp_rn_and_date,
            COUNT(1) AS consecutive_days_count
        from    (
            select 
                platform_user_id,
                obs_date,
                DATE_SUB(obs_date, rn) AS gp_rn_and_date
            from (
                    select 
                        platform_user_id,
                        obs_date,
                        ROW_NUMBER() OVER (PARTITION BY platform_user_id ORDER BY obs_date) AS rn
                    from inactive_join
                    where nmv_daily = 0 --不活跃用户信息
                ) as tmp1
                ) as tmp2
                group by platform_user_id,gp_rn_and_date
         ) as tmp3
    GROUP BY platform_user_id
)
------------------------------------------------------------------------------------------------------------------------

,user_inactive_tab as (
    select 
        inactive_streak.platform_user_id
        ,max(max_consecutive_days) as max_inactive_days_180d

        ,sum(case when nmv_daily = 0 and prev_1_nmv_daily = 0 and prev_2_nmv_daily = 0 and prev_3_nmv_daily = 0 then 1 else 0 end) as num_inactive_4_consec_days
    from inactive_streak
    left join consecutive_180days on inactive_streak.platform_user_id = consecutive_180days.platform_user_id
    group by inactive_streak.platform_user_id
)

-------------------- Aggregate --------------------
insert overwrite table ${SCHEMA}.ads_risk_vn_sfood_seller_store_info_df partition (grass_date = '${ds}')
select  a.platform_user_id
        ,coalesce(b.txn_days_l6m, 0) as txn_days_l6m
        ,coalesce(c.max_inactive_days_180d, 0) as max_inactive_days_180d
        ,coalesce(c.num_inactive_4_consec_days, 0) as num_inactive_4_consec_days

        ,case when b.nmv_l1m < 0 then 0 else coalesce(b.nmv_l1m, 0) end as nmv_l1m
        ,case when b.nmv_l1_l2m < 0 then 0 else coalesce(b.nmv_l1_l2m, 0) end as nmv_l1_l2m
        ,case when b.nmv_l2_l3m < 0 then 0 else coalesce(b.nmv_l2_l3m, 0) end as nmv_l2_l3m
        ,case when b.nmv_l3m < 0 then 0 else coalesce(b.nmv_l3m, 0) end as nmv_l3m
        ,case when b.nmv_l3_l4m < 0 then 0 else coalesce(b.nmv_l3_l4m, 0) end as nmv_l3_l4m
        ,case when b.nmv_l4_l5m < 0 then 0 else coalesce(b.nmv_l4_l5m, 0) end as nmv_l4_l5m
        ,case when b.nmv_l5_l6m < 0 then 0 else coalesce(b.nmv_l5_l6m, 0) end as nmv_l5_l6m
        ,case when b.nmv_l6m < 0 then 0 else coalesce(b.nmv_l6m, 0)  end as nmv_l6m
        ,case when b.nmv_l6m < 0 then 0 else coalesce(b.nmv_l6m, 0) / 6 end as avg_nmv_l6m
        ,case when b.nmv_l6_l7m < 0 then 0 else coalesce(b.nmv_l6_l7m, 0) end as nmv_l6_l7m
        ,case when b.nmv_l7_l8m < 0 then 0 else coalesce(b.nmv_l7_l8m, 0) end as nmv_l7_l8m
        ,case when b.nmv_l8_l9m < 0 then 0 else coalesce(b.nmv_l8_l9m, 0) end as nmv_l8_l9m
        ,case when b.nmv_l9_l10m < 0 then 0 else coalesce(b.nmv_l9_l10m, 0) end as nmv_l9_l10m
        ,case when b.nmv_l10_l11m < 0 then 0 else coalesce(b.nmv_l10_l11m, 0) end as nmv_l10_l11m
        ,case when b.nmv_l11_l12m < 0 then 0 else coalesce(b.nmv_l11_l12m, 0) end as nmv_l11_l12m

        ,case when b.order_cnt_l1m < 0 then 0 else coalesce(b.order_cnt_l1m, 0) end as order_cnt_l1m
        ,case when b.order_cnt_l1_l2m < 0 then 0 else coalesce(b.order_cnt_l1_l2m, 0) end as order_cnt_l1_l2m
        ,case when b.order_cnt_l2_l3m < 0 then 0 else coalesce(b.order_cnt_l2_l3m, 0) end as order_cnt_l2_l3m
        ,case when b.order_cnt_l3m < 0 then 0 else coalesce(b.order_cnt_l3m, 0) end as order_cnt_l3m
        ,case when b.order_cnt_l3_l4m < 0 then 0 else coalesce(b.order_cnt_l3_l4m, 0) end as order_cnt_l3_l4m
        ,case when b.order_cnt_l4_l5m < 0 then 0 else coalesce(b.order_cnt_l4_l5m, 0) end as order_cnt_l4_l5m
        ,case when b.order_cnt_l5_l6m < 0 then 0 else coalesce(b.order_cnt_l5_l6m, 0) end as order_cnt_l5_l6m
        ,case when b.order_cnt_l6m < 0 then 0 else coalesce(b.order_cnt_l6m, 0) end as order_cnt_l6m
        ,case when b.order_cnt_l6m < 0 then 0 else coalesce(b.order_cnt_l6m, 0) / 6 end as avg_order_cnt_l6m
        ,case when b.order_cnt_l6_l7m < 0 then 0 else coalesce(b.order_cnt_l6_l7m, 0) end as order_cnt_l6_l7m
        ,case when b.order_cnt_l7_l8m < 0 then 0 else coalesce(b.order_cnt_l7_l8m, 0) end as order_cnt_l7_l8m
        ,case when b.order_cnt_l8_l9m < 0 then 0 else coalesce(b.order_cnt_l8_l9m, 0) end as order_cnt_l8_l9m
        ,case when b.order_cnt_l9_l10m < 0 then 0 else coalesce(b.order_cnt_l9_l10m, 0) end as order_cnt_l9_l10m
        ,case when b.order_cnt_l10_l11m < 0 then 0 else coalesce(b.order_cnt_l10_l11m, 0) end as order_cnt_l10_l11m
        ,case when b.order_cnt_l11_l12m < 0 then 0 else coalesce(b.order_cnt_l11_l12m, 0) end as order_cnt_l11_l12m

        -- ,case when coalesce(b.nmv_l5_l6m,0) <= 0 then -9999 else coalesce(b.nmv_l1m, 0)*1.00/b.nmv_l5_l6m*1.00 end as nmv_drop_16
        -- ,case when coalesce(b.order_cnt_l5_l6m,0) <= 0 then -9999 else coalesce(b.order_cnt_l1m, 0)*1.00/order_cnt_l5_l6m*1.00 end as order_cnt_drop_16
        ,case when coalesce(b.nmv_l6m,0) <= 0 then -9999 else coalesce(b.nmv_l1m, 0)*1.00/(coalesce(b.nmv_l6m, 0)/6.00) end as nmv_drop_16 -- nmv_l1m/avg_nmv_l6m, order_cnt_l1m/avg_order_cnt_l6m
        ,case when coalesce(b.order_cnt_l6m,0) <= 0 then -9999 else coalesce(b.order_cnt_l1m, 0)*1.00/(coalesce(b.order_cnt_l6m, 0)/6.00) end as order_cnt_drop_16 -- nmv_l1m/avg_nmv_l6m, order_cnt_l1m/avg_order_cnt_l6m

        ,case when (coalesce(b.nmv_l1m,0)>0 and coalesce(b.nmv_l1_l2m,0)>0 and coalesce(b.nmv_l2_l3m,0)>0 and coalesce(b.nmv_l3_l4m,0)>0 and coalesce(b.nmv_l4_l5m,0)>0
                    and coalesce(b.nmv_l5_l6m,0)>0 and coalesce(b.nmv_l6_l7m,0)>0 and coalesce(b.nmv_l7_l8m,0)>0 and coalesce(b.nmv_l8_l9m,0)>0 and coalesce(b.nmv_l9_l10m,0)>0
                    and coalesce(b.nmv_l10_l11m,0)>0 and coalesce(b.nmv_l11_l12m,0)>0) then 1 else 0 end as txn_mth_l12m
        ,coalesce(b.buyer_cnt_l6m, 0) / 6 as avg_buyer_cnt_l6m

        ,0.5*(case when b.nmv_l1m < 0 then 0 else coalesce(b.nmv_l1m, 0) end)
        + 0.3*(case when b.nmv_l3m < 0 then 0 else coalesce(b.nmv_l3m, 0) end)/3 
        + 0.2*(case when b.avg_nmv_l6m < 0 then 0 else coalesce(b.avg_nmv_l6m, 0) end) as weighted_avg_nmv
        -- ,'${ds}' as grass_date
from user_tab a
left join user_nmv_tab b 
on a.platform_user_id = b.platform_user_id
left join user_inactive_tab c 
on a.platform_user_id = c.platform_user_id
;