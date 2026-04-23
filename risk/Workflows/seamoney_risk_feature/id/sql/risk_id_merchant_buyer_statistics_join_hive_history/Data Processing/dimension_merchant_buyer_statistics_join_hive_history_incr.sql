alter table ${SCHEMA}.dimension_merchant_buyer_statistics_join_hive_history_incr drop if exists partition(grass_region = '${region_upper}', grass_date < '${delete_limit_date}');

create or replace temporary view today_view as 
select 
    flag,
    flag_key,
    flag_object
from risk.dimension_merchant_buyer_statistics_join_hive_history_full
where grass_region = '${region_upper}'
    and grass_date = '${bizdate}'
;

create or replace temporary view yesterday_view as 
select 
    flag,
    flag_key,
    flag_object
from risk.dimension_merchant_buyer_statistics_join_hive_history_full
where grass_region = '${region_upper}'
    and grass_date = '${yesterday_date}'
    -- and grass_date = '2025-06-29'
;

create or replace temporary view join_view as 
select 
    t1.flag as t1_flag,
    t1.flag_key as t1_flag_key,
    t1.flag_object as t1_flag_object,
    t2.flag as t2_flag,
    t2.flag_key as t2_flag_key,
    t2.flag_object as t2_flag_object
from today_view t1 full outer join yesterday_view t2 
    on t1.flag = t2.flag and t1.flag_key = t2.flag_key
;

create or replace temporary view combine_view as 
select 
    t1_flag as flag,
    t1_flag_key as flag_key,
    t1_flag_object as flag_object,
    1 as change_type
from join_view
where t1_flag is not null 
    and t1_flag_key is not null 
    and t1_flag_object is not null 
    and t2_flag is null 
    and t2_flag_key is null 
    and t2_flag_object is null
union all 
select 
    t2_flag as flag,
    t2_flag_key as flag_key,
    '-9999' as flag_object,
    0 as change_type
from join_view
where t2_flag is not null 
    and t2_flag_key is not null 
    and t2_flag_object is not null 
    and t1_flag is null 
    and t1_flag_key is null 
    and t1_flag_object is null
union all 
select 
    t1_flag as flag,
    t1_flag_key as flag_key,
    t1_flag_object as flag_object,
    -1 as change_type
from join_view
where t1_flag is not null 
    and t1_flag_key is not null 
    and t1_flag_object is not null 
    and t1_flag = t2_flag
    and t1_flag_key = t2_flag_key
    and t1_flag_object <> t2_flag_object
;

insert overwrite ${SCHEMA}.dimension_merchant_buyer_statistics_join_hive_history_incr partition(grass_region = '${region_upper}', grass_date = '${bizdate}')
select 
    flag,
    flag_key,
    flag_object,
    change_type
from combine_view
;