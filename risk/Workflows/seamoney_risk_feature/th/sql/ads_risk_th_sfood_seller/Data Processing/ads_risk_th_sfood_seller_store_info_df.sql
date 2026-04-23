-- drop table if exists ${SCHEMA}.ads_risk_th_sfood_seller_store_info_df;
create table if not exists ${SCHEMA}.ads_risk_th_sfood_seller_store_info_df
(
    national_id string
    ,food_txn_days_l6m bigint
    ,food_inactive_4_days bigint
    ,food_nmv_l1m decimal(30,10)
    ,food_nmv_l1_l2m decimal(30,10)
    ,food_nmv_l2_l3m decimal(30,10)
    ,food_nmv_l3_l4m decimal(30,10)
    ,food_nmv_l4_l5m decimal(30,10)
    ,food_nmv_l5_l6m decimal(30,10)
    ,food_avg_nmv_l3m decimal(30,10)
    ,food_avg_nmv_l6m decimal(30,10)
    ,food_order_cnt_l1m bigint
    ,food_order_cnt_l5_l6m bigint
    ,food_avg_order_cnt_l6m decimal(30,10)
    ,food_txn_mth_l12m bigint
    ,food_avg_buyer_cnt_l6m decimal(30,10)
    ,food_cancel_rate_l7d decimal(30,10)
    ,food_cancel_rate_l15d decimal(30,10)
    ,food_nmv_drop_16 decimal(30,10)
    ,food_order_cnt_drop_16 decimal(30,10)
    ,food_has_non_individual_store bigint
    ,food_has_greylist_store bigint
    ,food_has_blacklist_store bigint
    ,food_has_whitelist_store bigint
    ,food_has_ban_sus_store bigint
    ,food_has_site_verified_store bigint
)
partitioned by
(
    grass_date string comment 'yyyy-MM-dd'
)
comment 'tag: risk feature summary table'
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION '${HDFS_PATH}/ads/ads_risk_th_sfood_seller_store_info_df';
-- MSCK REPAIR TABLE ${SCHEMA}.ads_risk_th_sfood_seller_store_info_df;

-- *********************************************** 1. Core user list ***********************************************    
with user_tab as (
    select national_id, split(store_id_list, ', ') as store_id_list
    from ${SCHEMA}.ads_risk_th_sfood_seller_info_df
    where grass_date = '${ds}'
)

,user_store_map_tab as (
    select national_id, cast(store_id as bigint) as store_id
    from user_tab
    lateral view explode(store_id_list) t as store_id
) 

-- *********************************************** 2. Foody store sales ***********************************************   
,orders_agg_tab as (
    -- 数据源1：Foody订单履约表
    --要修改 未知DI/DF表
    select store_id
        ,cast(order_id as string) as order_id
        ,cast(buyer_id as string) as buyer_id
        ,total_amount / 100000 as total_amount -- 系统为了存整数成于 100,000，所以这里除掉
        ,refund_amount / 100000 as refund_amount 
        ,date(from_unixtime(cast(create_time as bigint)/1000)) as create_date -- create_time 字段单位是 ms
    from shopeefood.shopeefood_mart_dwd_th_order_fulfilment_da 
    where cast(create_time as bigint) > unix_timestamp(cast((current_date - interval '360' day) as timestamp))*1000
        and cast(create_time as bigint) < unix_timestamp(cast((current_date - interval '1' day) as timestamp))*1000
        and (cancel_time=0 and cancel_reason=0 and cancel_source=0)
        and order_status in (440, 800)
        and total_amount > 0
        and settle_to != 0
    
    union all
    
    -- 数据源2：ShopeePay On-us订单
    select  cast(a.store_id as bigint) as store_id
        ,cast(a.as_order_id as string) as order_id
        ,cast(a.shopeepay_user_id as string) as buyer_id
        ,a.total_amount*0.99 as total_amount 
        ,0 as refund_amount
        ,cast(a.create_time as date) as create_date
    from shopeepay_risk.ads_risk_spp_merchant_transaction_user_onus_df__th a
    inner join user_store_map_tab b on cast(a.store_id as int) = b.store_id  -- 已修改 使用inner join替代in
    --要修改 不要写max 使用marker
    where date(a.grass_date) = (select max(date(grass_date)) from shopeepay_risk.ads_risk_spp_merchant_transaction_user_onus_df__th) 
        and a.transaction_type_name in ('Payment', 'Capture')
        and a.is_success = 1
        and cast(a.create_time as date) >= current_date - interval '360' day
    --已修改 使用union，避免多个view
    union all
    
    -- 数据源3：ShopeePay Off-us订单
    select  cast(a.store_id as bigint) as store_id
        ,cast(a.transaction_id as string) as order_id
        ,cast(a.user_id as string) as buyer_id
        ,a.total_amount*0.99 as total_amount
        ,0 as refund_amount 
        ,cast(a.create_time as date) as create_date
    from shopeepay_risk.ads_risk_spp_merchant_transaction_user_offus_df__th a
    inner join user_store_map_tab b on cast(a.store_id as int) = b.store_id  -- 已修改 使用inner join替代in
    --要修改 不需要写max 使用marker
    where date(a.grass_date) = (select max(date(grass_date)) from shopeepay_risk.ads_risk_spp_merchant_transaction_user_offus_df__th)
        and a.merchant_scope_name = 'On_us Merchant' 
        and a.user_scope_name = 'Off_us User'
        and a.is_success = 1
        and cast(a.create_time as date) >= current_date - interval '360' day
)

,user_orders_tab as (
    select a.national_id
        ,b.*
        ,datediff(current_date - interval '1' day, create_date) as dt
    from user_store_map_tab a
        left join orders_agg_tab b
            on a.store_id = b.store_id
)

,user_nmv_tab as (
    select  national_id
        
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
    
    from user_orders_tab 
    group by national_id 
)

--已修改 合并多个view
,user_inactive_tab as (
    select national_id
        ,sum(case when nmv_daily = 0 and prev_1_nmv_daily = 0 and prev_2_nmv_daily = 0 and prev_3_nmv_daily = 0 then 1 else 0 end) as num_inactive_4_consec_days
    from (
        select national_id
            ,obs_date
            ,nmv_daily
            ,lag(nmv_daily, 1) over (partition by national_id order by obs_date) as prev_1_nmv_daily
            ,lag(nmv_daily, 2) over (partition by national_id order by obs_date) as prev_2_nmv_daily
            ,lag(nmv_daily, 3) over (partition by national_id order by obs_date) as prev_3_nmv_daily
        from (
            select a.national_id
                ,a.obs_date
                ,sum(coalesce(b.total_amount-b.refund_amount, 0)) as nmv_daily 
            from (
                select national_id, obs_date
                from (select national_id from user_tab)
                cross join (
                    select explode(sequence(
                        current_date - interval '183' day,
                        current_date - interval '1' day,
                        interval '1' day
                    )) as obs_date
                )
            ) a
            left join user_orders_tab b
                on a.national_id = b.national_id and a.obs_date = b.create_date
            group by a.national_id, a.obs_date
        )
    )
    group by national_id
)

-- *********************************************** 3. MSS Check ***********************************************   
,user_mss_tab as (
    select a.national_id
        ,max(case when b.tag_busniess_type_tag in ('Business', 'Others') then 1 else 0 end) as has_non_individual_store -- 只允许 'Individual' 或 'null'
        ,max(case when c.store_id is null then 0 else 1 end) as has_greylist_store
        ,max(case when d.store_id is null then 0 else 1 end) as has_blacklist_store
        ,max(case when e.store_id is null then 0 else 1 end) as has_whitelist_store
        ,max(case when g.tag_ban_sus_tag is null then 0 else 1 end ) as has_ban_sus_store
        ,max(f.is_site_verified) as has_site_verified_store
    from user_store_map_tab a
        left join (
            -- MSS检查1：店铺业务类型检查
            select  a.entity_id
                ,case when customer_entity_type is null then null -- 0:None, 1:Individual, 2:Corporate, 3:CV_foundations_firm, 4:Business
                    when customer_entity_type = 1 then 'Individual'
                    when customer_entity_type = 4 then 'Business'
                    else 'Others' 
                end as tag_busniess_type_tag 
            from (
                select entity_id, customer_entity_id
                from merchantservice.mss_merchant_info_th_db__customer_entity_info_relation_tab__reg_daily_s0_live
                where entity_type = 3 and relation_status = 1
            ) a left join (
                select id, customer_entity_type
                from merchantservice.mss_merchant_info_th_db__customer_entity_info_tab__reg_daily_s0_live
                where info_status = 1
            ) b on a.customer_entity_id = b.id
        ) b on a.store_id = b.entity_id 
        left join (
            -- MSS检查2：店铺灰名单检查
            select cast(data as bigint) as store_id
            from risk.dwd_risk_th_credit_custom_list_df
            where date(grass_date) = current_date - interval '1' day
                and custom_list_name = 'offline_store_grey_list'
                and status = '1'
                and data_type = '12' 
        ) c on a.store_id = c.store_id 
        left join (
            -- MSS检查3：店铺黑名单检查
            select cast(data as bigint) as store_id
            from risk.dwd_risk_th_credit_custom_list_df 
            where date(grass_date) = current_date - interval '1' day
                and custom_list_name = 'cash_out_merchant_blacklist'
                and status = '1'
                and data_type = '12' 
        ) d on a.store_id = d.store_id 
        left join (
            -- MSS检查4：店铺白名单检查
            select cast(data as bigint) as store_id
            from risk.dwd_risk_th_credit_custom_list_df
            where date(grass_date) = current_date - interval '1' day
                and custom_list_name = 'th_food_store_whitelist'
                and status = '1'
                and data_type = '12' 
        ) e on a.store_id = e.store_id 
        left join (
            -- MSS检查5：Ban/Sus状态检查
            select cast(store_id_offline as bigint) as store_id_offline
                ,case when (offline_merchant_policy_memo like '%B1%' or offline_merchant_policy_memo like '%B2%' or offline_merchant_policy_memo like '%B3%' or offline_merchant_policy_memo like '%B4%') then 'Ban'
                    when (offline_merchant_policy_memo like '%G1%' or offline_merchant_policy_memo like '%G2%') then 'Sus' 
                end as tag_ban_sus_tag
            from dev_smcdrisk_antifraud.offline_merchant_banandsuslist_nondup
            where tag_black_action not like '%turngood%' 
        ) g on a.store_id = g.store_id_offline 
        left join (
            -- MSS检查6：站点验证检查
            select a.shop_id as store_id
                ,case when b.email like 'vendor%' or b.email like '%@shopeemobile-external.com' then 1 else 0 end as is_site_verified
            from merchantservice.ocha_crm_th_db__outlet_info_tab__reg_daily_s0_live a
                left join merchantservice.ocha_crm_th_db__auth_user__reg_daily_s0_live b
                    on a.deployed_by_id = b.id
            inner join user_store_map_tab usm on a.shop_id = usm.store_id  -- 已修改 使用inner join替代in
        ) f on a.store_id = f.store_id 
    group by a.national_id
)

-- *********************************************** 4. Aggregate *********************************************** 
insert overwrite table ${SCHEMA}.ads_risk_th_sfood_seller_store_info_df partition (grass_date = '${ds}')
select  a.national_id
    -- 活跃天数特征
    ,coalesce(b.txn_days_l6m, 0) as food_txn_days_l6m
    ,coalesce(c.num_inactive_4_consec_days, 0) as food_inactive_4_days
    
    -- NMV特征（处理负值，负值设为0）
    ,case when b.nmv_l1m < 0 then 0 else coalesce(b.nmv_l1m, 0) end as food_nmv_l1m
    ,case when b.nmv_l1_l2m < 0 then 0 else coalesce(b.nmv_l1_l2m, 0) end as food_nmv_l1_l2m
    ,case when b.nmv_l2_l3m < 0 then 0 else coalesce(b.nmv_l2_l3m, 0) end as food_nmv_l2_l3m
    ,case when b.nmv_l3_l4m < 0 then 0 else coalesce(b.nmv_l3_l4m, 0) end as food_nmv_l3_l4m
    ,case when b.nmv_l4_l5m < 0 then 0 else coalesce(b.nmv_l4_l5m, 0) end as food_nmv_l4_l5m
    ,case when b.nmv_l5_l6m < 0 then 0 else coalesce(b.nmv_l5_l6m, 0) end as food_nmv_l5_l6m
    ,case when b.nmv_l3m < 0 then 0 else coalesce(b.nmv_l3m, 0) / 3 end as food_avg_nmv_l3m
    ,case when b.nmv_l6m < 0 then 0 else coalesce(b.nmv_l6m, 0) / 6 end as food_avg_nmv_l6m
    
    -- 订单数特征（处理负值，负值设为0）
    ,case when b.order_cnt_l1m < 0 then 0 else coalesce(b.order_cnt_l1m, 0) end as food_order_cnt_l1m
    ,case when b.order_cnt_l5_l6m < 0 then 0 else coalesce(b.order_cnt_l5_l6m, 0) end as food_order_cnt_l5_l6m
    ,coalesce(b.order_cnt_ll6m, 0) / 6 as food_avg_order_cnt_l6m
    
    -- 持续交易特征：检查近12个月是否每个月都有交易
    ,case when (coalesce(b.nmv_l1m,0)>0 and coalesce(b.nmv_l1_l2m,0)>0 and coalesce(b.nmv_l2_l3m,0)>0 and coalesce(b.nmv_l3_l4m,0)>0 and coalesce(b.nmv_l4_l5m,0)>0
            and coalesce(b.nmv_l5_l6m,0)>0 and coalesce(b.nmv_l6_l7m,0)>0 and coalesce(b.nmv_l7_l8m,0)>0 and coalesce(b.nmv_l8_l9m,0)>0 and coalesce(b.nmv_l9_l10m,0)>0
            and coalesce(b.nmv_l10_l11m,0)>0 and coalesce(b.nmv_l11_l12m,0)>0) 
        then 1 else 0 
    end as food_txn_mth_l12m
    
    -- 买家数特征
    ,coalesce(b.buyer_cnt_l6m, 0) / 6 as food_avg_buyer_cnt_l6m
    
    -- 取消率特征（如果分母为0，返回-9999）
    ,case when coalesce(b.place_order_l7d,0) = 0 then -9999 else coalesce(b.cancel_order_l7d,0)*1.00 / b.place_order_l7d*1.00 end as food_cancel_rate_l7d
    ,case when coalesce(b.place_order_l15d,0) = 0 then -9999 else coalesce(b.cancel_order_l15d,0)*1.00 / b.place_order_l15d*1.00 end as food_cancel_rate_l15d
    
    -- 下降率特征（如果分母<=0，返回-9999）
    ,case when coalesce(b.nmv_l5_l6m,0) <= 0 then -9999 else coalesce(b.nmv_l1m, 0)*1.00/b.nmv_l5_l6m*1.00 end as food_nmv_drop_16
    ,case when coalesce(b.order_cnt_l5_l6m,0) <= 0 then -9999 else coalesce(b.order_cnt_l1m, 0)*1.00/b.order_cnt_l5_l6m*1.00 end as food_order_cnt_drop_16
    
    -- MSS检查特征
    ,coalesce(d.has_non_individual_store, 0) as food_has_non_individual_store
    ,coalesce(d.has_greylist_store, 0) as food_has_greylist_store
    ,coalesce(d.has_blacklist_store, 0) as food_has_blacklist_store
    ,coalesce(d.has_whitelist_store, 0) as food_has_whitelist_store
    ,coalesce(d.has_ban_sus_store, 0) as food_has_ban_sus_store
    ,coalesce(d.has_site_verified_store, 0) as food_has_site_verified_store
from user_tab a
    left join user_nmv_tab b 
        on a.national_id = b.national_id
    left join user_inactive_tab c 
        on a.national_id = c.national_id
    left join user_mss_tab d
        on a.national_id = d.national_id
;
