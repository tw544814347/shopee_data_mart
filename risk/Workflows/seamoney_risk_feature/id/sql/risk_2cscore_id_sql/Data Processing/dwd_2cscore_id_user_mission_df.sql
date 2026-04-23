--2026-03-24  chengguo.liu - 合规要求，credit_score_id_db切换至新db  smeter_score_id_db

create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

INSERT OVERWRITE TABLE ${SCHEMA}.dwd_2cscore_id_user_mission_df PARTITION (grass_date)
select
     t1.platform_user_id      platform_user_id
    ,t1.platform_type         platform_type
    ,t1.mission_start_score   mission_start_score
    ,t1.mission_id            mission_id
    ,t1.complete_status      mission_progress
    ,t1.completed_count       completed_count
    ,t1.start_time            start_time
    ,t1.complete_time       completion_time
    ,format_time(cast(t1.start_time/1000 as integer),'${region}')      start_time_local
    ,case when t1.complete_time = 0 then '9999-12-31 00:00:00'
    else format_time(cast(t1.complete_time/1000 as integer),'${region}') end completion_time_local
    ,t1.complete_condition           description
    ,t2.create_time           create_time
    ,t2.update_time           update_time
    ,t2.template_id   mission_template_id
    ,t2.mission_name          mission_name
    ,t2.mission_code          mission_code
    ,t2.mission_type          mission_type
    ,t2.mission_status        mission_status
    ,t2.uniqueness            uniqueness
    ,t2.will_get_score        will_get_score
    ,t2.visible_condition     visible_condition
    ,t2.complete_condition    complete_condition
    ,t2.ops                   ops
    ,t2.create_time          mission_create_time
    ,t2.update_time           mission_update_time
    ,t1.grass_date            grass_date
from
(   select a.*
    from risk.ods__smeter_score_id_db__user_mission_tab__df a
    where grass_date between '${begin_ds}' and '${ds}'

)t1
left join
(
    select b.*
    from risk.ods__smeter_score_id_db__mission_tab__df b
    where grass_date between '${begin_ds}' and '${ds}'

) t2
on t1.mission_id = t2.mission_id
and t1.grass_date = t2.grass_date
;