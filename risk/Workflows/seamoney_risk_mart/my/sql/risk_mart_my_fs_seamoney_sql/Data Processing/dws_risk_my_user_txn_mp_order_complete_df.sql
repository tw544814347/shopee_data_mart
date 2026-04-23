--drop table if exists ${SCHEMA}.dws_risk_my_user_txn_mp_order_complete_df;
create external table if not exists ${SCHEMA}.dws_risk_my_user_txn_mp_order_complete_df (
    platform_user_id string
    ,latest_buyer_shipping_address_state_360d string
    ,latest_buyer_shipping_address_zipcode_360d string
    ,latest_buyer_shipping_address_district_360d string
    ,latest_buyer_shipping_address_town_360d string
    ,latest_buyer_shipping_address_city_360d string
    ,no_of_district_360d bigint
    ,no_of_zipcode_360d bigint
    ,no_of_city_360d bigint
    ,no_of_town_360d bigint
    ,no_of_address_360d bigint
    ,no_of_state_360d bigint
)
partitioned by
    (grass_date string comment "Partition, YYYY-MM-DD") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/dws/dws_risk_reg_user_txn_mp_order_complete_df/grass_region=${grass_region}'
;
--msck repair table ${SCHEMA}.dws_risk_my_user_txn_mp_order_complete_df;

create or replace temporary view address_tb_1 as
select
    buyer_id as platform_user_id
    ,buyer_shipping_address as buyer_shipping_address
    ,buyer_shipping_address_state as buyer_shipping_address_state
    ,buyer_shipping_address_city as buyer_shipping_address_city
    ,buyer_shipping_address_district as buyer_shipping_address_district
    ,buyer_shipping_address_zipcode as buyer_shipping_address_zipcode
    ,buyer_shipping_address_town as buyer_shipping_address_town
    ,row_number() over (
        partition by buyer_id
        order by shipping_confirm_timestamp desc
    ) as rn
from mp_order.dwd_order_all_ent_df__reg_s1_live
where
    tz_type = 'local'
    and grass_region = 'MY'
    and order_be_status_id in (4, 11, 12, 13, 14, 15)
    and shipping_confirm_timestamp > 0
    and datediff(
        date '${current_grass_date}'
        ,cast(from_unixtime(shipping_confirm_timestamp) as date)
    ) between 1 and 360
    and is_bi_excluded = 0
;

create or replace temporary view user_latest_address_features as (
    select
        platform_user_id
        ,buyer_shipping_address_state as latest_buyer_shipping_address_state_360d
        ,buyer_shipping_address_city as latest_buyer_shipping_address_city_360d
        ,buyer_shipping_address_district as latest_buyer_shipping_address_district_360d
        ,buyer_shipping_address_zipcode as latest_buyer_shipping_address_zipcode_360d
        ,buyer_shipping_address_town as latest_buyer_shipping_address_town_360d
    from address_tb_1
    where rn = 1
)
;

create or replace temporary view user_address_stability_360d as (
    select
        platform_user_id
        ,count(distinct buyer_shipping_address) as no_of_address_360d
        ,count(distinct buyer_shipping_address_state) as no_of_state_360d
        ,count(distinct buyer_shipping_address_city) as no_of_city_360d
        ,count(distinct buyer_shipping_address_district) as no_of_district_360d
        ,count(distinct buyer_shipping_address_zipcode) as no_of_zipcode_360d
        ,count(distinct buyer_shipping_address_town) as no_of_town_360d
    from address_tb_1
    group by platform_user_id
)
;

insert overwrite table
    ${SCHEMA}.dws_risk_my_user_txn_mp_order_complete_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t2.latest_buyer_shipping_address_state_360d
    ,t2.latest_buyer_shipping_address_zipcode_360d
    ,t2.latest_buyer_shipping_address_district_360d
    ,t2.latest_buyer_shipping_address_town_360d
    ,t2.latest_buyer_shipping_address_city_360d
    ,t3.no_of_district_360d
    ,t3.no_of_zipcode_360d
    ,t3.no_of_city_360d
    ,t3.no_of_town_360d
    ,t3.no_of_address_360d
    ,t3.no_of_state_360d
from
    (
        select
            platform_user_id
        from ${SCHEMA}.dim_risk_${region}_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join user_latest_address_features t2 on t1.platform_user_id = t2.platform_user_id
    left join user_address_stability_360d t3 on t1.platform_user_id = t3.platform_user_id
;