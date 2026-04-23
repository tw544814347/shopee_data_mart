insert overwrite table ${SCHEMA}.ads_risk_user_device_latest_login_in_spp_df partition(grass_region)
select concat_ws('_', substr(md5(user_id), 0, 2), user_id, 'szdf',TRIM(REPLACE(szdf_device_id, '_', '-'))) as rowkey
       ,cast(login_timestamp as string) as qf
       ,event_timestamp as version
       ,grass_region
from risk.dwd_risk_user_device_shopeepay_login_info_df
where char_length(user_id) > 0
  and is_success = 'true'
  and login_timestamp > 0
  and char_length(szdf_device_id) > 0
  and grass_date >= date_sub('${grass_date}', 180)
union all 
select concat_ws('_', substr(md5(user_id), 0, 2), user_id, 'spdf',TRIM(REPLACE(shopee_df_plain, '_', '-'))) as rowkey
       ,cast(login_timestamp as string) as qf
       ,event_timestamp as version
       ,grass_region
from risk.dwd_risk_user_device_shopeepay_login_info_df
where char_length(user_id) > 0
  and is_success = 'true'
  and login_timestamp > 0
  and char_length(shopee_df_plain) > 0
  and grass_date >= date_sub('${grass_date}', 180)
;
