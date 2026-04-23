-- 修改记录：
-- 2026-03-17：由于近期上游黑名单数据经常不更新，更新之后一次性更新中断的很多天的数据，导致之前取最近两天做差值的增量更新方式需要手动触发任务，比较麻烦
-- 考虑到黑名单记录表只会增加，不会减少，状态也只有1，不存在状态变更的情况，综合起来将增量更新改为全量更新，任务只要最新成功运行一次数据质量就可以保证，兼容性更好。
alter table ${SCHEMA}.dimension_blacklist_tag_history_incr drop if exists partition(grass_region = '${region_upper}', grass_date < '${incr_limit_date}');

create or replace temporary view today_view as
select 
    `data`,
    status,
    case when datatype = 'szdf' then 'szdf'
        when datatype = 'phoneNo' then 'phone'
        else null
    end as data_type,
    data_source
from smcdrisk_antifraud.id_pii_blacklist_df
where run_date in (select latest_run_date from tmp_blacklist_date_record_tab)
    and char_length(`data`) > 0
    and status is not null
    and datatype in ('szdf', 'phoneNo')
    and char_length(data_source) > 0
    group by `data`, status, datatype, data_source
;

create or replace temporary view yesterday_view as
select 
    `data`,
    status,
    case when datatype = 'szdf' then 'szdf'
        when datatype = 'phoneNo' then 'phone'
        else null
    end as data_type,
    data_source
from smcdrisk_antifraud.id_pii_blacklist_df
where run_date in (select second_latest_run_date from tmp_blacklist_date_record_tab)
    and char_length(`data`) > 0
    and status is not null
    and datatype in ('szdf', 'phoneNo')
    and char_length(data_source) > 0
    group by `data`, status, datatype, data_source
;

create or replace temporary view join_view as
select 
    t1.`data` as t1_data,
    t1.data_type as t1_data_type,
    t1.data_source as t1_data_source,
    t1.status as t1_status,
    t2.`data` as t2_data,
    t2.data_type as t2_data_type,
    t2.data_source as t2_data_source,
    t2.status as t2_status
from today_view t1 full outer join yesterday_view t2 
on t1.`data` = t2.`data` and t1.data_type = t2.data_type and t1.data_source = t2.data_source
;

create or replace temporary view combine_view as 
select 
    t1_data as `data`,
    t1_data_type as data_type,
    t1_data_source as data_source,
    t1_status as status,
    1 as change_type
from join_view
where char_length(t1_data) > 0
    and char_length(t1_data_type) > 0
    and char_length(t1_data_source) > 0
    and char_length(t1_status) > 0
    and t2_data is null 
    and t2_data_type is null
    and t2_data_source is null 
    and t2_status is null
union all 
select 
    t2_data as `data`,
    --t2_status as status, -- 从黑名单中移除了，配置默认值
    -9999 as status,
    t2_data_source as data_source,
    t2_status as status,
    0 as change_type
from join_view
where char_length(t2_data) > 0
    and char_length(t2_data_type) > 0
    and char_length(t2_data_source) > 0
    and char_length(t2_status) > 0
    and t1_data is null 
    and t1_data_type is null
    and t1_data_source is null 
    and t1_status is null
union all 
select 
    t1_data as `data`,
    t1_data_type as data_type,
    t1_data_source as data_source,
    t1_status as status,
    -1 as change_type
from join_view
where t1_data is not null
    and t1_data_type is not null
    and t1_data_source is not null
    and t1_data = t2_data
    and t1_data_type = t2_data_type
    and t1_data_source = t2_data_source
    and t1_status <> t2_status
;

insert overwrite ${SCHEMA}.dimension_blacklist_tag_history_incr partition(grass_region='${region_upper}', grass_date = '${bizdate}')
select 
    `data`, data_type, data_source, status, change_type
from combine_view
;
