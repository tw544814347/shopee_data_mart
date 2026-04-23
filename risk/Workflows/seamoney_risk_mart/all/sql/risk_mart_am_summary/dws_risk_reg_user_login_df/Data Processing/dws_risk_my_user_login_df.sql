create or replace temporary function get_ip_to_city as 'com.shopee.de.udf.IP.v1.IP2LocLookupWithProxy';

create or replace temporary view today_data as
select
    user_id
    ,grass_region
    ,max(case when asc_rn = 1 then login_ip end) as fst_login_ip_td
    ,max(case when asc_rn = 1 then login_timestamp end) as fst_login_timestamp_td
    ,max(case when desc_rn = 1 then login_timestamp end) as lst_login_timestamp_td
    ,max(case when asc_dev_rn = 1 and is_device = "Y" then shopee_df end) as fst_login_shopee_df_td
    ,max(case when desc_dev_rn = 1 and is_device = "Y" then shopee_df end) as lst_login_shopee_df_td
    ,max(case when asc_dev_rn = 1 and is_device = "Y" then shopee_device_id end) as fst_login_shopee_device_id_td
    ,max(case when desc_dev_rn = 1 and is_device = "Y" then shopee_device_id end) as lst_login_shopee_device_id_td
    ,max(case when asc_dev_rn = 1 and is_device = "Y" then sz_dfp_device_id end) as fst_login_sz_dfp_device_id_td
    ,max(case when desc_dev_rn = 1 and is_device = "Y" then sz_dfp_device_id end) as lst_login_sz_dfp_device_id_td
from (
    select
        *
        ,row_number() over(partition by user_id, grass_region order by login_timestamp asc) as asc_rn
        ,row_number() over(partition by user_id, grass_region order by login_timestamp desc) as desc_rn
        ,row_number() over(partition by user_id, grass_region order by is_device desc, login_timestamp asc) as asc_dev_rn
        ,row_number() over(partition by user_id, grass_region order by is_device desc, login_timestamp desc) as desc_dev_rn
    from ${SCHEMA}.dwd_risk_login_di
    where grass_date = date('${bizdate}')
      and tz_type = 'local'
      and is_login = "Y"
      and grass_region = upper('${region}')
) a1
where (asc_rn = 1 or desc_rn = 1 or asc_dev_rn = 1 or desc_dev_rn = 1)
group by
    user_id
    ,grass_region;

create or replace temporary view tongdun as
select
    shopee_df
    ,shopee_device_id
    ,tongdun_device_id
    ,grass_region
from ${SCHEMA}.dim_risk_tongdun_device_mapping_tab
where tz_type = 'local'
  and grass_region = upper('${region}')
  and shopee_device_id <> ''
;

create or replace temporary view tongdun_history as
select
    shopee_df
    ,shopee_device_id
    ,tongdun_device_id
from ${SCHEMA}.dim_risk_tongdun_device_mapping_history_df
where tz_type = 'local'
and shopee_device_id <> ''
;

create or replace temporary view convert_data as
select
    a1.user_id
    ,a1.grass_region
    ,a1.fst_login_ip_td
    ,case
        when coalesce(fst_login_ip_td, '') <> ''  then get_ip_to_city(fst_login_ip_td)[4]
        end as fst_login_city_name_td
    ,case
        when coalesce(fst_login_ip_td, '') <> '' then get_ip_to_city(fst_login_ip_td)[8]
        end as fst_login_proxy_type_td
    ,a1.fst_login_shopee_df_td
    ,a1.fst_login_shopee_device_id_td
    ,a1.fst_login_timestamp_td
    ,a1.lst_login_shopee_df_td
    ,a1.lst_login_shopee_device_id_td
    ,a1.lst_login_timestamp_td
    ,a1.fst_login_sz_dfp_device_id_td
    ,a1.lst_login_sz_dfp_device_id_td
from today_data a1;

create or replace temporary view merge_table as
select
    coalesce(a1.user_id, a2.user_id) as user_id
    ,coalesce(a1.fst_login_ip_td, a2.fst_login_ip_td) as fst_login_ip_td
    ,coalesce(a1.fst_login_proxy_type_td, a2.fst_login_proxy_type_td) as fst_login_proxy_type_td
    ,coalesce(a1.fst_login_city_name_td, a2.fst_login_city_name_td) as fst_login_city_name_td
    ,coalesce(a1.fst_login_shopee_df_td, a2.fst_login_shopee_df_td) as fst_login_shopee_df_td
    ,coalesce(a1.fst_login_shopee_device_id_td, a2.fst_login_shopee_device_id_td) as fst_login_shopee_device_id_td
    ,coalesce(a1.fst_login_timestamp_td, a2.fst_login_timestamp_td) as fst_login_timestamp_td
    ,coalesce(a2.lst_login_shopee_df_td, a1.lst_login_shopee_df_td) as lst_login_shopee_df_td
    ,coalesce(a2.lst_login_shopee_device_id_td, a1.lst_login_shopee_device_id_td) as lst_login_shopee_device_id_td
    ,coalesce(a2.lst_login_timestamp_td, a1.lst_login_timestamp_td) as lst_login_timestamp_td
    ,coalesce(a1.fst_login_sz_dfp_device_id_td, a2.fst_login_sz_dfp_device_id_td) as fst_login_sz_dfp_device_id_td
    ,coalesce(a2.lst_login_sz_dfp_device_id_td, a1.lst_login_sz_dfp_device_id_td) as lst_login_sz_dfp_device_id_td
    ,coalesce(a1.grass_region, a2.grass_region) as grass_region
    ,date('${bizdate}') as grass_date
from (
    select
        *
    from ${SCHEMA}.dws_risk_user_login_df
    where grass_date = date_sub(date('${bizdate}'), 1)
      and tz_type = 'local'
      and grass_region = upper('${region}')
) a1
full outer join convert_data a2
  on a1.user_id = a2.user_id
    and a1.grass_region = a2.grass_region;

insert overwrite table ${SCHEMA}.dws_risk_user_login_df partition (tz_type='local', grass_region, grass_date)
select
    user_id
    ,fst_login_ip_td
    ,fst_login_proxy_type_td
    ,fst_login_city_name_td
    ,fst_login_shopee_df_td
    ,fst_login_shopee_device_id_td
    ,coalesce(a2.tongdun_device_id, b1.tongdun_device_id) as fst_login_tongdun_device_id_td
    ,fst_login_timestamp_td
    ,lst_login_shopee_df_td
    ,lst_login_shopee_device_id_td
    ,coalesce(a3.tongdun_device_id, b2.tongdun_device_id) as lst_login_tongdun_device_id_td
    ,lst_login_timestamp_td
    ,a1.fst_login_sz_dfp_device_id_td
    ,a1.lst_login_sz_dfp_device_id_td
    ,a1.grass_region
    ,date('${bizdate}') as grass_date
from merge_table a1
left outer join tongdun a2
  on a1.fst_login_shopee_device_id_td = a2.shopee_device_id
    and a1.grass_region = a2.grass_region
left outer join tongdun_history b1
  on a2.tongdun_device_id is null and a1.fst_login_shopee_device_id_td = b1.shopee_device_id
left outer join tongdun a3
  on a1.lst_login_shopee_device_id_td = a3.shopee_device_id
    and a1.grass_region = a3.grass_region
left outer join tongdun_history b2
  on a3.tongdun_device_id is null and a1.lst_login_shopee_device_id_td = b2.shopee_device_id
;