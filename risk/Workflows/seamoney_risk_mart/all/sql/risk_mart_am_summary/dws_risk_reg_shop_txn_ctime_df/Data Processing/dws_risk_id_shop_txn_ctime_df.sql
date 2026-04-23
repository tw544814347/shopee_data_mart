insert overwrite table ${SCHEMA}.dws_risk_shop_txn_ctime_df partition (tz_type='local', grass_region, grass_date)
select
    shop_id
    ,create_date
    ,terminal_flag
    ,diff_days
    ,diff_months
    ,gmv
    ,order_cnt
    ,cc_gmv
    ,nmv
    ,confirmed_order_cnt
    ,cc_nmv
    ,return_gmv
    ,return_order_cnt
    ,cancelled_order_cnt
    ,grass_region
    ,date('${bizdate}') as grass_date
from
(
    select
        shop_id
        ,date_format(create_datetime,'yyyy-MM-dd') as create_date
        ,if(grass_date=date('9999-01-01'), 0, 1) as terminal_flag
        ,date_add('${bizdate}',1)
        ,datediff(date_add('${bizdate}',1), date(date_format(create_datetime,'yyyy-MM-dd'))) as diff_days
        ,ceil(months_between(date_add('${bizdate}',1), date(date_format(create_datetime,'yyyy-MM-dd')))) as diff_months
        ,sum(gmv) as gmv
        ,count(order_id) as order_cnt
        ,sum(if(payment_method_id in (14,21,24,15,19), gmv, null)) as cc_gmv
        ,sum(if(is_net_order=1,gmv,null)) as nmv
        ,count(distinct if(is_net_order=1,order_id,null)) as confirmed_order_cnt
        ,sum(if(payment_method_id in (14,21,24,15,19) and is_net_order=1, gmv, null)) as cc_nmv
        ,sum(if(order_fe_status = 'COMPLETED' and order_be_status = 'RETURN_COMPLETED', gmv, null)) as return_gmv
        ,count(distinct if(order_fe_status = 'COMPLETED' and order_be_status = 'RETURN_COMPLETED',order_id,null)) as return_order_cnt
        ,count(distinct case when order_fe_status = 'CANCELLED' then order_id else null end) as cancelled_order_cnt
        ,grass_region
    from mp_order.dwd_order_all_ent_df__reg_s0_live
    where tz_type = 'local'
        and grass_region = upper('${region}')
        and grass_date >= date_add('${bizdate}',1) - interval '450' day
        and create_datetime between (date_add('${bizdate}',1) - interval '390' day) and date_add('${bizdate}',1)
    group by shop_id, date_format(create_datetime,'yyyy-MM-dd'), if(grass_date=date('9999-01-01'), 0, 1), grass_region
) t1
;

create or replace view ${SCHEMA}.dws_risk_${region}_shop_txn_ctime_df as
select
    *
from ${SCHEMA}.dws_risk_shop_txn_ctime_df
where
    grass_region = upper('${region}')
;