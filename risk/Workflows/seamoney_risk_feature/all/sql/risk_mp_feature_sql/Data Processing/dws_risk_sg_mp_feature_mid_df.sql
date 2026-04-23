--********************************************************************--
-- Author:              zhicheng.chen@shopee.com
-- Created Time:        2025-07-17T10:00:00
-- Description:         risk all region fearure about MP metrics
-- Data Granularity:    
-- PRD                  https://docs.google.com/spreadsheets/d/1yYtlZE7Di3UiKZ70TUcVkhqp7J2pekSHdG_wmixsqmc/edit?gid=1674787113#gid=1674787113
-- Jira                 https://jira.shopee.io/browse/SPFDT-49792
--********************************************************************--
${common_head}
WITH user_base AS 
(
    SELECT 
        DISTINCT 
        user_id as platform_user_id
        ,is_phone_verified
        ,datediff('${current_grass_date}', to_date(registration_datetime)) AS shopee_age
        ,case when status = 0 then '0:ACCOUNT_DELETE'
              when status = 1 then '1:ACCOUNT_NORMAL'
              when status = 2 then '2:ACCOUNT_BANNED'
              when status = 3 then '3:ACCOUNT_FROZEN' end as shopee_user_status
    FROM mp_user.dim_user__reg_s0_live
    WHERE grass_region = '${REGION}' and grass_date = '${ds}'
)
,active_info AS (
    SELECT user_id AS platform_user_id
        ,MAX(IF(datediff('${ds}',last_login_datetime_td) <= 30, 1, 0)) AS is_a30
        ,MAX(IF(datediff('${ds}',last_login_datetime_td) <= 90, 1, 0)) AS is_a90
        ,MAX(IF(datediff('${ds}',last_login_datetime_td) <= 180, 1, 0)) AS is_a180
        ,MAX(IF(datediff('${ds}',last_login_datetime_td) <= 360, 1, 0)) AS is_a360
    FROM mp_user.ads_activeness_user_activity_td__reg_s0_live
    WHERE grass_region = '${REGION}'
          AND grass_date = '${ds}'
        GROUP BY user_id
),
mp_transaction_info_precal as (
    select platform_user_id
          ,COUNT(distinct CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 1 THEN order_id ELSE NULL END) AS confirmed_order_l1d
          ,COUNT(distinct CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 30 THEN order_id ELSE NULL END) AS confirmed_order_l30d
          ,COUNT(distinct CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 90 THEN order_id ELSE NULL END) AS confirmed_order_l90d
          ,COUNT(distinct CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 180 THEN order_id ELSE NULL END) AS confirmed_order_l180d
          ,COUNT(distinct CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 360 THEN order_id ELSE NULL END) AS confirmed_order_l360d
          ,COUNT(distinct order_id) AS confirmed_order_history
          ,SUM(CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 1 THEN nmv_usd else NULL END) as nmv_usd_l1d
          ,SUM(CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 30 THEN nmv_usd else NULL END) as nmv_usd_l30d
          ,SUM(CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 90 THEN nmv_usd else NULL END) as nmv_usd_l90d
          ,SUM(CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 180 THEN nmv_usd else NULL END) as nmv_usd_l180d
          ,SUM(CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 360 THEN nmv_usd else NULL END) as nmv_usd_l360d
          ,SUM(nmv_usd) as nmv_usd_history
          ,SUM(CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 1 and payment_method = 7 THEN nmv_usd else NULL END) as spl_nmv_usd_l1d
          ,SUM(CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 30 and payment_method = 7 THEN nmv_usd else NULL END) as spl_nmv_usd_l30d
          ,SUM(CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 90 and payment_method = 7 THEN nmv_usd else NULL END) as spl_nmv_usd_l90d
          ,SUM(CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 180 and payment_method = 7 THEN nmv_usd else NULL END) as spl_nmv_usd_l180d
          ,SUM(CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 360 and payment_method = 7 THEN nmv_usd else NULL END) as spl_nmv_usd_l360d
          ,SUM(CASE WHEN payment_method = 7 THEN nmv_usd ELSE NULL END) as spl_nmv_usd_history
          ,COUNT(distinct CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 1 and payment_method = 6 THEN order_id ELSE NULL END) AS cod_confirmed_order_l1d
          ,COUNT(distinct CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 30 and payment_method = 6 THEN order_id ELSE NULL END) AS cod_confirmed_order_l30d
          ,COUNT(distinct CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 90 and payment_method = 6 THEN order_id ELSE NULL END) AS cod_confirmed_order_l90d
          ,COUNT(distinct CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 180 and payment_method = 6 THEN order_id ELSE NULL END) AS cod_confirmed_order_l180d
          ,COUNT(distinct CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 360 and payment_method = 6 THEN order_id ELSE NULL END) AS cod_confirmed_order_l360d
          ,COUNT(distinct CASE WHEN payment_method = 6 THEN order_id ELSE NULL END) AS cod_confirmed_order_history
    from 
      (
        SELECT 
            buyer_id AS platform_user_id,
            order_id,
            to_date(format_time(shipping_confirm_timestamp,'${REGION}')) AS shipping_confirm_date,
            CASE WHEN (nmv_usd IS NULL OR nmv_usd = 0) AND is_returned_item = 0 AND cancel_timestamp IS NULL
                THEN gmv_usd -- manually backfill historical records that didnt have nmv as the column did not exist back then
                ELSE nmv_usd 
            END AS nmv_usd, -- keep naming of gmv here for sake of consequential code dependency (2023-12)
            CASE WHEN payment_method_id = 24 then 7 --'SPayLater' 
                WHEN payment_method_id = 27 then 2 -- 'ShopeePay'
                WHEN payment_method_id =  1 then 1 --'Credit/Debt Card'
                WHEN payment_method_id =  6 then 6 --'COD'
                WHEN payment_be_channel_id = 40429 then 8 -- 'G-Cash'
                ELSE -1 END as payment_method
        FROM mp_order.dwd_order_item_all_ent_df__reg_s0_live  
        WHERE grass_region = '${REGION}'
            AND tz_type = 'local' 
            AND order_be_status_id IN (4, 11, 12, 13, 14, 15)
            AND shipping_confirm_timestamp > 0
            AND is_bi_excluded = 0
            AND payment_method_id <> 5 --PH: for free order need to exclude
            AND payment_method_id is not null -- checkout_tb.channelid IS NOT NULL
            AND is_net_order = 1 
            -- AND buyer_id in (
            --     SELECT userid FROM is_spl_activated)
            and to_date(create_datetime)<='${ds}'
    ) a 
    group by platform_user_id
),
mp_transaction_info as (
   select platform_user_id,
        confirmed_order_l1d,
        confirmed_order_l30d,
        confirmed_order_l90d,
        confirmed_order_l180d,
        confirmed_order_l360d,
        confirmed_order_history,
        nmv_usd_l1d,
        nmv_usd_l30d,
        nmv_usd_l90d,
        nmv_usd_l180d,
        nmv_usd_l360d,
        nmv_usd_history,
        spl_nmv_usd_l1d,
        spl_nmv_usd_l30d,
        spl_nmv_usd_l90d,
        spl_nmv_usd_l180d,
        spl_nmv_usd_l360d,
        spl_nmv_usd_history,
        if(confirmed_order_l1d>0,nmv_usd_l1d*1.0/confirmed_order_l1d,-9999) as abs_usd_l1d,
        if(confirmed_order_l30d>0,nmv_usd_l30d*1.0/confirmed_order_l30d,-9999) as abs_usd_l30d,
        if(confirmed_order_l90d>0,nmv_usd_l90d*1.0/confirmed_order_l90d,-9999) as abs_usd_l90d,
        if(confirmed_order_l180d>0,nmv_usd_l180d*1.0/confirmed_order_l180d,-9999) as abs_usd_l180d,
        if(confirmed_order_l360d>0,nmv_usd_l360d*1.0/confirmed_order_l360d,-9999) as abs_usd_l360d,
        if(confirmed_order_history>0,nmv_usd_history*1.0/confirmed_order_history,-9999) as abs_usd_history,
        if(confirmed_order_l1d>0,cod_confirmed_order_l1d*1.0/confirmed_order_l1d,-9999) as pct_cod_l1d,
        if(confirmed_order_l30d>0,cod_confirmed_order_l30d*1.0/confirmed_order_l30d,-9999) as pct_cod_l30d,
        if(confirmed_order_l90d>0,cod_confirmed_order_l90d*1.0/confirmed_order_l90d,-9999) as pct_cod_l90d,
        if(confirmed_order_l180d>0,cod_confirmed_order_l180d*1.0/confirmed_order_l180d,-9999) as pct_cod_l180d,
        if(confirmed_order_l360d>0,cod_confirmed_order_l360d*1.0/confirmed_order_l360d,-9999) as pct_cod_l360d,
        if(confirmed_order_history>0,cod_confirmed_order_history*1.0/confirmed_order_history,-9999) as pct_cod_history
    from mp_transaction_info_precal
)
insert overwrite table ${SCHEMA}.dws_risk_${region}_mp_feature_mid_df partition (grass_date = '${grass_date}')
    SELECT
    t1.platform_user_id,
    t1.shopee_age,
    t1.is_phone_verified,
    coalesce(t2.is_a30,-9999) as is_a30,
    coalesce(t2.is_a90,-9999) as is_a90,
    coalesce(t2.is_a180,-9999) as is_a180,
    coalesce(t2.is_a360,-9999) as is_a360,
    t1.shopee_user_status,
    coalesce(t3.confirmed_order_l1d,-9999) as confirmed_order_l1d,
    coalesce(t3.confirmed_order_l30d,-9999) as confirmed_order_l30d,
    coalesce(t3.confirmed_order_l90d,-9999) as confirmed_order_l90d,
    coalesce(t3.confirmed_order_l180d,-9999) as confirmed_order_l180d,
    coalesce(t3.confirmed_order_l360d,-9999) as confirmed_order_l360d,
    coalesce(t3.confirmed_order_history,-9999) as confirmed_order_history,
    coalesce(t3.nmv_usd_l1d,-9999) as nmv_usd_l1d,
    coalesce(t3.nmv_usd_l30d,-9999) as nmv_usd_l30d,
    coalesce(t3.nmv_usd_l90d,-9999) as nmv_usd_l90d,
    coalesce(t3.nmv_usd_l180d,-9999) as nmv_usd_l180d,
    coalesce(t3.nmv_usd_l360d,-9999) as nmv_usd_l360d,
    coalesce(t3.nmv_usd_history,-9999) as nmv_usd_history,
    coalesce(t3.spl_nmv_usd_l1d,-9999) as spl_nmv_usd_l1d,
    coalesce(t3.spl_nmv_usd_l30d,-9999) as spl_nmv_usd_l30d,
    coalesce(t3.spl_nmv_usd_l90d,-9999) as spl_nmv_usd_l90d,
    coalesce(t3.spl_nmv_usd_l180d,-9999) as spl_nmv_usd_l180d,
    coalesce(t3.spl_nmv_usd_l360d,-9999) as spl_nmv_usd_l360d,
    coalesce(t3.spl_nmv_usd_history,-9999) as spl_nmv_usd_history,
    coalesce(t3.abs_usd_l1d,-9999) as abs_usd_l1d,
    coalesce(t3.abs_usd_l30d,-9999) as abs_usd_l30d,
    coalesce(t3.abs_usd_l90d,-9999) as abs_usd_l90d,
    coalesce(t3.abs_usd_l180d,-9999) as abs_usd_l180d,
    coalesce(t3.abs_usd_l360d,-9999) as abs_usd_l360d,
    coalesce(t3.abs_usd_history,-9999) as abs_usd_history,
    coalesce(t3.pct_cod_l1d,-9999) as pct_cod_l1d,
    coalesce(t3.pct_cod_l30d,-9999) as pct_cod_l30d,
    coalesce(t3.pct_cod_l90d,-9999) as pct_cod_l90d,
    coalesce(t3.pct_cod_l180d,-9999) as pct_cod_l180d,
    coalesce(t3.pct_cod_l360d,-9999) as pct_cod_l360d,
    coalesce(t3.pct_cod_history,-9999) as pct_cod_history
FROM user_base t1
LEFT JOIN active_info t2 ON t1.platform_user_id = t2.platform_user_id
LEFT JOIN mp_transaction_info t3 ON t1.platform_user_id = t3.platform_user_id
;