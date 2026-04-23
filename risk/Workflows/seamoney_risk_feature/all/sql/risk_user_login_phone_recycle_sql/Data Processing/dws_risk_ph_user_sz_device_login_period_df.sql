--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-09-05
-- Theme Domain：        risk user_login period
-- Description:         计算用户每次登录的日期,上一次以及下一次的登录日期(当天登录算一次)
-- Data Granularity:    
-- jira : https://jira.shopee.io/browse/SPFDT-42340
-- 变更历史：
-- update by zongyi.lu@shopee.com 2024-10-09 1.不用过滤is_phone_verified = 1 https://docs.google.com/spreadsheets/d/1emcyI2D6mmhZBxZl_BRh5Q-cvpAyJ6iZRa8AHNbovA0/edit?gid=1985808598#gid=1985808598
-- update by zongyi.lu@shopee.com 2024-10-09 新增login_from字段
-- update by wei.tao 切换至 szdf 新表
--********************************************************************--   


drop table if exists ${SCHEMA}.dws_risk_reg_user_sz_device_login_period_df__middle_${region};
create table if not exists ${SCHEMA}.dws_risk_reg_user_sz_device_login_period_df__middle_${region} as  
select 
        tt1.user_id 
        ,tt1.grass_date 
        ,tt1.login_timestamp as login_timestamp
        ,tt1.login_from      as login_from
        ,collect_set(tt1.sz_dfp_device_id) as sz_dfp_device_id
    from(
        select 
        t1.user_id 
        ,t1.grass_date 
        ,t1.login_timestamp as login_timestamp
        ,t1.login_from      as login_from
        ,t1.sz_dfp_device_id as sz_dfp_device_id
        ,row_number() over(partition by t1.user_id,t1.grass_date order by t1.login_timestamp desc ) as rn 
        -- ,collect_set(t1.sz_dfp_device_id) as sz_dfp_device_id
        -- ,count(1)cnt 
        from risk.dwd_risk_szdf_login_di t1 
        join (
            select 
                user_id
            from mp_user.dim_user__reg_s0_live
            where grass_region = upper('${region}') 
            and grass_date = '${grass_date}'
            and status = 1
            -- and is_phone_verified = 1
        ) t2 on t1.user_id = t2.user_id
        where t1.grass_region = upper('${region}') and t1.login_from not like '%WEB%'
    ) tt1 
    where rn=1 
    group by tt1.user_id 
        ,tt1.grass_date 
        ,tt1.login_timestamp
        ,tt1.login_from
;

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_sz_device_login_period_df partition(grass_date='${grass_date}')
select
ttt1.user_id  
,ttt1.grass_date as login_date 
,lag(grass_date) over (partition by ttt1.user_id order by grass_date)  as  previous_login_date
,lead(grass_date) over (partition by ttt1.user_id order by grass_date) as  next_login_date
,ttt1.login_timestamp as login_timestamp 
,lag(login_timestamp) over (partition by ttt1.user_id order by login_timestamp)  as  previous_login_timestamp
,lead(login_timestamp) over (partition by ttt1.user_id order by login_timestamp) as  next_login_timestamp
,ttt1.sz_dfp_device_id as login_sz_device_id
,lag(sz_dfp_device_id) over (partition by ttt1.user_id order by login_timestamp)  as  previous_login_sz_device_id
,lead(sz_dfp_device_id) over (partition by ttt1.user_id order by login_timestamp) as  next_login_sz_device_id
,ttt1.login_from as login_from
,lag(login_from) over (partition by ttt1.user_id order by login_timestamp)  as  previous_login_from
,lead(login_from) over (partition by ttt1.user_id order by login_timestamp) as  next_login_from
from ${SCHEMA}.dws_risk_reg_user_sz_device_login_period_df__middle_${region} ttt1