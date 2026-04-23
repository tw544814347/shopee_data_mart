insert overwrite table risk.ads_risk_ph_uw_fes_whitelist_df partition(grass_date='${grass_date}')
select 
platform_user_id as platform_user_id
,1               as status 
from risk.ods__credit_risk_control_ph_db__loan_limit_tab__df
where grass_date ='2022-09-13'
and app_id ='fes'
and status =1
and create_time<=1663084800
group by platform_user_id
;