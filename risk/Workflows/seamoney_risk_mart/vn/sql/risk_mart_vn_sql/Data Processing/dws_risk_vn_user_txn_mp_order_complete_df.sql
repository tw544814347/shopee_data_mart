create or replace temporary view dws_user_shipping_address_district_df as
select
    platform_user_id
    ,buyer_shipping_address_district
from ${SCHEMA}.dwd_risk_${region}_user_txn_mp_order_complete_df
where
    grass_date = '${grass_date}'
    and shipping_confirm_timestamp > 0
    and is_bi_excluded = 0
    and date(from_unixtime(shipping_confirm_timestamp - 3600)) >= date_sub(current_date, 360)
    and date(from_unixtime(shipping_confirm_timestamp - 3600)) <= current_date
;

create or replace temporary view dws_user_shipping_address_district_cnt_df as
select
    platform_user_id
    ,count(distinct buyer_shipping_address_district) as buyer_shipping_address_district_cnt_360d
from dws_user_shipping_address_district_df
group by platform_user_id
;

create or replace temporary view dws_user_most_order_shipping_address_district_df as (
    SELECT 
        platform_user_id,
        buyer_shipping_address_district AS most_order_shipping_address_district_360d
    FROM (
        SELECT
            platform_user_id,
            buyer_shipping_address_district,
            ROW_NUMBER() OVER (PARTITION BY platform_user_id ORDER BY COUNT(*) DESC, buyer_shipping_address_district ASC) AS rn
        FROM dws_user_shipping_address_district_df
        GROUP BY platform_user_id, buyer_shipping_address_district
    ) a
    WHERE rn = 1
);

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t2.buyer_shipping_address_district_cnt_360d
    ,t3.most_order_shipping_address_district_360d
from
    (
        select
            platform_user_id
        from ${SCHEMA}.dim_risk_${region}_user_info_df
        where grass_date = '${grass_date}'
    ) t1
left join dws_user_shipping_address_district_cnt_df t2
on t1.platform_user_id = t2.platform_user_id
left join dws_user_most_order_shipping_address_district_df t3
on t1.platform_user_id = t3.platform_user_id
;


