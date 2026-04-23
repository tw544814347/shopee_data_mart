--********************************************************************--
-- Author:              zhicheng.chen@shopee.com
-- Created Time:        2025-08-05 T11:00:00
-- Description:         risk all region fearure about MP transaction features, dws table 
-- Data Granularity:    
-- PRD                  https://docs.google.com/spreadsheets/d/1yYtlZE7Di3UiKZ70TUcVkhqp7J2pekSHdG_wmixsqmc/edit?gid=1674787113#gid=1674787113
-- Jira                 https://jira.shopee.io/browse/SPFDT-49792
--********************************************************************--
${common_head}
insert overwrite table ${SCHEMA}.dws_risk_${region}_mp_transaction_info_df partition (grass_date = '${ds}')
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
          ,SUM(CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 1 and payment_method = 24 THEN nmv_usd else NULL END) as spl_nmv_usd_l1d
          ,SUM(CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 30 and payment_method = 24 THEN nmv_usd else NULL END) as spl_nmv_usd_l30d
          ,SUM(CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 90 and payment_method = 24 THEN nmv_usd else NULL END) as spl_nmv_usd_l90d
          ,SUM(CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 180 and payment_method = 24 THEN nmv_usd else NULL END) as spl_nmv_usd_l180d
          ,SUM(CASE WHEN datediff('${current_grass_date}',shipping_confirm_date) <= 360 and payment_method = 24 THEN nmv_usd else NULL END) as spl_nmv_usd_l360d
          ,SUM(CASE WHEN payment_method = 24 THEN nmv_usd ELSE NULL END) as spl_nmv_usd_history
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
            CASE WHEN payment_method_id = 24 then 24 --'SPayLater' 
                WHEN payment_method_id = 27 then 2 -- 'ShopeePay'
                WHEN payment_method_id =  1 then 1 --'Credit/Debt Card'
                WHEN payment_method_id =  6 then 6 --'COD'
                WHEN payment_be_channel_id = 40429 then 8 -- 'G-Cash'
                ELSE -1 END as payment_method -----24 is spl,  6 is cod
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
;