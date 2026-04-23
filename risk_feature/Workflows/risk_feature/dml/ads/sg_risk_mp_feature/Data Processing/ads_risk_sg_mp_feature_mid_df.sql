--********************************************************************--
-- Author:              zhicheng.chen@shopee.com
-- Created Time:        2025-07-17T10:00:00
-- Description:         risk all region fearure about MP metrics
-- Data Granularity:    
-- PRD                  https://docs.google.com/spreadsheets/d/1yYtlZE7Di3UiKZ70TUcVkhqp7J2pekSHdG_wmixsqmc/edit?gid=1674787113#gid=1674787113
-- Jira                 https://jira.shopee.io/browse/SPFDT-49792
-- History siyuan.sun   2026-01-19 PH地区新增high_risk_loan_apps特征, 其他地区comment注释掉
--********************************************************************--
${common_head}
WITH user_base AS 
(
    SELECT 
        DISTINCT 
        cast(user_id as string) as platform_user_id
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
    SELECT cast(user_id as string) AS platform_user_id
        ,MAX(IF(datediff('${ds}',last_login_datetime_td) <= 30, 1, 0)) AS is_a30
        ,MAX(IF(datediff('${ds}',last_login_datetime_td) <= 90, 1, 0)) AS is_a90
        ,MAX(IF(datediff('${ds}',last_login_datetime_td) <= 180, 1, 0)) AS is_a180
        ,MAX(IF(datediff('${ds}',last_login_datetime_td) <= 360, 1, 0)) AS is_a360
    FROM mp_user.ads_activeness_user_activity_td__reg_s0_live
    WHERE grass_region = '${REGION}'
          AND grass_date = '${ds}'
        GROUP BY user_id
),
buyer_order_cnt_info as 
(
    select cast(buyer_id as string) as buyer_id,
           paid_order_cnt_1d,
           paid_order_cnt_30d,
           paid_order_cnt_90d,
           paid_order_cnt_180d
    from mp_order.dws_buyer_gmv_nd__reg_s0_live
    where grass_region = '${REGION}'
        and tz_type = 'local'
        and grass_date = '${ds}'
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
        nmv_usd_l1d*1.0/confirmed_order_l1d as abs_usd_l1d,
        nmv_usd_l30d*1.0/confirmed_order_l30d as abs_usd_l30d,
        nmv_usd_l90d*1.0/confirmed_order_l90d as abs_usd_l90d,
        nmv_usd_l180d*1.0/confirmed_order_l180d as abs_usd_l180d,
        nmv_usd_l360d*1.0/confirmed_order_l360d as abs_usd_l360d,
        nmv_usd_history*1.0/confirmed_order_history as abs_usd_history,
        cod_confirmed_order_l1d*1.0/confirmed_order_l1d as pct_cod_l1d,
        cod_confirmed_order_l30d*1.0/confirmed_order_l30d as pct_cod_l30d,
        cod_confirmed_order_l90d*1.0/confirmed_order_l90d as pct_cod_l90d,
        cod_confirmed_order_l180d*1.0/confirmed_order_l180d as pct_cod_l180d,
        cod_confirmed_order_l360d*1.0/confirmed_order_l360d as pct_cod_l360d,
        cod_confirmed_order_history*1.0/confirmed_order_history as pct_cod_history
    from risk_feature.dws_risk_${region}_mp_transaction_info_df
    where grass_date = '${ds}'
)

${comment},high_risk_loan_apps as (
${comment}    select  platform_user_id
${comment}            ,number_of_high_risk_loan_apps_l90d
${comment}            ,number_of_high_risk_loan_apps_l180d
${comment}            ,number_of_high_risk_loan_apps_l360d
${comment}    from risk_feature.dws_risk_${region}_mp_feature_high_risk_loan_apps_df
${comment}    where grass_date = '${ds}'
${comment}) 

insert overwrite table ${SCHEMA}.ads_risk_${region}_mp_feature_mid_df partition (grass_date = '${ds}')
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
    coalesce(t3.pct_cod_history,-9999) as pct_cod_history,
    coalesce(t4.paid_order_cnt_1d,-9999) as buyer_paid_order_in_l1d,
    coalesce(t4.paid_order_cnt_30d,-9999) as buyer_paid_order_in_l30d,
    coalesce(t4.paid_order_cnt_90d,-9999) as buyer_paid_order_in_l90d,
    coalesce(t4.paid_order_cnt_180d,-9999) as buyer_paid_order_in_l180d
${comment}    ,coalesce(t5.number_of_high_risk_loan_apps_l90d,-9999) as number_of_high_risk_loan_apps_l90d
${comment}    ,coalesce(t5.number_of_high_risk_loan_apps_l180d,-9999) as number_of_high_risk_loan_apps_l180d
${comment}    ,coalesce(t5.number_of_high_risk_loan_apps_l360d,-9999) as number_of_high_risk_loan_apps_l360d
FROM user_base t1
LEFT JOIN active_info t2 ON t1.platform_user_id = t2.platform_user_id
LEFT JOIN mp_transaction_info t3 ON t1.platform_user_id = t3.platform_user_id
left join buyer_order_cnt_info t4 on t1.platform_user_id = t4.buyer_id
${comment} left join high_risk_loan_apps t5 on t1.platform_user_id = t5.platform_user_id 
;