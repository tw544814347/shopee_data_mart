--drop table if exists ${SCHEMA}.dws_risk_shop_txn_df;
create external table if not exists ${SCHEMA}.dws_risk_shop_txn_df
(
shop_id bigint comment 'unique id of the shop'
,txn_days_in_180d bigint comment 'number of days in last 180 days that the shop has transactions'
,max_inactivate_days_in_180d bigint comment 'the shop maximum inactive days in last 180 days'
,seller_shopee_age bigint comment 'The number of days since the merchant placed the first order'
,open_more_than_6m bigint comment 'Whether the shop has opened for more than 6 month'
,open_more_than_12m bigint comment 'Whether the shop has opened for more than 1 year'
,ttl_order_in_3d bigint comment 'total number of order in last 3 days'
,seller_confirmed_order_in_30d bigint comment 'number of confirmed order in 30 days'
,seller_confirmed_order_in_31_60d bigint comment 'number of confirmed order in 31_60 days'
,seller_confirmed_order_in_61_90d bigint comment 'number of confirmed order in 61_90 days'
,seller_confirmed_order_in_91_120d bigint comment 'number of confirmed order in 91_120 days'
,seller_confirmed_order_in_121_150d bigint comment 'number of confirmed order in 121_150 days'
,seller_confirmed_order_in_151_180d bigint comment 'number of confirmed order in 151_180 days'
,seller_confirmed_order_in_181_210d bigint comment 'number of confirmed order in 181_210 days'
,seller_confirmed_order_in_211_240d bigint comment 'number of confirmed order in 211_240 days'
,seller_confirmed_order_in_241_270d bigint comment 'number of confirmed order in 241_270 days'
,seller_confirmed_order_in_271_300d bigint comment 'number of confirmed order in 271_300 days'
,seller_confirmed_order_in_301_330d bigint comment 'number of confirmed order in 301_330 days'
,seller_confirmed_order_in_331_360d bigint comment 'number of confirmed order in 331_360 days'
,seller_confirmed_order_in_361_390d bigint comment 'number of confirmed order in 361_390 days'
,gmv_in_3d decimal(30,10) comment 'gmv in last 3 days'
,gmv_in_7d decimal(30,10) comment 'gmv in recent 7 days'
,gmv_in_8_14d decimal(30,10) comment 'gmv in last 8-14 days'
,gmv_in_15_21d decimal(30,10) comment 'gmv in last 15-21 days'
,gmv_in_22_28d decimal(30,10) comment 'gmv in last 22-28 days'
,gmv_usd_in_7d_pay decimal(30,10) comment 'gmv_usd in last 7 pay datetime days'

,nmv_in_3d decimal(30,10) comment 'nmv in last 3 days'
,nmv_in_7d decimal(30,10) comment 'nmv in recent 7 days'
,nmv_in_8_14d decimal(30,10) comment 'nmv in last 8-14 days'
,nmv_in_15_21d decimal(30,10) comment 'nmv in last 15-21 days'
,nmv_in_22_28d decimal(30,10) comment 'nmv in last 22-28 days'
,nmv_in_30d decimal(30,10) comment 'nmv in recent 30days'
,nmv_in_31_60d decimal(30,10) comment 'nmv in recent 31_60 days'
,nmv_in_61_90d decimal(30,10) comment 'nmv in recent 61_90 days'
,nmv_in_91_120d decimal(30,10) comment 'nmv in recent 91_120 days'
,nmv_in_121_150d decimal(30,10) comment 'nmv in recent 121_150 days'
,nmv_in_151_180d decimal(30,10) comment 'nmv in recent 151_180 days'
,nmv_in_181_210d decimal(30,10) comment 'nmv in recent 181_210 days'
,nmv_in_211_240d decimal(30,10) comment 'nmv in recent 211_240 days'
,nmv_in_241_270d decimal(30,10) comment 'nmv in recent 241_270 days'
,nmv_in_271_300d decimal(30,10) comment 'nmv in recent 271_300 days'
,nmv_in_301_330d decimal(30,10) comment 'nmv in recent 301 - 330 days'
,nmv_in_331_360d decimal(30,10) comment 'nmv in recent 331 - 360days'
,nmv_in_361_390d decimal(30,10) comment 'nmv in recent 361 - 390 days'
,nmv_usd_in_7d_pay decimal(30,10) comment 'nmv_usd in recent 7 pay days'
,nmv_usd_in_30d_pay decimal(30,10) comment 'nmv_usd in recent 1month pay days'
,nmv_usd_in_60d_pay decimal(30,10) comment 'nmv_usd in recent 2month pay days'
,nmv_usd_in_90d_pay decimal(30,10) comment 'nmv_usd in recent 3month pay days'
,nmv_usd_in_180d_pay decimal(30,10) comment 'nmv_usd in recent 6month pay days'

,return_order_in_30d bigint comment 'number of return order in 30 days'
,return_order_in_31_60d bigint comment 'number of return order in 31_60 days'
,return_order_in_61_90d bigint comment 'number of return order in 61_90 days'
,return_order_in_91_120d bigint comment 'number of return order in 91_120 days'
,return_order_in_121_150d bigint comment 'number of return order in 121_150 days'
,return_order_in_151_180d bigint comment 'number of return order in 151_180 days'
,return_order_in_181_210d bigint comment 'number of return order in 181_210 days'
,return_order_in_211_240d bigint comment 'number of return order in 211_240 days'
,return_order_in_241_270d bigint comment 'number of return order in 241_270 days'
,return_order_in_271_300d bigint comment 'number of return order in 271_300 days'
,return_order_in_301_330d bigint comment 'number of return order in 301_330 days'
,return_order_in_331_360d bigint comment 'number of return order in 331_360 days'
,return_order_in_361_390d bigint comment 'number of return order in 361_390 days'
,return_gmv_in_30d decimal(30,10) comment 'gmv of return order in 30 days'
,return_gmv_31_60d decimal(30,10) comment 'gmv of return order in 31_60 days'
,return_gmv_in_61_90d decimal(30,10) comment 'gmv of return order in 61_90 days'
,return_gmv_in_91_120d decimal(30,10) comment 'gmv of return order in 91_120 days'
,return_gmv_in_121_150d decimal(30,10) comment 'gmv of return order in 121_150 days'
,return_gmv_in_151_180d decimal(30,10) comment 'gmv of return order in 151_180 days'
,return_gmv_in_181_210d decimal(30,10) comment 'gmv of return order in 181_210 days'
,return_gmv_in_211_240d decimal(30,10) comment 'gmv of return order in 211_240 days'
,return_gmv_in_241_270d decimal(30,10) comment 'gmv of return order in 241_270 days'
,return_gmv_in_271_300d decimal(30,10) comment 'gmv of return order in 271_300 days'
,return_gmv_in_301_330d decimal(30,10) comment 'gmv of return order in 301_330 days'
,return_gmv_in_331_360d decimal(30,10) comment 'gmv of return order in 331_360 days'
,return_gmv_in_361_390d decimal(30,10) comment 'gmv of return order in 361_390 days'
,avg_nmv_last_12m_tag decimal(30,10) comment 'average monthly nmv in last 12 month'
,avg_nmv_last_6m_tag decimal(30,10) comment 'average monthly nmv in last 6 month'
,avg_nmv_last_3m_tag decimal(30,10) comment 'average monthly nmv in last 3 month'
,min_nmv_last_12m_tag decimal(30,10) comment 'minimum monthly nmv in last 12 month'
,min_nmv_last_6m_tag decimal(30,10) comment 'minimum monthly nmv in last 6 month'
,min_nmv_last_3m_tag decimal(30,10) comment 'minimum monthly nmv in last 3 month'
,has_order_month_last_3m bigint comment 'number of month that has txn in last 3 month'
,has_order_month_last_6m bigint comment 'number of month that has txn in last 6 month'
,cc_payment_ratio_last_3m decimal(30,10) comment 'percentage of txns that paid by credit payment method in last 3 month'
,cc_payment_ratio_last_6m decimal(30,10) comment 'percentage of txns that paid by credit payment method in last 6 month'
,distinct_buyer_in_3d bigint comment 'total number of unique buyer in last 3 days'
,buyer_in_30d bigint comment 'number of distinct buyer in 30 days'
,buyer_in_31_60d bigint comment 'number of distinct buyer in 31_60 days'
,buyer_in_61_90d bigint comment 'number of distinct buyer in 61_90 days'
,buyer_in_91_120d bigint comment 'number of distinct buyer in 91_120 days'
,buyer_in_121_150d bigint comment 'number of distinct buyer in 121_150 days'
,buyer_in_151_180d bigint comment 'number of distinct buyer in 151_180 days'
,buyer_in_181_210d bigint comment 'number of distinct buyer in 181_210 days'
,buyer_in_211_240d bigint comment 'number of distinct buyer in 211_240 days'
,buyer_in_241_270d bigint comment 'number of distinct buyer in 241_270 days'
,buyer_in_271_300d bigint comment 'number of distinct buyer in 271_300 days'
,buyer_in_301_330d bigint comment 'number of distinct buyer in 301_330 days'
,buyer_in_331_360d bigint comment 'number of distinct buyer in 331_360 days'
,buyer_in_361_390d bigint comment 'number of distinct buyer in 361_390 days'
,cancellation_rate_l7d decimal(10,4) comment 'The seller order cancellation rate in the last 7 days'
,cancellation_rate_l30d decimal(10,4) comment 'The seller order cancellation rate in the last 30 days'
,create_order_cnt_in_7d        bigint  comment 'number of create order in 7days' 
,create_order_cnt_in_15d       bigint  comment 'number of create order in 15days'    
,create_order_cnt_in_30d       bigint  comment 'number of create order in 30days'    
,create_order_cnt_in_60d       bigint  comment 'number of create order in 60days'    
,create_order_cnt_in_90d       bigint  comment 'number of create order in 90days'    
,create_order_cnt_in_180d      bigint  comment 'number of create order in 180days'    
,cancelled_order_cnt_in_7d     bigint  comment 'number of cancel order in 7days'   
,cancelled_order_cnt_in_15d    bigint  comment 'number of cancel order in 15days'   
,cancelled_order_cnt_in_30d    bigint  comment 'number of cancel order in 30days'   
,cancelled_order_cnt_in_60d    bigint  comment 'number of cancel order in 60days'   
,cancelled_order_cnt_in_90d    bigint  comment 'number of cancel order in 90days'   
,cancelled_order_cnt_in_180d   bigint  comment 'number of cancel order in 180days'   
)
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
comment 'Tag:risk summary table'
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_shop_txn_df';
--msck repair table ${SCHEMA}.dws_risk_shop_txn_df;

create or replace temporary view txn_escrow_paid as
select shop_id
       ,buyer_id
       ,order_id
       ,gmv
       ,gmv_usd
       ,nmv
       ,nmv_usd
       ,is_net_order
       ,payment_method_id
       ,create_datetime
       ,escrow_paid_datetime
       ,pay_datetime
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

create or replace temporary view pay_day_nmv_gmv_view as
SELECT shop_id
       ,sum(case when pay_day_diff between 1 and 7 then nvl(gmv_usd,0) else 0 end )   as gmv_usd_in_7d_pay
       ,sum(case when pay_day_diff between 1 and 7 then nvl(nmv_usd,0) else 0 end )   as nmv_usd_in_7d_pay
       ,sum(case when pay_day_diff between 1 and 30 then nvl(nmv_usd,0) else 0 end )  as nmv_usd_in_30d_pay
       ,sum(case when pay_day_diff between 1 and 60 then nvl(nmv_usd,0) else 0 end )  as nmv_usd_in_60d_pay
       ,sum(case when pay_day_diff between 1 and 90 then nvl(nmv_usd,0) else 0 end )  as nmv_usd_in_90d_pay
       ,sum(case when pay_day_diff between 1 and 180 then nvl(nmv_usd,0) else 0 end ) as nmv_usd_in_180d_pay
from
(
    select
        shop_id
        ,datediff('${bizdate}', date(date_format(pay_datetime,'yyyy-MM-dd'))) as pay_day_diff
        ,sum(nvl(gmv_usd,0)) as gmv_usd
        ,sum(nvl(nmv_usd,0)) as nmv_usd
    from txn_escrow_paid
    group by 1,2
)
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
    ,t9.gmv_usd_in_7d_pay

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
    ,t9.nmv_usd_in_7d_pay
    ,t9.nmv_usd_in_30d_pay
    ,t9.nmv_usd_in_60d_pay
    ,t9.nmv_usd_in_90d_pay
    ,t9.nmv_usd_in_180d_pay

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
left join pay_day_nmv_gmv_view t9
on t1.shop_id = t9.shop_id 
;


create or replace view ${SCHEMA}.dws_risk_${region}_shop_txn_df as
select
    *
from ${SCHEMA}.dws_risk_shop_txn_df
where
    grass_region = upper('${region}')
;