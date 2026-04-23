alter table ${SCHEMA}.dimension_blacklist_tag_history_full drop if exists partition(grass_region = '${region_upper}', grass_date < '${full_limit_date}');

-- drop table if exists tmp_blacklist_date_record_tab;
-- create table if not exists tmp_blacklist_date_record_tab as 
-- select 
--     max(run_date) as latest_run_date,
--     min(run_date) as second_latest_run_date
-- from (
--     select 
--         distinct run_date
--     from smcdrisk_antifraud.id_pii_blacklist_df
--     order by run_date desc 
--     limit 2
-- ) t;

create or replace temporary view filter_view as 
select 
    `data`,
    status,
    case when datatype = 'szdf' then 'szdf'
        when datatype = 'phoneNo' then 'phone'
        else null
    end as datatype,
    concat_ws(',', collect_set(distinct data_source)) as data_sources
from smcdrisk_antifraud.id_pii_blacklist_df
where run_date in (select max(run_date) from smcdrisk_antifraud.id_pii_blacklist_df)
    and char_length(`data`) > 0
    and status is not null
    and datatype in ('szdf', 'phoneNo')
    and char_length(data_source) > 0
    group by `data`, status, datatype
;

insert overwrite ${SCHEMA}.dimension_blacklist_tag_history_full partition(grass_region='${region_upper}', grass_date = '${bizdate}')
select 
    substring(md5(`data`), 0, 2) || '_' || datatype || '_' || `data` as rowkey,
    status,
    data_sources
from filter_view
;