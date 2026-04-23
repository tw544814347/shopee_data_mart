--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-08-13
-- Theme Domain：       user profile
-- Description:         
-- Data Granularity:   
-- 变更历史：
-- zongyi.lu@shopee.com 将whitelist相关的字段置null 不涉及线上(当时的需求单子https://jira.shopee.io/browse/SPFDT-16962)
-- 20240813 zongyi.lu@shopee.com 1.新增注释 2.用户最近180天的city_name,因为udf get_ip_to_city不太稳定可能会某天拿不到用户的cityname,因此新增兜底逻辑,取最近180天的用户cityname https://jira.shopee.io/browse/SPFDT-42574
-- 20260105 wei.tao 统一模板 拆分地区 
-- 20260311 chenyingying 新增字段is_svip_active, jira: https://jira.shopee.io/browse/SPFDT-61284
--********************************************************************--

set spark.sql.hive.convertMetastoreParquet=false;
drop table if exists risk.tmp_config_address_pm_${reg};


create table risk.tmp_config_address_pm_${reg} stored as orc as
select
    user_id
    ,grass_region
    ,concat_ws(',', collect_set(trim(regexp_replace(config_address, ',', '')))) as config_addr_list_td
from ${SCHEMA}.dim_risk_user_address_df
where tz_type='local'
  and grass_region = upper('${reg}')
  and grass_date = date('${bizdate}')
  and trim(regexp_replace(config_address, ',', '')) <> ''
  and (is_valid = 'Y'
    or (is_valid = 'N'
        and modified_time <= unix_timestamp(date('${bizdate}'))
        and modified_time > unix_timestamp(date('${bizdate}')- interval 90 day)
        )
    )
group by
    user_id
    ,grass_region
having config_addr_list_td <> ''
;

drop table if exists risk.tmp_network_base_pm_${reg};
create table risk.tmp_network_base_pm_${reg} stored as orc as
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

drop table if exists risk.tmp_network_pm_${reg};
create table risk.tmp_network_pm_${reg} stored as orc as
select
    a1.user_id
    ,a1.grass_region
    ,concat_ws(',', collect_set(a2.user_id)) as fst_lvl_network_user_id_list_td
from risk.tmp_network_base_pm_${reg} a1
left outer join risk.tmp_network_base_pm_${reg} a2
  on a1.tongdun_device_id = a2.tongdun_device_id
where a1.user_id <> a2.user_id
group by
    a1.user_id
    ,a1.grass_region
having fst_lvl_network_user_id_list_td <> ''
;

drop table if exists risk.tmp_network_szdf_pm_${reg};
create table risk.tmp_network_szdf_pm_${reg} stored as orc as
select
    a1.user_id
    ,a1.grass_region
    ,concat_ws(',', collect_set(a2.user_id)) as fst_lvl_network_user_id_list_sz_dfp_td
from risk.tmp_network_base_pm_${reg} a1
left outer join risk.tmp_network_base_pm_${reg} a2
  on a1.sz_dfp_device_id = a2.sz_dfp_device_id
where a1.user_id <> a2.user_id
group by
    a1.user_id
    ,a1.grass_region
having fst_lvl_network_user_id_list_sz_dfp_td <> ''
;

drop table if exists risk.tmp_login_device_td_pm_${reg};
create table risk.tmp_login_device_td_pm_${reg} stored as orc as
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

drop table if exists risk.tmp_complete_dev_table_pm_${reg};
create table risk.tmp_complete_dev_table_pm_${reg} stored as orc as
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

drop table if exists risk.tmp_frequency_device_1y_pm_${reg};
create table risk.tmp_frequency_device_1y_pm_${reg} stored as orc as
select
    user_id
    ,grass_region
    ,shopee_df
    ,hash_shopee_df
    ,tongdun_device_id
    ,sz_dfp_device_id
from risk.tmp_complete_dev_table_pm_${reg}
where hash_shopee_df is not null
union all
select
    user_id
    ,grass_region
    ,fst_login_shopee_df_td as shopee_df
    ,fst_login_hash_shopee_df_td as hash_shopee_df
    ,fst_login_tongdun_device_id_td as tongdun_device_id
    ,fst_login_sz_dfp_device_id_td as sz_dfp_device_id
from risk.tmp_login_device_td_pm_${reg}
where fst_login_hash_shopee_df_td is not null
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
from risk.tmp_frequency_device_1y_pm_${reg}
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

drop table if exists risk.tmp_frequency_device_pm_${reg};
create table risk.tmp_frequency_device_pm_${reg} stored as orc as
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
    from risk.tmp_frequency_device_1y_pm_${reg} a1
    group by
        user_id
        ,grass_region
    having frequency_shopee_df_list_1y <> '' or frequency_hex_hash_shopee_df_list_1y <> ''
     or frequency_tongdun_device_id_list_1y <> '' or frequency_sz_dfp_device_id_list_1y <> ''
) a1
;

drop table if exists risk.tmp_shopee_device_login_year_df_pm_${reg};
create table risk.tmp_shopee_device_login_year_df_pm_${reg} stored as orc as
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
    and grass_region = upper('${reg}')
    and grass_date >= date_sub(date('${bizdate}'), 365)
    and grass_date <= date('${bizdate}')
group by user_id, shopee_df, grass_region, grass_date
) t
group by t.user_id, t.shopee_df, t.grass_region
having count(t.grass_date) > 30
) a1
left join (
    select 'MX' as grass_region, userid, device_fingerprint, hashed_fingerprint from marketplace.shopee_device_extension_mx_db__device_ext_tab__reg_continuous_s0_live group by userid, device_fingerprint, hashed_fingerprint
    union all
    select 'BR' as grass_region, userid, device_fingerprint, hashed_fingerprint from marketplace.shopee_device_extension_br_db__device_ext_tab__reg_continuous_s0_live group by userid, device_fingerprint, hashed_fingerprint
) a2
on a1.user_id = a2.userid and a1.shopee_df = a2.device_fingerprint
and a1.grass_region = a2.grass_region
;

drop table if exists risk.tmp_tongdun_device_login_year_df_pm_${reg};
create table risk.tmp_tongdun_device_login_year_df_pm_${reg} stored as orc as
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
    and grass_region = upper('${reg}')
    and grass_date >= date_sub(date('${bizdate}'), 365)
    and grass_date <= date('${bizdate}')
group by user_id, tongdun_device_id, grass_region, grass_date
) t
group by user_id, tongdun_device_id, grass_region
having count(grass_date) > 30
;

drop table if exists risk.tmp_sz_dfp_device_login_year_df_pm_${reg};
create table risk.tmp_sz_dfp_device_login_year_df_pm_${reg} stored as orc as
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
    and grass_region = upper('${reg}')
    and grass_date >= date_sub(date('${bizdate}'), 365)
    and grass_date <= date('${bizdate}')
group by user_id, sz_dfp_device_id, grass_region, grass_date
) t
group by user_id, sz_dfp_device_id, grass_region
having count(grass_date) > 30
;

drop table if exists risk.tmp_user_device_login_30d_1y_pm_${reg};
create table risk.tmp_user_device_login_30d_1y_pm_${reg} stored as orc as
select
    user_id
    ,shopee_df
    ,hash_shopee_df
    ,null as tongdun_device_id
    ,null as sz_dfp_device_id
    ,grass_region
from risk.tmp_shopee_device_login_year_df_pm_${reg}
union all
select
    user_id
    ,null as shopee_df
    ,null as hash_shopee_df
    ,tongdun_device_id
    ,null as sz_dfp_device_id
    ,grass_region
from risk.tmp_tongdun_device_login_year_df_pm_${reg}
union all
select
    user_id
    ,null as shopee_df
    ,null as hash_shopee_df
    ,null as tongdun_device_id
    ,sz_dfp_device_id
    ,grass_region
from risk.tmp_sz_dfp_device_login_year_df_pm_${reg}
;

drop table if exists risk.tmp_login_device_30days_1y_pm_${reg};
create table risk.tmp_login_device_30days_1y_pm_${reg} stored as orc as
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
from risk.tmp_frequency_device_1y_pm_${reg}
union all
select
    user_id
    ,shopee_df
    ,hash_shopee_df
    ,tongdun_device_id
    ,sz_dfp_device_id
    ,grass_region
from risk.tmp_user_device_login_30d_1y_pm_${reg}
) a1
group by user_id,grass_region
) t1
;

drop table if exists risk.tmp_complete_city_table_pm_${reg};
create table risk.tmp_complete_city_table_pm_${reg} stored as orc as
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

drop table if exists risk.tmp_complete_city_table_without_proxy_pm_${reg};
create table risk.tmp_complete_city_table_without_proxy_pm_${reg} stored as orc as
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

drop table if exists risk.tmp_last_login_pm_${reg};
create table risk.tmp_last_login_pm_${reg} stored as orc as
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

drop table if exists risk.tmp_last_login_without_proxy_pm_${reg};
create table risk.tmp_last_login_without_proxy_pm_${reg} stored as orc as
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

drop table if exists risk.tmp_frequency_city_all_pm_${reg};
create table risk.tmp_frequency_city_all_pm_${reg} stored as orc as
select
    user_id
    ,grass_region
    ,concat_ws(',', collect_set(city_name)) as frequency_city_name_list_6m
from (
    select
        user_id
        ,grass_region
        ,city_name
    from risk.tmp_complete_city_table_pm_${reg}
    where city_name is not null
    union all
    select
        user_id
        ,grass_region
        ,fst_login_city_name_td as city_name
    from risk.tmp_last_login_pm_${reg}
    where fst_login_city_name_td is not null
) a1
group by
    user_id
    ,grass_region
having frequency_city_name_list_6m <> ''
;

drop table if exists risk.tmp_frequency_city_without_proxy_pm_${reg};
create table risk.tmp_frequency_city_without_proxy_pm_${reg} stored as orc as
select
    user_id
    ,grass_region
    ,concat_ws(',', collect_set(city_name)) as frequency_city_name_list_without_proxy_6m
from (
    select
        user_id
        ,grass_region
        ,city_name
    from risk.tmp_complete_city_table_without_proxy_pm_${reg}
    where city_name is not null
    union all
    select
        user_id
        ,grass_region
        ,fst_login_city_name_td as city_name
    from risk.tmp_last_login_without_proxy_pm_${reg}
) a1
group by
    user_id
    ,grass_region
having frequency_city_name_list_without_proxy_6m <> ''
;

drop table if exists risk.tmp_frequency_city_pm_${reg};
create table risk.tmp_frequency_city_pm_${reg} stored as orc as
select
    a1.user_id
    ,a1.grass_region
    ,a1.frequency_city_name_list_6m
    ,a2.frequency_city_name_list_without_proxy_6m
from risk.tmp_frequency_city_all_pm_${reg} a1
left join risk.tmp_frequency_city_without_proxy_pm_${reg} a2
on a1.user_id = a2.user_id and a1.grass_region = a2.grass_region
;

drop table if exists risk.tmp_user_table_pm_${reg};
create table risk.tmp_user_table_pm_${reg} stored as orc as
select
    t1.user_id
    ,t1.shop_id
    ,t1.shopee_registration_timestamp
    ,t2.shopee_loyalty
    ,t1.grass_region
from
(
    select
        user_id
        ,shop_id
        ,registration_timestamp as shopee_registration_timestamp
        ,grass_region
    from mp_user.dim_user__reg_s0_live
    where tz_type = 'local'
        and grass_region = upper('${reg}')
        and grass_date = date('${bizdate}')
) t1
left join
(
    select
        user_id
        ,case
            when loyalty_tier = 10 then 'classic'
            when loyalty_tier = 20 then 'silver'
            when loyalty_tier = 30 then 'gold'
            when loyalty_tier = 40 then 'platinum'
            when loyalty_tier = 0 then 'error'
            else 'classic'
        end as shopee_loyalty
        ,grass_region
    from mp_user.dim_user_ext__reg_s0_live
    where
        tz_type = 'local'
        and grass_region = upper('${reg}')
        and grass_date = date('${bizdate}')
) t2
on t1.grass_region = t2.grass_region
and t1.user_id = t2.user_id
;

drop table if exists risk.tmp_phone_td_pm_${reg};
create table risk.tmp_phone_td_pm_${reg} stored as orc as
select
    *
from (
    select
        *
        ,bind_phone as phone
        ,from_unixtime(bind_timestamp) as bind_date
        ,lead(from_unixtime(bind_timestamp), 1, date('${bizdate}')) over(partition by
            user_id, grass_region order by bind_timestamp asc) as next_bind_date
    from ${SCHEMA}.dwd_risk_user_phone_bind_df
    where tz_type='local'
      and grass_date = date('${bizdate}')
      and grass_region = upper('${reg}')
      and bind_phone is not null
) a1
where datediff(next_bind_date, bind_date) > 15;

drop table if exists risk.tmp_phone_fst_pm_${reg};
create table risk.tmp_phone_fst_pm_${reg} stored as orc as
select
    user_id
    ,phone_number as phone
    ,grass_region
from mp_user.dim_user__reg_s1_live
where tz_type = 'local'
    and grass_region = upper('${reg}')
    and grass_date = date('${bizdate}')
    and phone_number is not null
;

drop table if exists risk.tmp_complete_phone_table_pm_${reg};
create table risk.tmp_complete_phone_table_pm_${reg} stored as orc as
select
    buyer_id as user_id
    ,phone
    ,grass_region
from ${SCHEMA}.dws_risk_buyer_phone_complete_df
where tz_type='local'
  and grass_date = date('${bizdate}')
  and grass_region = upper('${reg}')
  and complete_physical_ord_cnt_6m > 2
  and phone is not null
;

drop table if exists risk.tmp_frequency_phone_pm_${reg};
create table risk.tmp_frequency_phone_pm_${reg} stored as orc as
select
    user_id
    ,grass_region
    ,concat_ws(',', collect_set(md5(phone))) as frequency_phone_list_td
from (
    select
        user_id
        ,phone
        ,grass_region
    from risk.tmp_phone_td_pm_${reg}
    union all
    select
        user_id
        ,phone
        ,grass_region
    from risk.tmp_phone_fst_pm_${reg}
    union all
    select
        user_id
        ,phone
        ,grass_region
    from risk.tmp_complete_phone_table_pm_${reg}
) a1
group by
    user_id
    ,grass_region
having frequency_phone_list_td <> ''
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
    ,addr.config_addr_list_td
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
    ,tmp_sz_device_feature_df.frequency_sz_dfp_device_id_list_1y_v3
    ,tmp_sz_device_feature_df.frequency_sz_dfp_device_id_list_seller_1y_v3
    ,tmp_sz_device_feature_df.szdf_ever_login_1y
    ,tmp_sz_device_feature_df.silence_day_cnt_td_v3
    ,tmp_sz_device_feature_df.frequency_city_name_list_6m_v3
    ,is_svip_active_df.is_svip_active
    ,usr.grass_region
    ,cast('${bizdate}' as date) as grass_date
from risk.tmp_user_table_pm_${reg} as usr
left outer join risk.tmp_config_address_pm_${reg} addr
on usr.user_id = addr.user_id
    and usr.grass_region = addr.grass_region
left outer join risk.tmp_network_pm_${reg} net
  on usr.user_id = net.user_id
    and usr.grass_region = net.grass_region
left outer join risk.tmp_login_device_td_pm_${reg} login_device_td
  on usr.user_id = login_device_td.user_id
    and usr.grass_region = login_device_td.grass_region
left outer join risk.tmp_frequency_device_pm_${reg} f_device
  on usr.user_id = f_device.user_id
    and usr.grass_region = f_device.grass_region
left outer join risk.tmp_login_device_30days_1y_pm_${reg} lf_device
  on usr.user_id = lf_device.user_id
    and usr.grass_region = lf_device.grass_region
left outer join risk.tmp_frequency_city_pm_${reg} f_city
  on usr.user_id = f_city.user_id
    and usr.grass_region = f_city.grass_region
left outer join risk.tmp_frequency_phone_pm_${reg} f_phone
  on usr.user_id = f_phone.user_id
    and usr.grass_region = f_phone.grass_region
left outer join risk.tmp_network_szdf_pm_${reg} net_szdf 
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