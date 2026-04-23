-- =============================================================================
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-08-13
-- Theme Domain：       user city_name
-- Description:         用户最近180天的city_name,因为udf get_ip_to_city不太稳定可能会某天拿不到用户的cityname,因此新增兜底逻辑,取最近180天的用户cityname
-- Data Granularity:   
-- 变更历史：       
-- =============================================================================
--  Version History:
--  2024-08-13 - zongyi.lu@shopee.com jira: https://jira.shopee.io/browse/SPFDT-42574 (讨论后是新做一个feature,frequency_city_name_list_6m_new) 
--  2025-11-19 - chengguo.liu  切换到szdf dwd登录表
-- =============================================================================

--drop table if exists ${SCHEMA}.dws_risk_user_city_name_version_nd;
create external table if not exists ${SCHEMA}.dws_risk_user_city_name_version_nd
(
    user_id                                 bigint  comment 'shopee user id'
    ,frequency_city_name_list_6m_v3         string  comment 'frequency city name list'
)
comment 'the address user configured'
partitioned by
(
    grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_city_name_version_nd';
--msck repair table ${SCHEMA}.dws_risk_user_city_name_version_nd;


create or replace temporary view tmp_buyer_city_name as
select
    buyer_id as user_id
    ,grass_region
    ,checkout_city_name as city_name
from risk.dwd_risk_order_complete_di
where grass_date <= date('${grass_date}')
and grass_date > date_sub(date('${grass_date}'), 180)
and coalesce(checkout_ip, '') <> ''
and tz_type = 'local'
and grass_region in ${batch_region_pm_v2}
and is_physical_product_order = 'Y'
and buyer_id is not null 
and checkout_city_name is not null 
group by 
buyer_id
,grass_region
,checkout_city_name
;

create or replace temporary view tmp_login_city_name as
select
    user_id
    ,grass_region
    ,fst_login_city_name_td
from risk.dws_risk_user_sz_device_login_version_df
where tz_type='local'
  and grass_date >= date_sub('${grass_date}',180)
  and grass_region in ${batch_region_pm_v2}
  and user_id is not null
  and fst_login_city_name_td is not null
group by user_id
    ,grass_region
    ,fst_login_city_name_td
;

insert overwrite table ${SCHEMA}.dws_risk_user_city_name_version_nd partition(grass_region,grass_date)
select
    user_id
    ,concat_ws(',', collect_set(city_name)) as frequency_city_name_list_6m_v3
    ,grass_region
    ,'${grass_date}' as grass_date
from (
    select
        user_id
        ,grass_region
        ,city_name
    from tmp_buyer_city_name
    where city_name is not null
    union all
    select
        user_id
        ,grass_region
        ,fst_login_city_name_td as city_name
    from tmp_login_city_name
    where fst_login_city_name_td is not null
) a1
group by
    user_id
    ,grass_region
having concat_ws(',', collect_set(city_name)) <> '' 
;

