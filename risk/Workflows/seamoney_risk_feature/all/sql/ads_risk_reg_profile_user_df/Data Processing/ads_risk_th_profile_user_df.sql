--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-08-13
-- Theme Domain：       user profile
-- Description:         
-- Data Granularity:   
-- 变更历史：
-- zongyi.lu@shopee.com 将whitelist相关的字段置null 不涉及线上(当时的需求单子https://jira.shopee.io/browse/SPFDT-16962)
-- 20240813 zongyi.lu@shopee.com 1.新增注释 2.用户最近180天的city_name,因为udf get_ip_to_city不太稳定可能会某天拿不到用户的cityname,因此新增兜底逻辑,取最近180天的用户cityname https://jira.shopee.io/browse/SPFDT-42574
-- 20250618 wei.tao DWD/DWS新增 SPP 数据源，但是此表保持不变，新增过滤条件，jira：https://jira.shopee.io/browse/SPFDT-52751
-- 20260104 wei.tao 按地区拆分成模版统一，减少资源占用
-- 20260311 chenyingying 新增字段is_svip_active, jira: https://jira.shopee.io/browse/SPFDT-61284
--********************************************************************--

set spark.sql.hive.convertMetastoreParquet=false;

drop table if exists risk.network_base_${reg};
create table risk.network_base_${reg} stored as orc as
select
    user_id
    ,grass_region
    ,tongdun_device_id
    ,sz_dfp_device_id
from ${SCHEMA}.dim_risk_user_device_df
where tz_type='local'
  and grass_region = upper('${reg}')
  and grass_date = date('${bizdate}')
  and tongdun_device_id is not null
  and user_id is not null
group by
    user_id
    ,grass_region
    ,tongdun_device_id
    ,sz_dfp_device_id
;

drop table if exists risk.network_${reg};
create table risk.network_${reg} stored as orc as
select
    a1.user_id
    ,a1.grass_region
    ,concat_ws(',', collect_set(a2.user_id)) as fst_lvl_network_user_id_list_td
from risk.network_base_${reg} a1
left outer join risk.network_base_${reg} a2
  on a1.tongdun_device_id = a2.tongdun_device_id
where a1.user_id <> a2.user_id
group by
    a1.user_id
    ,a1.grass_region
having fst_lvl_network_user_id_list_td <> ''
;

drop table if exists risk.network_szdf_${reg};
create table risk.network_szdf_${reg} stored as orc as
select
    a1.user_id
    ,a1.grass_region
    ,concat_ws(',', collect_set(a2.user_id)) as fst_lvl_network_user_id_list_sz_dfp_td
from risk.network_base_${reg} a1
left outer join risk.network_base_${reg} a2
  on a1.sz_dfp_device_id = a2.sz_dfp_device_id
where a1.user_id <> a2.user_id
group by
    a1.user_id
    ,a1.grass_region
having fst_lvl_network_user_id_list_sz_dfp_td <> ''
;

drop table if exists risk.login_device_td_${reg};
create table risk.login_device_td_${reg} stored as orc as
select
    user_id
    ,grass_region
    ,fst_login_shopee_df_td
    ,fst_login_hash_shopee_df_td
    ,fst_login_tongdun_device_id_td
    ,fst_login_sz_dfp_device_id_td
    ,datediff(date('${bizdate}'), from_unixtime(lst_login_timestamp_td)) as silence_day_cnt_td
from ${SCHEMA}.dws_risk_user_login_device_df
where tz_type='local'
  and grass_date = date('${bizdate}')
  and grass_region = upper('${reg}')
  and user_id is not null
;

drop table if exists risk.complete_dev_table_${reg};
create table risk.complete_dev_table_${reg} stored as orc as
select
    buyer_id as user_id
    ,grass_region
    ,shopee_df
    ,shopee_device_id as hash_shopee_df
    ,tongdun_device_id
    ,sz_dfp_device_id
from ${SCHEMA}.dws_risk_buyer_device_complete_df
where tz_type='local'
  and grass_date = date('${bizdate}')
  and grass_region = upper('${reg}')
  and buyer_id is not null
  and (
    (fas_timestamp_of_complete_physical_product_ord_1y < unix_timestamp(date_sub(date('${bizdate}'), 30))
        and complete_physical_product_ord_cnt_1y > 1)
    or (complete_physical_product_ord_cnt_1y > 3 and complete_physical_product_ord_day_cnt_1y > 3)
    )
;

drop table if exists risk.frequency_device_1y_${reg};
create table risk.frequency_device_1y_${reg} stored as orc as
select
    user_id
    ,grass_region
    ,shopee_df
    ,hash_shopee_df
    ,tongdun_device_id
    ,sz_dfp_device_id
from risk.complete_dev_table_${reg}
where hash_shopee_df is not null
union all
select
    user_id
    ,grass_region
    ,fst_login_shopee_df_td as shopee_df
    ,fst_login_hash_shopee_df_td as hash_shopee_df
    ,fst_login_tongdun_device_id_td as tongdun_device_id
    ,fst_login_sz_dfp_device_id_td as sz_dfp_device_id
from risk.login_device_td_${reg}
where fst_login_hash_shopee_df_td is not null
;


create or replace temporary view frequency_device as
select
    user_id
    ,grass_region
    ,case when frequency_shopee_df_list_1y <> '' then frequency_shopee_df_list_1y end as frequency_shopee_df_list_1y
    ,case when frequency_hex_hash_shopee_df_list_1y <> '' then frequency_hex_hash_shopee_df_list_1y end as frequency_hex_hash_shopee_df_list_1y
    ,case when frequency_tongdun_device_id_list_1y <> '' then frequency_tongdun_device_id_list_1y end as frequency_tongdun_device_id_list_1y
    ,case when frequency_sz_dfp_device_id_list_1y <> '' then frequency_sz_dfp_device_id_list_1y end as frequency_sz_dfp_device_id_list_1y
from (
    select
        user_id
        ,grass_region
        ,concat_ws(',', collect_set(shopee_df)) as frequency_shopee_df_list_1y
        ,concat_ws(',', collect_set(hex(unbase64(hash_shopee_df)))) as frequency_hex_hash_shopee_df_list_1y
        ,concat_ws(',', collect_set(tongdun_device_id)) as frequency_tongdun_device_id_list_1y
        ,concat_ws(',', collect_set(sz_dfp_device_id)) as frequency_sz_dfp_device_id_list_1y
    from risk.frequency_device_1y_${reg} a1
    group by
        user_id
        ,grass_region
    having frequency_shopee_df_list_1y <> '' or frequency_hex_hash_shopee_df_list_1y <> ''
     or frequency_tongdun_device_id_list_1y <> '' or frequency_sz_dfp_device_id_list_1y <> ''
) a1
;

drop table if exists risk.shopee_device_login_year_df_${reg};
create table risk.shopee_device_login_year_df_${reg} stored as orc as
select
a1.user_id, a1.shopee_df ,base64(a2.hashed_fingerprint) as hash_shopee_df, a1.grass_region, a1.cnt_login_1year
from
(
select
    t.user_id,
    t.shopee_df,
    t.grass_region,
    count(t.grass_date) as cnt_login_1year
from
(
select
    user_id
    ,shopee_df
    ,grass_region
    ,grass_date
from ${SCHEMA}.dws_risk_user_device_login_di
where tz_type = 'local'
    and is_spp_update <> '1'
    and grass_region = upper('${reg}')
    and grass_date >= date_sub(date('${bizdate}'), 365)
    and grass_date <= date('${bizdate}')
group by user_id, shopee_df, grass_region, grass_date
) t
group by t.user_id, t.shopee_df, t.grass_region
having count(t.grass_date) > 30
) a1
left join (select userid, device_fingerprint, hashed_fingerprint 
        -- from marketplace.shopee_device_extension_db__device_ext_tab__reg_continuous_s0_live 
        from risk.dim_shopee_device_extension_v2_db__device_ext_tab__reg_df
        group by userid, device_fingerprint, hashed_fingerprint) a2
on a1.user_id = a2.userid and a1.shopee_df = a2.device_fingerprint
;

drop table if exists risk.tongdun_device_login_year_df_${reg};
create table risk.tongdun_device_login_year_df_${reg} stored as orc as
select
    user_id,
    tongdun_device_id,
    grass_region,
    count(grass_date) as cnt_login_1year
from
(
select
    user_id
    ,tongdun_device_id
    ,grass_region
    ,grass_date
from ${SCHEMA}.dws_risk_user_device_login_di
where tz_type = 'local'
    and is_spp_update <> '1'
    and grass_region = upper('${reg}')
    and grass_date >= date_sub(date('${bizdate}'), 365)
    and grass_date <= date('${bizdate}')
group by user_id, tongdun_device_id, grass_region, grass_date
) t
group by user_id, tongdun_device_id, grass_region
having count(grass_date) > 30
;

drop table if exists risk.sz_dfp_device_login_year_df_${reg};
create table risk.sz_dfp_device_login_year_df_${reg} stored as orc as
select
    user_id,
    sz_dfp_device_id,
    grass_region,
    count(grass_date) as cnt_login_1year
from
(
select
    user_id
    ,sz_dfp_device_id
    ,grass_region
    ,grass_date
from ${SCHEMA}.dws_risk_user_device_login_di
where tz_type = 'local'
    and is_spp_update <> '1'
    and grass_region = upper('${reg}')
    and grass_date >= date_sub(date('${bizdate}'), 365)
    and grass_date <= date('${bizdate}')
group by user_id, sz_dfp_device_id, grass_region, grass_date
) t
group by user_id, sz_dfp_device_id, grass_region
having count(grass_date) > 30
;

drop table if exists risk.tmp_new_risk_login_1year_${reg};
create table risk.tmp_new_risk_login_1year_${reg} stored as orc as
select
    user_id
    ,case when frequency_sz_dfp_device_id_list_seller_1y <> '' then frequency_sz_dfp_device_id_list_seller_1y end as frequency_sz_dfp_device_id_list_seller_1y_v2
    ,grass_region
from
(
select user_id ,grass_region
,concat_ws(',', collect_set(sz_dfp_device_id)) as frequency_sz_dfp_device_id_list_seller_1y
from
(
select
    user_id
    ,sz_dfp_device_id
    ,grass_region
from risk.sz_dfp_device_login_year_df_${reg}
union all 
select
    user_id
    ,sz_dfp_device_id
    ,grass_region
from risk.dwd_risk_v2_login_di as new_login_di
where tz_type = 'local'
    and grass_region = upper('${reg}')
    and grass_date >= date_sub(date('${bizdate}'), 365)
    and grass_date <= date('${bizdate}')
) tmp 
group by user_id,grass_region
) t1
;

drop table if exists risk.user_device_login_30d_1y_${reg};
create table risk.user_device_login_30d_1y_${reg} stored as orc as
select
    user_id
    ,shopee_df
    ,hash_shopee_df
    ,null as tongdun_device_id
    ,null as sz_dfp_device_id
    ,grass_region
from risk.shopee_device_login_year_df_${reg}
union all
select
    user_id
    ,null as shopee_df
    ,null as hash_shopee_df
    ,tongdun_device_id
    ,null as sz_dfp_device_id
    ,grass_region
from risk.tongdun_device_login_year_df_${reg}
union all
select
    user_id
    ,null as shopee_df
    ,null as hash_shopee_df
    ,null as tongdun_device_id
    ,sz_dfp_device_id
    ,grass_region
from risk.sz_dfp_device_login_year_df_${reg}
;

create or replace temporary view login_device_30days_1y as
select
    user_id
    ,case when frequency_shopee_df_list_seller_1y <> '' then frequency_shopee_df_list_seller_1y end as frequency_shopee_df_list_seller_1y
    ,case when frequency_hex_hash_shopee_df_list_seller_1y <> '' then frequency_hex_hash_shopee_df_list_seller_1y end as frequency_hex_hash_shopee_df_list_seller_1y
    ,case when frequency_tongdun_device_id_list_seller_1y <> '' then frequency_tongdun_device_id_list_seller_1y end as frequency_tongdun_device_id_list_seller_1y
    ,case when frequency_sz_dfp_device_id_list_seller_1y <> '' then frequency_sz_dfp_device_id_list_seller_1y end as frequency_sz_dfp_device_id_list_seller_1y
    ,grass_region
from
(
select user_id ,grass_region
,concat_ws(',', collect_set(shopee_df)) as frequency_shopee_df_list_seller_1y
,concat_ws(',', collect_set(hex(unbase64(hash_shopee_df)))) as frequency_hex_hash_shopee_df_list_seller_1y
,concat_ws(',', collect_set(tongdun_device_id)) as frequency_tongdun_device_id_list_seller_1y
,concat_ws(',', collect_set(sz_dfp_device_id)) as frequency_sz_dfp_device_id_list_seller_1y
from
(
select
    user_id
    ,shopee_df
    ,hash_shopee_df
    ,tongdun_device_id
    ,sz_dfp_device_id
    ,grass_region
from risk.frequency_device_1y_${reg}
union all
select
    user_id
    ,shopee_df
    ,hash_shopee_df
    ,tongdun_device_id
    ,sz_dfp_device_id
    ,grass_region
from risk.user_device_login_30d_1y_${reg}
) a1
group by user_id,grass_region
) t1
;

drop table if exists risk.complete_city_table_${reg};
create table risk.complete_city_table_${reg} stored as orc as
select
    buyer_id as user_id
    ,grass_region
    ,city_name
from ${SCHEMA}.dws_risk_buyer_city_complete_df
where tz_type='local'
  and grass_date = date('${bizdate}')
  and grass_region = upper('${reg}')
  and buyer_id is not null
  and (complete_physical_product_ord_cnt_6m > 2
    or checkout_shipping_same_city_of_complete_physical_product_ord_cnt_6m > 1
    )
;

drop table if exists risk.complete_city_table_without_proxy_${reg};
create table risk.complete_city_table_without_proxy_${reg} stored as orc as
select
    buyer_id as user_id
    ,grass_region
    ,city_name
from ${SCHEMA}.dws_risk_buyer_city_complete_df
where tz_type='local'
  and grass_date = date('${bizdate}')
  and grass_region = upper('${reg}')
  and buyer_id is not null
  and (complete_physical_product_ord_cnt_without_proxy_6m > 2
    or checkout_shipping_same_city_of_complete_physical_product_ord_cnt_without_proxy_6m > 1
    )
;

drop table if exists risk.last_login_${reg};
create table risk.last_login_${reg} stored as orc as
select
    user_id
    ,grass_region
    ,fst_login_city_name_td
from ${SCHEMA}.dws_risk_user_login_df
where tz_type='local'
  and grass_date = date('${bizdate}')
  and grass_region = upper('${reg}')
  and user_id is not null
  and fst_login_city_name_td is not null
;

drop table if exists risk.last_login_without_proxy_${reg};
create table risk.last_login_without_proxy_${reg} stored as orc as
select
    user_id
    ,grass_region
    ,fst_login_city_name_td
from ${SCHEMA}.dws_risk_user_login_df
where tz_type='local'
  and grass_date = date('${bizdate}')
  and grass_region = upper('${reg}')
  and user_id is not null
  and fst_login_city_name_td is not null
  and fst_login_proxy_type_td = 0
;

drop table if exists risk.frequency_city_all_${reg};
create table risk.frequency_city_all_${reg} stored as orc as
select
    user_id
    ,grass_region
    ,concat_ws(',', collect_set(city_name)) as frequency_city_name_list_6m
from (
    select
        user_id
        ,grass_region
        ,city_name
    from risk.complete_city_table_${reg}
    where city_name is not null
    union all
    select
        user_id
        ,grass_region
        ,fst_login_city_name_td as city_name
    from risk.last_login_${reg}
    where fst_login_city_name_td is not null
) a1
group by
    user_id
    ,grass_region
having frequency_city_name_list_6m <> ''
;

drop table if exists risk.frequency_city_without_proxy_${reg};
create table risk.frequency_city_without_proxy_${reg} stored as orc as
select
    user_id
    ,grass_region
    ,concat_ws(',', collect_set(city_name)) as frequency_city_name_list_without_proxy_6m
from (
    select
        user_id
        ,grass_region
        ,city_name
    from risk.complete_city_table_without_proxy_${reg}
    where city_name is not null
    union all
    select
        user_id
        ,grass_region
        ,fst_login_city_name_td as city_name
    from risk.last_login_without_proxy_${reg}
) a1
group by
    user_id
    ,grass_region
having frequency_city_name_list_without_proxy_6m <> ''
;

create or replace temporary view frequency_city as
select
    a1.user_id
    ,a1.grass_region
    ,a1.frequency_city_name_list_6m
    ,a2.frequency_city_name_list_without_proxy_6m
from risk.frequency_city_all_${reg} a1
left join risk.frequency_city_without_proxy_${reg} a2
on a1.user_id = a2.user_id and a1.grass_region = a2.grass_region
;

create or replace temporary view user_order_cnt as
select
    shopee_user_id
    ,completed_order_avg_duration_1m
    ,completed_order_avg_duration_3m
    ,completed_order_avg_duration_6m
    ,last3_completed_order_avg_duration_3m
from risk_feature.dws_risk_${reg}_user_txn_mp_feature_df
where grass_date = '${bizdate}'
;

create or replace temporary view buyer_contact_history_tab as
select 
buyer_id as user_id, all_shipping_addresses, all_recipient_phones, grass_region
from risk.ads_risk_${grass_region_marker}_buyer_contact_history_df where grass_date = '${ds}'
;

create or replace temporary view tmp_sz_device_feature_df as
select
    user_id
    ,frequency_sz_dfp_device_id_list_1y_v3
    ,frequency_sz_dfp_device_id_list_seller_1y_v3
    ,szdf_ever_login_1y
    ,silence_day_cnt_td_v3
    ,frequency_city_name_list_6m_v3
    ,grass_region
from ${SCHEMA}.dws_risk_user_behavior_sz_device_feature_df
where grass_region = upper('${reg}')
and grass_date = '${grass_date}'
;



insert overwrite table ${SCHEMA}.ads_risk_profile_user_df partition (tz_type='local', grass_region, grass_date )
select
    usr.user_id
    ,usr.shop_id
    ,usr.config_addr_list_td
    ,f_device.frequency_shopee_df_list_1y
    ,f_device.frequency_hex_hash_shopee_df_list_1y
    ,f_device.frequency_tongdun_device_id_list_1y
    ,f_city.frequency_city_name_list_6m
    ,f_city.frequency_city_name_list_without_proxy_6m
    ,f_phone.frequency_phone_list_td
    ,net.fst_lvl_network_user_id_list_td
    ,login_device_td.silence_day_cnt_td
    ,lf_device.frequency_shopee_df_list_seller_1y
    ,lf_device.frequency_hex_hash_shopee_df_list_seller_1y
    ,lf_device.frequency_tongdun_device_id_list_seller_1y
    ,usr.shopee_registration_timestamp
    ,usr.shopee_loyalty
    ,f_device.frequency_sz_dfp_device_id_list_1y
    ,lf_device.frequency_sz_dfp_device_id_list_seller_1y
    ,usr_order.completed_order_avg_duration_1m
    ,usr_order.completed_order_avg_duration_3m
    ,usr_order.completed_order_avg_duration_6m
    ,usr_order.last3_completed_order_avg_duration_3m
    ,net_szdf.fst_lvl_network_user_id_list_sz_dfp_td
    ,user_login_szdf.login_szdf_3d
    ,user_login_szdf.login_szdf_7d
    ,user_login_szdf.login_szdf_14d
    ,user_login_szdf.login_szdf_30d
    ,user_login_szdf.login_szdf_60d
    ,user_login_szdf.login_bad_szdf_3d
    ,user_login_szdf.login_bad_szdf_7d
    ,user_login_szdf.login_bad_szdf_14d
    ,user_login_szdf.login_bad_szdf_30d
    ,user_login_szdf.login_bad_szdf_60d
    ,user_login_info.buyer_login_days_in_14d
    ,user_login_info.buyer_login_days_in_30d
    ,user_login_info.buyer_login_days_in_60d
    ,user_login_info.buyer_login_days_in_180d
    ,user_city_name.frequency_city_name_list_6m_new
    ,new_login_tab.frequency_sz_dfp_device_id_list_seller_1y_v2
    ,buyer_contact_history_tab.all_shipping_addresses as completed_orders_receiver_address_list
    ,buyer_contact_history_tab.all_recipient_phones as completed_orders_receiver_phone_list
    ,tmp_sz_device_feature_df.frequency_sz_dfp_device_id_list_1y_v3
    ,tmp_sz_device_feature_df.frequency_sz_dfp_device_id_list_seller_1y_v3
    ,tmp_sz_device_feature_df.szdf_ever_login_1y
    ,tmp_sz_device_feature_df.silence_day_cnt_td_v3
    ,tmp_sz_device_feature_df.frequency_city_name_list_6m_v3
    ,is_svip_active_df.is_svip_active
    ,usr.grass_region
    ,cast('${bizdate}' as date) as grass_date
from
(
    select
        user_id
        ,shop_id
        ,shopee_registration_timestamp
        ,shopee_loyalty
        ,config_addr_list_td
        ,grass_region
    from ${SCHEMA}.dws_risk_user_info_metrics_1_df
    where grass_date = '${bizdate}' and grass_region = upper('${reg}')
)
 as usr
left outer join risk.network_${reg} net
  on usr.user_id = net.user_id
    and usr.grass_region = net.grass_region
left outer join risk.login_device_td_${reg} login_device_td
  on usr.user_id = login_device_td.user_id
    and usr.grass_region = login_device_td.grass_region
left outer join frequency_device f_device
  on usr.user_id = f_device.user_id
    and usr.grass_region = f_device.grass_region
left outer join login_device_30days_1y lf_device
  on usr.user_id = lf_device.user_id
    and usr.grass_region = lf_device.grass_region
left outer join frequency_city f_city
  on usr.user_id = f_city.user_id
    and usr.grass_region = f_city.grass_region
left outer join risk.dws_risk_user_behavior_mp_frequency_phone_df f_phone
  on usr.user_id = f_phone.user_id
    and usr.grass_region = f_phone.grass_region
    and f_phone.grass_date = '${bizdate}'
left outer join user_order_cnt usr_order 
  on usr.user_id = usr_order.shopee_user_id 
left outer join risk.network_szdf_${reg} net_szdf 
  on usr.user_id = net_szdf.user_id
  and usr.grass_region = net_szdf.grass_region 
left outer join ${SCHEMA}.dws_risk_af_user_device_login_nd user_login_szdf
  on usr.user_id = user_login_szdf.user_id 
  and usr.grass_region = user_login_szdf.grass_region 
  and user_login_szdf.grass_date = '${bizdate}'
left outer join ${SCHEMA}.dws_risk_user_login_info_df user_login_info
  on usr.user_id = user_login_info.user_id
  and usr.grass_region = user_login_info.grass_region
  and user_login_info.grass_date = '${bizdate}'
left outer join risk.dws_risk_user_city_name_nd user_city_name
  on usr.user_id = user_city_name.user_id
  and usr.grass_region = user_city_name.grass_region
  and user_city_name.grass_date = '${bizdate}'
left outer join risk.tmp_new_risk_login_1year_${reg} new_login_tab
  on usr.user_id = new_login_tab.user_id
  and usr.grass_region = new_login_tab.grass_region
left outer join buyer_contact_history_tab buyer_contact_history_tab
  on usr.user_id = buyer_contact_history_tab.user_id
  and usr.grass_region = buyer_contact_history_tab.grass_region
left outer join tmp_sz_device_feature_df
  on usr.user_id = tmp_sz_device_feature_df.user_id
  and usr.grass_region = tmp_sz_device_feature_df.grass_region 
left join (
    select  ${non_dfs_comment} shopee_user_id,
            ${dfs_comment} cast(user_id as string) as shopee_user_id,
            is_svip_active
    from    ${is_svip_active_ft_tbl}
    where   grass_date = '${bizdate}'
    ${dfs_comment} and tz_type = 'local'
    ${dfs_comment} and grass_region = '${grass_region}'
) is_svip_active_df
on usr.user_id = is_svip_active_df.shopee_user_id
;

create or replace view ${SCHEMA}.ads_risk_${reg}_profile_user_df as
select
    *
from ${SCHEMA}.ads_risk_profile_user_df
where
    grass_region = upper('${reg}')
;