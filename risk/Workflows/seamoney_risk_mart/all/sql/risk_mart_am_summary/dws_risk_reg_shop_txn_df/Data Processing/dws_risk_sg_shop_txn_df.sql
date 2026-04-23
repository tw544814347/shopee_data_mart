create or replace temporary view txn_escrow_paid as
select shop_id
       ,buyer_id
       ,order_id
       ,gmv
       ,is_net_order
       ,payment_method_id
       ,create_datetime
       ,escrow_paid_datetime
       ,date_format(escrow_paid_datetime,'yyyy-MM-dd') as escrow_paid_date
       ,order_be_status
       ,grass_date
from mp_order.dwd_order_all_ent_df__reg_s0_live
where tz_type = 'local'
and grass_region = upper('${region}')
and (grass_date>=date_sub(date_add('${grass_date}',1),450) or (grass_date = '9999-01-01' and order_be_status IN ('ESCROW_PAID','CANCEL_COMPLETED','INVALID')))
;

create or replace temporary view txn_active_info as
select shop_id
       ,count(distinct case when daily_gmv > 0 then escrow_paid_date else null end) as txn_days_in_180d
       ,max(diff) as max_inactivate_days_in_180d
from
      (select shop_id
              ,escrow_paid_date
              ,sum(gmv) as daily_gmv
              ,datediff(escrow_paid_date, lag(escrow_paid_date) over(partition by shop_id order by escrow_paid_date)) as diff
       from txn_escrow_paid
       where (grass_date>=date_sub(date_add('${grass_date}',1),180) or (grass_date = '9999-01-01' and order_be_status IN ('ESCROW_PAID','CANCEL_COMPLETED','INVALID'))) 
       group by 1,2)
group by 1;

create or replace temporary view txn_buyer_info as
select
    shop_id
    ,count(distinct if(datediff(date_add('${bizdate}',1), escrow_paid_datetime) between 0 and 3, buyer_id, null)) as distinct_buyer_in_3d
    ,count(distinct if(datediff(date_add('${bizdate}',1), escrow_paid_datetime) between 0 and 30 and is_net_order=1, buyer_id, null)) as buyer_in_30d
    ,count(distinct if(datediff(date_add('${bizdate}',1), escrow_paid_datetime) between 31 and 60 and is_net_order=1, buyer_id, null)) as buyer_in_31_60d
    ,count(distinct if(datediff(date_add('${bizdate}',1), escrow_paid_datetime) between 61 and 90 and is_net_order=1, buyer_id, null)) as buyer_in_61_90d
    ,count(distinct if(datediff(date_add('${bizdate}',1), escrow_paid_datetime) between 91 and 120 and is_net_order=1, buyer_id, null)) as buyer_in_91_120d
    ,count(distinct if(datediff(date_add('${bizdate}',1), escrow_paid_datetime) between 121 and 150 and is_net_order=1, buyer_id, null)) as buyer_in_121_150d
    ,count(distinct if(datediff(date_add('${bizdate}',1), escrow_paid_datetime) between 151 and 180 and is_net_order=1, buyer_id, null)) as buyer_in_151_180d
    ,count(distinct if(datediff(date_add('${bizdate}',1), escrow_paid_datetime) between 181 and 210 and is_net_order=1, buyer_id, null)) as buyer_in_181_210d
    ,count(distinct if(datediff(date_add('${bizdate}',1), escrow_paid_datetime) between 211 and 240 and is_net_order=1, buyer_id, null)) as buyer_in_211_240d
    ,count(distinct if(datediff(date_add('${bizdate}',1), escrow_paid_datetime) between 241 and 270 and is_net_order=1, buyer_id, null)) as buyer_in_241_270d
    ,count(distinct if(datediff(date_add('${bizdate}',1), escrow_paid_datetime) between 271 and 300 and is_net_order=1, buyer_id, null)) as buyer_in_271_300d
    ,count(distinct if(datediff(date_add('${bizdate}',1), escrow_paid_datetime) between 301 and 330 and is_net_order=1, buyer_id, null)) as buyer_in_301_330d
    ,count(distinct if(datediff(date_add('${bizdate}',1), escrow_paid_datetime) between 331 and 360 and is_net_order=1, buyer_id, null)) as buyer_in_331_360d
    ,count(distinct if(datediff(date_add('${bizdate}',1), escrow_paid_datetime) between 361 and 390 and is_net_order=1, buyer_id, null)) as buyer_in_361_390d
    ,sum(case when datediff(date_add('${grass_date}',1), escrow_paid_date) between 0 and 3 then gmv else null end) as gmv_in_3d
    ,sum(case when datediff(date_add('${grass_date}',1), escrow_paid_date) between 0 and 7 then gmv else null end) as gmv_in_7d
    ,sum(case when datediff(date_add('${grass_date}',1), escrow_paid_date) between 8 and 14 then gmv else null end) as gmv_in_8_14d
    ,sum(case when datediff(date_add('${grass_date}',1), escrow_paid_date) between 15 and 21 then gmv else null end) as gmv_in_15_21d
    ,sum(case when datediff(date_add('${grass_date}',1), escrow_paid_date) between 22 and 28 then gmv else null end) as gmv_in_22_28d
    ,count(distinct case when datediff(date_add('${grass_date}',1), escrow_paid_date) between 0 and 3 then order_id else null end) as ttl_order_in_3d
from txn_escrow_paid
group by shop_id
;

create or replace temporary view txn_buyer_cancel_info as
select
    shop_id
    ,count(DISTINCT CASE WHEN (create_datetime >= (CURRENT_DATE - interval  '7'  day)) AND order_fe_status = 'CANCELLED' THEN order_id ELSE NULL END) / CAST(COUNT(DISTINCT CASE WHEN (create_datetime >= (CURRENT_DATE - interval  '7'  day)) THEN order_id ELSE NULL END) AS decimal(10,4)) cancellation_rate_l7d
    ,count(DISTINCT CASE WHEN (create_datetime >= (CURRENT_DATE - interval  '30'  day)) AND order_fe_status = 'CANCELLED' THEN order_id ELSE NULL END) / CAST(COUNT(DISTINCT CASE WHEN (create_datetime >= (CURRENT_DATE - interval  '30'  day)) THEN order_id ELSE NULL END) AS decimal(10,4)) cancellation_rate_l30d
from mp_order.dwd_order_all_ent_df__reg_s0_live
where tz_type = 'local'
    and grass_region = upper('${region}')
    and grass_date >= date_add('${bizdate}',1) - interval '391' day
    and create_datetime between (date_add('${bizdate}',1) - interval '390' day) and date_add('${bizdate}',1)
group by 1
;

create or replace temporary view shop_open_info as
select shop_id
       ,case when months > 6 then 1 else 0 end as open_more_than_6m
       ,case when months > 12 then 1 else 0 end as open_more_than_12m
from
(
    select shop_id
          ,max(datediff(date_add('${bizdate}',1), date(date_format(create_datetime,'yyyy-MM-dd')))/30) as months
    from txn_escrow_paid
    group by 1
)
;

create or replace temporary view txn_monthly_info as
SELECT shop_id
        ,CAST(MIN(CASE WHEN months <= 12 THEN monthly_nmv ELSE NULL END) AS DOUBLE) min_nmv_last_12m_tag
        ,CAST(MIN(CASE WHEN months <= 6 THEN monthly_nmv ELSE NULL END) AS DOUBLE) min_nmv_last_6m_tag
        ,CAST(MIN(CASE WHEN months <= 3 THEN monthly_nmv ELSE NULL END) AS DOUBLE) min_nmv_last_3m_tag
        ,CAST(SUM(CASE WHEN months <= 12 THEN monthly_nmv ELSE NULL END) AS DOUBLE)/12 avg_nmv_last_12m_tag
        ,CAST(SUM(CASE WHEN months <= 6 THEN monthly_nmv ELSE NULL END) AS DOUBLE)/6 avg_nmv_last_6m_tag
        ,CAST(SUM(CASE WHEN months <= 3 THEN monthly_nmv ELSE NULL END) AS DOUBLE)/3 avg_nmv_last_3m_tag
        ,COUNT(DISTINCT CASE WHEN months <= 3 AND monthly_nmv > 0 THEN months ELSE NULL END) has_order_month_last_3m
        ,COUNT(DISTINCT CASE WHEN months <= 6 AND monthly_nmv > 0 THEN months ELSE NULL END) has_order_month_last_6m
        ,CAST(SUM(CASE WHEN months <= 3 THEN monthly_cc_nmv ELSE NULL END) / (CASE WHEN SUM(CASE WHEN months <= 3 THEN monthly_nmv ELSE NULL END) >0 then SUM(CASE WHEN months <= 3 THEN monthly_nmv ELSE NULL END) ELSE NULL END) AS DOUBLE) cc_payment_ratio_last_3m
        ,CAST(SUM(CASE WHEN months <= 6 THEN monthly_cc_nmv ELSE NULL END) / (CASE WHEN SUM(CASE WHEN months <= 6 THEN monthly_nmv ELSE NULL END) >0 then SUM(CASE WHEN months <= 6 THEN monthly_nmv ELSE NULL END) ELSE NULL END) AS DOUBLE) cc_payment_ratio_last_6m
from
(
    select
        shop_id
        ,ceil(months_between(CURRENT_DATE, escrow_paid_datetime)) as months
        ,SUM(CASE WHEN is_net_order = 1 THEN gmv ELSE NULL END) monthly_nmv
        ,SUM(CASE WHEN is_net_order = 1 AND payment_method_id IN (14,21,24,15,19) THEN gmv ELSE NULL END) monthly_cc_nmv
    from txn_escrow_paid
    group by 1,2
)
group by shop_id
;

create or replace temporary view txn_seller_shopee_age as
select shop_id
       ,datediff(current_date,min(grass_date)) as seller_shopee_age
from
      (select shop_id,
              grass_date,
              sum(gmv) as daily_gmv,
              datediff(grass_date, lag(grass_date) over(partition by shop_id order by grass_date)) as diff,
              grass_date >= date_add('${bizdate}',1) - interval '180' day as in_180d
       from mp_order.dwd_order_all_ent_df__reg_s0_live
       where tz_type = 'local'
       and grass_region = upper('${region}')
       and is_net_order = 1
       and grass_date != date('9999-01-01')
       group by 1,2)
group by 1;

create or replace temporary view txn_detail_info as
select
    shop_id
    ,sum(if(diff_days between 0 and 30, confirmed_order_cnt, 0)) as seller_confirmed_order_in_30d
    ,sum(if(diff_days between 31 and 60, confirmed_order_cnt, 0)) as seller_confirmed_order_in_31_60d
    ,sum(if(diff_days between 61 and 90, confirmed_order_cnt, 0)) as seller_confirmed_order_in_61_90d
    ,sum(if(diff_days between 91 and 120, confirmed_order_cnt, 0)) as seller_confirmed_order_in_91_120d
    ,sum(if(diff_days between 121 and 150, confirmed_order_cnt, 0)) as seller_confirmed_order_in_121_150d
    ,sum(if(diff_days between 151 and 180, confirmed_order_cnt, 0)) as seller_confirmed_order_in_151_180d
    ,sum(if(diff_days between 181 and 210, confirmed_order_cnt, 0)) as seller_confirmed_order_in_181_210d
    ,sum(if(diff_days between 211 and 240, confirmed_order_cnt, 0)) as seller_confirmed_order_in_211_240d
    ,sum(if(diff_days between 241 and 270, confirmed_order_cnt, 0)) as seller_confirmed_order_in_241_270d
    ,sum(if(diff_days between 271 and 300, confirmed_order_cnt, 0)) as seller_confirmed_order_in_271_300d
    ,sum(if(diff_days between 301 and 330, confirmed_order_cnt, 0)) as seller_confirmed_order_in_301_330d
    ,sum(if(diff_days between 331 and 360, confirmed_order_cnt, 0)) as seller_confirmed_order_in_331_360d
    ,sum(if(diff_days between 361 and 390, confirmed_order_cnt, 0)) as seller_confirmed_order_in_361_390d
    ,sum(if(diff_days <=3, nmv, null)) as nmv_in_3d
    ,sum(if(diff_days <=7, nmv, null)) as nmv_in_7d
    ,sum(if(diff_days between 8 and 14, nmv, null)) as nmv_in_8_14d
    ,sum(if(diff_days between 15 and 21, nmv, null)) as nmv_in_15_21d
    ,sum(if(diff_days between 22 and 28, nmv, null)) as nmv_in_22_28d
    ,sum(if(diff_days between 0 and 30, nmv, null)) as nmv_in_30d
    ,sum(if(diff_days between 31 and 60, nmv, null)) as nmv_in_31_60d
    ,sum(if(diff_days between 61 and 90, nmv, null)) as nmv_in_61_90d
    ,sum(if(diff_days between 91 and 120, nmv, null)) as nmv_in_91_120d
    ,sum(if(diff_days between 121 and 150, nmv, null)) as nmv_in_121_150d
    ,sum(if(diff_days between 151 and 180, nmv, null)) as nmv_in_151_180d
    ,sum(if(diff_days between 181 and 210, nmv, null)) as nmv_in_181_210d
    ,sum(if(diff_days between 211 and 240, nmv, null)) as nmv_in_211_240d
    ,sum(if(diff_days between 241 and 270, nmv, null)) as nmv_in_241_270d
    ,sum(if(diff_days between 271 and 300, nmv, null)) as nmv_in_271_300d
    ,sum(if(diff_days between 301 and 330, nmv, null)) as nmv_in_301_330d
    ,sum(if(diff_days between 331 and 360, nmv, null)) as nmv_in_331_360d
    ,sum(if(diff_days between 361 and 390, nmv, null)) as nmv_in_361_390d
    ,sum(if(terminal_flag = 1 and diff_days between 0 and 30, return_order_cnt, 0)) as return_order_in_30d
    ,sum(if(terminal_flag = 1 and diff_days between 31 and 60, return_order_cnt, 0)) as return_order_in_31_60d
    ,sum(if(terminal_flag = 1 and diff_days between 61 and 90, return_order_cnt, 0)) as return_order_in_61_90d
    ,sum(if(terminal_flag = 1 and diff_days between 91 and 120, return_order_cnt, 0)) as return_order_in_91_120d
    ,sum(if(terminal_flag = 1 and diff_days between 121 and 150, return_order_cnt, 0)) as return_order_in_121_150d
    ,sum(if(terminal_flag = 1 and diff_days between 151 and 180, return_order_cnt, 0)) as return_order_in_151_180d
    ,sum(if(terminal_flag = 1 and diff_days between 181 and 210, return_order_cnt, 0)) as return_order_in_181_210d
    ,sum(if(terminal_flag = 1 and diff_days between 211 and 240, return_order_cnt, 0)) as return_order_in_211_240d
    ,sum(if(terminal_flag = 1 and diff_days between 241 and 270, return_order_cnt, 0)) as return_order_in_241_270d
    ,sum(if(terminal_flag = 1 and diff_days between 271 and 300, return_order_cnt, 0)) as return_order_in_271_300d
    ,sum(if(terminal_flag = 1 and diff_days between 301 and 330, return_order_cnt, 0)) as return_order_in_301_330d
    ,sum(if(terminal_flag = 1 and diff_days between 331 and 360, return_order_cnt, 0)) as return_order_in_331_360d
    ,sum(if(terminal_flag = 1 and diff_days between 361 and 390, return_order_cnt, 0)) as return_order_in_361_390d
    ,sum(if(terminal_flag = 1 and diff_days between 0 and 30, return_gmv, null)) as return_gmv_in_30d
    ,sum(if(terminal_flag = 1 and diff_days between 31 and 60, return_gmv, null)) as return_gmv_31_60d
    ,sum(if(terminal_flag = 1 and diff_days between 61 and 90, return_gmv, null)) as return_gmv_in_61_90d
    ,sum(if(terminal_flag = 1 and diff_days between 91 and 120, return_gmv, null)) as return_gmv_in_91_120d
    ,sum(if(terminal_flag = 1 and diff_days between 121 and 150, return_gmv, null)) as return_gmv_in_121_150d
    ,sum(if(terminal_flag = 1 and diff_days between 151 and 180, return_gmv, null)) as return_gmv_in_151_180d
    ,sum(if(terminal_flag = 1 and diff_days between 181 and 210, return_gmv, null)) as return_gmv_in_181_210d
    ,sum(if(terminal_flag = 1 and diff_days between 211 and 240, return_gmv, null)) as return_gmv_in_211_240d
    ,sum(if(terminal_flag = 1 and diff_days between 241 and 270, return_gmv, null)) as return_gmv_in_241_270d
    ,sum(if(terminal_flag = 1 and diff_days between 271 and 300, return_gmv, null)) as return_gmv_in_271_300d
    ,sum(if(terminal_flag = 1 and diff_days between 301 and 330, return_gmv, null)) as return_gmv_in_301_330d
    ,sum(if(terminal_flag = 1 and diff_days between 331 and 360, return_gmv, null)) as return_gmv_in_331_360d
    ,sum(if(terminal_flag = 1 and diff_days between 361 and 390, return_gmv, null)) as return_gmv_in_361_390d
    ,sum(if(diff_days between 1 and 7, order_cnt, 0))             as create_order_cnt_in_7d     
    ,sum(if(diff_days between 1 and 15, order_cnt, 0))            as create_order_cnt_in_15d    
    ,sum(if(diff_days between 1 and 30, order_cnt, 0))            as create_order_cnt_in_30d    
    ,sum(if(diff_days between 1 and 60, order_cnt, 0))            as create_order_cnt_in_60d    
    ,sum(if(diff_days between 1 and 90, order_cnt, 0))            as create_order_cnt_in_90d    
    ,sum(if(diff_days between 1 and 180, order_cnt, 0))           as create_order_cnt_in_180d   
    ,sum(if(diff_days between 1 and 7, cancelled_order_cnt, 0))   as cancelled_order_cnt_in_7d  
    ,sum(if(diff_days between 1 and 15, cancelled_order_cnt, 0))  as cancelled_order_cnt_in_15d 
    ,sum(if(diff_days between 1 and 30, cancelled_order_cnt, 0))  as cancelled_order_cnt_in_30d 
    ,sum(if(diff_days between 1 and 60, cancelled_order_cnt, 0))  as cancelled_order_cnt_in_60d 
    ,sum(if(diff_days between 1 and 90, cancelled_order_cnt, 0))  as cancelled_order_cnt_in_90d 
    ,sum(if(diff_days between 1 and 180, cancelled_order_cnt, 0)) as cancelled_order_cnt_in_180d
from ${SCHEMA}.dws_risk_shop_txn_ctime_df
where tz_type = 'local'
    and grass_region = upper('${region}')
    and grass_date = '${bizdate}'
group by 1
;

insert overwrite table ${SCHEMA}.dws_risk_shop_txn_df partition (tz_type='local', grass_region, grass_date)
select
    t1.shop_id
    ,t2.txn_days_in_180d
    ,t2.max_inactivate_days_in_180d
    ,t8.seller_shopee_age
    ,coalesce(t3.open_more_than_6m,-1) as open_more_than_6m
    ,coalesce(t3.open_more_than_12m,-1) as open_more_than_12m
    ,t6.ttl_order_in_3d
    ,t4.seller_confirmed_order_in_30d
    ,t4.seller_confirmed_order_in_31_60d
    ,t4.seller_confirmed_order_in_61_90d
    ,t4.seller_confirmed_order_in_91_120d
    ,t4.seller_confirmed_order_in_121_150d
    ,t4.seller_confirmed_order_in_151_180d
    ,t4.seller_confirmed_order_in_181_210d
    ,t4.seller_confirmed_order_in_211_240d
    ,t4.seller_confirmed_order_in_241_270d
    ,t4.seller_confirmed_order_in_271_300d
    ,t4.seller_confirmed_order_in_301_330d
    ,t4.seller_confirmed_order_in_331_360d
    ,t4.seller_confirmed_order_in_361_390d
    ,t6.gmv_in_3d
    ,t6.gmv_in_7d
    ,t6.gmv_in_8_14d
    ,t6.gmv_in_15_21d
    ,t6.gmv_in_22_28d
    ,t4.nmv_in_3d
    ,t4.nmv_in_7d
    ,t4.nmv_in_8_14d
    ,t4.nmv_in_15_21d
    ,t4.nmv_in_22_28d
    ,t4.nmv_in_30d
    ,t4.nmv_in_31_60d
    ,t4.nmv_in_61_90d
    ,t4.nmv_in_91_120d
    ,t4.nmv_in_121_150d
    ,t4.nmv_in_151_180d
    ,t4.nmv_in_181_210d
    ,t4.nmv_in_211_240d
    ,t4.nmv_in_241_270d
    ,t4.nmv_in_271_300d
    ,t4.nmv_in_301_330d
    ,t4.nmv_in_331_360d
    ,t4.nmv_in_361_390d
    ,t4.return_order_in_30d
    ,t4.return_order_in_31_60d
    ,t4.return_order_in_61_90d
    ,t4.return_order_in_91_120d
    ,t4.return_order_in_121_150d
    ,t4.return_order_in_151_180d
    ,t4.return_order_in_181_210d
    ,t4.return_order_in_211_240d
    ,t4.return_order_in_241_270d
    ,t4.return_order_in_271_300d
    ,t4.return_order_in_301_330d
    ,t4.return_order_in_331_360d
    ,t4.return_order_in_361_390d
    ,t4.return_gmv_in_30d
    ,t4.return_gmv_31_60d
    ,t4.return_gmv_in_61_90d
    ,t4.return_gmv_in_91_120d
    ,t4.return_gmv_in_121_150d
    ,t4.return_gmv_in_151_180d
    ,t4.return_gmv_in_181_210d
    ,t4.return_gmv_in_211_240d
    ,t4.return_gmv_in_241_270d
    ,t4.return_gmv_in_271_300d
    ,t4.return_gmv_in_301_330d
    ,t4.return_gmv_in_331_360d
    ,t4.return_gmv_in_361_390d
    ,t5.avg_nmv_last_12m_tag
    ,t5.avg_nmv_last_6m_tag
    ,t5.avg_nmv_last_3m_tag
    ,t5.min_nmv_last_12m_tag
    ,t5.min_nmv_last_6m_tag
    ,t5.min_nmv_last_3m_tag
    ,t5.has_order_month_last_3m
    ,t5.has_order_month_last_6m
    ,t5.cc_payment_ratio_last_3m
    ,t5.cc_payment_ratio_last_6m
    ,t6.distinct_buyer_in_3d
    ,t6.buyer_in_30d
    ,t6.buyer_in_31_60d
    ,t6.buyer_in_61_90d
    ,t6.buyer_in_91_120d
    ,t6.buyer_in_121_150d
    ,t6.buyer_in_151_180d
    ,t6.buyer_in_181_210d
    ,t6.buyer_in_211_240d
    ,t6.buyer_in_241_270d
    ,t6.buyer_in_271_300d
    ,t6.buyer_in_301_330d
    ,t6.buyer_in_331_360d
    ,t6.buyer_in_361_390d
    ,t7.cancellation_rate_l7d
    ,t7.cancellation_rate_l30d
    ,t4.create_order_cnt_in_7d      
    ,t4.create_order_cnt_in_15d     
    ,t4.create_order_cnt_in_30d     
    ,t4.create_order_cnt_in_60d     
    ,t4.create_order_cnt_in_90d     
    ,t4.create_order_cnt_in_180d    
    ,t4.cancelled_order_cnt_in_7d   
    ,t4.cancelled_order_cnt_in_15d  
    ,t4.cancelled_order_cnt_in_30d  
    ,t4.cancelled_order_cnt_in_60d  
    ,t4.cancelled_order_cnt_in_90d  
    ,t4.cancelled_order_cnt_in_180d 
    ,t1.grass_region
    ,t1.grass_date
from
(
    select
    shop_id
    ,grass_region
    ,grass_date
    from
    ${SCHEMA}.dim_risk_shop_df t1
    where tz_type = 'local'
    and grass_region = upper('${region}')
    and grass_date = date '${bizdate}'
) t1
left join txn_active_info t2
on t1.shop_id = t2.shop_id
left join shop_open_info t3
on t1.shop_id = t3.shop_id
left join txn_detail_info t4
on t1.shop_id = t4.shop_id
left join txn_monthly_info t5
on t1.shop_id = t5.shop_id
left join txn_buyer_info t6
on t1.shop_id = t6.shop_id
left join txn_buyer_cancel_info t7
on t1.shop_id = t7.shop_id
left join txn_seller_shopee_age t8
on t1.shop_id = t8.shop_id
;

create or replace view ${SCHEMA}.dws_risk_${region}_shop_txn_df as
select
    *
from ${SCHEMA}.dws_risk_shop_txn_df
where
    grass_region = upper('${region}')
;
