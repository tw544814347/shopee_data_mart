------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-03-12
-- Description:         用户行为主题域，MP User Login主题
-- Data Granularity:    platform_user_id
-- PRD:                 
------------------------------------------------------------------------

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_behavior_app_info_df partition (grass_date = '${grass_date}')
select 
t2.platform_user_id 
,case 
    -- Android version 2.40.11 matched 3 digits CODE 251
    when appversion_len=1 and app_type = 'android5' and cast(app_version as int) >= 240 then 1
    when appversion_len=1 and app_type = 'android3' and cast(app_version as int)  >= 251 then 1 
    -- IOS 2.51.8
    when appversion_len=1 and app_type = 'ios' and cast(split(app_version, '.')[0] as int) > 2 then 1 
    when appversion_len=1 and app_type = 'ios' and cast(split(app_version, '.')[0] as int) = 2
                                and cast(split(app_version, '.')[1] as int) > 51 then 1 
    when appversion_len=1 and app_type = 'ios' and cast(split(app_version, '.')[0] as int) = 2 
                                and cast(split(app_version, '.')[1] as int) = 51
                                and cast(split(app_version, '.')[2] as int) >= 8 then 1 
    else 0 end as app_support_flag 
from (
select
    t1.userid as platform_user_id
    ,case when length(cast(t1.appversion as string)) in (2,4) then 0 else 1 end appversion_len -- len = 2 or 4 are historical and dirty data
    ,case when t1.machine_code like '%apple%' and length(cast(t1.appversion as string)) = 5 then 'ios'
          when length(cast(t1.appversion as string)) = 3 then 'android3'
          when t1.machine_code like '%android%' and length(cast(t1.appversion as string)) = 5 then 'android5'
          else 'unknown' end as app_type
    ,case when t1.machine_code like '%apple%' and length(cast(t1.appversion as string))=5 then
            concat(substr(cast(t1.appversion as string),0,1),'.',
                    substr(cast(t1.appversion as string),2,2),'.',
                    substr(cast(t1.appversion as string),length(cast(t1.appversion as string))-1,2))  
        when machine_code like '%android%' and length(cast(t1.appversion as string))=5 then cast(t1.appversion as string)
        when length(cast(t1.appversion as string)) = 3  then cast(t1.appversion as string)
        else 'unknown' end as app_version
from marketplace.shopee_account_v2_db__account_tab__${region}_df t1
) t2
