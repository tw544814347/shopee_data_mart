--drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df (
    platform_user_id string comment 'platform_user_id'
    ,completed_order_cnt_360d bigint comment 'completed_order_cnt_360d'
)
partitioned by
    (grass_date string comment "YYYY-MM-DD") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/dws/dws_risk_aio_user_txn_mp_order_complete_df/garss_region=${upper_region}'
;
--msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df;

create temporary view user_full_list as (
    select
        platform_user_id
    from ${SCHEMA}.dim_risk_sg_user_info_df
    where grass_date = '${grass_date}'
)
;

create temporary view orders_base as (
    select
        t1.platform_user_id
        ,t1.order_id
        ,from_unixtime(t1.shipping_confirm_timestamp - 3600) as shipping_confirm_time
        ,month(
            cast(from_unixtime(t1.shipping_confirm_timestamp - 3600) as date)
        ) as month_1
    from risk.dwd_risk_sg_user_txn_mp_order_complete_df as t1
    where
        grass_date = '${grass_date}'
        and t1.shipping_confirm_timestamp is not null
        and t1.is_bi_excluded = 0
        and t1.has_return_item = 0
        and t1.is_net_order = 1
        and datediff(
            cast(from_unixtime(t1.shipping_confirm_timestamp - 3600) as date)
            ,current_date
        ) between 0 and 360
)
;

create temporary view orders_month as (
    select
        platform_user_id
        ,count(distinct month_1) as completed_order_cnt_360d
    from orders_base
    group by platform_user_id
)
;

insert overwrite table
    ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df partition (grass_date = '${ds}')
select
    t1.platform_user_id
    ,coalesce(t2.completed_order_cnt_360d, 0) as completed_order_cnt_360d
from
    user_full_list t1
    left join orders_month t2 on t1.platform_user_id = t2.platform_user_id
;