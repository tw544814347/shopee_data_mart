insert overwrite table risk.ads_risk_id_uw_bcl_whitelist_df partition(grass_date='${grass_date}')
select 
platform_user_id as platform_user_id
,1               as status 
from risk.ods__credit_risk_control_id_db__cashloan_limit_tab__df
where grass_date ='2022-09-27'
and status =1
and create_time<=1664294400
group by platform_user_id
;