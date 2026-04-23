add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

-- 2024-04-16 通过risk 刷历史数据,只刷ID 20230701 - 2023-12-05
-- BCL	2
-- SCL	3
-- SPL	1
-- FES	4
-- CHP	9
-- CPL	8

-- prd: https://docs.google.com/spreadsheets/d/1DWY3g2wJiBzJs6TX16MerBASAJqSvEDvszjMJincxs0/edit#gid=1108261156
-- 第一版的历史数据
    -- credit_sp_tab	spl
    -- loan_limit_tab	fes
    -- cashloan_limit	bcl
    -- loan_limit_tab	scl
-- 第二版的数据
    -- whitelist_tab 
-- 第三版的数据 待risk 迁移到 UC 

-- 第一版的历史数据
-- insert overwrite table ${SCHEMA}.dwd_uc_whitelist_user_df partition(grass_region,app_id,grass_date)
-- select 
-- platform_user_id          as platform_user_id
-- ,'spl'                    as prod
-- ,status                   as status 
-- ,create_time              as create_time
-- ,upper('${table_region}') as grass_region 
-- ,1                        as app_id 
-- ,'${grass_date}'          as grass_date
-- from ${SCHEMA}.ods__credit_risk_control_${table_region}_db__credit_sp_tab__df
-- where grass_date = '${grass_date}'
-- union all 
-- select 
-- platform_user_id          as platform_user_id
-- ,'bcl'                    as prod
-- ,status                   as status 
-- ,create_time              as create_time
-- ,upper('${table_region}') as grass_region 
-- ,2                        as app_id 
-- ,'${grass_date}'          as grass_date
-- from ${SCHEMA}.ods__credit_risk_control_${table_region}_db__cashloan_limit_tab__df
-- where grass_date = '${grass_date}'
-- -- scl fes 白名单从loan_limit_tab获取
-- union all 
-- select 
-- platform_user_id                           as platform_user_id
-- ,case when app_id = 'spjup' then 'scl'
--       when app_id = 'fes'  then 'fes'  end as prod
-- ,status                                    as status 
-- ,create_time                               as create_time
-- ,upper('${table_region}')                  as grass_region 
-- ,case when app_id = 'spjup' then 3
--       when app_id = 'fes'  then 4  end     as app_id 
-- ,'${grass_date}'                           as grass_date
-- from ${SCHEMA}.ods__credit_risk_control_${table_region}_db__loan_limit_tab__df
-- where grass_date = '${grass_date}'
-- and app_id in('spjup','fes')
-- ;

-- 第二版的数据
-- BCL	2
-- SCL	3
-- SPL	1
-- FES	4
-- CHP	9
-- CPL	8
insert overwrite table ${SCHEMA}.dwd_uc_whitelist_user_df partition(grass_region,app_id,grass_date)
select 
platform_user_id                  as platform_user_id
,case when app_id=1 then 'spl'
     when app_id=2 then 'bcl'
     when app_id=3 then 'scl'
     when app_id=4 then 'fes'
     when app_id=8 then 'cpl'
     when app_id=9 then 'chp'   end                                       as prod 
,status                                                                 as status
,format_time(create_time,upper('${table_region}'))                      as create_time
,upper('${table_region}')                                               as grass_region 
,app_id                                                                 as app_id 
,'${grass_date}'                                                        as grass_date
from ${SCHEMA}.ods__credit_risk_underwriting_${table_region}_db__whitelist_tab__df
where grass_date = '${grass_date}' 
-- and app_id in(1,2,3,4)
;
