--drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_item_complete_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_item_complete_df (
    platform_user_id            string comment 'platform user id'
    ,no_of_level_1_cat_90d bigint
    ,no_of_level_2_cat_90d bigint
    ,no_of_level_3_cat_90d bigint
    ,no_of_level_1_cat_180d bigint
    ,no_of_level_2_cat_180d bigint
    ,no_of_level_3_cat_180d bigint
)
partitioned by (grass_date string comment 'YYYY-MM-DD') 
stored as orc tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_mart/dws/dws_risk_reg_user_txn_mp_order_item_complete_df/grass_region=${grass_region}'
;
--msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_item_complete_df;

create or replace temporary view order_cat_tb_1 as (
    select
        buyer_id as userid
        ,category_id
        ,category_level
        ,level1_category_id
        ,level1_category
        ,level2_category_id
        ,level2_category
        ,level3_category_id
        ,level3_category
        ,shipping_confirm_timestamp
    from mp_order.dwd_order_item_all_ent_df__reg_s0_live
    where
        tz_type = 'local'
        and grass_region = 'MY'
        and is_paid_ads_topup = 0
        and is_bi_excluded = 0
        and order_be_status not in (
            'INVALID'
            ,'CANCEL_PROCESSING'
            ,'CANCEL_COMPLETED'
            ,'RETURN_PROCESSING'
            ,'RETURN_COMPLETED'
            ,'CANCEL_PENDING'
        )
)
;

create or replace temporary view order_cat_90d as (
    select
        order_cat_tb_1.*
    from order_cat_tb_1
    where from_unixtime(shipping_confirm_timestamp) >= date_sub('${current_grass_date}', 90)
)
;

create or replace temporary view order_cat_180d as (
    select
        order_cat_tb_1.*
    from order_cat_tb_1
    where from_unixtime(shipping_confirm_timestamp) >= date_sub('${current_grass_date}', 180)
)
;

create or replace temporary view order_cat_stability_90d as (
    select
        userid as platform_user_id
        ,count(distinct level1_category_id) as no_of_level_1_cat_90d
        ,count(distinct level2_category_id) as no_of_level_2_cat_90d
        ,count(distinct level3_category_id) as no_of_level_3_cat_90d
    from order_cat_90d
    group by userid
)
;

create or replace temporary view order_cat_stability_180d as (
    select
        userid as platform_user_id
        ,count(distinct level1_category_id) as no_of_level_1_cat_180d
        ,count(distinct level2_category_id) as no_of_level_2_cat_180d
        ,count(distinct level3_category_id) as no_of_level_3_cat_180d
    from order_cat_180d
    group by userid
)
;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_item_complete_df partition(grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t2.no_of_level_1_cat_90d
    ,t2.no_of_level_2_cat_90d
    ,t2.no_of_level_3_cat_90d
    ,t3.no_of_level_1_cat_180d
    ,t3.no_of_level_2_cat_180d
    ,t3.no_of_level_3_cat_180d
from
(
    select
        platform_user_id
    from ${SCHEMA}.dim_risk_my_user_info_df
    where grass_date = '${grass_date}'
) t1
left join order_cat_stability_90d t2 on t1.platform_user_id = t2.platform_user_id
left join order_cat_stability_180d t3 on t1.platform_user_id = t3.platform_user_id
;







