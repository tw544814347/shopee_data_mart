-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-11-19
-- Theme Domain:        User Behavior Login
-- Data Granularity:    
-- Description:         Daily user device login accumulated table
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-11-19 - chengguo.liu - 初始化
-- =============================================================================

--drop table if exists ${SCHEMA}.dws_risk_user_sz_device_login_version_df;
create external table if not exists ${SCHEMA}.dws_risk_user_sz_device_login_version_df
(
    user_id bigint comment 'shopee user id'
    ,fst_login_ip_td string comment 'the ip of first login time'
    ,fst_login_proxy_type_td string comment 'proxy type of first logic time'
    ,fst_login_city_name_td string comment 'the city name of first login time'
    ,fst_login_timestamp_td bigint comment 'first timestamp login'
    ,lst_login_timestamp_td bigint comment 'last timestamp login'
    ,fst_login_sz_dfp_device_id_td string comment 'the sz dfp device id of the first login time'
    ,lst_login_sz_dfp_device_id_td string comment 'the sz dfp device id of the latest login time'
    ,shopeepay_user_id string comment 'spp uid'
)
comment 'risk feature summary table'
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_sz_device_login_version_df';
--msck repair table ${SCHEMA}.dws_risk_user_sz_device_login_version_df;


create or replace temporary function get_ip_to_city as 'com.shopee.de.udf.IP.v1.IP2LocLookupWithProxy';

create or replace temporary view today_data as
select
    user_id
    ,grass_region
    ,max(case when asc_rn = 1 then login_ip end) as fst_login_ip_td
    ,max(case when asc_rn = 1 then login_timestamp end) as fst_login_timestamp_td
    ,max(case when desc_rn = 1 then login_timestamp end) as lst_login_timestamp_td
    ,max(case when asc_dev_rn = 1 and is_device = "Y" then sz_dfp_device_id end) as fst_login_sz_dfp_device_id_td
    ,max(case when desc_dev_rn = 1 and is_device = "Y" then sz_dfp_device_id end) as lst_login_sz_dfp_device_id_td
from (
    select
        *
        ,row_number() over(partition by user_id, grass_region order by login_timestamp asc) as asc_rn
        ,row_number() over(partition by user_id, grass_region order by login_timestamp desc) as desc_rn
        ,row_number() over(partition by user_id, grass_region order by is_device desc, login_timestamp asc) as asc_dev_rn
        ,row_number() over(partition by user_id, grass_region order by is_device desc, login_timestamp desc) as desc_dev_rn
    from ${SCHEMA}.dwd_risk_szdf_login_di
    where grass_date = date('${grass_date}')
      and tz_type = 'local'
      and is_login = "Y"
      and grass_region = upper('${region}')
) a1
where (asc_rn = 1 or desc_rn = 1 or asc_dev_rn = 1 or desc_dev_rn = 1)
group by
    user_id
    ,grass_region;

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
    ,a1.fst_login_timestamp_td
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
    ,coalesce(a1.fst_login_timestamp_td, a2.fst_login_timestamp_td) as fst_login_timestamp_td
    ,coalesce(a2.lst_login_timestamp_td, a1.lst_login_timestamp_td) as lst_login_timestamp_td
    ,coalesce(a1.fst_login_sz_dfp_device_id_td, a2.fst_login_sz_dfp_device_id_td) as fst_login_sz_dfp_device_id_td
    ,coalesce(a2.lst_login_sz_dfp_device_id_td, a1.lst_login_sz_dfp_device_id_td) as lst_login_sz_dfp_device_id_td
    ,coalesce(a1.grass_region, a2.grass_region) as grass_region
    ,date('${grass_date}') as grass_date
from (
    select
        *
    from ${SCHEMA}.dws_risk_user_sz_device_login_version_df
    where grass_date = date_sub(date('${grass_date}'), 1)
      and tz_type = 'local'
      and grass_region = upper('${region}')
) a1
full outer join convert_data a2
  on a1.user_id = a2.user_id
    and a1.grass_region = a2.grass_region;

insert overwrite table ${SCHEMA}.dws_risk_user_sz_device_login_version_df partition (tz_type='local', grass_region, grass_date)
select
    t1.user_id
    ,t1.fst_login_ip_td
    ,t1.fst_login_proxy_type_td
    ,t1.fst_login_city_name_td
    ,t1.fst_login_timestamp_td
    ,t1.lst_login_timestamp_td
    ,t1.fst_login_sz_dfp_device_id_td
    ,t1.lst_login_sz_dfp_device_id_td
    ,spp.shopeepay_user_id
    ,t1.grass_region
    ,'${grass_date}' as grass_date
from merge_table t1
left join (
    select
    *
    from risk.dim_risk_${region}_sp_to_spp_id_mapping_df
    where grass_date = (select max(grass_date) from risk.dim_risk_${region}_sp_to_spp_id_mapping_df)
) spp 
on (t1.user_id=spp.shopee_user_id)
;


create or replace view ${SCHEMA}.dws_risk_${region}_user_sz_device_login_version_df as
select
    *
from ${SCHEMA}.dws_risk_user_sz_device_login_version_df
where
    grass_region = upper('${region}')
;