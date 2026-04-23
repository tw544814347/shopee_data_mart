insert overwrite ${SCHEMA}.ads_risk_${region_lower}_seller_feature_df partition (grass_date='${ds}')
select 
    SUBSTRING(MD5(t1.seller_id), 1, 2)||'_'||t1.seller_id as row_key
    ,t1.seller_id
    ,t2.total_order_count_7d
    ,t2.total_order_count_15d
    ,t2.total_order_count_30d
    ,t2.total_gmv_paid_7d
    ,t2.total_gmv_paid_15d
    ,t2.total_gmv_paid_30d
    ,coalesce(t2.total_gmv_paid_7d/t2.total_order_count_7d, -9999) as   abs_paid_7d

    ,t2.total_gmv_paid_15d/t2.total_order_count_15d as   abs_paid_15d
    ,t2.total_gmv_paid_30d/t2.total_order_count_30d as   abs_paid_30d
    ,t2.refund_gmv_paid_7d
    ,t2.refund_gmv_paid_15d
    ,t2.refund_gmv_paid_30d
    ,t2.refund_gmv_paid_7d/t2.total_gmv_paid_7d as gmv_refund_rate_7d
    ,t2.refund_gmv_paid_15d/t2.total_gmv_paid_15d as gmv_refund_rate_15d
    ,t2.refund_gmv_paid_30d/t2.total_gmv_paid_30d as gmv_refund_rate_30d
    ,t1.shop_type    
    
-- added by wei.tao
    ,coalesce(t2.total_gmv_paid_6d/t2.total_order_count_6d, -9999) as   abs_paid_6d
    ,coalesce(t2.total_gmv_paid_5d/t2.total_order_count_5d, -9999) as   abs_paid_5d
    ,coalesce(t2.total_gmv_paid_4d/t2.total_order_count_4d, -9999) as   abs_paid_4d
    ,coalesce(t2.total_gmv_paid_3d/t2.total_order_count_3d, -9999) as   abs_paid_3d
    ,coalesce(t2.total_gmv_paid_2d/t2.total_order_count_2d, -9999) as   abs_paid_2d
    ,coalesce(t2.total_gmv_paid_1d/t2.total_order_count_1d, -9999) as   abs_paid_1d

    ,coalesce(t2.total_gmv_paid_7d_7d/t2.total_order_count_7d_7d, -9999) as   abs_paid_7d_7d
    ,coalesce(t2.total_gmv_paid_6d_7d/t2.total_order_count_6d_7d, -9999) as   abs_paid_6d_7d
    ,coalesce(t2.total_gmv_paid_5d_7d/t2.total_order_count_5d_7d, -9999) as   abs_paid_5d_7d
    ,coalesce(t2.total_gmv_paid_4d_7d/t2.total_order_count_4d_7d, -9999) as   abs_paid_4d_7d
    ,coalesce(t2.total_gmv_paid_3d_7d/t2.total_order_count_3d_7d, -9999) as   abs_paid_3d_7d
    ,coalesce(t2.total_gmv_paid_2d_7d/t2.total_order_count_2d_7d, -9999) as   abs_paid_2d_7d
    ,coalesce(t2.total_gmv_paid_1d_7d/t2.total_order_count_1d_7d, -9999) as   abs_paid_1d_7d

    ,coalesce((t2.total_gmv_paid_7d/t2.total_order_count_7d) / (t2.total_gmv_paid_7d_7d/t2.total_order_count_7d_7d), -9999) as abs_paid_7d_wow
    ,coalesce((t2.total_gmv_paid_6d/t2.total_order_count_6d) / (t2.total_gmv_paid_6d_7d/t2.total_order_count_6d_7d), -9999) as abs_paid_6d_wow
    ,coalesce((t2.total_gmv_paid_5d/t2.total_order_count_5d) / (t2.total_gmv_paid_5d_7d/t2.total_order_count_5d_7d), -9999) as abs_paid_5d_wow
    ,coalesce((t2.total_gmv_paid_4d/t2.total_order_count_4d) / (t2.total_gmv_paid_4d_7d/t2.total_order_count_4d_7d), -9999) as abs_paid_4d_wow
    ,coalesce((t2.total_gmv_paid_3d/t2.total_order_count_3d) / (t2.total_gmv_paid_3d_7d/t2.total_order_count_3d_7d), -9999) as abs_paid_3d_wow
    ,coalesce((t2.total_gmv_paid_2d/t2.total_order_count_2d) / (t2.total_gmv_paid_2d_7d/t2.total_order_count_2d_7d), -9999) as abs_paid_2d_wow
    ,coalesce((t2.total_gmv_paid_1d/t2.total_order_count_1d) / (t2.total_gmv_paid_1d_7d/t2.total_order_count_1d_7d), -9999) as abs_paid_1d_wow
--

from (
    select
        cast(user_id as string) as seller_id
        ,case
            when is_official_shop = 1 then 'official'
            when is_preferred_shop = 1 then 'preferred'
            when is_cb_shop = 1 then 'cb'
            when is_managed_shop = 1 then ' managed'
            else null end as shop_type
    from mp_user.dim_shop__${region_lower}_s0_live
    where grass_region = '${region_upper}'
    and grass_date ='${ds}'
)t1 
left join (
    select
        cast(seller_id as string) as seller_id
        ,count(distinct if(is_7d, order_id, null)) as total_order_count_7d
        ,count(distinct if(is_15d, order_id, null)) as total_order_count_15d
        ,count(distinct if(is_30d, order_id, null)) as total_order_count_30d
        ,sum(if(is_7d, gmv, 0)) as total_gmv_paid_7d 
        ,sum(if(is_15d, gmv, 0)) as total_gmv_paid_15d
        ,sum(if(is_30d, gmv, 0)) as total_gmv_paid_30d
        ,sum(if(is_7d and is_refund, gmv, 0))  as refund_gmv_paid_7d
        ,sum(if(is_15d and is_refund, gmv, 0)) as refund_gmv_paid_15d
        ,sum(if(is_30d and is_refund, gmv, 0)) as refund_gmv_paid_30d

-- added by wei.tao
        ,sum(if(is_6d, gmv, 0)) as total_gmv_paid_6d -- sum_gmv
        ,sum(if(is_5d, gmv, 0)) as total_gmv_paid_5d
        ,sum(if(is_4d, gmv, 0)) as total_gmv_paid_4d
        ,sum(if(is_3d, gmv, 0)) as total_gmv_paid_3d
        ,sum(if(is_2d, gmv, 0)) as total_gmv_paid_2d
        ,sum(if(is_1d, gmv, 0)) as total_gmv_paid_1d

        ,count(distinct if(is_6d, order_id, null)) as total_order_count_6d -- count_order
        ,count(distinct if(is_5d, order_id, null)) as total_order_count_5d
        ,count(distinct if(is_4d, order_id, null)) as total_order_count_4d
        ,count(distinct if(is_3d, order_id, null)) as total_order_count_3d
        ,count(distinct if(is_2d, order_id, null)) as total_order_count_2d
        ,count(distinct if(is_1d, order_id, null)) as total_order_count_1d

        ,sum(if(is_7d_7d, gmv, 0)) as total_gmv_paid_7d_7d
        ,sum(if(is_6d_7d, gmv, 0)) as total_gmv_paid_6d_7d
        ,sum(if(is_5d_7d, gmv, 0)) as total_gmv_paid_5d_7d
        ,sum(if(is_4d_7d, gmv, 0)) as total_gmv_paid_4d_7d
        ,sum(if(is_3d_7d, gmv, 0)) as total_gmv_paid_3d_7d
        ,sum(if(is_2d_7d, gmv, 0)) as total_gmv_paid_2d_7d
        ,sum(if(is_1d_7d, gmv, 0)) as total_gmv_paid_1d_7d

        ,count(distinct if(is_7d_7d, order_id, null)) as total_order_count_7d_7d
        ,count(distinct if(is_6d_7d, order_id, null)) as total_order_count_6d_7d
        ,count(distinct if(is_5d_7d, order_id, null)) as total_order_count_5d_7d
        ,count(distinct if(is_4d_7d, order_id, null)) as total_order_count_4d_7d
        ,count(distinct if(is_3d_7d, order_id, null)) as total_order_count_3d_7d
        ,count(distinct if(is_2d_7d, order_id, null)) as total_order_count_2d_7d
        ,count(distinct if(is_1d_7d, order_id, null)) as total_order_count_1d_7d
-- 

    from (
        select 
            seller_id
            ,order_id
            ,shipping_confirm_datetime
            ,gmv
            ,has_return_item = 1 or (order_be_status in (${br_exclude_order_status}7, 8, 9, 10) and logistics_status_id=6) as is_refund
            ,date(shipping_confirm_datetime) between '${ds}' - interval '29' day and '${ds}' as is_30d --by wei.tao
            ,date(shipping_confirm_datetime) between '${ds}' - interval '14' day and '${ds}' as is_15d --by wei.tao
            ,date(shipping_confirm_datetime) between '${ds}' - interval '6' day and '${ds}' as is_7d --by wei.tao

-- added by wei.tao
            ,date(shipping_confirm_datetime) between '${ds}' - interval '5' day and '${ds}' as is_6d
            ,date(shipping_confirm_datetime) between '${ds}' - interval '4' day and '${ds}' as is_5d
            ,date(shipping_confirm_datetime) between '${ds}' - interval '3' day and '${ds}' as is_4d
            ,date(shipping_confirm_datetime) between '${ds}' - interval '2' day and '${ds}' as is_3d
            ,date(shipping_confirm_datetime) between '${ds}' - interval '1' day and '${ds}' as is_2d
            ,date(shipping_confirm_datetime) between '${ds}' and '${ds}' as is_1d

            ,date(shipping_confirm_datetime) between '${ds}' - interval '13' day and '${ds}' - interval '7' day as is_7d_7d
            ,date(shipping_confirm_datetime) between '${ds}' - interval '12' day and '${ds}' - interval '7' day as is_6d_7d
            ,date(shipping_confirm_datetime) between '${ds}' - interval '11' day and '${ds}' - interval '7' day as is_5d_7d
            ,date(shipping_confirm_datetime) between '${ds}' - interval '10' day and '${ds}' - interval '7' day as is_4d_7d
            ,date(shipping_confirm_datetime) between '${ds}' - interval '9' day and '${ds}' - interval '7' day as is_3d_7d
            ,date(shipping_confirm_datetime) between '${ds}' - interval '8' day and '${ds}' - interval '7' day as is_2d_7d
            ,date(shipping_confirm_datetime) between '${ds}' - interval '7' day and '${ds}' - interval '7' day as is_1d_7d
--

        from mp_order.dwd_order_all_ent_df__${region_lower}_s0_live
        where grass_region = '${region_upper}'
        and grass_date >= '${ds}' - interval '30' day
        )t21
    group by 
        seller_id
)t2 
on t1.seller_id=t2.seller_id;


