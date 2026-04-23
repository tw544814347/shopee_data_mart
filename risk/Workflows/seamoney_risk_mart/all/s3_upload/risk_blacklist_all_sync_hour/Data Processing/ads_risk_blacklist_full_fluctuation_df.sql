--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-08-10
-- Theme Domain：       blacklist
-- Description:         传送名单数据量监控;结果数据保存到gsheet(https://docs.google.com/spreadsheets/d/1WG9Yi3OtFoJoZ7rY6vMMnIlQ_lCz6KEcsNyCGvWAB2Y/edit?gid=0#gid=0)
-- Data Granularity:    
-- 变更历史：
--********************************************************************--
select 
t1.grass_region 
,t1.table_name 
,case when t1.status='1' then 'Add' 
      when t1.status='-1' then 'Delete' end status 
,t1.cnt_today
,coalesce(t2.cnt_lastday,0) as cnt_lastday
,abs(case when coalesce(t2.cnt_lastday,0)=0 then 1
      when coalesce(t2.cnt_lastday,0)>0 then round(((t1.cnt_today-t2.cnt_lastday)*1.0000)/(t2.cnt_lastday*1.0000),4) end)*100 as fluctuation_type 
from (
    select 
    tt1.grass_region 
    ,tt1.table_name 
    ,tt1.status 
    ,count(1) cnt_today
    from risk.ads_risk_blacklist_full_df tt1 
    where tt1.grass_date='${grass_date}'
    and length(tt1.table_name )>1
    group by 
    tt1.grass_region 
    ,tt1.table_name 
    ,tt1.status 
) t1 
left join (
    select 
    grass_region 
    ,table_name 
    ,status 
    ,count(1) cnt_lastday
    from risk.ads_risk_blacklist_full_df tt2 
    where tt2.grass_date=date_sub('${grass_date}',1)
    group by tt2.grass_region 
    ,tt2.table_name 
    ,tt2.status 
) t2 on t1.grass_region = t2.grass_region and t1.table_name = t2.table_name and t1.status = t2.status
union all 
select 
t1.grass_region 
,t1.table_name 
,case when t1.status='1' then 'Add' 
      when t1.status='-1' then 'Delete' end status 
,t1.cnt_today
,coalesce(t2.cnt_lastday,0) as cnt_lastday
,abs(case when coalesce(t2.cnt_lastday,0)=0 then 1
      when coalesce(t2.cnt_lastday,0)>0 then round(((t1.cnt_today-t2.cnt_lastday)*1.0000)/(t2.cnt_lastday*1.0000),4) end)*100 as fluctuation_type 
from (
    select 
    tt1.grass_region 
    ,tt1.description as table_name 
    ,tt1.status 
    ,count(1) cnt_today
    from risk.ads_risk_blacklist_incremental_df tt1 
    where tt1.grass_date='${grass_date}'
    and length(tt1.table_name )>1
    group by 
    tt1.grass_region 
    ,tt1.description 
    ,tt1.status 
) t1 
left join (
    select 
    grass_region 
    ,description as table_name 
    ,status 
    ,count(1) cnt_lastday
    from risk.ads_risk_blacklist_incremental_df tt2 
    where tt2.grass_date=date_sub('${grass_date}',1)
    group by tt2.grass_region 
    ,tt2.description 
    ,tt2.status 
) t2 on t1.grass_region = t2.grass_region and t1.table_name = t2.table_name and t1.status = t2.status
order by t1.table_name
