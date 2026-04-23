------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-10-30
-- Description:         MP user level address feature
-- Data Granularity:    shopee_user_id
-- PRD:                 
-- Jira:                TH/PH/VN需求单 https://jira.shopee.io/browse/SPFDT-56805
--                      ID需求单 https://jira.shopee.io/browse/SPFDT-54041
-- version:
--  2025.10.30  需求上线
--  2026-01-06  新增用户近1年常用地址 Jira: https://jira.shopee.io/browse/SPFDT-58726
------------------------------------------------------------------------


DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_${region}_user_historical_address_list_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_${region}_user_historical_address_list_df
(
    shopee_user_id string comment '用户ID'
    ,address_level1_list string comment '历史省级地址列表，近100条去重'
    ,address_level1_list_length bigint comment '省级地址列表长度'
    ,address_level1_count bigint comment '省级地址去重数量'
    ,address_level2_list string comment '历史市级地址列表，近100条去重'
    ,address_level2_list_length bigint comment '市级地址列表长度'
    ,address_level2_count bigint comment '市级地址去重数量'
    ,address_level3_list string comment '历史区级地址列表，近100条去重'
    ,address_level3_list_length bigint comment '区级地址列表长度'
    ,address_level3_count bigint comment '区级地址去重数量'
    ,address_level1_list_completed string comment '完整省级地址列表，近100条去重，省市区均非空'
    ,address_level1_list_length_completed bigint comment '完整省级地址列表长度'
    ,address_level1_count_completed bigint comment '完整省级地址去重数量'
    ,address_level2_list_completed string comment '完整市级地址列表，近100条去重，省市区均非空'
    ,address_level2_list_length_completed bigint comment '完整市级地址列表长度'
    ,address_level2_count_completed bigint comment '完整市级地址去重数量'
    ,address_level3_list_completed string comment '完整区级地址列表，近100条去重，省市区均非空'
    ,address_level3_list_length_completed bigint comment '完整区级地址列表长度'
    ,address_level3_count_completed bigint comment '完整区级地址去重数量'
    ,address_level1_frequent_list string comment 'user most frequent address level1 list in last 365 days'
    ,address_level2_frequent_list string comment 'user most frequent address level2 list in last 365 days'
    ,address_level3_frequent_list string comment 'user most frequent address level3 list in last 365 days'
)
comment 'user historical address : province/city/district'
partitioned by
( 
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="ZSTD")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_${region}_user_historical_address_list_df';
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_${region}_user_historical_address_list_df;

with l1_list as (
select user_id,
    address_level1_list,
    length(cast(address_level1_list as string)) as address_level1_list_length,
    cardinality(address_level1_list) as address_level1_count
from 
(
    select 
        user_id,
        collect_set(address_level1_value) as address_level1_list
    from 
    (   
        select 
            user_id,
            address_level1_value,
            row_number() over(partition by user_id order by modify_timestamp desc) as rn
        from 
        (
            select 
                user_id, 
                address_level1.value as address_level1_value, 
                max(modify_timestamp) as modify_timestamp
            from mp_user.dim_user_address__reg_s1_live                
            where grass_region = '${grass_region}' and grass_date = date('${grass_date}')
            group by user_id, address_level1.value
        ) t1
    ) t2
    where rn <= 100
    group by user_id
) t3
),
l2_list as (
select user_id,
    address_level2_list,
    length(cast(address_level2_list as string)) as address_level2_list_length,
    cardinality(address_level2_list) as address_level2_count
from 
(
    select 
        user_id,
        collect_set(address_level2_value) as address_level2_list
    from 
    (   
        select 
            user_id,
            address_level2_value,
            row_number() over(partition by user_id order by modify_timestamp desc) as rn
        from 
        (
            select 
                user_id, 
                address_level2.value as address_level2_value, 
                max(modify_timestamp) as modify_timestamp
            from mp_user.dim_user_address__reg_s1_live                
            where grass_region = '${grass_region}' and grass_date = date('${grass_date}')
            group by user_id, address_level2.value
        ) t1
    ) t2
    where rn <= 100
    group by user_id
) t3
),
l3_list as (
select user_id,
    address_level3_list,
    length(cast(address_level3_list as string)) as address_level3_list_length,
    cardinality(address_level3_list) as address_level3_count
from 
(
    select 
        user_id,
        collect_set(address_level3_value) as address_level3_list
    from 
    (   
        select 
            user_id,
            address_level3_value,
            row_number() over(partition by user_id order by modify_timestamp desc) as rn
        from 
        (
            select 
                user_id, 
                address_level3.value as address_level3_value, 
                max(modify_timestamp) as modify_timestamp
            from mp_user.dim_user_address__reg_s1_live                
            where grass_region = '${grass_region}' and grass_date = date('${grass_date}')
            group by user_id, address_level3.value
        ) t1
    ) t2
    where rn <= 100
    group by user_id
) t3
),
completed_address as (
    select 
        user_id,
        state,
        city,
        district,
        modified_time
    from 
    (
        select
            userid as user_id
            ,address as config_address
            ,state
            ,city
            ,district
            ,cast(mtime as bigint) as modified_time
            ,case when status in (1, 2) then 'Y'
                else 'N'
                end as is_valid
            ,country
        from marketplace.shopee_account_address_${region}_db__buyer_address_tab__reg_continuous_s0_live
        where country = '${grass_region}'
    ) buyer_address
    where trim(regexp_replace(buyer_address.config_address, ',', '')) <> ''
        and (is_valid = 'Y'
            or (is_valid = 'N'
                and modified_time <= unix_timestamp(date('${grass_date}'))
                and modified_time > unix_timestamp(date('${grass_date}') - interval 90 day)
                )
            )
        and buyer_address.state is not null 
        and buyer_address.city is not null
        and buyer_address.district is not null
        and buyer_address.state <> ''
        and buyer_address.city <> ''
        and buyer_address.district <> ''
),
completed_address_l1_list as (
select 
    user_id
    ,collect_set(state) as address_level1_list_completed
    ,length(cast(collect_set(state) as string)) as address_level1_list_length_completed
    ,cardinality(collect_set(state)) as address_level1_count_completed
from 
(
    select 
        user_id, state, row_number() over(partition by user_id order by modified_time desc) as rn
    from 
    (   select user_id, state, max(modified_time) as modified_time
        from completed_address
        group by user_id, state
    ) t1
) t2 
where rn <= 100
group by user_id
),
completed_address_l2_list as (
select 
    user_id
    ,collect_set(city) as address_level2_list_completed
    ,length(cast(collect_set(city) as string)) as address_level2_list_length_completed
    ,cardinality(collect_set(city)) as address_level2_count_completed
from 
(
    select 
        user_id, city, row_number() over(partition by user_id order by modified_time desc) as rn
    from 
    (   select user_id, city, max(modified_time) as modified_time
        from completed_address
        group by user_id, city
    ) t1
) t2 
where rn <= 100
group by user_id
),
completed_address_l3_list as (
select 
    user_id
    ,collect_set(district) as address_level3_list_completed
    ,length(cast(collect_set(district) as string)) as address_level3_list_length_completed
    ,cardinality(collect_set(district)) as address_level3_count_completed
from 
(
    select 
        user_id, district, row_number() over(partition by user_id order by modified_time desc) as rn
    from 
    (   select user_id, district, max(modified_time) as modified_time
        from completed_address
        group by user_id, district
    ) t1
) t2 
where rn <= 100
group by user_id
),
address_base as (
    select
        user_id
        ,address_level1.value as address_level1_value
        ,address_level2.value as address_level2_value
        ,address_level3.value as address_level3_value
    from mp_user.dim_user_address__reg_s1_live
    where grass_region = upper('${region}')
    and grass_date >= date_sub('${grass_date}', 365)
    and grass_date <= '${grass_date}'
    group by 1, 2, 3, 4
),
frequent_address_level_list as (
    select
        user_id
        ,collect_set(case when rn1 = 1 and address_level1_value <> '' then address_level1_value end) as address_level1_frequent_list
        ,collect_set(case when rn2 = 1 and address_level2_value <> '' then address_level2_value end) as address_level2_frequent_list
        ,collect_set(case when rn3 = 1 and address_level3_value <> '' then address_level3_value end) as address_level3_frequent_list
    from (
        select
            user_id
            ,address_level1_value
            ,address_level2_value
            ,address_level3_value
            ,rank() over (partition by user_id, address_level1_value order by cnt1 desc) as rn1
            ,rank() over (partition by user_id, address_level2_value order by cnt2 desc) as rn2
            ,rank() over (partition by user_id, address_level3_value order by cnt3 desc) as rn3
        from (
            select
                user_id
                ,address_level1_value
                ,address_level2_value
                ,address_level3_value
                ,count(*) over (partition by user_id, address_level1_value) as cnt1
                ,count(*) over (partition by user_id, address_level2_value) as cnt2
                ,count(*) over (partition by user_id, address_level3_value) as cnt3
            from address_base
        ) t1
    ) t2
    group by user_id
)


insert overwrite table ${SCHEMA}.ads_risk_${region}_user_historical_address_list_df partition(grass_date = '${grass_date}')
select 
    base.user_id  as shopee_user_id
    ,cast(l1_list.address_level1_list as string)
    ,l1_list.address_level1_list_length
    ,l1_list.address_level1_count
    ,cast(l2_list.address_level2_list as string)
    ,l2_list.address_level2_list_length
    ,l2_list.address_level2_count
    ,cast(l3_list.address_level3_list as string)
    ,l3_list.address_level3_list_length
    ,l3_list.address_level3_count
    ,cast(completed_address_l1_list.address_level1_list_completed as string)
    ,completed_address_l1_list.address_level1_list_length_completed
    ,completed_address_l1_list.address_level1_count_completed
    ,cast(completed_address_l2_list.address_level2_list_completed as string)
    ,completed_address_l2_list.address_level2_list_length_completed
    ,completed_address_l2_list.address_level2_count_completed
    ,cast(completed_address_l3_list.address_level3_list_completed as string)
    ,completed_address_l3_list.address_level3_list_length_completed
    ,completed_address_l3_list.address_level3_count_completed
    ,cast(frequent_address_level_list.address_level1_frequent_list as string)
    ,cast(frequent_address_level_list.address_level2_frequent_list as string)
    ,cast(frequent_address_level_list.address_level3_frequent_list as string)
from 
(
    select user_id
    from mp_user.dim_user__reg_s0_live
    where tz_type = 'local'
    and grass_region = '${grass_region}' 
    and grass_date = date('${grass_date}')
) base
left join l1_list on base.user_id = l1_list.user_id
left join l2_list on base.user_id = l2_list.user_id
left join l3_list on base.user_id = l3_list.user_id
left join completed_address_l1_list on base.user_id = completed_address_l1_list.user_id
left join completed_address_l2_list on base.user_id = completed_address_l2_list.user_id
left join completed_address_l3_list on base.user_id = completed_address_l3_list.user_id
left join frequent_address_level_list on base.user_id = frequent_address_level_list.user_id
;
