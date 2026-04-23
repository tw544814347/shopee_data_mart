insert overwrite table risk.ads_risk_vn_uw_spl_whitelist_df partition(grass_date='${grass_date}')
select 
platform_user_id as platform_user_id
,1               as status 
FROM  risk.ods__credit_risk_control_vn_db__credit_sp_tab__df
WHERE grass_date = '2023-01-05'
AND status = 1
AND create_time <= 1673020800
group by platform_user_id
;