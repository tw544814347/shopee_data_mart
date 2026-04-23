alter table ${SCHEMA}.dimension_shop_id_mapping_platform_uid_history_incr drop if exists partition(grass_region='${region_upper}', grass_date <= '${incr_limit_date}');

create or replace temporary view join_view as 
select 
    t1.shop_id as t1_shop_id,
    t1.platform_userid as t1_platform_userid,
    t2.shop_id as t2_shop_id,
    t2.platform_userid as t2_platform_userid
from (
    select 
        cast(shop_id as string) as shop_id,
        cast(user_id as string) as platform_userid
    from mp_user.dim_user__reg_s0_live
    where grass_region = '${region_upper}'
        and grass_date = '${bizdate}'
        and shop_id > 0
        and user_id > 0
        group by shop_id, user_id
) t1 full outer join (
    select 
        cast(shop_id as string) as shop_id,
        cast(user_id as string) as platform_userid
    from mp_user.dim_user__reg_s0_live
    where grass_region = '${region_upper}'
        and grass_date = '${before_yesterday_date}'
        and shop_id > 0
        and user_id > 0
        group by shop_id, user_id
) t2 on t1.shop_id = t2.shop_id and t1.platform_userid = t2.platform_userid
;

create or replace temporary view combine_view as 
select 
    t1_shop_id as shop_id,
    t1_platform_userid as platform_userid,
    1 as change_type
from join_view
where char_length(t1_shop_id) > 0
    and char_length(t1_platform_userid) > 0
    and t2_shop_id is null 
    and t2_platform_userid is null
union all 
select 
    t2_shop_id as shop_id,
    'delete_' || '${bizdate}' || '_' || t2_platform_userid as platform_userid,
    0 as change_type
from join_view
where char_length(t2_shop_id) > 0
    and char_length(t2_platform_userid) > 0
    and t1_shop_id is null 
    and t1_platform_userid is null
;

insert overwrite ${SCHEMA}.dimension_shop_id_mapping_platform_uid_history_incr partition(grass_region='${region_upper}', grass_date = '${bizdate}')
select 
    shop_id, platform_userid, change_type
from combine_view
;
