--drop table if exists ${SCHEMA}.dws_risk_user_behavior_mp_frequency_phone_df;
create external table if not exists ${SCHEMA}.dws_risk_user_behavior_mp_frequency_phone_df
(
    user_id                              string               comment 'user_id'
    ,frequency_phone_list_td             string               comment 'frequency_phone_list_td'
    ,frequency_phone_list_td_decrypt     string               comment 'frequency_phone_list_td'
)
partitioned by
(
    grass_region   string   comment "grass_region"
    ,grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_behavior_mp_frequency_phone_df';
--msck repair table ${SCHEMA}.dws_risk_user_behavior_mp_frequency_phone_df;


create or replace temporary view phone_fst as
select
    user_id
    ,phone_number as phone
    ,grass_region
from mp_user.dim_user__reg_s1_live
where tz_type = 'local'
    and grass_region = upper('${region}')
    and grass_date = date('${bizdate}')
    and phone_number is not null
;

create or replace temporary view phone_td as
select
    *
from (
    select
        *
        ,bind_phone as phone
        ,from_unixtime(bind_timestamp) as bind_date
        ,lead(from_unixtime(bind_timestamp), 1, date('${bizdate}')) over(partition by
            user_id, grass_region order by bind_timestamp asc) as next_bind_date
    from ${SCHEMA}.dwd_risk_user_phone_bind_df
    where tz_type='local'
      and grass_date = date('${bizdate}')
      and grass_region = upper('${region}')
      and bind_phone is not null
) a1
where datediff(next_bind_date, bind_date) > 15;

create or replace temporary view complete_phone_table as
select
    buyer_id as user_id
    ,phone
    ,grass_region
from ${SCHEMA}.dws_risk_buyer_phone_complete_df
where tz_type='local'
  and grass_date = date('${bizdate}')
  and grass_region = upper('${region}')
  and complete_physical_ord_cnt_6m > 2
  and phone is not null
;

create or replace temporary view frequency_phone as
select
    user_id
    ,grass_region
    ,concat_ws(',', collect_set(md5(phone))) as frequency_phone_list_td
    ,concat_ws(',', collect_set((phone))) as frequency_phone_list_td_decrypt
from (
    select
        user_id
        ,phone
        ,grass_region
    from phone_td
    union all
    select
        user_id
        ,phone
        ,grass_region
    from phone_fst
    union all
    select
        user_id
        ,phone
        ,grass_region
    from complete_phone_table
) a1
group by
    user_id
    ,grass_region
having frequency_phone_list_td <> ''
;


insert overwrite table ${SCHEMA}.dws_risk_user_behavior_mp_frequency_phone_df partition (grass_region, grass_date )
select
    t1.user_id
    ,t2.frequency_phone_list_td
    ,t2.frequency_phone_list_td_decrypt
    ,t1.grass_region
    ,'${bizdate}' as grass_date
from
(
    select
        user_id
        ,grass_region
    from mp_user.dim_user__reg_s0_live
    where tz_type = 'local'
        and grass_region = upper('${region}')
        and grass_date = date('${bizdate}')
) t1
left join frequency_phone t2
on t1.grass_region = t2.grass_region
and t1.user_id = t2.user_id
;


