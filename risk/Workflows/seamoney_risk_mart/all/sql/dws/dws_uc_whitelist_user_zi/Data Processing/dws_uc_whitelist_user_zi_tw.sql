insert overwrite table ${SCHEMA}.dws_uc_whitelist_user_zi_his partition(grass_region,app_id)
select 
platform_user_id
,prod           
,status         
,start_date     
,end_date       
,grass_region 
,app_id 
from ${SCHEMA}.dws_uc_whitelist_user_zi
where start_date <'${grass_date}'
and grass_region ='${upper_region}'
;

create or replace temporary view tmp_uc_whitelist_user as
select 
t1.platform_user_id
,t1.grass_region 
,t1.app_id 
,t1.prod 
,t1.status 
-- 1-新增, 2-status不变, 3-status改变
,case when t2.platform_user_id is null then 1 
      when t2.platform_user_id is not null and t1.status = t2.status then 2 
      when t2.platform_user_id is not null and t1.status <> t2.status then 3 end update_type
from risk.dwd_uc_whitelist_user_df t1 
left join (
    select 
    platform_user_id
    ,grass_region 
    ,app_id 
    ,status 
    from risk.dwd_uc_whitelist_user_df
    where grass_date =date_sub('${grass_date}',1)
    and grass_region ='${upper_region}'
) t2 on t1.platform_user_id = t2.platform_user_id and t1.grass_region = t2.grass_region and t1.app_id = t2.app_id 
where t1.grass_date ='${grass_date}'
and t1.grass_region ='${upper_region}'
;

insert overwrite table ${SCHEMA}.dws_uc_whitelist_user_zi partition(grass_region,app_id)
select 
t1.platform_user_id
,t1.prod           
,t1.status         
,t1.start_date     
,case when t2.platform_user_id is not null and t1.end_date='9999-12-31' then date_add('${grass_date}',-1) 
      else t1.end_date end as end_date    
,t1.grass_region 
,t1.app_id 
from ${SCHEMA}.dws_uc_whitelist_user_zi_his t1 
left join tmp_uc_whitelist_user t2 on t1.platform_user_id = t2.platform_user_id and t1.grass_region = t2.grass_region and t1.app_id = t2.app_id and t2.update_type=3
where t1.grass_region ='${upper_region}'
union all 
select 
t1.platform_user_id
,t1.prod           
,t1.status         
,'${grass_date}' as start_date     
,'9999-12-31'    as end_date    
,t1.grass_region 
,t1.app_id 
from tmp_uc_whitelist_user t1
where t1.update_type in(1,3)
;
