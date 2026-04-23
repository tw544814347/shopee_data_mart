-- ID地区计划上线新业务Merchant Loan、给线下使用shopeepay收款的商家提供贷款
-- merchantservice.mss_merchant_info_id_db__staff_permission_tab__id_daily_s0_live	tob_uid（最终入参） 一一对应于 partner_id（商户ID）
-- mss_merchant_info_id_db__store_tab__id_daily_s0_live	partner_id 一对多 于id（商铺ID）
-- shopeepay.wallet_id_merchant_db__transaction_tab__reg_daily_s0_live	user_id作为关联的商铺ID，extinfo.buyer_id才是Buyer标识
-- ODS -> mart 表 mart_dwd_ows_merchant_transaction_tab_df__id + mart_dwd_wide_merchant_order_acquiring_all_ent_df__id
create or replace temporary view tob_uid_external_info as
select 
a.tob_uid                 as tob_uid
,a.ml_account_status      as ml_account_status
,coalesce(max(a.diff), 0) as ml_max_inactivate_days_in_180d
from (
select 
    t1.tob_uid
    ,case when t2.partner_id is null then 1 else 0 end as ml_account_status --0: normal, 1: abnormal
    ,t2.partner_id
    ,t3.day 
    ,sum(case when t3.store_id is not null then t3.nmv else 0 end) as nmv 
    ,t3.day - (lag(t3.day, 1) OVER(PARTITION BY t1.tob_uid ORDER BY t3.day)) as diff
from merchantservice.mss_merchant_info_id_db__staff_permission_tab__id_daily_s0_live  t1 
left join (select 
               id as store_id 
               ,case when partner_id = 0 then id else partner_id end partner_id
           from merchantservice.mss_merchant_info_id_db__store_tab__id_daily_s0_live 
           where store_status = 1 
        ) t2 on t1.partner_id = t2.partner_id
left join (
            select 
                store_id                                                                     as store_id
                ,sum(amount*1.0/100000)                                                      as nmv
                ,datediff('${grass_date}',to_date(from_unixtime(create_time + 7*3600)))      as  day
            from (
            select 
                store_id, shopeepay_user_id, ows_merchant_transaction_id, create_time, amount, status
            from 
            shopeepay.mart_dwd_ows_merchant_transaction_tab_df__id
            where transaction_type = 13
            union all 
            select 
                store_id, shopeepay_user_id, as_order_id as ows_merchant_transaction_id, create_time, amount, 
                case when order_status = 1 then 1
                    when  order_status = 2 then 2
                    when  order_status in (3,4) then 3
                    when  order_status in (6) then 4
                    when  order_status in (5) then 6 
                    end as status
            from 
            shopeepay.mart_dwd_wide_merchant_order_acquiring_all_ent_df__id
            where order_type_name in ('Payment','Capture') and partner_type_name = 'Merchant Payment'
            )
            where status = 3 and amount > 0
                and datediff('${grass_date}',to_date(from_unixtime(create_time + 7*3600)))<=270
            group by store_id
                ,datediff('${grass_date}',to_date(from_unixtime(create_time + 7*3600)))
        ) t3 on t2.store_id = t3.store_id and t3.day<=180
where  t1.role_id = 1 
group by 
    t1.tob_uid
    ,case when t2.partner_id is null then 1 else 0 end
    ,t2.partner_id
    ,t3.day 
) a 
group by a.tob_uid
,a.ml_account_status
;


insert overwrite table ${SCHEMA}.ads_risk_id_merchant_loan_partner_uw_nd partition(grass_date='${grass_date}')
select
t1.tob_uid                                                         as tob_uid
,t1.partner_id                                                     as partner_id 
,sum(t1.ml_nmv_l3d          )                                      as ml_nmv_l3d           
,sum(t1.ml_nmv_l7d          )                                      as ml_nmv_l7d           
,sum(t1.ml_nmv_l14d         )                                      as ml_nmv_l14d          
,sum(t1.ml_nmv_l30d         )                                      as ml_nmv_l30d          
,sum(t1.ml_nmv_l31_60d      )                                      as ml_nmv_l31_60d       
,sum(t1.ml_nmv_l61_90d      )                                      as ml_nmv_l61_90d       
,sum(t1.ml_nmv_l91_120d     )                                      as ml_nmv_l91_120d      
,sum(t1.ml_nmv_l121_150d    )                                      as ml_nmv_l121_150d     
,sum(t1.ml_nmv_l151_180d    )                                      as ml_nmv_l151_180d     
,sum(t1.ml_nmv_l181_210d    )                                      as ml_nmv_l181_210d     
,sum(t1.ml_nmv_l211_240d    )                                      as ml_nmv_l211_240d     
,sum(t1.ml_nmv_l241_270d    )                                      as ml_nmv_l241_270d     
,sum(t1.ml_nmv_l271_300d    )                                      as ml_nmv_l271_300d     
,sum(t1.ml_nmv_l301_330d    )                                      as ml_nmv_l301_330d     
,sum(t1.ml_nmv_l331_360d    )                                      as ml_nmv_l331_360d     
,min(t1.ml_first_txn_date   )                                      as ml_first_txn_date    
,sum(t1.ml_open_more_than_6m)                                      as ml_open_more_than_6m 
,sum(t1.ml_open_more_than_12m)                                     as ml_open_more_than_12m
,sum(t1.ml_txn_days_in_180d       )                                as ml_txn_days_in_180d  
,sum(t1.ml_txn_l3m                )/3                              as ml_avg_txn_l3m           
,sum(t1.ml_txn_l6m                )/6                              as ml_avg_txn_l6m           
,sum(t1.ml_txn_l12m               )/12                             as ml_avg_txn_l12m          
,sum(t1.ml_txn_l3d                )                                as ml_txn_l3d           
,sum(t1.ml_txn_l7d                )                                as ml_txn_l7d           
,sum(t1.ml_txn_l14d               )                                as ml_txn_l14d          
,sum(t1.ml_txn_l30d               )                                as ml_txn_l30d          
,sum(t1.ml_txn_l31_60d            )                                as ml_txn_l31_60d       
,sum(t1.ml_txn_l61_90d            )                                as ml_txn_l61_90d       
,sum(t1.ml_txn_l91_120d           )                                as ml_txn_l91_120d      
,sum(t1.ml_txn_l121_150d          )                                as ml_txn_l121_150d     
,sum(t1.ml_txn_l151_180d          )                                as ml_txn_l151_180d     
,sum(t1.ml_txn_l181_210d          )                                as ml_txn_l181_210d     
,sum(t1.ml_txn_l211_240d          )                                as ml_txn_l211_240d     
,sum(t1.ml_txn_l241_270d          )                                as ml_txn_l241_270d     
,sum(t1.ml_txn_l271_300d          )                                as ml_txn_l271_300d     
,sum(t1.ml_txn_l301_330d          )                                as ml_txn_l301_330d     
,sum(t1.ml_txn_l331_360d          )                                as ml_txn_l331_360d 
,sum(t1.ml_shop_cnt               )                                as ml_shop_cnt 
,sum(t1.ml_buyer_l3d              )                                as ml_buyer_l3d         
,sum(t1.ml_buyer_l7d              )                                as ml_buyer_l7d         
,sum(t1.ml_buyer_l14d             )                                as ml_buyer_l14d        
,sum(t1.ml_buyer_l30d             )                                as ml_buyer_l30d        
,sum(t1.ml_buyer_l31_60d          )                                as ml_buyer_l31_60d     
,sum(t1.ml_buyer_l61_90d          )                                as ml_buyer_l61_90d     
,sum(t1.ml_buyer_l91_120d         )                                as ml_buyer_l91_120d    
,sum(t1.ml_buyer_l121_150d        )                                as ml_buyer_l121_150d   
,sum(t1.ml_buyer_l151_180d        )                                as ml_buyer_l151_180d   
,sum(t1.ml_buyer_l181_210d        )                                as ml_buyer_l181_210d   
,sum(t1.ml_buyer_l211_240d        )                                as ml_buyer_l211_240d   
,sum(t1.ml_buyer_l241_270d        )                                as ml_buyer_l241_270d   
,sum(t1.ml_buyer_l271_300d        )                                as ml_buyer_l271_300d   
,sum(t1.ml_buyer_l301_330d        )                                as ml_buyer_l301_330d   
,sum(t1.ml_buyer_l331_360d        )                                as ml_buyer_l331_360d  
,min(t1.ml_min_nmv_l3m            )                                as ml_min_nmv_l3m     
,min(t1.ml_min_nmv_l6m            )                                as ml_min_nmv_l6m     
,min(t1.ml_min_nmv_l12m           )                                as ml_min_nmv_l12m    
,sum(t1.ml_nmv_l3m                )/3                              as ml_avg_nmv_l3m             
,sum(t1.ml_nmv_l6m                )/6                              as ml_avg_nmv_l6m             
,sum(t1.ml_nmv_l12m               )/12                             as ml_avg_nmv_l12m            
,sum(t1.ml_has_txn_month_l3m      )                                as ml_has_txn_month_l3m   
,sum(t1.ml_has_txn_month_l6m      )                                as ml_has_txn_month_l6m   
,sum(t1.ml_has_txn_month_l12m     )                                as ml_has_txn_month_l12m  
,sum(t1.ml_buyer_l3m              )                                as ml_buyer_l3m           
,sum(t1.ml_buyer_l6m              )                                as ml_buyer_l6m           
,sum(t1.ml_buyer_l12m             )                                as ml_buyer_l12m     
,max( t2.ml_account_status              )                          as ml_account_status              
,sum( t1.ml_main_category               )                          as ml_main_category               
,max( t2.ml_max_inactivate_days_in_180d   )                        as ml_max_inactivate_days_in_180d               
from risk.ads_risk_id_merchant_loan_store_uw_nd t1 
left join tob_uid_external_info t2 on t1.tob_uid = t2.tob_uid
where t1.grass_date ='${grass_date}'
group by t1.tob_uid    
,t1.partner_id
;