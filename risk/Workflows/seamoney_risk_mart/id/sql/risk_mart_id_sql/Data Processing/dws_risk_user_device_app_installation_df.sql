insert overwrite table ${SCHEMA}.dws_risk_user_device_app_installation_df partition (grass_region, grass_date)
select  user_id as platform_user_id
        ,device_fingerprint
        ,device_id
        ,platform as platform
        ,max(if(app_id = 'com.bpjstku', 1, 0)) as is_bpjs_installed
        ,'${region}' as grass_region
        ,'${grass_date}' as grass_date
from    ${SCHEMA}.dwd_datapoint_applist_zi
where   grass_region = '${region}'
  and   end_date = '9999-12-31'
group by user_id, device_fingerprint, device_id, platform
;