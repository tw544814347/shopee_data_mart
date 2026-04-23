------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-03-27
-- Description:         业务维护的指标，region_tier
-- Data Granularity:    shopee_user_id
-- PRD:                 https://fs.idata.shopeemobile.com/job-management/job-edit/600
-- 2026-03-27,chengguo.liu,业务维护的指标，扫描BR全量订单数据，较多硬编码，业务要求保留原始逻辑迁移                  
------------------------------------------------------------------------


drop table if exists ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_region_tier_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_region_tier_df (
    shopee_user_id string comment 'shopee_user_id'
    ,region_tag_360d string comment 'region_tag_360d'
    ,region_tier_360d bigint comment 'region_tier_360d'
)
partitioned by
    (grass_date string comment "YYYY-MM-DD") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/dws/dws_risk_reg_user_metrics_biz_manage_region_tier_df/grass_region=${grass_region}'
;
msck repair table ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_region_tier_df;


create or replace temporary view orders_tab as (
    select
        op.order_id as orderid
        ,op.gmv
        ,op.gmv_usd
        ,op.buyer_id as userid
        ,cast(op.shipping_confirm_datetime as timestamp) as shipping_confirm_time
        ,cast(from_unixtime(op.shipping_confirm_timestamp) as date) shipping_confirm_date
        ,op.checkout_id
        ,op.buyer_shipping_address_state
        ,case
            when op.buyer_shipping_address_state = 'Distrito Federal' then 'DF'
            when op.buyer_shipping_address_state = 'São Paulo' then 'SP'
            when op.buyer_shipping_address_state in ('Rio de Janeiro', 'Rio De Janeiro') then 'RJ'
            when op.buyer_shipping_address_state in ('Rio Grande do Sul', 'Rio Grande Do Sul') then 'RS'
            when op.buyer_shipping_address_state = 'Mato Grosso' then 'MT'
            when op.buyer_shipping_address_state = 'Santa Catarina' then 'SC'
            when op.buyer_shipping_address_state = 'Paraná' then 'PR'
            when op.buyer_shipping_address_state in ('Mato Grosso do Sul', 'Mato Grosso Do Sul') then 'MS'
            when op.buyer_shipping_address_state = 'Espírito Santo' then 'ES'
            when op.buyer_shipping_address_state = 'Goiás' then 'GO'
            when op.buyer_shipping_address_state = 'Minas Gerais' then 'MG'
            when op.buyer_shipping_address_state = 'Amazonas' then 'AM'
            when op.buyer_shipping_address_state in ('Rio Grande do Norte', 'Rio Grande Do Norte') then 'RN'
            when op.buyer_shipping_address_state = 'Pernambuco' then 'PE'
            when op.buyer_shipping_address_state = 'Tocantins' then 'TO'
            when op.buyer_shipping_address_state = 'Bahia' then 'BA'
            when op.buyer_shipping_address_state = 'Sergipe' then 'SE'
            when op.buyer_shipping_address_state = 'Pará' then 'PA'
            when op.buyer_shipping_address_state = 'Acre' then 'AC'
            when op.buyer_shipping_address_state = 'Ceará' then 'CE'
            when op.buyer_shipping_address_state = 'Roraima' then 'RR'
            when op.buyer_shipping_address_state = 'Rondônia' then 'RO'
            when op.buyer_shipping_address_state = 'Alagoas' then 'AL'
            when op.buyer_shipping_address_state = 'Amapá' then 'AP'
            when op.buyer_shipping_address_state = 'Paraíba' then 'PB'
            when op.buyer_shipping_address_state = 'Maranhão' then 'MA'
            when op.buyer_shipping_address_state = 'Piauí' then 'PI'
            else 'ELSE'
        end as region_tag
    from mp_order.dwd_order_all_ent_df__reg_s0_live op
    where
        op.grass_region = '${grass_region}'
        and op.order_be_status_id in (4, 11, 12, 13, 14, 15)
        and op.shipping_confirm_datetime is not null
        and is_bi_excluded = 0
)
;

create or replace temporary view return_tab as (
    select
        return_id
        ,orderid
    from marketplace.shopee_return_v2_br_db__return_v2_tab__br_continuous_s0_live
    where
        grass_region = '${grass_region}'
        and status in (2, 5)
)
;

create or replace temporary view region_tag_base as (
    select
        ot.userid
        ,ot.region_tag
        ,count(distinct ot.orderid) as order_num
    from
        orders_tab ot
        left join return_tab rt on cast(ot.orderid as bigint) = cast(rt.orderid as bigint)
    where
        rt.orderid is null
        and shipping_confirm_date >= date_sub(current_date(), 360)
    group by ot.userid, ot.region_tag
)
;

create or replace temporary view region_tag_base2 as (
    select
        *
        ,row_number() over (
            partition by userid
            order by order_num desc
        ) as `rank`
    from region_tag_base
)
;

create or replace temporary view region_tag_in_l12m as (
    select
        userid
        ,region_tag as region_tag_12m
    from region_tag_base2
    where `rank` = 1
)
;

create or replace temporary view region_tier_base as (
    select
        *
        ,case
            when region_tag in ('MG', 'ES', 'RJ', 'SP') then 1
            when region_tag in ('PR', 'SC', 'RS') then 2
            when region_tag in ('MS', 'MT', 'GO', 'DF') then 3
            when region_tag in ('MA', 'PI', 'CE', 'RN', 'PB', 'PE', 'AL', 'SE', 'BA') then 4
            when region_tag in ('RO', 'AC', 'AM', 'RR', 'PA', 'AP', 'TO') or region_tag is null then 5
            else 6
        end as region_tier
    from orders_tab
)
;

create or replace temporary view region_tier_base2 as (
    select
        ot.userid
        ,ot.region_tier
        ,count(distinct ot.orderid) as order_num
    from
        region_tier_base ot
        left join return_tab rt on cast(ot.orderid as bigint) = cast(rt.orderid as bigint)
    where
        rt.orderid is null
        and shipping_confirm_date >= date_sub(current_date(), 360)
    group by ot.userid, ot.region_tier
)
;

create or replace temporary view region_tier_base3 as (
    select
        *
        ,row_number() over (
            partition by userid
            order by order_num desc, region_tier asc
        ) as `rank`
    from region_tier_base2
)
;

create or replace temporary view region_tier_in_l12m as (
    select
        userid
        ,region_tier as region_tier_12m
    from region_tier_base3
    where `rank` = 1
)
;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_region_tier_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id as shopee_user_id
    ,coalesce(t2.region_tag_12m, '-1') as region_tag_360d
    ,coalesce(t3.region_tier_12m, -1) as region_tier_360d
from
(
    select
        platform_user_id
    from ${SCHEMA}.dim_risk_br_user_info_df
    where grass_date = '${grass_date}'
) t1
left join region_tag_in_l12m t2 on t1.platform_user_id = t2.userid
left join region_tier_in_l12m t3 on t1.platform_user_id = t3.userid
;