insert overwrite table ${SCHEMA}.ads_risk_user_login_country_city_in_spp_df partition(grass_region,grass_date)
select concat_ws('_', substr(md5(user_id), 0, 2), user_id, 'country', login_timestamp, country_name) as rowkey,
       '1'                                                                                           as qf,
       is_auto_login,
       grass_region,
       grass_date
from risk.dwd_risk_user_device_shopeepay_login_info_df
where char_length(user_id) > 0
  and login_timestamp > 0
  and char_length(country_name) > 0
union all 
select concat_ws('_', substr(md5(user_id), 0, 2), user_id, 'city', login_timestamp, ipinfo__city_ip) as rowkey,
       '1'                                                                                           as qf,
       is_auto_login,
       grass_region,
       grass_date
from risk.dwd_risk_user_device_shopeepay_login_info_df
where char_length(user_id) > 0
  and login_timestamp > 0
  and char_length(ipinfo__city_ip) > 0
;
