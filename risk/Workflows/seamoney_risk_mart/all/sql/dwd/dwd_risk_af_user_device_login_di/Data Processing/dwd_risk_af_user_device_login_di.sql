-- create or replace temporary view risk_fraud_user_tag as
-- select 
--     userid  as user_id
--     ,'ID'   as grass_region
-- from marketplace.shopee_fraud_backend_id_db__fraud_user_tag_tab__reg_daily_s0_live a 
-- join marketplace.shopee_fraud_backend_id_db__fraud_tag_tab__reg_daily_s0_live b on a.tagid = b.id 
-- where (b.type = 1 and b.severity = 1)
-- or b.type = 2
-- group by userid
-- union all 
-- select 
--     userid user_id
--     ,'PH'   as grass_region
-- from marketplace.shopee_fraud_backend_ph_db__fraud_user_tag_tab__reg_daily_s0_live a 
-- join marketplace.shopee_fraud_backend_ph_db__fraud_tag_tab__reg_daily_s0_live b on a.tagid = b.id 
-- where (b.type = 1 and b.severity = 1)
-- or b.type = 2
-- group by userid
-- union all 
-- select 
--     userid  as user_id
--     ,'MY'   as grass_region
-- from marketplace.shopee_fraud_backend_my_db__fraud_user_tag_tab__reg_daily_s0_live a 
-- join marketplace.shopee_fraud_backend_my_db__fraud_tag_tab__reg_daily_s0_live b on a.tagid = b.id 
-- where (b.type = 1 and b.severity = 1)
-- or b.type = 2
-- group by userid
-- union all 
-- select 
--     userid as user_id
--     ,'SG'  as grass_region 
-- from marketplace.shopee_fraud_backend_sg_db__fraud_user_tag_tab__reg_daily_s0_live a 
-- join marketplace.shopee_fraud_backend_sg_db__fraud_tag_tab__reg_daily_s0_live b on a.tagid = b.id 
-- where (b.type = 1 and b.severity = 1)
-- or b.type = 2
-- group by userid
-- ;
uncache table if exists risk_fraud_user_tag;
cache table risk_fraud_user_tag options ('storageLevel' 'MEMORY_AND_DISK')
select 
user_id 
,grass_region 
from (
    select  user_id
            ,fraud_tag_id
            ,grass_region
            ,row_number() over(partition by user_id order by create_datetime desc ) rn 
    from    antifraud_dw.dim_user_fraud_tag_di
    where   severity = 'SEVERE'
    and   fraud_tag_status = 1
) a 
where rn =1
;

insert overwrite table ${SCHEMA}.dwd_risk_af_user_device_login_di partition(grass_region,grass_date)
select
    t1.user_id                                                         as user_id
    ,t1.dfpinfosz__securitydeviceid                                    as szdf_device_id
    ,t1.phone                                                          as phone_no 
    ,t1.grass_date                                                     as login_date
    ,case when t2.user_id is not null then '1' else '0' end            as is_fraud_tag
    -- -- 上游表删除了tagid字段，先注释掉这个字段，让yingjie的数据先跑
    -- ,null                    as is_fraud_tag
    ,case when instr(t1.dfpinfosz__tags,'is_app_multi_open_system') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_emulator') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_cloud_phone') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_repack') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_wrong_pkg_name') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_debugging') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_app_debuggable') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_fake_df') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_fake_protocol') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_no_deviceinfo') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_java_hook') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_inline_hook') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_suspicous_so') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_risk_app_running_cheatingapp') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_ochook') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_cinfo_lost') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_info_not_match_rom') >0 and instr(t1.dfpinfosz__tags,'is_fake_identity') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_info_not_match_rom') >0 and instr(t1.dfpinfosz__tags,'is_risk_app_install_automation') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_faker_riru_running') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_black_rom') >0 then 1 
          else 0 end                                                   as is_bad_tag
    ,t1.shopee_df_plain                                                as shopee_df_plain
    ,t1.hashed_shopee_df                                               as hashed_shopee_df
    ,t1.ipinfo__country_ip                                             as ipinfo_country_ip
    ,t1.event_timestamp/1000                                           as login_timestamp 
    ,t1.dfpinfosz__tags                                                as dfpinfosz__tags
    ,t1.is_auto_login                                                  as is_auto_login   
    ,t1.client_ip                                                      as client_ip       
    ,t1.dfpinfosz__bssid                                               as dfpinfosz__bssid
    ,t1.ipinfo__city_ip                                                as ipinfo__city_ip
    ,t1.grass_region                                                   as grass_region 
    ,t1.grass_date                                                     as grass_date 
from antifraud_dw.dwd_evt_shopee_login_di t1
left join risk_fraud_user_tag t2 on t1.user_id = t2.user_id and t1.grass_region = t2.grass_region 
where t1.grass_date = '${grass_date}'
and t1.is_success = 'true'
group by 
   t1.user_id                     
   ,t1.dfpinfosz__securitydeviceid
   ,t1.phone                      
   ,t1.grass_date 
   ,case when t2.user_id is not null then '1' else '0' end    
   ,case when instr(t1.dfpinfosz__tags,'is_app_multi_open_system') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_emulator') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_cloud_phone') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_repack') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_wrong_pkg_name') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_debugging') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_app_debuggable') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_fake_df') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_fake_protocol') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_no_deviceinfo') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_java_hook') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_inline_hook') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_suspicous_so') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_risk_app_running_cheatingapp') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_ochook') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_cinfo_lost') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_info_not_match_rom') >0 and instr(t1.dfpinfosz__tags,'is_fake_identity') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_info_not_match_rom') >0 and instr(t1.dfpinfosz__tags,'is_risk_app_install_automation') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_faker_riru_running') >0 then 1
          when instr(t1.dfpinfosz__tags,'is_black_rom') >0 then 1 
          else 0 end
    ,t1.shopee_df_plain     
    ,t1.hashed_shopee_df    
    ,t1.ipinfo__country_ip  
    ,t1.event_timestamp/1000
    ,t1.grass_region  
    ,t1.dfpinfosz__tags    
    ,t1.is_auto_login       
    ,t1.client_ip           
    ,t1.dfpinfosz__bssid 
    ,t1.ipinfo__city_ip         

union all
select
    t1.user_id                                                         as user_id
     ,t1.dfpinfosz__security_device_id                                    as szdf_device_id
     ,t1.phone                                                          as phone_no
     ,t1.grass_date                                                     as login_date
     ,case when t2.user_id is not null then '1' else '0' end            as is_fraud_tag
     ,case when instr(t1.dfpinfosz__tags,'is_app_multi_open_system') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_emulator') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_cloud_phone') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_repack') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_wrong_pkg_name') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_debugging') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_app_debuggable') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_fake_df') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_fake_protocol') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_no_deviceinfo') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_java_hook') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_inline_hook') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_suspicous_so') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_risk_app_running_cheatingapp') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_ochook') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_cinfo_lost') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_info_not_match_rom') >0 and instr(t1.dfpinfosz__tags,'is_fake_identity') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_info_not_match_rom') >0 and instr(t1.dfpinfosz__tags,'is_risk_app_install_automation') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_faker_riru_running') >0 then 1
           when instr(t1.dfpinfosz__tags,'is_black_rom') >0 then 1
           else 0 end                                                   as is_bad_tag
     ,t1.shopee_df_plain                                                as shopee_df_plain
     ,t1.hashed_shopee_df                                               as hashed_shopee_df
     ,t1.ipinfo__country_ip                                             as ipinfo_country_ip
     ,t1.event_timestamp/1000                                           as login_timestamp
     ,t1.dfpinfosz__tags                                                as dfpinfosz__tags
     ,t1.is_auto_login                                                  as is_auto_login
     ,t1.client_ip                                                      as client_ip
     ,t1.dfpinfosz__bssid                                               as dfpinfosz__bssid
     ,t1.ipinfo__city_ip                                                as ipinfo__city_ip
     ,t1.grass_region                                                   as grass_region
     ,t1.grass_date                                                     as grass_date
from antifraud_dw.dwd_evt_shopeepay_login_di t1
         left join risk_fraud_user_tag t2 on t1.user_id = t2.user_id and t1.grass_region = t2.grass_region
where t1.grass_date = '${grass_date}'
  and t1.is_success = 'true'
group by
    t1.user_id
       ,t1.dfpinfosz__security_device_id
       ,t1.phone
       ,t1.grass_date
       ,case when t2.user_id is not null then '1' else '0' end
       ,case when instr(t1.dfpinfosz__tags,'is_app_multi_open_system') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_emulator') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_cloud_phone') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_repack') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_wrong_pkg_name') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_debugging') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_app_debuggable') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_fake_df') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_fake_protocol') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_no_deviceinfo') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_java_hook') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_inline_hook') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_suspicous_so') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_risk_app_running_cheatingapp') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_ochook') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_cinfo_lost') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_info_not_match_rom') >0 and instr(t1.dfpinfosz__tags,'is_fake_identity') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_info_not_match_rom') >0 and instr(t1.dfpinfosz__tags,'is_risk_app_install_automation') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_faker_riru_running') >0 then 1
             when instr(t1.dfpinfosz__tags,'is_black_rom') >0 then 1
             else 0 end
       ,t1.shopee_df_plain
       ,t1.hashed_shopee_df
       ,t1.ipinfo__country_ip
       ,t1.event_timestamp/1000
       ,t1.grass_region
       ,t1.dfpinfosz__tags
       ,t1.is_auto_login
       ,t1.client_ip
       ,t1.dfpinfosz__bssid
       ,t1.ipinfo__city_ip    
;