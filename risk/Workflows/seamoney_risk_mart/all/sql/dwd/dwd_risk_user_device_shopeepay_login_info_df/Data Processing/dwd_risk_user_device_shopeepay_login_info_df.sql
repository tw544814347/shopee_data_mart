insert overwrite table ${SCHEMA}.dwd_risk_user_device_shopeepay_login_info_df partition(grass_region,grass_date)
select t1.user_id                       as user_id
     , t1.request_id                    as request_id   
     , t1.dfpinfosz__security_device_id as szdf_device_id
     , t1.phone                         as phone_no
     , t1.grass_date                    as login_date
     , case
           when instr(t1.dfpinfosz__tags, 'is_app_multi_open_system') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_emulator') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_cloud_phone') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_repack') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_wrong_pkg_name') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_debugging') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_app_debuggable') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_fake_df') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_fake_protocol') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_no_deviceinfo') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_java_hook') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_inline_hook') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_suspicous_so') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_risk_app_running_cheatingapp') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_ochook') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_cinfo_lost') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_info_not_match_rom') > 0 and
                instr(t1.dfpinfosz__tags, 'is_fake_identity') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_info_not_match_rom') > 0 and
                instr(t1.dfpinfosz__tags, 'is_risk_app_install_automation') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_faker_riru_running') > 0 then 1
           when instr(t1.dfpinfosz__tags, 'is_black_rom') > 0 then 1
           else 0 end                   as is_bad_tag
     , t1.shopee_df_plain               as shopee_df_plain
     , t1.hashed_shopee_df              as hashed_shopee_df
     , t1.event_timestamp               as event_timestamp
     , t1.event_timestamp / 1000        as login_timestamp
     , t1.dfpinfosz__tags               as dfpinfosz__tags
     , t1.is_auto_login                 as is_auto_login
     , t1.login_channel                 as login_channel
     , t1.device_language               as device_language
     , t1.platform_id                   as platform_id
     , t1.is_success                    as is_success
     , case when t1.is_success =  'true' then 'success' else 'failed' end as login_result
     , t1.client_ip                     as client_ip
     , t1.dfpinfosz__bssid              as dfpinfosz__bssid
     , t1.ipinfo__country_ip            as ipinfo__country_ip
     , t2.country_name                  as country_name
     , t1.ipinfo__city_ip               as ipinfo__city_ip
     , t1.grass_region                  as grass_region
     , t1.grass_date                    as grass_date
from antifraud_dw.dwd_evt_shopeepay_login_di t1
         left join risk.dim_risk_ip_country_mapping t2
                   on t1.ipinfo__country_ip = t2.ipinfo_country_ip
where t1.grass_date = '${grass_date}'
group by t1.user_id
       , t1.request_id
       , t1.dfpinfosz__security_device_id
       , t1.phone
       , t1.grass_date
       , case
             when instr(t1.dfpinfosz__tags, 'is_app_multi_open_system') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_emulator') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_cloud_phone') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_repack') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_wrong_pkg_name') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_debugging') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_app_debuggable') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_fake_df') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_fake_protocol') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_no_deviceinfo') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_java_hook') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_inline_hook') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_suspicous_so') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_risk_app_running_cheatingapp') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_ochook') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_cinfo_lost') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_info_not_match_rom') > 0 and
                  instr(t1.dfpinfosz__tags, 'is_fake_identity') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_info_not_match_rom') > 0 and
                  instr(t1.dfpinfosz__tags, 'is_risk_app_install_automation') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_faker_riru_running') > 0 then 1
             when instr(t1.dfpinfosz__tags, 'is_black_rom') > 0 then 1
             else 0 end
       , t1.shopee_df_plain
       , t1.hashed_shopee_df
       , t1.event_timestamp
       , t1.dfpinfosz__tags
       , t1.is_auto_login
       , t1.login_channel
       , t1.device_language
       , t1.platform_id
       , t1.is_success
       , t1.client_ip
       , t1.dfpinfosz__bssid
       , t1.ipinfo__country_ip
       , t2.country_name   
       , t1.ipinfo__city_ip
       , t1.grass_region
       , t1.grass_date
;