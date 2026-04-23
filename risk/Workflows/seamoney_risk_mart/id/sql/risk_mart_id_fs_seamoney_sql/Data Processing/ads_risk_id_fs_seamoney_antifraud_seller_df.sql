------------------------------------------------------------------------
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-03-15
-- Description:         业务维护的指标，对外提供ads表 
-- Data Granularity:    shop_id
-- PRD:                 
------------------------------------------------------------------------
--drop table if exists ${SCHEMA}.ads_risk_id_fs_seamoney_antifraud_seller_df;
create table if not exists ${SCHEMA}.ads_risk_id_fs_seamoney_antifraud_seller_df
(
    shop_id string comment 'shop_id'
    ,platform_user_id string comment 'platform_user_id'
    ,fes_big_shop bigint
    ,none_buyer_l7d boolean
    ,none_gmv_l7d boolean
    ,none_buyer_l3d boolean
    ,spl_hist_dpd_30 boolean
    ,cnt_hit_blacklist_sme bigint
    ,shop_risk_level string
    ,cnt_order_7d bigint
)
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/ads/ads_risk_fs_seamoney_antifraud_seller_df/grass_region=ID';

--msck repair table ${SCHEMA}.ads_risk_id_fs_seamoney_antifraud_seller_df;


insert overwrite table
    ${SCHEMA}.ads_risk_id_fs_seamoney_antifraud_seller_df partition (grass_date = '${grass_date}')
select
    t1.shop_id
    ,t1.platform_user_id
    ,t1.fes_big_shop
    ,t2.none_buyer_l7d
    ,t2.none_gmv_l7d
    ,t2.none_buyer_l3d
    ,t2.spl_hist_dpd_30
    ,t2.cnt_hit_blacklist_sme
    ,t3.shop_risk_level
    ,t3.cnt_order_7d
from
    (
        select
            shop_id
            ,user_id as platform_user_id
            ,case when is_official_shop = 1 or is_preferred_shop = 1 then 1 else 0 end as fes_big_shop
        from mp_user.dim_shop__reg_s0_live
        where 
            tz_type = 'local'
            and grass_region = 'ID'
            and grass_date = '${grass_date}'
            and shop_id <> '0'
    ) t1
    left join
    (
        select 
            platform_user_id
            ,none_buyer_l7d
            ,none_gmv_l7d
            ,none_buyer_l3d
            ,spl_hist_dpd_30
            ,cnt_hit_blacklist_sme
        from risk.dws_risk_${region}_user_metrics_biz_manage_df
        where grass_date = '${grass_date}'
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join
    (
        select
            shop_id
            ,shop_risk_level
            ,cnt_order_7d
        from risk.dws_risk_id_shop_af_tag_df
        where grass_date = '${grass_date}'
    ) t3 on t1.shop_id = t3.shop_id
;