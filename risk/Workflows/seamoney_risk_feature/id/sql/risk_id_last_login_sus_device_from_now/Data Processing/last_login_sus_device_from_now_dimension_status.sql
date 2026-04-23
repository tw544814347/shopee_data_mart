alter table ${SCHEMA}.last_login_sus_device_from_now_dimension_status drop if exists partition(dt <= '${delete_limit_date}');

create or replace temporary view last_view as 
select 
    szdf
from risk.last_login_sus_device_from_now_dimension
where region = '${region_lower}'
    and dt = '${bizdate}'
;

create or replace temporary view yesterday_view as 
select 
    szdf
from risk.last_login_sus_device_from_now_dimension
where region = '${region_lower}'
    and dt = '${ds_t_2}'
;

create or replace temporary view join_view as 
select 
    t1.szdf as last_szdf,
    t2.szdf as yesterday_szdf
from last_view t1 full outer join yesterday_view t2 
    on t1.szdf = t2.szdf
;

insert overwrite ${SCHEMA}.last_login_sus_device_from_now_dimension_status partition (region = '${region_lower}', dt = '${bizdate}')
select 
    last_szdf as szdf,
    '1' as status
from join_view
where last_szdf is not null
union all 
select 
    last_szdf as szdf,
    '-1' as status
from join_view
where last_szdf is null
    and yesterday_szdf is not null
;
