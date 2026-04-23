
insert overwrite table risk.ads_risk_my_uw_scl_whitelist_df partition(grass_date='${grass_date}')
select 
platform_user_id as platform_user_id
,1               as status 
from risk.ods__credit_risk_control_my_db__loan_limit_tab__df
where grass_date ='2022-09-17'
and app_id ='spjup'
and status =1
and create_time<=1663603200
group by platform_user_id
;