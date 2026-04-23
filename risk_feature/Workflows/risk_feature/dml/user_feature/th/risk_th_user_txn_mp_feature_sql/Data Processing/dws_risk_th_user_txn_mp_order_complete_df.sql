--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-10-30
-- Theme Domain：       feature station 迁移
-- Description:         feature station 迁移
-- Data Granularity:    https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit?gid=524192113#gid=524192113
-- 变更历史
--********************************************************************--

drop table if exists ${SCHEMA}.dws_risk_th_user_txn_mp_order_complete_df;
create external table if not exists ${SCHEMA}.dws_risk_th_user_txn_mp_order_complete_df (
    shopee_user_id                                    string     comment 'shopee user id'
    ,platform_user_id                                  string     comment 'platform user id'
    ,uw_cod_percent_360d                               double     comment 'COD confirmed order ratio in last 360 days (cod_order_cnt / total_confirmed_order_cnt)'
    ,uw_cod_percent_90d                                double     comment 'COD confirmed order ratio in last 90 days (cod_order_cnt / total_confirmed_order_cnt)'
    ,uw_abs_usd_360d                                   double     comment 'average basket size in USD in last 360 days (confirmed_gmv_usd / confirmed_order_cnt)'
    ,uw_cod_percent_180d                               double     comment 'COD confirmed order ratio in last 180 days (cod_order_cnt / total_confirmed_order_cnt)'
    ,uw_confirmed_gmv_usd_90d_spl_exclude              double     comment 'confirmed GMV in USD in last 90 days, excluding SPL (payment_channel=others only)'
    ,completed_order_avg_duration_1m                   bigint     comment 'average completed order duration in last 1 month (30 days)'
    ,completed_order_avg_duration_3m                   bigint     comment 'average completed order duration in last 3 months (90 days)'
    ,completed_order_avg_duration_6m                   bigint     comment 'average completed order duration in last 6 months (180 days)'
    ,last3_completed_order_avg_duration_3m             bigint     comment 'average completed order duration in last 3 months (90 days) for the last 3 completed orders'
)
partitioned by (
    grass_date                                        string     comment 'Partition, YYYY-MM-DD'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_aio_user_txn_mp_order_complete_df/grass_region=TH';
msck repair table ${SCHEMA}.dws_risk_th_user_txn_mp_order_complete_df;

create or replace temporary view uw_confirmed_order_feature as
select 
t1.platform_user_id
,cast(t1.cod_confirmed_order_90d as double)/ (case when t1.uw_confirmed_order_90d=0 then null else t1.uw_confirmed_order_90d end)     as uw_cod_percent_90d
,cast(t1.cod_confirmed_order_180d as double) / (case when t1.uw_confirmed_order_180d=0 then null else t1.uw_confirmed_order_180d end) as uw_cod_percent_180d
,cast(t1.cod_confirmed_order_360d as double) / (case when t1.uw_confirmed_order_360d=0 then null else t1.uw_confirmed_order_360d end) as uw_cod_percent_360d
,t1.uw_confirmed_gmv_usd_360d/(case when t1.uw_confirmed_order_360d=0 then null else t1.uw_confirmed_order_360d end)                  as uw_abs_usd_360d
,t1.uw_confirmed_gmv_usd_90d_spl_exclude
from(
    select 
    platform_user_id
    ,count(distinct case when to_date(shipping_confirm_time_local)>=date_sub('${grass_date}',90) and to_date(shipping_confirm_time_local)<=date_add('${grass_date}',1) and payment_method_id = 6 then order_id else null end) as  cod_confirmed_order_90d
    ,count(distinct case when to_date(shipping_confirm_time_local)>=date_sub('${grass_date}',180) and to_date(shipping_confirm_time_local)<=date_add('${grass_date}',1) and payment_method_id = 6 then order_id else null end) as cod_confirmed_order_180d
    ,count(distinct case when to_date(shipping_confirm_time_local)>=date_sub('${grass_date}',360) and to_date(shipping_confirm_time_local)<=date_add('${grass_date}',1) and payment_method_id = 6 then order_id else null end) as cod_confirmed_order_360d
    ,count(distinct case when to_date(shipping_confirm_time_local)>=date_sub('${grass_date}',90) and to_date(shipping_confirm_time_local)<=date_add('${grass_date}',1) then order_id else null end) as  uw_confirmed_order_90d
    ,count(distinct case when to_date(shipping_confirm_time_local)>=date_sub('${grass_date}',180) and to_date(shipping_confirm_time_local)<=date_add('${grass_date}',1) then order_id else null end) as uw_confirmed_order_180d
    ,count(distinct case when to_date(shipping_confirm_time_local)>=date_sub('${grass_date}',360) and to_date(shipping_confirm_time_local)<=date_add('${grass_date}',1) then order_id else null end) as uw_confirmed_order_360d
    ,sum(case when to_date(shipping_confirm_time_local)>=date_sub('${grass_date}',360) and to_date(shipping_confirm_time_local)<=date_add('${grass_date}',1) then  gmv_usd else 0 end) as uw_confirmed_gmv_usd_360d
    ,sum(case when to_date(shipping_confirm_time_local)>=date_sub('${grass_date}',90) and to_date(shipping_confirm_time_local)<=date_add('${grass_date}',1) and payment_channel = 'others' then gmv_usd else 0 end ) as uw_confirmed_gmv_usd_90d_spl_exclude
    from ${SCHEMA}.dwd_risk_th_user_txn_mp_order_complete_df
    where grass_date ='${grass_date}'
    and shipping_confirm_timestamp is not null 
    and order_be_status_id in (4, 11, 12, 13, 14, 15)
    and is_bi_excluded = 0
    and has_return_item = 0
    and is_net_order = 1 
    group by platform_user_id
) t1
;

create or replace temporary view complete_order_feature
as
select  buyer_id as platform_user_id
        ,sum(if(date_diff between 0 and 30, complete_duration, 0)) as completed_order_duration_1m
        ,sum(if(date_diff between 0 and 90, complete_duration, 0)) as completed_order_duration_3m
        ,sum(if(date_diff between 0 and 180, complete_duration, 0)) as completed_order_duration_6m
        ,count(distinct if(date_diff between 0 and 1, order_id, null)) as completed_order_cnt_1d
        ,count(distinct if(date_diff between 0 and 7, order_id, null)) as completed_order_cnt_7d
        ,count(distinct if(date_diff between 0 and 30, order_id, null)) as completed_order_cnt_1m
        ,count(distinct if(date_diff between 0 and 90, order_id, null)) as completed_order_cnt_3m
        ,count(distinct if(date_diff between 0 and 180, order_id, null)) as completed_order_cnt_6m
        ,count(distinct if(date_diff between 0 and 30 and big_shop_flag = 1, order_id, null)) as big_shop_completed_order_cnt_1m
        ,count(distinct if(date_diff between 0 and 90 and big_shop_flag = 1, order_id, null)) as big_shop_completed_order_cnt_3m
        ,count(distinct if(date_diff between 0 and 180 and big_shop_flag = 1, order_id, null)) as big_shop_completed_order_cnt_6m
        ,count(distinct if(date_diff between 0 and 30 and is_physical_product_order = 'N', order_id, null)) as virtual_completed_order_cnt_1m
        ,count(distinct if(date_diff between 0 and 90 and is_physical_product_order = 'N', order_id, null)) as virtual_completed_order_cnt_3m
        ,count(distinct if(date_diff between 0 and 180 and is_physical_product_order = 'N', order_id, null)) as virtual_completed_order_cnt_6m
        ,sum(case when last_3m_rn <= 3 then complete_duration else 0 end) as last3_completed_order_duration_3m
from    (
    select  buyer_id
            ,order_id
            ,complete_date
            ,complete_duration
            ,big_shop_flag
            ,is_physical_product_order
            ,case   when datediff(date('${grass_date}'), complete_date) BETWEEN 0 AND 90 then row_number() over(partition by buyer_id order by complete_timestamp desc)
                    else 99
             end last_3m_rn
            ,datediff(date('${grass_date}'), complete_date) as date_diff
    from    risk.dwd_risk_order_complete_di a
    where   tz_type = 'local'
      and   grass_region = '${grass_region}'
      and   grass_date >= date_sub('${grass_date}', 180)
      and   grass_date <= date'${grass_date}'
) a
group by buyer_id
;

create or replace temporary view completed_order_avg_duration as
select 
    platform_user_id
    ,case when completed_order_cnt_1m>0 then completed_order_duration_1m/completed_order_cnt_1m else 0 end                                          as completed_order_avg_duration_1m
    ,case when completed_order_cnt_3m>0 then completed_order_duration_3m/completed_order_cnt_3m else 0 end                                          as completed_order_avg_duration_3m
    ,case when completed_order_cnt_6m>0 then completed_order_duration_6m/completed_order_cnt_6m else 0 end                                          as completed_order_avg_duration_6m
    ,case when completed_order_cnt_3m>0 then last3_completed_order_duration_3m/if(completed_order_cnt_3m > 3, 3, completed_order_cnt_3m) else 0 end as last3_completed_order_avg_duration_3m
from complete_order_feature
;

insert overwrite table ${SCHEMA}.dws_risk_th_user_txn_mp_order_complete_df partition(grass_date ='${grass_date}')
select
    t1.platform_user_id as shopee_user_id
    ,t1.platform_user_id
    ,t2.uw_cod_percent_360d
    ,t2.uw_cod_percent_90d
    ,t2.uw_abs_usd_360d
    ,t2.uw_cod_percent_180d
    ,t2.uw_confirmed_gmv_usd_90d_spl_exclude
    ,t3.completed_order_avg_duration_1m
    ,t3.completed_order_avg_duration_3m
    ,t3.completed_order_avg_duration_6m
    ,t3.last3_completed_order_avg_duration_3m
from
(
    select
        user_id as platform_user_id
    from mp_user.dim_user__reg_s0_live
    where
        tz_type = 'local'
        and grass_region = '${grass_region}'
        and grass_date = '${grass_date}'
) t1
left join uw_confirmed_order_feature t2
on t1.platform_user_id = t2.platform_user_id
left join completed_order_avg_duration t3
on t1.platform_user_id = t3.platform_user_id
;
