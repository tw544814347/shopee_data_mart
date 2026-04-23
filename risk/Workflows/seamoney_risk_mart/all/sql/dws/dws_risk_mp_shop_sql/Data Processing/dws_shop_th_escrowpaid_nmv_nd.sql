  with matured_orders_tab AS (
    SELECT 
        CAST(o.seller_id AS string) AS platform_user_id
        ,o.grass_region
        ,a.shop_id
        ,o.order_id
        ,DATE(o.escrow_paid_datetime) AS escrow_paid_datetime
        ,(CASE 
        WHEN DATE(o.grass_date) < DATE('2020-01-01') AND is_net_order = 1 then o.gmv
        WHEN DATE(o.grass_date) < DATE('2020-01-01') AND is_net_order = 0 then 0
        ELSE o.nmv
        END) as nmv 
   
        ,(CASE 
        WHEN DATE(o.grass_date) < DATE('2020-01-01') AND is_net_order = 1 then o.gmv_usd
        WHEN DATE(o.grass_date) < DATE('2020-01-01') AND is_net_order = 0 then 0
        ELSE o.nmv_usd
        END) as nmv_usd  
        
        ,DATEDIFF(CURRENT_DATE,DATE(o.escrow_paid_datetime)) AS day

    FROM mp_order.dwd_order_all_ent_df__reg_s0_live o

    Inner JOIN 
    (   SELECT 
        user_id AS platform_user_id
        ,shop_id
        ,grass_region
     FROM   mp_user.dim_shop__reg_s0_live
     WHERE  grass_date = '${begin_ds}' AND grass_region = '${grass_region}') a
    ON CAST(o.seller_id AS String) = a.platform_user_id
    and o.grass_region=a.grass_region
    WHERE 
        ( 
            o.grass_date != DATE('9999-01-01') 
            OR (  o.grass_date = DATE('9999-01-01') AND order_be_status IN ('ESCROW_PAID','CANCEL_COMPLETED','INVALID')  ) 
            )
        AND
        ( DATEDIFF(CURRENT_DATE,DATE(o.escrow_paid_datetime)) BETWEEN 1 AND 240 ) 
        AND o.grass_date >= (current_date() - INTERVAL '240' DAY)
        AND o.grass_region = '${grass_region}'
)

,daily_order_bef_disburse AS (
    SELECT 
    platform_user_id
    ,grass_region
    ,shop_id
    ,COALESCE(SUM(CASE WHEN day <=7 THEN nmv ELSE 0 END), 0) AS nmv_in_7d
    ,COALESCE(SUM(CASE WHEN day <=15 THEN nmv ELSE 0 END), 0) AS nmv_in_15d
    ,COALESCE(SUM(CASE WHEN day between 1 and 30 THEN nmv ELSE 0 END), 0) AS nmv_in_30d
    ,COALESCE(SUM(CASE WHEN day between 31 and 60 THEN nmv ELSE 0 END), 0) AS nmv_in_31_60d
    ,COALESCE(SUM(CASE WHEN day between 61 and 90 THEN nmv ELSE 0 END), 0) AS nmv_in_61_90d
    ,COALESCE(SUM(CASE WHEN day between 91 and 120 THEN nmv ELSE 0 END), 0) AS nmv_in_91_120d
    ,COALESCE(SUM(CASE WHEN day between 121 and 150 THEN nmv ELSE 0 END), 0) AS nmv_in_121_150d
    ,COALESCE(SUM(CASE WHEN day between 151 and 180 THEN nmv ELSE 0 END), 0) AS nmv_in_151_180d
    ,COALESCE(SUM(CASE WHEN day between 181 and 210 THEN nmv ELSE 0 END), 0) AS nmv_in_181_210d
    ,COALESCE(SUM(CASE WHEN day <=7 THEN order_cnt ELSE 0 END), 0) AS escrowpaid_order_cnt_in_7d
    ,COALESCE(SUM(CASE WHEN day <=15 THEN order_cnt ELSE 0 END), 0) AS escrowpaid_order_cnt_in_15d
    ,COALESCE(SUM(CASE WHEN day <=30 THEN order_cnt ELSE 0 END), 0) AS escrowpaid_order_cnt_in_30d
    ,COALESCE(SUM(CASE WHEN day <=60 THEN order_cnt ELSE 0 END), 0) AS escrowpaid_order_cnt_in_60d
    ,COALESCE(SUM(CASE WHEN day <=90 THEN order_cnt ELSE 0 END), 0) AS escrowpaid_order_cnt_in_90d
    ,COALESCE(SUM(CASE WHEN day <=180 THEN order_cnt ELSE 0 END), 0) AS escrowpaid_order_cnt_in_180d
    ,COALESCE(SUM(CASE WHEN day <=7 THEN nmv_usd ELSE 0 END), 0) AS nmv_in_7d_usd
    ,COALESCE(SUM(CASE WHEN day <=15 THEN nmv_usd ELSE 0 END), 0) AS nmv_in_15d_usd
    ,COALESCE(SUM(CASE WHEN day between 1 and 30 THEN nmv_usd ELSE 0 END), 0) AS nmv_in_30d_usd
    ,COALESCE(SUM(CASE WHEN day between 31 and 60 THEN nmv_usd ELSE 0 END), 0) AS nmv_in_31_60d_usd
    ,COALESCE(SUM(CASE WHEN day between 61 and 90 THEN nmv_usd ELSE 0 END), 0) AS nmv_in_61_90d_usd
    ,COALESCE(SUM(CASE WHEN day between 91 and 120 THEN nmv_usd ELSE 0 END), 0) AS nmv_in_91_120d_usd
    ,COALESCE(SUM(CASE WHEN day between 121 and 150 THEN nmv_usd ELSE 0 END), 0) AS nmv_in_121_150d_usd
    ,COALESCE(SUM(CASE WHEN day between 151 and 180 THEN nmv_usd ELSE 0 END), 0) AS nmv_in_151_180d_usd
    ,COALESCE(SUM(CASE WHEN day between 181 and 210 THEN nmv_usd ELSE 0 END), 0) AS nmv_in_181_210d_usd
   FROM (
       SELECT 
            platform_user_id
            ,grass_region
            ,shop_id
            ,day
            ,count(order_id) as order_cnt--order在表里没有重复
            ,SUM(nmv) AS nmv 
            ,SUM(nmv_usd) AS nmv_usd
        FROM matured_orders_tab
        WHERE nmv> 0
        GROUP BY 1,2,3,4
    )
  GROUP BY 1,2,3
)
,shop_escrowpaid_nmv_nd AS (
    SELECT 
    shop_id
    ,platform_user_id
    ,escrowpaid_order_cnt_in_7d
    ,escrowpaid_order_cnt_in_15d
    ,escrowpaid_order_cnt_in_30d
    ,escrowpaid_order_cnt_in_60d
    ,escrowpaid_order_cnt_in_90d
    ,escrowpaid_order_cnt_in_180d
    ,nmv_in_7d as escrowpaid_nmv_in_7d
    ,nmv_in_15d as escrowpaid_nmv_in_15d
    ,nmv_in_30d as escrowpaid_nmv_in_30d
    ,nmv_in_31_60d as escrowpaid_nmv_in_31_60d
    ,nmv_in_61_90d as escrowpaid_nmv_in_61_90d
    ,nmv_in_91_120d as escrowpaid_nmv_in_91_120d
    ,nmv_in_121_150d as escrowpaid_nmv_in_121_150d
    ,nmv_in_151_180d as escrowpaid_nmv_in_151_180d
    ,nmv_in_181_210d as escrowpaid_nmv_in_181_210d
    ,(0.5*COALESCE(nmv_in_30d,0)  
    + 0.3* ((COALESCE(nmv_in_31_60d,0)  + COALESCE(nmv_in_61_90d,0) + COALESCE(nmv_in_30d,0) )/3)
    + 0.2* ((COALESCE(nmv_in_31_60d,0)  + COALESCE(nmv_in_61_90d,0) + COALESCE(nmv_in_91_120d,0) 
            +COALESCE(nmv_in_121_150d,0)+ COALESCE(nmv_in_151_180d,0)+ COALESCE(nmv_in_30d,0) )/6)) 
        AS escrowpaid_weighted_monthly_nmv
    ,(0.5*COALESCE(nmv_in_31_60d,0) + 0.3* ((COALESCE(nmv_in_31_60d,0) + COALESCE(nmv_in_61_90d,0) + COALESCE(nmv_in_91_120d,0) )/3) + 0.2* ((COALESCE(nmv_in_31_60d,0) + COALESCE(nmv_in_61_90d,0) + COALESCE(nmv_in_91_120d,0) +COALESCE(nmv_in_121_150d,0)+ COALESCE(nmv_in_151_180d,0)+ COALESCE(nmv_in_181_210d,0) )/6)) AS escrowpaid_weighted_nmv_l1m
    ,nmv_in_7d_usd as escrowpaid_nmv_usd_in_7d
    ,nmv_in_15d_usd as escrowpaid_nmv_usd_in_15d
    ,nmv_in_30d_usd as escrowpaid_nmv_usd_in_30d
    ,nmv_in_31_60d_usd as escrowpaid_nmv_usd_in_31_60d
    ,nmv_in_61_90d_usd as escrowpaid_nmv_usd_in_61_90d
    ,nmv_in_91_120d_usd as escrowpaid_nmv_usd_in_91_120d
    ,nmv_in_121_150d_usd as escrowpaid_nmv_usd_in_121_150d
    ,nmv_in_151_180d_usd as escrowpaid_nmv_usd_in_151_180d
    ,nmv_in_181_210d_usd as escrowpaid_nmv_usd_in_181_210d
    ,(0.5*COALESCE(nmv_in_30d_usd,0) 
    + 0.3* ((COALESCE(nmv_in_31_60d_usd,0)  + COALESCE(nmv_in_61_90d_usd,0) + COALESCE(nmv_in_30d_usd,0) )/3)
    + 0.2* ((COALESCE(nmv_in_31_60d_usd,0)  + COALESCE(nmv_in_61_90d_usd,0) + COALESCE(nmv_in_91_120d_usd,0) 
            +COALESCE(nmv_in_121_150d_usd,0)+ COALESCE(nmv_in_151_180d_usd,0)+ COALESCE(nmv_in_30d_usd,0) )/6)) 
        AS escrowpaid_weighted_monthly_nmv_usd
    ,(0.5*COALESCE(nmv_in_31_60d_usd,0) + 0.3* ((COALESCE(nmv_in_31_60d_usd,0) + COALESCE(nmv_in_61_90d_usd,0) + COALESCE(nmv_in_91_120d_usd,0) )/3) + 0.2* ((COALESCE(nmv_in_31_60d_usd,0) + COALESCE(nmv_in_61_90d_usd,0) + COALESCE(nmv_in_91_120d_usd,0) +COALESCE(nmv_in_121_150d_usd,0)+ COALESCE(nmv_in_151_180d_usd,0)+ COALESCE(nmv_in_181_210d_usd,0) )/6)) AS escrowpaid_weighted_nmv_usd_l1m
    ,grass_region
    ,'${begin_ds}' as grass_date
    from 
    daily_order_bef_disburse
)

insert overwrite ${SCHEMA}.dws_shop_escrowpaid_nmv_nd PARTITION (grass_region,grass_date)
select
    t1.shop_id
    ,t1.platform_user_id
    ,t2.escrowpaid_order_cnt_in_7d
    ,t2.escrowpaid_order_cnt_in_15d
    ,t2.escrowpaid_order_cnt_in_30d
    ,t2.escrowpaid_order_cnt_in_60d
    ,t2.escrowpaid_order_cnt_in_90d
    ,t2.escrowpaid_order_cnt_in_180d
    ,t2.escrowpaid_nmv_in_7d
    ,t2.escrowpaid_nmv_in_15d
    ,t2.escrowpaid_nmv_in_30d
    ,t2.escrowpaid_nmv_in_31_60d
    ,t2.escrowpaid_nmv_in_61_90d
    ,t2.escrowpaid_nmv_in_91_120d
    ,t2.escrowpaid_nmv_in_121_150d
    ,t2.escrowpaid_nmv_in_151_180d
    ,t2.escrowpaid_nmv_in_181_210d
    ,t2.escrowpaid_weighted_monthly_nmv
    ,t2.escrowpaid_weighted_nmv_l1m
    ,t2.escrowpaid_nmv_usd_in_7d
    ,t2.escrowpaid_nmv_usd_in_15d
    ,t2.escrowpaid_nmv_usd_in_30d
    ,t2.escrowpaid_nmv_usd_in_31_60d
    ,t2.escrowpaid_nmv_usd_in_61_90d
    ,t2.escrowpaid_nmv_usd_in_91_120d
    ,t2.escrowpaid_nmv_usd_in_121_150d
    ,t2.escrowpaid_nmv_usd_in_151_180d
    ,t2.escrowpaid_nmv_usd_in_181_210d
    ,t2.escrowpaid_weighted_monthly_nmv_usd
    ,t2.escrowpaid_weighted_nmv_usd_l1m
    ,t3.avg_escrowpaid_nmv_l3m
    ,t3.avg_escrowpaid_nmv_l6m
    ,t3.daily_escrow_l6m_75pctl
    ,t1.grass_region
    ,t1.grass_date
from
(select shop_id,user_id as platform_user_id,grass_region,grass_date from mp_user.dim_shop__reg_s0_live where grass_date = date '${bizdate}' and grass_region = '${grass_region}' and shop_id <> 0) t1
left join
(select * from shop_escrowpaid_nmv_nd where grass_date = '${bizdate}' and grass_region = '${grass_region}') t2
on t1.grass_region = t2.grass_region
and t1.shop_id = t2.shop_id
left join
(select shop_id,grass_region,avg_escrowpaid_nmv_l3m,avg_escrowpaid_nmv_l6m,daily_escrow_l6m_75pctl from ${SCHEMA}.dws_shop_escrowpaid_txn_nd where grass_date = '${bizdate}' and grass_region = '${grass_region}') t3
on t1.grass_region = t3.grass_region
and t1.shop_id = t3.shop_id
;




create or replace view ${SCHEMA}.dws_shop_${region}_escrowpaid_nmv_nd as
select
    *
from ${SCHEMA}.dws_shop_escrowpaid_nmv_nd
where
    grass_region = upper('${region}')
;