insert overwrite table risk.ads_risk_br_uw_spl_whitelist_df partition(grass_date='${grass_date}')
select 
platform_user_id as platform_user_id
,1               as status 
FROM  risk.ods__credit_risk_control_br_db__credit_sp_tab__df
WHERE grass_date = '2022-09-16'
AND status = 1
AND create_time <= 1663344000
group by platform_user_id
;