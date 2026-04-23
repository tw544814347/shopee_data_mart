create or replace temporary view buyer_device_complete_nd_spdf as
select
    base.buyer_id
    ,coalesce(user_device.shopee_df, tongdun.shopee_df, tongdun_history.shopee_df, '') as shopee_df
    ,base.shopee_device_id
    ,base.sz_dfp_device_id
    ,coalesce(tongdun.tongdun_device_id, tongdun_history.tongdun_device_id, '') as tongdun_device_id
    ,base.complete_physical_product_ord_cnt_1y
    ,base.complete_physical_product_ord_day_cnt_1y
    ,base.fas_timestamp_of_complete_physical_product_ord_1y
    ,base.grass_region
    ,date('${bizdate}') as grass_date
from (
    select
        buyer_id
        ,grass_region
        ,shopee_device_id
        ,sz_dfp_device_id
        ,sum(complete_physical_product_ord_cnt_1d) as complete_physical_product_ord_cnt_1y
        ,count(case
            when complete_physical_product_ord_cnt_1d > 0 then grass_date
            end) as complete_physical_product_ord_day_cnt_1y
        ,min(case
            when complete_physical_product_ord_cnt_1d > 0 then fas_timestamp_of_complete_physical_product_ord_1d
            end) as fas_timestamp_of_complete_physical_product_ord_1y
    from ${SCHEMA}.dws_risk_buyer_device_complete_di
    where grass_date <= date('${bizdate}')
      and grass_date > date_sub(date('${bizdate}'), 365)
      and tz_type = 'local'
      and grass_region = upper('${region}')
      and complete_physical_product_ord_cnt_1d > 0
      and shopee_device_id is not null
    group by
        buyer_id
        ,grass_region
        ,shopee_device_id
        ,sz_dfp_device_id
) base
left outer join (
    select
        case when trim(shopee_df) = '' then null else shopee_df end as shopee_df
        ,shopee_device_id
        ,hash_shopee_df
        ,case when trim(tongdun_device_id) = '' then null else tongdun_device_id end as tongdun_device_id
        ,grass_region
    from ${SCHEMA}.dim_risk_tongdun_device_mapping_tab
    where tz_type='local'
      and grass_region = upper('${region}')
) tongdun
  on base.grass_region = tongdun.grass_region and base.shopee_device_id = tongdun.hash_shopee_df
left outer join (
    select
        case when trim(shopee_df) = '' then null else shopee_df end as shopee_df
        ,shopee_device_id
        ,hash_shopee_df
        ,case when trim(tongdun_device_id) = '' then null else tongdun_device_id end as tongdun_device_id
    from ${SCHEMA}.dim_risk_tongdun_device_mapping_history_df
    where tz_type='local'
) tongdun_history
  on tongdun.tongdun_device_id is null and base.shopee_device_id = tongdun_history.hash_shopee_df
-- tongdun表在2023-02已停，部分数据shopee_df关联不到，从dim_risk_user_device_df取
left outer join (
    select
        user_id,
        case when trim(shopee_df) = '' then null else shopee_df end as shopee_df
        ,shopee_device_id
        ,hash_shopee_df
        ,case when trim(tongdun_device_id) = '' then null else tongdun_device_id end as tongdun_device_id,
        grass_region
    from ${SCHEMA}.dim_risk_user_device_df
    where tz_type='local'
      and grass_region = upper('${region}')
      and grass_date = '${bizdate}'
) user_device
  on base.buyer_id = user_device.user_id and base.shopee_device_id = user_device.hash_shopee_df;


insert overwrite table ${SCHEMA}.dws_risk_buyer_device_complete_df partition (tz_type='local', grass_region, grass_date)
select
    t1.buyer_id
    ,t1.shopee_df
    ,t1.shopee_device_id
    ,t1.tongdun_device_id
    ,t1.complete_physical_product_ord_cnt_1y
    ,t1.complete_physical_product_ord_day_cnt_1y
    ,t1.fas_timestamp_of_complete_physical_product_ord_1y
    ,coalesce(t1.sz_dfp_device_id, t2.sz_dfp_device_id, t3.sz_dfp_device_id) as sz_dfp_device_id
    ,spp.shopeepay_user_id
    ,t1.grass_region
    ,t1.grass_date
from buyer_device_complete_nd_spdf t1
left join
(
    select
        device_type
        ,device_id
        ,sz_dfp_device_id
        ,grass_region
    from ${SCHEMA}.dim_risk_sz_dfp_device_mapping_df
    where tz_type='local'
      and grass_date = date('${bizdate}')
      and grass_region = upper('${region}')
      and device_type = 'tddf'
) t2
on t1.tongdun_device_id = t2.device_id
left join
(
    select
        device_type
        ,device_id
        ,sz_dfp_device_id
        ,grass_region
    from ${SCHEMA}.dim_risk_sz_dfp_device_mapping_df
    where tz_type='local'
      and grass_date = date('${bizdate}')
      and grass_region = upper('${region}')
      and device_type = 'spdf'
) t3
on t1.shopee_device_id = t3.device_id
left join (
    select
    *
    from risk.dim_risk_${region}_sp_to_spp_id_mapping_df
    where grass_date = '${ds}'
) spp 
on (t1.buyer_id=spp.shopee_user_id and t1.grass_date>=spp.create_date)
;

create or replace view ${SCHEMA}.dws_risk_${region}_buyer_device_complete_df as
select
    *
from ${SCHEMA}.dws_risk_buyer_device_complete_df
where
    grass_region = upper('${region}')
;