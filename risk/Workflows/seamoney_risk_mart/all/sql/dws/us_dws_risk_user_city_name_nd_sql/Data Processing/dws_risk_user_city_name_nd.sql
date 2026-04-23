--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-08-13
-- Theme Domain：       user city_name
-- Description:         用户最近180天的city_name,因为udf get_ip_to_city不太稳定可能会某天拿不到用户的cityname,因此新增兜底逻辑,取最近180天的用户cityname
-- Data Granularity:   
-- jira: https://jira.shopee.io/browse/SPFDT-42574 (讨论后是新做一个feature,frequency_city_name_list_6m_new) 
-- 变更历史：
--********************************************************************--
create or replace temporary view tmp_buyer_city_name as
select
    buyer_id as user_id
    ,grass_region
    ,checkout_city_name as city_name
from risk.dwd_risk_order_complete_di
where grass_date <= date('${bizdate}')
and grass_date > date_sub(date('${bizdate}'), 180)
and coalesce(checkout_ip, '') <> ''
and tz_type = 'local'
and grass_region in ${batch_region_am}
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
from risk.dws_risk_user_login_df
where tz_type='local'
  and grass_date >= date_sub('${grass_date}',180)
  and grass_region in ${batch_region_pm}
  and user_id is not null
  and fst_login_city_name_td is not null
group by user_id
    ,grass_region
    ,fst_login_city_name_td
;
insert overwrite table risk.dws_risk_user_city_name_nd partition(grass_region,grass_date)
select
    user_id
    ,concat_ws(',', collect_set(city_name)) as frequency_city_name_list_6m_new
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
having frequency_city_name_list_6m_new <> '' 
;

