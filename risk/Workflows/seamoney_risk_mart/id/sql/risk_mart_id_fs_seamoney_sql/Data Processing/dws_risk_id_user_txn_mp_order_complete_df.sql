--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-09-03
-- Theme Domain：       id_user_txn_mp_order_complete
-- Description:         id_user_txn_mp_order_complete
-- Data Granularity:    
-- 变更历史：
-- update by zongyi.lu@shopee.com 2024-10-21 新增字段  jira https://jira.shopee.io/browse/SPFDT-45159
-- update by zongyi.lu@shopee.como 2024-11-11 将10-21新增的字段默认值改为-9999
-- update by wei.tao marketplace.shopee_checkout_v2_db__checkout_v2_tab__{xx}_hf -> mp_order.dwd_checkout_all_ent_snapshot_df__{xx}_live
--********************************************************************--
--drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df (
    platform_user_id string comment 'platform_user_id'
    ,is_wholeseller bigint comment 'Whether a user has orders with purchasing in bulk'
    ,pctg_of_wholeseller_order double comment '% of orders made as wholeseller'
    ,is_dropshipper bigint comment 'Whether a user indicates himself as a drop-shipper'
    ,pctg_of_dropshipper_gmv double comment '% of total NMV made as a drop-shipper'
    ,pctg_of_dropshipper_order double comment 'Total % of orders made as drop-shipper'
    ,address_userid_cnt bigint comment 'address_userid_cnt'
    ,cnt_order_l12m bigint comment 'number of orders in last 12 months'
    ,pctg_of_cod__order_in_30d double comment 'pctg_of_cod__order_in_30d'
    ,pctg_of_cod__order_in_90d double comment 'pctg_of_cod__order_in_90d'
    ,pctg_of_cod__order_in_180d double comment 'pctg_of_cod__order_in_180d'
    ,pctg_of_cod__order_in_360d double comment 'pctg_of_cod__order_in_360d'
    ,pctg_of_cod__order_in_lifetime double comment 'pctg_of_cod__order_in_lifetime'
    ,confirmed_gmv_usd_in_30d decimal(30, 10) comment 'confirmed_gmv_usd_in_30d'
    ,confirmed_gmv_usd_in_30d_spl_only decimal(30, 10) comment 'confirmed_gmv_usd_in_30d_spl_only'
    ,confirmed_gmv_usd_in_30d_spl_exclude decimal(30, 10) comment 'confirmed_gmv_usd_in_30d_spl_exclude'
    ,confirmed_gmv_usd_in_60d decimal(30, 10) comment 'confirmed_gmv_usd_in_60d'
    ,confirmed_gmv_usd_in_60d_spl_only decimal(30, 10) comment 'confirmed_gmv_usd_in_60d_spl_only'
    ,confirmed_gmv_usd_in_60d_spl_exclude decimal(30, 10) comment 'confirmed_gmv_usd_in_60d_spl_exclude'
    ,confirmed_gmv_usd_in_90d_spl_only decimal(30, 10) comment 'confirmed_gmv_usd_in_90d_spl_only'
    ,confirmed_gmv_usd_in_90d_spl_exclude decimal(30, 10) comment 'confirmed_gmv_usd_in_90d_spl_exclude'
    ,confirmed_gmv_usd_in_180d_spl_only decimal(30, 10) comment 'confirmed_gmv_usd_in_180d_spl_only'
    ,confirmed_gmv_usd_in_180d_spl_exclude decimal(30, 10) comment 'confirmed_gmv_usd_in_180d_spl_exclude'
    ,confirmed_gmv_usd_in_360d_spl_only decimal(30, 10) comment 'confirmed_gmv_usd_in_360d_spl_only'
    ,confirmed_gmv_usd_in_360d_spl_exclude decimal(30, 10) comment 'confirmed_gmv_usd_in_360d_spl_exclude'
    ,confirmed_gmv_usd_in_lifetime decimal(30, 10) comment 'confirmed_gmv_usd_in_lifetime'
)
partitioned by
    (grass_date string comment "YYYY-MM-DD") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/dws/dws_risk_aio_user_txn_mp_order_complete_df/garss_region=${upper_region}'
;
--msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df;


create or replace temporary view return_tab as (
    select
        userid
        ,return_id
        ,orderid as order_id
    from marketplace.shopee_return_v2_db__return_v2_tab__reg_daily_s0_live
    where
        grass_region = '${upper_region}'
        and status in (2, 5)
)
;

create or replace temporary view shopee_orders_tab as (
    SELECT
        buyer_id AS user_id
        , order_id
        , checkout_id
        , gmv_usd
        , gmv
        , shop_id
        , FROM_UNIXTIME(shipping_confirm_timestamp - 3600) AS shipping_confirm_time
        , CAST(FROM_UNIXTIME(shipping_confirm_timestamp - 3600) AS DATE) shipping_confirm_date
        , CAST(FROM_UNIXTIME(create_timestamp - 3600) AS DATE) grass_date
        , order_be_status_id
        , order_be_status
        ,CASE
            WHEN payment_channel IN ('SPayLater', 'ShopeePayLater') THEN 'spl'
            ELSE 'others'
        END AS payment_channel
    FROM mp_order.dwd_order_all_ent_df__reg_s0_live
    WHERE grass_region = '${upper_region}'
        AND tz_type = 'local'
        AND order_be_status_id IN (4, 11, 12, 13, 14, 15)
        AND shipping_confirm_timestamp > 0
        AND is_bi_excluded = 0
);

create or replace temporary view orders_tab AS (
        SELECT 
            t1.user_id
            , t1.order_id
            , t1.gmv_usd
            , t1.gmv
            , t1.shop_id
            , t1.shipping_confirm_time
            , t1.shipping_confirm_date
            , t1.grass_date
            , t1.order_be_status_id
            , t1.order_be_status
            , case when t2.channelid='89000' then 6 else 8 end payment_method -- 1 credit card --2 shopee wallet --3 dragon pay online --4 wechat pay/touch pay --5 offline pay --6 COD --7 shopee SPL
        FROM shopee_orders_tab t1 
        left join (
            select 
            checkout_id as checkout_id
            ,get_json_object(checkout_info,'$.checkout_payment_info.channelid') as channelid
            from mp_order.dwd_checkout_all_ent_snapshot_df__id_live
            where grass_region='ID' and grass_date >= date('${ds}')
        ) t2 on t1.checkout_id = t2.checkout_id
        );

create or replace temporary view order_item_proflie_agg as (
    select
        buyer_id as user_id
        ,order_id
        ,cast(from_unixtime(shipping_confirm_timestamp - 3600) as date) shipping_confirm_date
        ,sum(item_amount) as amount
        ,sum(gmv) as gmv
    from mp_order.dwd_order_item_all_ent_df__reg_s0_live
    where
        grass_region = '${upper_region}'
        and tz_type = 'local'
        and order_be_status_id in (4, 11, 12, 13, 14, 15)
        and shipping_confirm_timestamp > 0
        and is_bi_excluded = 0
    group by buyer_id, order_id, cast(from_unixtime(shipping_confirm_timestamp - 3600) as date)
)
;

create or replace temporary view wholesale_buyer_indicated as (
    select
        op.user_id
        ,1 is_wholeseller
        ,count(distinct (case when op.amount > 50 and op.gmv > 1500000 then op.order_id else null end)) wholeseller_orders
        ,count(distinct op.order_id) total_orders
        ,count(distinct (case when op.amount > 50 and op.gmv > 1500000 then op.order_id else null end)) / cast(nullif(count(distinct op.order_id), 0) as double) pctg_of_wholeseller_order
        ,sum(case when op.amount > 50 and op.gmv > 1500000 then op.gmv else 0 end) wholeseller_gmv
        ,sum(op.gmv) total_gmv
        ,sum(case when op.amount > 50 and op.gmv > 1500000 then op.gmv else 0 end) / cast(nullif(sum(op.gmv), 0) as double) pctg_of_wholeseller_gmv
    from
        order_item_proflie_agg op
        left join return_tab rt on op.order_id = rt.order_id
    where
        rt.return_id is null
        and op.shipping_confirm_date >= date_sub('${smd_grass_date}', 90)
    group by op.user_id
    having count(distinct (case when op.amount > 50 and op.gmv > 1500000 then op.order_id else null end)) >= 1
)
;

create or replace temporary view dropshipper_buyer_indicated as (
    select
        opp.user_id
        ,1 is_dropshipper
        ,count(distinct (case when enabled = 1 then op.order_id else null end)) dropshipper_orders
        ,count(distinct op.order_id) total_orders
        ,count(distinct (case when enabled = 1 then op.order_id else null end)) / cast(nullif(count(distinct op.order_id), 0) as double) pctg_of_dropshipper_order
        ,sum(case when enabled = 1 then opp.gmv else 0 end) dropshipper_gmv
        ,sum(opp.gmv) total_gmv
        ,sum(case when enabled = 1 then opp.gmv else 0 end) / cast(nullif(sum(opp.gmv), 0) as double) pctg_of_dropshipper_gmv
    from
        (
            select
                buyer_id as user_id
                ,order_id
                ,GET_JSON_OBJECT(extinfo, '$.dropshipping_info.enabled') enabled
                ,create_datetime
            from mp_order.dwd_ofo_all_ent_df__reg_live
            where grass_region = '${upper_region}'
        ) op
        join orders_tab opp on op.order_id = opp.order_id
        left join return_tab rt on opp.order_id = rt.order_id
    where
        opp.shipping_confirm_date >= date_sub('${smd_grass_date}', 90)
        and rt.return_id is null
    group by opp.user_id
    having count(distinct (case when enabled = 1 then op.order_id else null end)) >= 1
)
;

create or replace temporary view pctg_of_cod_tab as (
    select
        opp.user_id
        ,count(distinct case when opp.payment_method=6 then op.order_id else null end )/cast(nullif(count(distinct opp.order_id),0) as double) pctg_of_cod__order_in_lifetime
        ,count(distinct(case when opp.shipping_confirm_date >= date_sub('${grass_date}',360) and opp.payment_method = 6 then op.order_id else null end))/
              cast(nullif(count(distinct (case when opp.shipping_confirm_date >= date_sub('${grass_date}',360) then op.order_id else null end)),0) as double) as pctg_of_cod__order_in_360d
        ,count(distinct(case when opp.shipping_confirm_date >= date_sub('${grass_date}',180) and opp.payment_method = 6 then op.order_id else null end))/
              cast(nullif(count(distinct (case when opp.shipping_confirm_date >= date_sub('${grass_date}',180) then op.order_id else null end)),0) as double) as pctg_of_cod__order_in_180d
        ,count(distinct(case when opp.shipping_confirm_date >= date_sub('${grass_date}',90) and opp.payment_method = 6 then op.order_id else null end))/
              cast(nullif(count(distinct (case when opp.shipping_confirm_date >= date_sub('${grass_date}',90) then op.order_id else null end)),0) as double) as pctg_of_cod__order_in_90d
        ,count(distinct(case when opp.shipping_confirm_date >= date_sub('${grass_date}',30) and opp.payment_method = 6 then op.order_id else null end))/
              cast(nullif(count(distinct (case when opp.shipping_confirm_date >= date_sub('${grass_date}',30) then op.order_id else null end)),0) as double) as pctg_of_cod__order_in_30d
    from
        (
            select
                buyer_id as user_id
                ,order_id
            from mp_order.dwd_ofo_all_ent_df__reg_live
            where grass_region = '${upper_region}'
        ) op
        join orders_tab opp on op.order_id = opp.order_id
        left join return_tab rt on opp.order_id = rt.order_id
    where
        opp.shipping_confirm_date >= date_sub('${smd_grass_date}', 360)
        and rt.return_id is null
    group by opp.user_id
)
;

CREATE TEMPORARY VIEW user_txn_order_payment_tab AS (
    SELECT shopee_orders_tab.user_id,
        SUM(CASE WHEN shipping_confirm_date >= date_sub('${current_grass_date}', 30) THEN gmv_usd ELSE 0 END) AS confirmed_gmv_usd_in_30d,
        SUM(CASE WHEN shipping_confirm_date >= date_sub('${current_grass_date}', 30) AND payment_channel = 'spl' THEN gmv_usd ELSE 0 END) AS confirmed_gmv_usd_in_30d_spl_only,
        SUM(CASE WHEN shipping_confirm_date >= date_sub('${current_grass_date}', 30) AND payment_channel = 'others' THEN gmv_usd ELSE 0 END) AS confirmed_gmv_usd_in_30d_spl_exclude,
        SUM(CASE WHEN shipping_confirm_date >= date_sub('${current_grass_date}', 60) THEN gmv_usd ELSE 0 END) AS confirmed_gmv_usd_in_60d,
        SUM(CASE WHEN shipping_confirm_date >= date_sub('${current_grass_date}', 60) AND payment_channel = 'spl' THEN gmv_usd ELSE 0 END) AS confirmed_gmv_usd_in_60d_spl_only,
        SUM(CASE WHEN shipping_confirm_date >= date_sub('${current_grass_date}', 60) AND payment_channel = 'others' THEN gmv_usd ELSE 0 END) AS confirmed_gmv_usd_in_60d_spl_exclude,
        SUM(CASE WHEN shipping_confirm_date >= date_sub('${current_grass_date}', 90) AND payment_channel = 'spl' THEN gmv_usd ELSE 0 END) AS confirmed_gmv_usd_in_90d_spl_only,
        SUM(CASE WHEN shipping_confirm_date >= date_sub('${current_grass_date}', 90) AND payment_channel = 'others' THEN gmv_usd ELSE 0 END) AS confirmed_gmv_usd_in_90d_spl_exclude,
        SUM(CASE WHEN shipping_confirm_date >= date_sub('${current_grass_date}', 180) AND payment_channel = 'spl' THEN gmv_usd ELSE 0 END) AS confirmed_gmv_usd_in_180d_spl_only,
        SUM(CASE WHEN shipping_confirm_date >= date_sub('${current_grass_date}', 180) AND payment_channel = 'others' THEN gmv_usd ELSE 0 END) AS confirmed_gmv_usd_in_180d_spl_exclude,
        SUM(CASE WHEN shipping_confirm_date >= date_sub('${current_grass_date}', 360) AND payment_channel = 'spl' THEN gmv_usd ELSE 0 END) AS confirmed_gmv_usd_in_360d_spl_only,
        SUM(CASE WHEN shipping_confirm_date >= date_sub('${current_grass_date}', 360) AND payment_channel = 'others' THEN gmv_usd ELSE 0 END) AS confirmed_gmv_usd_in_360d_spl_exclude,
        SUM(gmv_usd) AS confirmed_gmv_usd_in_lifetime
    FROM shopee_orders_tab
        LEFT JOIN return_tab ON shopee_orders_tab.order_id = return_tab.order_id
    WHERE shipping_confirm_date < '${current_grass_date}'
        AND return_tab.return_id IS NULL
    GROUP BY shopee_orders_tab.user_id
);

create or replace temporary view reseller_user_list as (
    select
        user_id
    from
        (
            select
                user_id
            from wholesale_buyer_indicated
            union all
            select
                user_id
            from dropshipper_buyer_indicated
        )
    group by user_id
)
;

create or replace temporary view reseller_users as (
    select
        a.user_id
        ,is_wholeseller
        ,is_dropshipper
        ,pctg_of_wholeseller_order
        ,pctg_of_wholeseller_gmv
        ,pctg_of_dropshipper_order
        ,pctg_of_dropshipper_gmv
    from
        reseller_user_list a
        left join wholesale_buyer_indicated b on a.user_id = b.user_id
        left join dropshipper_buyer_indicated c on a.user_id = c.user_id
)
;

drop table if exists ${SCHEMA}.tmp_dwd_risk_mp_order_base_df;
create table ${SCHEMA}.tmp_dwd_risk_mp_order_base_df stored as orc as
select
buyer_id as platform_user_id
,order_id
,shop_id
,seller_id
,gmv
,payment_method_id
,checkout_id
,create_datetime as event_time
, create_datetime as create_time
,TO_DATE(substr(create_datetime,1,10)) grass_date
,grass_region
,order_sn
,buyer_shipping_address
,is_net_order
,order_fe_status
,complete_timestamp
from mp_order.dwd_order_all_ent_df__reg_s1_live
where tz_type = 'local'
and grass_region = '${upper_region}'
and grass_date >= ADD_MONTHS('${smd_grass_date}', -12)
;

drop table if exists ${SCHEMA}.tmp_dws_risk_mp_order_info_df;
create table ${SCHEMA}.tmp_dws_risk_mp_order_info_df stored as orc as
select t1.platform_user_id
,coalesce(t2.cnt_order_l12m,0) as cnt_order_l12m
from
(select user_id as platform_user_id from mp_user.dim_user__reg_s0_live where tz_type = 'local' and grass_region = '${upper_region}' and grass_date = '${ds}') t1
left join
(
select
platform_user_id
,count(distinct order_id) as cnt_order_l12m
from ${SCHEMA}.tmp_dwd_risk_mp_order_base_df
where is_net_order=1
group by platform_user_id
) t2
on t1.platform_user_id = t2.platform_user_id
;

CREATE or replace TEMPORARY VIEW SPL_order as (
    select
    order_sn,
    shop_id,
    platform_user_id,
    checkout_id,
    CAST(create_time AS DATE) as create_time,
    buyer_shipping_address
    from ${SCHEMA}.tmp_dwd_risk_mp_order_base_df
    where grass_region='${upper_region}'
    and grass_date >= ADD_MONTHS('${smd_grass_date}', -1)
    and grass_date <= '${smd_grass_date}'
    and CAST(FROM_UNIXTIME(complete_timestamp) AS DATE) <= '${smd_grass_date}'
    and order_fe_status='COMPLETED'
    and payment_method_id = 24
    order by     
    order_sn,
    shop_id,
    platform_user_id,
    checkout_id,
    CAST(create_time AS DATE),
    buyer_shipping_address
);

CREATE or replace TEMPORARY VIEW address_data as (
    select platform_user_id, buyer_shipping_address
    from ${SCHEMA}.tmp_dwd_risk_mp_order_base_df
    where grass_region='${upper_region}'
    and grass_date >= current_date - interval '1' month
    and grass_date <= current_date
    group by platform_user_id, buyer_shipping_address
);

create or replace TEMPORARY view order_base_address_cnt as
select platform_user_id
,max(case when address_userid_cnt >= 2 then address_userid_cnt - 1 else 0 end) as address_userid_cnt
from
(
  select
      base.order_sn, base.platform_user_id,
      count(distinct address.platform_user_id) as address_userid_cnt
  from SPL_order base
  left join address_data address
  on base.buyer_shipping_address = address.buyer_shipping_address
  group by base.order_sn, base.platform_user_id
)
group by platform_user_id
;

insert overwrite table risk.dws_risk_id_user_txn_mp_order_complete_df partition (grass_date = '${ds}')
select
    t1.platform_user_id
    ,COALESCE(t2.is_wholeseller, 0) as is_wholeseller
    ,COALESCE(t2.pctg_of_wholeseller_order, 0) as pctg_of_wholeseller_order
    ,COALESCE(t2.is_dropshipper, 0) as is_dropshipper
    ,COALESCE(t2.pctg_of_dropshipper_gmv, 0) as pctg_of_dropshipper_gmv
    ,COALESCE(t2.pctg_of_dropshipper_order, 0) as pctg_of_dropshipper_order
    ,t5.address_userid_cnt
    ,t4.cnt_order_l12m
    ,COALESCE(t6.pctg_of_cod__order_in_30d, -9999)    as pctg_of_cod__order_in_30d  
    ,COALESCE(t6.pctg_of_cod__order_in_90d, -9999)    as pctg_of_cod__order_in_90d 
    ,COALESCE(t6.pctg_of_cod__order_in_180d, -9999)   as pctg_of_cod__order_in_180d 
    ,COALESCE(t6.pctg_of_cod__order_in_360d, -9999)   as pctg_of_cod__order_in_360d 
    ,COALESCE(t6.pctg_of_cod__order_in_lifetime, -9999) as pctg_of_cod__order_in_lifetime
    ,COALESCE(t7.confirmed_gmv_usd_in_30d, -9999) as confirmed_gmv_usd_in_30d
    ,COALESCE(t7.confirmed_gmv_usd_in_30d_spl_only, -9999) as confirmed_gmv_usd_in_30d_spl_only
    ,COALESCE(t7.confirmed_gmv_usd_in_30d_spl_exclude, -9999) as confirmed_gmv_usd_in_30d_spl_exclude
    ,COALESCE(t7.confirmed_gmv_usd_in_60d, -9999) as confirmed_gmv_usd_in_60d
    ,COALESCE(t7.confirmed_gmv_usd_in_60d_spl_only, -9999) as confirmed_gmv_usd_in_60d_spl_only
    ,COALESCE(t7.confirmed_gmv_usd_in_60d_spl_exclude, -9999) as confirmed_gmv_usd_in_60d_spl_exclude
    ,COALESCE(t7.confirmed_gmv_usd_in_90d_spl_only, -9999) as confirmed_gmv_usd_in_90d_spl_only
    ,COALESCE(t7.confirmed_gmv_usd_in_90d_spl_exclude, -9999) as confirmed_gmv_usd_in_90d_spl_exclude
    ,COALESCE(t7.confirmed_gmv_usd_in_180d_spl_only, -9999) as confirmed_gmv_usd_in_180d_spl_only
    ,COALESCE(t7.confirmed_gmv_usd_in_180d_spl_exclude, -9999) as confirmed_gmv_usd_in_180d_spl_exclude
    ,COALESCE(t7.confirmed_gmv_usd_in_360d_spl_only, -9999) as confirmed_gmv_usd_in_360d_spl_only
    ,COALESCE(t7.confirmed_gmv_usd_in_360d_spl_exclude, -9999) as confirmed_gmv_usd_in_360d_spl_exclude
    ,COALESCE(t7.confirmed_gmv_usd_in_lifetime, -9999) as confirmed_gmv_usd_in_lifetime
from
    (
        select
            platform_user_id
        from risk.dim_risk_id_user_info_df
        where grass_date = '${ds}'
    ) t1
    left join reseller_users t2 on t1.platform_user_id = t2.user_id
    left join ${SCHEMA}.tmp_dws_risk_mp_order_info_df t4 on t1.platform_user_id = t4.platform_user_id
    left join order_base_address_cnt t5 on t1.platform_user_id = t5.platform_user_id
    left join pctg_of_cod_tab t6 on t1.platform_user_id = t6.user_id 
    left join user_txn_order_payment_tab t7 on t1.platform_user_id = t7.user_id
;