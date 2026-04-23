insert overwrite table ${SCHEMA}.ads_risk_user_login_cnt_in_spp_df partition(grass_region,grass_date)
select concat_ws('_', substr(md5(user_id), 0, 2), user_id, login_result, login_timestamp,event_timestamp) as rowkey
       ,'1'                                                                                as qf
       ,is_auto_login
       ,grass_region
       ,grass_date
from risk.dwd_risk_user_device_shopeepay_login_info_df
where char_length(user_id) > 0
  and login_timestamp > 0
  and event_timestamp > 0
;
