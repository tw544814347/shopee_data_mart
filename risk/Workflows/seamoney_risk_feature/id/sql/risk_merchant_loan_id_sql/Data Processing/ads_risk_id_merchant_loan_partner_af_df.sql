insert overwrite table ${SCHEMA}.ads_risk_id_merchant_loan_partner_af_df partition(grass_date='${grass_date}')
select 
t1.tob_uid                      as tob_uid
,t1.partner_id                  as merchant_id 
,t1.staff_status                as staff_status
,t2.partner_status              as merchant_status
,t3.cnt_store_blacklist         as cnt_store_blacklist        
,t3.cnt_spl_whitelist           as cnt_store_blacklist  
,t3.flag_whitelist_merchant     as flag_whitelist_merchant     
,t3.cnt_store                   as cnt_store              
,t3.spl_concentration_rate_l12m as spl_concentration_rate_l12m   
,t3.spl_user_overdue_rate       as spl_user_overdue_rate_l12m    
,t3.spl_amount_overdue_rate     as spl_amount_overdue_rate_l12m  
,null                            as  activation_szdf               
from merchantservice.mss_merchant_info_id_db__staff_info_tab__id_daily_s0_live t1 
left join merchantservice.mss_merchant_info_id_db__partner_tab__id_daily_s0_live t2 on t1.partner_id = t2.id 
left join smcdrisk_antifraud.f_id_merchant_loan_af_base_table t3 on t1.partner_id = t3.merchant_id 
where t1.tob_uid >0
;
