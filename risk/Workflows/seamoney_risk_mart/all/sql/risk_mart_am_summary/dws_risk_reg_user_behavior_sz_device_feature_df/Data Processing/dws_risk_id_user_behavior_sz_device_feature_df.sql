-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-11-21
-- Theme Domain:        User Behavior Login
-- Data Granularity:    
-- Description:         Daily user device login accumulated table
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-11-21 - chengguo.liu - 初始化
-- =============================================================================

--drop table if exists ${SCHEMA}.dws_risk_user_behavior_sz_device_feature_df;
create external table if not exists ${SCHEMA}.dws_risk_user_behavior_sz_device_feature_df
(
    user_id bigint comment 'shopee user id'
    ,frequency_sz_dfp_device_id_list_1y_v3 string comment 'frequency sz dfp device id list'
    ,frequency_sz_dfp_device_id_list_seller_1y_v3 string comment 'frequency sz dfp device id list seller'
    ,szdf_ever_login_1y string comment 'frequency sz dfp device id list seller'
    ,silence_day_cnt_td_v3 bigint comment 'silence day count'
    ,frequency_city_name_list_6m_v3 string comment 'frequency city name list 6m'
)
comment 'risk feature summary table'
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_behavior_sz_device_feature_df';
--msck repair table ${SCHEMA}.dws_risk_user_behavior_sz_device_feature_df;


create or replace temporary view complete_dev_table as
select
    buyer_id as user_id
    ,grass_region
    ,shopee_df
    ,shopee_device_id as hash_shopee_df
    ,tongdun_device_id
    ,sz_dfp_device_id
from ${SCHEMA}.dws_risk_buyer_device_complete_df
where tz_type='local'
  and grass_date = date('${grass_date}')
  and grass_region = upper('${region}')
  and buyer_id is not null
  and (
    (fas_timestamp_of_complete_physical_product_ord_1y < unix_timestamp(date_sub(date('${grass_date}'), 30))
        and complete_physical_product_ord_cnt_1y > 1)
    or (complete_physical_product_ord_cnt_1y > 3 and complete_physical_product_ord_day_cnt_1y > 3)
    )
;

create or replace temporary view login_device_td as
select
    user_id
    ,grass_region
    ,fst_login_sz_dfp_device_id_td
    ,datediff(date('${current_grass_date}'), from_unixtime(lst_login_timestamp_td)) as silence_day_cnt_td_v3
from ${SCHEMA}.dws_risk_user_sz_device_login_version_df
where tz_type='local'
  and grass_date = date('${grass_date}')
  and grass_region = upper('${region}')
  and user_id is not null
;

create or replace temporary view frequency_device_1y as
select
    user_id
    ,grass_region
    ,sz_dfp_device_id
from complete_dev_table
where sz_dfp_device_id <> ''
union all
select
    user_id
    ,grass_region
    ,fst_login_sz_dfp_device_id_td as sz_dfp_device_id
from login_device_td
where fst_login_sz_dfp_device_id_td <> ''
;

create or replace temporary view frequency_device as
select
    user_id
    ,grass_region
    ,case when frequency_sz_dfp_device_id_list_1y <> '' then frequency_sz_dfp_device_id_list_1y end as frequency_sz_dfp_device_id_list_1y_v3
from (
    select
        user_id
        ,grass_region
        ,concat_ws(',', collect_set(sz_dfp_device_id)) as frequency_sz_dfp_device_id_list_1y
    from frequency_device_1y a1
    group by
        user_id
        ,grass_region
    having frequency_sz_dfp_device_id_list_1y <> ''
) a1
;

create or replace temporary view sz_dfp_device_login_year_df as
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
from ${SCHEMA}.dws_risk_user_sz_device_login_di
where tz_type = 'local'
    and is_spp_source <> '1'
    and grass_region = upper('${region}')
    and grass_date >= date_sub(date('${grass_date}'), 365)
    and grass_date <= date('${grass_date}')
group by user_id, sz_dfp_device_id, grass_region, grass_date
) t
group by user_id, sz_dfp_device_id, grass_region
having count(grass_date) > 30
;

create or replace temporary view login_device_30days_1y as
select
    user_id
    ,case when frequency_sz_dfp_device_id_list_seller_1y <> '' then frequency_sz_dfp_device_id_list_seller_1y end as frequency_sz_dfp_device_id_list_seller_1y_v3
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
from frequency_device_1y
union all
select
    user_id
    ,sz_dfp_device_id
    ,grass_region
from sz_dfp_device_login_year_df
) a1
group by user_id,grass_region
) t1
;

create or replace temporary view tmp_new_risk_login_1year as
select
    user_id
    ,case when frequency_sz_dfp_device_id_list_seller_1y <> '' then frequency_sz_dfp_device_id_list_seller_1y end as szdf_ever_login_1y
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
    from risk.dws_risk_user_sz_device_login_di
    where tz_type = 'local'
        and grass_region = upper('${region}')
        and grass_date >= date_sub(date('${grass_date}'), 365)
        and grass_date <= date('${grass_date}')
) tmp 
group by user_id,grass_region
) t1
;

insert overwrite table ${SCHEMA}.dws_risk_user_behavior_sz_device_feature_df partition(tz_type, grass_region, grass_date)
select
    t1.user_id
    ,t2.frequency_sz_dfp_device_id_list_1y_v3
    ,t3.frequency_sz_dfp_device_id_list_seller_1y_v3
    ,t4.szdf_ever_login_1y
    ,t5.silence_day_cnt_td_v3
    ,t6.frequency_city_name_list_6m_v3
    ,'local' as tz_type
    ,t1.grass_region
    ,'${grass_date}' as grass_date
from
(
    select
        user_id
        ,grass_region
    from mp_user.dim_user__reg_s0_live
    where tz_type = 'local'
        and grass_region = upper('${region}')
        and grass_date = date('${grass_date}')
) t1
left outer join frequency_device t2
    on t1.user_id = t2.user_id and t1.grass_region = t2.grass_region
left outer join login_device_30days_1y t3
    on t1.user_id = t3.user_id and t1.grass_region = t3.grass_region
left outer join tmp_new_risk_login_1year t4
    on t1.user_id = t4.user_id and t1.grass_region = t4.grass_region
left outer join login_device_td t5
    on t1.user_id = t5.user_id and t1.grass_region = t5.grass_region
left outer join (
    select
        user_id
        ,grass_region
        ,frequency_city_name_list_6m_v3
    from risk.dws_risk_user_city_name_version_nd
    where grass_date = '${grass_date}'
) t6
    on t1.user_id = t6.user_id and t1.grass_region = t6.grass_region
;