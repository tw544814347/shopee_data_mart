-- -- jira:https://jira.shopee.io/browse/SPFDT-54041
-- -- author:wei.tao@shopee.com
-- -- create_time:20250729
-- -- note:避免过长 address_list 针对过去最新的不超过100个收货地址做截断
-- -- 2026-01-06  chengguo.liu@shopee.com 新增近1年常用地址, Jira: https://jira.shopee.io/browse/SPFDT-58726

--DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_id_user_historical_address_list_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_id_user_historical_address_list_df
(
    user_id string
    ,address_level1_list string comment 'from dim_user_address__reg_s1_live'
    ,address_level1_list_length bigint comment 'from dim_user_address__reg_s1_live'
    ,address_level1_count bigint comment 'from dim_user_address__reg_s1_live'
    ,address_level2_list string comment 'from dim_user_address__reg_s1_live'
    ,address_level2_list_length bigint comment 'from dim_user_address__reg_s1_live'
    ,address_level2_count bigint comment 'from dim_user_address__reg_s1_live'
    ,address_level3_list string comment 'from dim_user_address__reg_s1_live'
    ,address_level3_list_length bigint comment 'from dim_user_address__reg_s1_live'
    ,address_level3_count bigint comment 'from dim_user_address__reg_s1_live'

    ,address_level1_list_completed string comment 'from shopee_account_address_reg_db__buyer_address_tab__reg_continuous_s0_live'
    ,address_level1_list_length_completed bigint comment 'from shopee_account_address_reg_db__buyer_address_tab__reg_continuous_s0_live'
    ,address_level1_count_completed bigint comment 'from shopee_account_address_reg_db__buyer_address_tab__reg_continuous_s0_live'
    ,address_level2_list_completed string comment 'from shopee_account_address_reg_db__buyer_address_tab__reg_continuous_s0_live'
    ,address_level2_list_length_completed bigint comment 'from shopee_account_address_reg_db__buyer_address_tab__reg_continuous_s0_live'
    ,address_level2_count_completed bigint comment 'from shopee_account_address_reg_db__buyer_address_tab__reg_continuous_s0_live'
    ,address_level3_list_completed string comment 'from shopee_account_address_reg_db__buyer_address_tab__reg_continuous_s0_live'
    ,address_level3_list_length_completed bigint comment 'from shopee_account_address_reg_db__buyer_address_tab__reg_continuous_s0_live'
    ,address_level3_count_completed bigint comment 'from shopee_account_address_reg_db__buyer_address_tab__reg_continuous_s0_live'
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
location '${HDFS_PATH}/risk_mart/ads/ads_risk_id_user_historical_address_list_df';
--MSCK REPAIR TABLE ${SCHEMA}.ads_risk_id_user_historical_address_list_df;

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
                user_id, address_level1_value, max(modify_timestamp) as modify_timestamp
            from 
            (
                select distinct 
                user_id,
                address_level1.value as address_level1_value,
                modify_timestamp
                from mp_user.dim_user_address__reg_s1_live                
                where grass_region = 'ID' and grass_date = date('${grass_date}')
            ) t0
            group by user_id, address_level1_value
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
                user_id, address_level2_value, max(modify_timestamp) as modify_timestamp
            from 
            (
                select distinct 
                user_id,
                address_level2.value as address_level2_value,
                modify_timestamp
                from mp_user.dim_user_address__reg_s1_live                
                where grass_region = 'ID' and grass_date = date('${grass_date}')
            ) t0
            group by user_id, address_level2_value
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
                user_id, address_level3_value, max(modify_timestamp) as modify_timestamp
            from 
            (
                select distinct 
                user_id,
                address_level3.value as address_level3_value,
                modify_timestamp
                from mp_user.dim_user_address__reg_s1_live                
                where grass_region = 'ID' and grass_date = date('${grass_date}')
            ) t0
            group by user_id, address_level3_value
        ) t1
    ) t2
    where rn <= 100
    group by user_id
) t3
),
address_list_tab as (
select 
        user_id
        ,address_level1_list
        ,address_level1_list_length
        ,address_level1_count
        ,address_level2_list
        ,address_level2_list_length
        ,address_level2_count
        ,address_level3_list
        ,address_level3_list_length
        ,address_level3_count
from 
(
select coalesce(l1_list.user_id,l2_list.user_id,l3_list.user_id) as user_id,
        cast(l1_list.address_level1_list as string),
        cast(l1_list.address_level1_list_length as bigint),
        cast(l1_list.address_level1_count as bigint),
        cast(l2_list.address_level2_list as string),
        cast(l2_list.address_level2_list_length as bigint),
        cast(l2_list.address_level2_count as bigint),
        cast(l3_list.address_level3_list as string),
        cast(l3_list.address_level3_list_length as bigint),
        cast(l3_list.address_level3_count as bigint)
from l1_list
full join l2_list on l1_list.user_id = l2_list.user_id
full join l3_list on l1_list.user_id = l3_list.user_id
) tmp
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
        from marketplace.shopee_account_address_id_db__buyer_address_tab__reg_continuous_s0_live
        where country in ('ID')
    ) buyer_address
    where trim(regexp_replace(buyer_address.config_address, ',', '')) <> ''
        and (is_valid = 'Y'
            or (is_valid = 'N'
                and modified_time <= unix_timestamp(date('${bizdate}'))
                and modified_time > unix_timestamp(date('${bizdate}') - interval 90 day)
                )
            )
        and buyer_address.state is not null 
        and buyer_address.city is not null
        and buyer_address.district is not null
        -- and buyer_address.country is not null
        and buyer_address.state <> ''
        and buyer_address.city <> ''
        and buyer_address.district <> ''
        -- and buyer_address.country <> ''
),
completed_address_l1_list as (
select 
    user_id
    ,collect_set(state) as address_level1_list_new
    ,length(cast(collect_set(state) as string)) as address_level1_list_length_new
    ,cardinality(collect_set(state)) as address_level1_count_new
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
    ,collect_set(city) as address_level2_list_new
    ,length(cast(collect_set(city) as string)) as address_level2_list_length_new
    ,cardinality(collect_set(city)) as address_level2_count_new
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
    ,collect_set(district) as address_level3_list_new
    ,length(cast(collect_set(district) as string)) as address_level3_list_length_new
    ,cardinality(collect_set(district)) as address_level3_count_new
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


insert overwrite table ${SCHEMA}.ads_risk_id_user_historical_address_list_df partition(grass_date = '${grass_date}')
select 
    t1.user_id    
    ,cast(t2.address_level1_list as string)
    ,cast(t2.address_level1_list_length as bigint)
    ,cast(t2.address_level1_count as bigint)
    ,cast(t2.address_level2_list as string)
    ,cast(t2.address_level2_list_length as bigint)
    ,cast(t2.address_level2_count as bigint)
    ,cast(t2.address_level3_list as string)
    ,cast(t2.address_level3_list_length as bigint)
    ,cast(t2.address_level3_count as bigint)
    ,cast(t3.address_level1_list_new as string)
    ,cast(t3.address_level1_list_length_new as bigint)
    ,cast(t3.address_level1_count_new as bigint)
    ,cast(t3.address_level2_list_new as string)
    ,cast(t3.address_level2_list_length_new as bigint)
    ,cast(t3.address_level2_count_new as bigint)
    ,cast(t3.address_level3_list_new as string)
    ,cast(t3.address_level3_list_length_new as bigint)
    ,cast(t3.address_level3_count_new as bigint)
    ,cast(t4.address_level1_frequent_list as string)
    ,cast(t4.address_level2_frequent_list as string)
    ,cast(t4.address_level3_frequent_list as string)
from (
    select
        user_id
    from mp_user.dim_user__${region}_s0_live
    where grass_date = '${grass_date}'
) t1
left join address_list_tab t2 
on t1.user_id = t2.user_id
left join (
    select 
        user_id
        ,address_level1_list_new
        ,address_level2_list_new
        ,address_level3_list_new
        ,address_level1_list_length_new
        ,address_level1_count_new
        ,address_level2_list_length_new
        ,address_level2_count_new
        ,address_level3_list_length_new
        ,address_level3_count_new
    from        
    (
    select coalesce(l1_list.user_id,l2_list.user_id,l3_list.user_id) as user_id,
            cast(l1_list.address_level1_list_new as string) as address_level1_list_new,
            cast(l1_list.address_level1_list_length_new as bigint) as address_level1_list_length_new,
            cast(l1_list.address_level1_count_new as bigint) as address_level1_count_new,
            cast(l2_list.address_level2_list_new as string) as address_level2_list_new, 
            cast(l2_list.address_level2_list_length_new as bigint) as address_level2_list_length_new,
            cast(l2_list.address_level2_count_new as bigint) as address_level2_count_new,
            cast(l3_list.address_level3_list_new as string) as address_level3_list_new,
            cast(l3_list.address_level3_list_length_new as bigint) as address_level3_list_length_new,
            cast(l3_list.address_level3_count_new as bigint) as address_level3_count_new
    from completed_address_l1_list as l1_list
    full join completed_address_l2_list as l2_list on l1_list.user_id = l2_list.user_id
    full join completed_address_l3_list as l3_list on l1_list.user_id = l3_list.user_id
    ) buyer_address
) t3 
on t1.user_id = t3.user_id
left join frequent_address_level_list t4
on t1.user_id = t4.user_id
;


