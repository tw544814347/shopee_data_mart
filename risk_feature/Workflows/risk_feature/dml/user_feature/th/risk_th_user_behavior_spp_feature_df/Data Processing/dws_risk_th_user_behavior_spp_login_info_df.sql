------------------------------------------------------------------------
-- Author:              wei.tao@shopee.com
-- Created Time:        2026-02-03
-- Description:         用户行为主题域，SPP User Login主题
-- Data Granularity:    shopeepay user id 
-- PRD:                 
------------------------------------------------------------------------
set spark.sql.hive.convertMetastoreParquet=false;

drop table if exists ${SCHEMA}.dws_risk_${region}_user_behavior_spp_login_info_df;
create table if not exists ${SCHEMA}.dws_risk_${region}_user_behavior_spp_login_info_df
(
    shopeepay_user_id string comment 'shopeepay_user_id' ,
    frequency_sz_dfp_device_id_list_seller_1y_v2 string comment 'frequency_sz_dfp_device_id_list_seller_1y_v2' , 
    frequency_sz_dfp_device_id_list_1y_v3 string comment 'frequency_sz_dfp_device_id_list_1y_v3' ,
    frequency_sz_dfp_device_id_list_seller_1y_v3 string comment 'frequency_sz_dfp_device_id_list_seller_1y_v3' ,
    frequency_city_name_list_6m_v3 string comment 'frequency_city_name_list_6m_v3',
    silence_day_cnt_td_v3 string comment 'silence_day_cnt_td_v3' 
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
msck repair table ${SCHEMA}.dws_risk_${region}_user_behavior_spp_login_info_df;

drop table if exists sz_dfp_device_login_year_df_${region};
create table sz_dfp_device_login_year_df_${region} stored as orc as 
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
    from risk.dws_risk_user_device_login_di 
    where tz_type = 'local'
        and shopeepay_user_id is not null
        and grass_region = upper('${region}')
        and grass_date >= date_sub(date('${grass_date}'), 365)
        and grass_date <= date('${grass_date}')
    group by shopeepay_user_id, sz_dfp_device_id, grass_region, grass_date
) t
group by user_id, sz_dfp_device_id, grass_region
having count(grass_date) > 30
;

drop table if exists frequency_device_1y_${region};
create table frequency_device_1y_${region} stored as orc as
select
    t1.shopeepay_user_id as user_id
    ,t1.grass_region
    ,t1.fst_login_sz_dfp_device_id_td as sz_dfp_device_id 
from risk_feature.dws_risk_user_sz_device_spp_login_version_df t1
where t1.tz_type='local'
  and t1.shopeepay_user_id is not null
  and t1.grass_date = date('${grass_date}')
  and t1.grass_region = upper('${region}')
  and t1.fst_login_sz_dfp_device_id_td <> ''
union all 
    select
        shopeepay_user_id as user_id 
        ,grass_region
        ,sz_dfp_device_id
    from risk.dws_risk_buyer_device_complete_df
    where tz_type='local'
    and grass_date = date('${grass_date}')
    and grass_region = upper('${region}')
    and shopeepay_user_id is not null
    and (
        (fas_timestamp_of_complete_physical_product_ord_1y < unix_timestamp(date_sub(date('${grass_date}'), 30))
            and complete_physical_product_ord_cnt_1y > 1)
        or (complete_physical_product_ord_cnt_1y > 3 and complete_physical_product_ord_day_cnt_1y > 3)
        )
    and sz_dfp_device_id <> ''
--
;

drop table if exists ${region}_sz_dfp_device_login_year_df;
create table ${region}_sz_dfp_device_login_year_df stored as orc as
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
    from risk.dws_risk_user_sz_device_login_di 
    where tz_type = 'local'
        and grass_region = upper('${region}')
        and grass_date >= date_sub(date('${grass_date}'), 365)
        and grass_date <= date('${grass_date}')
        and shopeepay_user_id is not null
    group by shopeepay_user_id, sz_dfp_device_id, grass_region, grass_date
) t
group by user_id, sz_dfp_device_id, grass_region
having count(grass_date) > 30
;

drop table if exists tmp_login_city_name_${region};
create table tmp_login_city_name_${region} stored as orc as
select
    t1.shopeepay_user_id as user_id
    ,t1.grass_region
    ,t1.fst_login_city_name_td
from risk_feature.dws_risk_user_sz_device_spp_login_version_df t1
where t1.grass_date >= date_sub('${grass_date}',180)
    and t1.shopeepay_user_id is not null
    and t1.grass_region = upper('${region}')
    and t1.fst_login_city_name_td is not null
group by t1.shopeepay_user_id
    ,t1.grass_region
    ,t1.fst_login_city_name_td
;

drop table if exists tmp_buyer_city_name_${region};
create table tmp_buyer_city_name_${region} stored as orc as
select
    shopeepay_user_id as user_id
    ,grass_region
    ,checkout_city_name as city_name
from risk.dwd_risk_order_complete_di
where grass_date <= date('${grass_date}')
and grass_date > date_sub(date('${grass_date}'), 180)
and shopeepay_user_id is not null
and coalesce(checkout_ip, '') <> ''
and tz_type = 'local'
and grass_region = '${grass_region}'
and is_physical_product_order = 'Y'
and shopeepay_user_id is not null 
and checkout_city_name is not null 
group by 
shopeepay_user_id
,grass_region
,checkout_city_name
;

drop table if exists dws_risk_user_city_name_version_nd_${region}_tmp1;
create table dws_risk_user_city_name_version_nd_${region}_tmp1 stored as orc as (
    select
        user_id
        ,case when frequency_sz_dfp_device_id_list_seller_1y <> '' then frequency_sz_dfp_device_id_list_seller_1y end as frequency_sz_dfp_device_id_list_seller_1y_v2
    from (
        select 
            user_id
            ,concat_ws(',', collect_set(sz_dfp_device_id)) as frequency_sz_dfp_device_id_list_seller_1y
        from (
            select 
                regexp_replace(salted_user_id, '_salt_\\d+$', '') as user_id
                ,sz_dfp_device_id
            from (
                select 
                    concat(user_id, '_salt_', cast(floor(rand() * 10) as int)) as salted_user_id
                    ,sz_dfp_device_id
                from (
                    select
                        user_id
                        ,sz_dfp_device_id
                    from sz_dfp_device_login_year_df_${region}
                    union
                    select
                        shopeepay_user_id as user_id
                        ,sz_dfp_device_id
                    from risk.dwd_risk_szdf_login_di as new_login_di 
                    where tz_type = 'local'
                        and shopeepay_user_id is not null
                        and grass_region = upper('${region}')
                        and grass_date >= date_sub(date('${grass_date}'), 365)
                        and grass_date <= date('${grass_date}')
                ) tmp_base
            ) tmp_salted
            group by salted_user_id, sz_dfp_device_id
        ) tmp_unsalt
        group by user_id
    ) t1
);

drop table if exists dws_risk_user_city_name_version_nd_${region}_tmp2;
create table dws_risk_user_city_name_version_nd_${region}_tmp2 stored as orc as (
    select
        user_id
        ,case when frequency_sz_dfp_device_id_list_1y <> '' then frequency_sz_dfp_device_id_list_1y end as frequency_sz_dfp_device_id_list_1y_v3
    from (
        select
            user_id
            ,concat_ws(',', collect_set(sz_dfp_device_id)) as frequency_sz_dfp_device_id_list_1y
        from (
            select 
                regexp_replace(salted_user_id, '_salt_\\d+$', '') as user_id
                ,sz_dfp_device_id
            from (
                select 
                    concat(user_id, '_salt_', cast(floor(rand() * 10) as int)) as salted_user_id
                    ,sz_dfp_device_id
                from frequency_device_1y_${region}
            ) tmp_salted
            group by salted_user_id, sz_dfp_device_id
        ) tmp_unsalt
        group by user_id
        having frequency_sz_dfp_device_id_list_1y <> ''
    ) a1
);

drop table if exists dws_risk_user_city_name_version_nd_${region}_tmp3;
create table dws_risk_user_city_name_version_nd_${region}_tmp3 stored as orc as (
    select
        user_id
        ,case when frequency_sz_dfp_device_id_list_seller_1y <> '' then frequency_sz_dfp_device_id_list_seller_1y end as frequency_sz_dfp_device_id_list_seller_1y_v3
    from (
        select 
            user_id 
            ,concat_ws(',', collect_set(sz_dfp_device_id)) as frequency_sz_dfp_device_id_list_seller_1y
        from (
            select 
                regexp_replace(salted_user_id, '_salt_\\d+$', '') as user_id
                ,sz_dfp_device_id
            from (
                select 
                    concat(user_id, '_salt_', cast(floor(rand() * 10) as int)) as salted_user_id
                    ,sz_dfp_device_id
                from (
                    select
                        user_id
                        ,sz_dfp_device_id
                    from frequency_device_1y_${region}
                    union
                    select
                        user_id
                        ,sz_dfp_device_id
                    from ${region}_sz_dfp_device_login_year_df
                ) a1_base
            ) tmp_salted
            group by salted_user_id, sz_dfp_device_id
        ) tmp_unsalt
        group by user_id
    ) t1
);

drop table if exists dws_risk_user_city_name_version_nd_${region}_tmp5;
create table dws_risk_user_city_name_version_nd_${region}_tmp5 stored as orc as (
    select
        user_id
        ,frequency_city_name_list_6m_v3
    from 
    (
        select
            user_id
            ,concat_ws(',', collect_set(city_name)) as frequency_city_name_list_6m_v3
        from (
            select
                regexp_replace(salted_user_id, '_salt_\\d+$', '') as user_id
                ,city_name
            from (
                select
                    concat(user_id, '_salt_', cast(floor(rand() * 10) as int)) as salted_user_id
                    ,city_name
                from (
                    select
                        user_id
                        ,fst_login_city_name_td as city_name
                    from tmp_login_city_name_${region}
                    where fst_login_city_name_td is not null
                    union 
                    select
                        user_id
                        ,city_name
                    from tmp_buyer_city_name_${region}
                    where city_name is not null
                ) a1_base
            ) a1_salted
            group by salted_user_id, city_name
        ) a1_unsalt
        group by user_id
        having concat_ws(',', collect_set(city_name)) <> ''
    )
);

drop table if exists dws_risk_user_city_name_version_nd_${region}_tmp6;
create table dws_risk_user_city_name_version_nd_${region}_tmp6 stored as orc as (
select
    t1.shopeepay_user_id as user_id
    ,datediff(date('${current_grass_date}'), from_unixtime(t1.lst_login_timestamp_td)) as silence_day_cnt_td_v3
from risk_feature.dws_risk_user_sz_device_spp_login_version_df t1
where t1.tz_type='local'
  and t1.grass_date = date('${grass_date}')
  and t1.grass_region = upper('${region}')
  and t1.shopeepay_user_id is not null
);

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_behavior_spp_login_info_df partition (grass_date = '${grass_date}')
select 
    a.user_id as shopeepay_user_id
    ,tmp1.frequency_sz_dfp_device_id_list_seller_1y_v2
    ,tmp2.frequency_sz_dfp_device_id_list_1y_v3
    ,tmp3.frequency_sz_dfp_device_id_list_seller_1y_v3
    ,tmp5.frequency_city_name_list_6m_v3
    ,tmp6.silence_day_cnt_td_v3
from (
    select cast(shopeepay_user_id as string) as user_id
    from shopeepay.mart_dwd_us_user_account_tab_ds__${region}
    where grass_date = '${grass_date}'
) as a
left join dws_risk_user_city_name_version_nd_${region}_tmp1 tmp1 on a.user_id = tmp1.user_id
left join dws_risk_user_city_name_version_nd_${region}_tmp2 tmp2 on a.user_id = tmp2.user_id
left join dws_risk_user_city_name_version_nd_${region}_tmp3 tmp3 on a.user_id = tmp3.user_id
left join dws_risk_user_city_name_version_nd_${region}_tmp5 tmp5 on a.user_id = tmp5.user_id
left join dws_risk_user_city_name_version_nd_${region}_tmp6 tmp6 on a.user_id = tmp6.user_id
distribute by a.user_id