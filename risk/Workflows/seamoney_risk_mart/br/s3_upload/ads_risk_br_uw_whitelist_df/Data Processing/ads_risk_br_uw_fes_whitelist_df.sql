
insert overwrite table risk.ads_risk_br_uw_fes_whitelist_df partition(grass_date='${grass_date}')
select 
platform_user_id as platform_user_id
,1               as status 
FROM  risk.ods__credit_risk_control_br_db__loan_limit_tab__df
WHERE grass_date = '2023-01-05'
AND status = 1
AND create_time <= 1672934400
AND app_id = 'fes'
group by platform_user_id
;