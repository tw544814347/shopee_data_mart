------------------------------------------------------------------------
-- Author:              wei.tao@shopee.com
-- Created Time:        2026-02-03
-- Description:         用户行为主题域，SPP User Login主题
-- Data Granularity:    shopeepay user id 
-- PRD:                 
------------------------------------------------------------------------

--dwd_risk_order_complete_di （对于 spuid 映射 sppuid）-- done
--dws_risk_buyer_device_complete_df （对于 spuid 映射 sppuid） --done
    ---->dws_risk_th_buyer_device_complete_di ->dwd_risk_order_item_complete_di ->mp表
--dws_risk_user_sz_device_spp_login_version_df --doing（已经建好表了，需要 backfill）
    --需要改代码部署一个新的 sppuid 的表 --来源于 dwd_risk_szdf_login_di -- 需要加上 sppuid 的映射 


--如果 spp 登录源的数据加上 sppuid 映射，那 merge sp 数据源的情况下，mp 登录数据源的表之后要加 sppuid 吗？如果加的话是用我们自己的方式加映射？

-- drop table if exists ${SCHEMA}.dws_risk_${region}_user_behavior_spp_login_info_df;
create table if not exists ${SCHEMA}.dws_risk_${region}_user_behavior_spp_login_info_df
(
    shopeepay_user_id string comment 'shopeepay_user_id' ,
    frequency_sz_dfp_device_id_list_seller_1y_v2 string comment 'frequency_sz_dfp_device_id_list_seller_1y_v2' , 
    frequency_sz_dfp_device_id_list_1y_v3 string comment 'frequency_sz_dfp_device_id_list_1y_v3' ,
    frequency_sz_dfp_device_id_list_seller_1y_v3 string comment 'frequency_sz_dfp_device_id_list_seller_1y_v3' ,
    szdf_ever_login_1y string comment 'szdf_ever_login_1y' ,--null
    frequency_city_name_list_6m_v3 string comment 'frequency_city_name_list_6m_v3' 
) 
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_behavior_spp_login_info_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_behavior_spp_login_info_df;

create or replace temporary view sz_dfp_device_login_year_df_${region} as 
select
    user_id,
    sz_dfp_device_id,
    grass_region,
    count(grass_date) as cnt_login_1year
from (
    select
        shopeepay_user_id as user_id
        ,sz_dfp_device_id
        ,grass_region
        ,grass_date
    from ${SCHEMA}.dws_risk_user_device_login_di 
    where tz_type = 'local'
        and is_spp_update <> '1' -- 和之前保持一致？
        and grass_region = upper('${region}')
        and grass_date >= date_sub(date('${bizdate}'), 365)
        and grass_date <= date('${bizdate}')
    group by shopeepay_user_id, sz_dfp_device_id, grass_region, grass_date
) t
group by user_id, sz_dfp_device_id, grass_region
having count(grass_date) > 30
;

create or replace temporary view frequency_device_1y as
select
    shopeepay_user_id as user_id
    ,grass_region
    ,fst_login_sz_dfp_device_id_td as sz_dfp_device_id
from ${SCHEMA}.dws_risk_user_sz_device_spp_login_version_df --加工一个 sppid 的 dwd 表的数据出来 dws
where tz_type='local'
  and grass_date = date('${grass_date}')
  and grass_region = upper('${region}')
  and user_id is not null
  and fst_login_sz_dfp_device_id_td <> ''
union all 
-- 需要加入转 sppid 的逻辑吗，混合数据源 frequency_sz_dfp_device_id_list_1y_v3 & frequency_sz_dfp_device_id_list_seller_1y_v3
    select
        buyer_id as user_id --需要的话需要转 sppuid 并且加工出来一个 有 sppuid 的 dws 表
        ,grass_region
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
    and sz_dfp_device_id <> ''
--
;

create or replace temporary view sz_dfp_device_login_year_df as
select
    user_id,
    sz_dfp_device_id,
    grass_region
from (
    select
        shopeepay_user_id as user_id
        ,sz_dfp_device_id
        ,grass_region
        ,grass_date
    from ${SCHEMA}.dws_risk_user_sz_device_login_di -- dwd_risk_v2_login_di
    where tz_type = 'local'
        and is_spp_source = '1' --spp
        and grass_region = upper('${region}')
        and grass_date >= date_sub(date('${grass_date}'), 365)
        and grass_date <= date('${grass_date}')
    group by shopeepay_user_id, sz_dfp_device_id, grass_region, grass_date
) t
group by user_id, sz_dfp_device_id, grass_region
having count(grass_date) > 30
;

create or replace temporary view tmp_login_city_name as
select
    shopeepay_user_id as user_id
    ,grass_region
    ,fst_login_city_name_td
from ${SCHEMA}.dws_risk_user_sz_device_spp_login_version_df
where grass_date >= date_sub('${grass_date}',180)
    and grass_region = upper('${region}')
    and user_id is not null
    and fst_login_city_name_td is not null
group by shopeepay_user_id
    ,grass_region
    ,fst_login_city_name_td
;


-- 需要加入非sppuid 的数据源吗？ 属于混合数据源计算指标 --frequency_city_name_list_6m_v3
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
and grass_region in ${batch_region_am}
and is_physical_product_order = 'Y'
and buyer_id is not null 
and checkout_city_name is not null 
group by 
buyer_id
,grass_region
,checkout_city_name
;
--

create or replace temporary view dws_risk_user_city_name_version_nd as 
select
    user_id
    ,concat_ws(',', collect_set(city_name)) as frequency_city_name_list_6m_v3
    ,grass_region
    ,'${grass_date}' as grass_date
from (
    select
        user_id
        ,grass_region
        ,fst_login_city_name_td as city_name
    from tmp_login_city_name
    where fst_login_city_name_td is not null
    union all
    select
        user_id
        ,grass_region
        ,city_name
    from tmp_buyer_city_name
    where city_name is not null
) a1
group by
    user_id
    ,grass_region
having concat_ws(',', collect_set(city_name)) <> '' 
;


with tmp1 as (
    select
        user_id
        ,case when frequency_sz_dfp_device_id_list_seller_1y <> '' then frequency_sz_dfp_device_id_list_seller_1y end as frequency_sz_dfp_device_id_list_seller_1y_v2
    from (
        select 
            user_id ,grass_region
            ,concat_ws(',', collect_set(sz_dfp_device_id)) as frequency_sz_dfp_device_id_list_seller_1y
        from (
            select
                user_id
                ,sz_dfp_device_id
                ,grass_region
            from sz_dfp_device_login_year_df_${region}
            union all 
            select
                shopeepay_user_id as user_id
                ,sz_dfp_device_id
                ,grass_region
            from ${SCHEMA}.dwd_risk_v2_login_di as new_login_di -- 需要从 dwd_risk_v2_login_di 出 
            where tz_type = 'local'
                and grass_region = upper('${region}')
                -- and is_spp = 1 --之前就没限制 
                and grass_date >= date_sub(date('${bizdate}'), 365)
                and grass_date <= date('${bizdate}')
        ) tmp 
        group by user_id, grass_region
    ) t1
),
tmp2 as (
    select
        user_id
        ,case when frequency_sz_dfp_device_id_list_1y <> '' then frequency_sz_dfp_device_id_list_1y end as frequency_sz_dfp_device_id_list_1y_v3
    from (
        select
            user_id
            ,concat_ws(',', collect_set(sz_dfp_device_id)) as frequency_sz_dfp_device_id_list_1y
        from frequency_device_1y a1
        group by
            user_id
        having frequency_sz_dfp_device_id_list_1y <> ''
    ) a1
),
tmp3 as (
    select
        user_id
        ,case when frequency_sz_dfp_device_id_list_seller_1y <> '' then frequency_sz_dfp_device_id_list_seller_1y end as frequency_sz_dfp_device_id_list_seller_1y_v3
    from (
        select 
            user_id ,grass_region
            ,concat_ws(',', collect_set(sz_dfp_device_id)) as frequency_sz_dfp_device_id_list_seller_1y
        from (
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
),
tmp4 as (
    select
        user_id
        ,case when frequency_sz_dfp_device_id_list_seller_1y <> '' then frequency_sz_dfp_device_id_list_seller_1y end as szdf_ever_login_1y
    from (
        select 
            user_id ,grass_region
            ,concat_ws(',', collect_set(sz_dfp_device_id)) as frequency_sz_dfp_device_id_list_seller_1y
        from (
            select
                shopeepay_user_id as user_id
                ,sz_dfp_device_id
                ,grass_region
            from ${SCHEMA}.dws_risk_user_sz_device_login_di -- 从 dwd_risk_v2_login_di 出
            where tz_type = 'local'
                and grass_region = upper('${region}')
                -- and is_spp_source = '1' --之前就没限制 
                and grass_date >= date_sub(date('${grass_date}'), 365)
                and grass_date <= date('${grass_date}')
        ) tmp 
        group by user_id,grass_region
    ) t1
),
tmp5 as (
    select
        user_id
        ,frequency_city_name_list_6m_v3
    from dws_risk_user_city_name_version_nd
    where grass_date = '${grass_date}'
)

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_behavior_spp_login_info_df partition (grass_date = '${grass_date}')
select 
    a.user_id as shopeepay_user_id
    ,tmp1.frequency_sz_dfp_device_id_list_seller_1y_v2
    ,tmp2.frequency_sz_dfp_device_id_list_1y_v3
    ,tmp3.frequency_sz_dfp_device_id_list_seller_1y_v3
    ,tmp4.szdf_ever_login_1y
    ,tmp5.frequency_city_name_list_6m_v3
from (
    select cast(shopeepay_user_id as string) as user_id
    from shopeepay.mart_dwd_us_user_account_tab_ds__${region}
    where grass_date = '${grass_date}'
) as a
left join tmp1 on a.user_id = tmp1.user_id
left join tmp2 on a.user_id = tmp2.user_id
left join tmp3 on a.user_id = tmp3.user_id
left join tmp4 on a.user_id = tmp4.user_id
left join tmp5 on a.user_id = tmp5.user_id