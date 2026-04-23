--update info：
    -- by wei.tao 表迁移 FROM RTI表 迁移到 对应的 dwd 表 20250717
    -- 迁移指南见：https://docs.google.com/spreadsheets/d/1kHneXkiVvooBo1JAlmDp5PbxQDy8YY-NCkA0T26iI2A/edit?gid=1995587848#gid=1995587848

insert overwrite table ${SCHEMA}.ads_risk_id_merchant_loan_store_uw_nd partition(grass_date='${grass_date}')
select
tob_uid                                                          as tob_uid
,partner_id                                                     as partner_id 
,store_id                                                       as store_id
,sum(ml_nmv_l3d          )                                      as ml_nmv_l3d           
,sum(ml_nmv_l7d          )                                      as ml_nmv_l7d           
,sum(ml_nmv_l14d         )                                      as ml_nmv_l14d          
,sum(ml_nmv_l30d         )                                      as ml_nmv_l30d          
,sum(ml_nmv_l31_60d      )                                      as ml_nmv_l31_60d       
,sum(ml_nmv_l61_90d      )                                      as ml_nmv_l61_90d       
,sum(ml_nmv_l91_120d     )                                      as ml_nmv_l91_120d      
,sum(ml_nmv_l121_150d    )                                      as ml_nmv_l121_150d     
,sum(ml_nmv_l151_180d    )                                      as ml_nmv_l151_180d     
,sum(ml_nmv_l181_210d    )                                      as ml_nmv_l181_210d     
,sum(ml_nmv_l211_240d    )                                      as ml_nmv_l211_240d     
,sum(ml_nmv_l241_270d    )                                      as ml_nmv_l241_270d     
,sum(ml_nmv_l271_300d    )                                      as ml_nmv_l271_300d     
,sum(ml_nmv_l301_330d    )                                      as ml_nmv_l301_330d     
,sum(ml_nmv_l331_360d    )                                      as ml_nmv_l331_360d     
,min(ml_first_txn_date   )                                      as ml_first_txn_date    
,sum(case when floor(months_between('${grass_date}',ml_first_txn_date))>=6 then ml_open_cnt else 0 end)                             as ml_open_more_than_6m 
,sum(case when floor(months_between('${grass_date}',ml_first_txn_date))>=12 then ml_open_cnt else 0 end)                            as ml_open_more_than_12m
,sum(ml_txn_days_in_180d       )                                as ml_txn_days_in_180d  
,sum(ml_txn_l3m                )                                as ml_txn_l3m           
,sum(ml_txn_l6m                )                                as ml_txn_l6m           
,sum(ml_txn_l12m               )                                as ml_txn_l12m          
,sum(ml_txn_l3d                )                                as ml_txn_l3d           
,sum(ml_txn_l7d                )                                as ml_txn_l7d           
,sum(ml_txn_l14d               )                                as ml_txn_l14d          
,sum(ml_txn_l30d               )                                as ml_txn_l30d          
,sum(ml_txn_l31_60d            )                                as ml_txn_l31_60d       
,sum(ml_txn_l61_90d            )                                as ml_txn_l61_90d       
,sum(ml_txn_l91_120d           )                                as ml_txn_l91_120d      
,sum(ml_txn_l121_150d          )                                as ml_txn_l121_150d     
,sum(ml_txn_l151_180d          )                                as ml_txn_l151_180d     
,sum(ml_txn_l181_210d          )                                as ml_txn_l181_210d     
,sum(ml_txn_l211_240d          )                                as ml_txn_l211_240d     
,sum(ml_txn_l241_270d          )                                as ml_txn_l241_270d     
,sum(ml_txn_l271_300d          )                                as ml_txn_l271_300d     
,sum(ml_txn_l301_330d          )                                as ml_txn_l301_330d     
,sum(ml_txn_l331_360d          )                                as ml_txn_l331_360d 
,1                                                              as ml_shop_cnt       
,sum(ml_buyer_l3d              )                                as ml_buyer_l3d         
,sum(ml_buyer_l7d              )                                as ml_buyer_l7d         
,sum(ml_buyer_l14d             )                                as ml_buyer_l14d        
,sum(ml_buyer_l30d             )                                as ml_buyer_l30d        
,sum(ml_buyer_l31_60d          )                                as ml_buyer_l31_60d     
,sum(ml_buyer_l61_90d          )                                as ml_buyer_l61_90d     
,sum(ml_buyer_l91_120d         )                                as ml_buyer_l91_120d    
,sum(ml_buyer_l121_150d        )                                as ml_buyer_l121_150d   
,sum(ml_buyer_l151_180d        )                                as ml_buyer_l151_180d   
,sum(ml_buyer_l181_210d        )                                as ml_buyer_l181_210d   
,sum(ml_buyer_l211_240d        )                                as ml_buyer_l211_240d   
,sum(ml_buyer_l241_270d        )                                as ml_buyer_l241_270d   
,sum(ml_buyer_l271_300d        )                                as ml_buyer_l271_300d   
,sum(ml_buyer_l301_330d        )                                as ml_buyer_l301_330d   
,sum(ml_buyer_l331_360d        )                                as ml_buyer_l331_360d  
,sum(least(ml_nmv_l30d,ml_nmv_l31_60d,ml_nmv_l61_90d))               as ml_min_nmv_l3m     
,sum(least(ml_nmv_l30d,ml_nmv_l31_60d,ml_nmv_l61_90d
          ,ml_nmv_l91_120d,ml_nmv_l121_150d ,ml_nmv_l151_180d))      as ml_min_nmv_l6m     
,sum(least(ml_nmv_l30d,ml_nmv_l31_60d,ml_nmv_l61_90d
          ,ml_nmv_l91_120d ,ml_nmv_l121_150d ,ml_nmv_l151_180d
          ,ml_nmv_l181_210d ,ml_nmv_l211_240d ,ml_nmv_l241_270d 
          ,ml_nmv_l271_300d ,ml_nmv_l301_330d ,ml_nmv_l331_360d ))   as ml_min_nmv_l12m    
,sum(ml_nmv_l3m                )                                as ml_nmv_l3m             
,sum(ml_nmv_l6m                )                                as ml_nmv_l6m             
,sum(ml_nmv_l12m               )                                as ml_nmv_l12m            
,sum(case when floor(months_between('${grass_date}',ml_first_txn_date))<=3 then ml_has_txn else 0 end )                                      as ml_has_txn_month_l3m   
,sum(case when floor(months_between('${grass_date}',ml_first_txn_date))<=6 then ml_has_txn else 0 end )                                      as ml_has_txn_month_l6m   
,sum(case when floor(months_between('${grass_date}',ml_first_txn_date))<=12 then ml_has_txn else 0 end )                                     as ml_has_txn_month_l12m  
,sum(ml_buyer_l3m              )                                as ml_buyer_l3m           
,sum(ml_buyer_l6m              )                                as ml_buyer_l6m           
,sum(ml_buyer_l12m             )                                as ml_buyer_l12m       
,sum( ml_account_status              )                          as ml_account_status              
,sum( ml_main_category               )                          as ml_main_category               
,sum( ml_max_inactivate_days_in_180d   )                        as ml_max_inactivate_days_in_180d           
from( 
    select 
        t1.tob_uid                                                                                                              as tob_uid
        ,t1.partner_id                                                                                                          as partner_id 
        ,t2.store_id                                                                                                            as store_id
        ,sum(case when t3.diff_received_day <= 3  then t3.nmv else 0 end)                                                       as ml_nmv_l3d                     
        ,sum(case when t3.diff_received_day <= 7  then t3.nmv else 0 end)                                                       as ml_nmv_l7d                     
        ,sum(case when t3.diff_received_day <= 14 then t3.nmv else 0 end)                                                       as ml_nmv_l14d                    
        ,sum(case when t3.diff_received_day <= 30 then t3.nmv else 0 end)                                                       as ml_nmv_l30d                    
        ,sum(case when t3.diff_received_day >= 31 and t3.diff_received_day<= 60 then t3.nmv else 0 end)                         as ml_nmv_l31_60d                 
        ,sum(case when t3.diff_received_day >= 61 and t3.diff_received_day<= 90 then t3.nmv else 0 end)                         as ml_nmv_l61_90d                 
        ,sum(case when t3.diff_received_day >= 91 and t3.diff_received_day<= 120 then t3.nmv else 0 end)                        as ml_nmv_l91_120d                
        ,sum(case when t3.diff_received_day >= 121 and t3.diff_received_day<= 150 then t3.nmv else 0 end)                       as ml_nmv_l121_150d               
        ,sum(case when t3.diff_received_day >= 151 and t3.diff_received_day<= 180 then t3.nmv else 0 end)                       as ml_nmv_l151_180d               
        ,sum(case when t3.diff_received_day >= 181 and t3.diff_received_day<= 210 then t3.nmv else 0 end)                       as ml_nmv_l181_210d               
        ,sum(case when t3.diff_received_day >= 211 and t3.diff_received_day<= 240 then t3.nmv else 0 end)                       as ml_nmv_l211_240d               
        ,sum(case when t3.diff_received_day >= 241 and t3.diff_received_day<= 270 then t3.nmv else 0 end)                       as ml_nmv_l241_270d               
        ,sum(case when t3.diff_received_day >= 271 and t3.diff_received_day<= 300 then t3.nmv else 0 end)                       as ml_nmv_l271_300d               
        ,sum(case when t3.diff_received_day >= 301 and t3.diff_received_day<= 330 then t3.nmv else 0 end)                       as ml_nmv_l301_330d               
        ,sum(case when t3.diff_received_day >= 331 and t3.diff_received_day<= 360 then t3.nmv else 0 end)                       as ml_nmv_l331_360d               
        ,min(t3.received_date)                                                                                                  as ml_first_txn_date              
        -- ,sum(case when floor(months_between('${grass_date}',min(t3.received_date)))>=6 then 1 else 0 end)                       as ml_open_more_than_6m           
        -- ,sum(case when floor(months_between('${grass_date}',min(t3.received_date)))>=12 then 1 else 0 end)                      as ml_open_more_than_12m   
        ,sum(1)                                                                                                                 as ml_open_cnt
        ,sum(case when t3.diff_received_day<=180 then 1 else null end )                                                         as ml_txn_days_in_180d            
        ,count(case when t3.diff_received_day<=90 then t3.transaction_id else null end )                                        as ml_txn_l3m                 
        ,count(case when t3.diff_received_day<=180 then t3.transaction_id else null end )                                       as ml_txn_l6m                 
        ,count(case when t3.diff_received_day<=365 then t3.transaction_id else null end )                                       as ml_txn_l12m                
        ,count(case when t3.diff_received_day<=3 then t3.transaction_id else null end )                                         as ml_txn_l3d                     
        ,count(case when t3.diff_received_day<=7 then t3.transaction_id else null end )                                         as ml_txn_l7d                     
        ,count(case when t3.diff_received_day<=14 then t3.transaction_id else null end )                                        as ml_txn_l14d                    
        ,count(case when t3.diff_received_day<=30 then t3.transaction_id else null end )                                        as ml_txn_l30d                    
        ,count(case when t3.diff_received_day >= 31 and t3.diff_received_day<= 60 then t3.transaction_id else 0 end)            as ml_txn_l31_60d                 
        ,count(case when t3.diff_received_day >= 61 and t3.diff_received_day<= 90 then t3.transaction_id else 0 end)            as ml_txn_l61_90d                 
        ,count(case when t3.diff_received_day >= 91 and t3.diff_received_day<= 120 then t3.transaction_id else 0 end)           as ml_txn_l91_120d                
        ,count(case when t3.diff_received_day >= 121 and t3.diff_received_day<= 150 then t3.transaction_id else 0 end)          as ml_txn_l121_150d               
        ,count(case when t3.diff_received_day >= 151 and t3.diff_received_day<= 180 then t3.transaction_id else 0 end)          as ml_txn_l151_180d               
        ,count(case when t3.diff_received_day >= 181 and t3.diff_received_day<= 210 then t3.transaction_id else 0 end)          as ml_txn_l181_210d               
        ,count(case when t3.diff_received_day >= 211 and t3.diff_received_day<= 240 then t3.transaction_id else 0 end)          as ml_txn_l211_240d               
        ,count(case when t3.diff_received_day >= 241 and t3.diff_received_day<= 270 then t3.transaction_id else 0 end)          as ml_txn_l241_270d               
        ,count(case when t3.diff_received_day >= 271 and t3.diff_received_day<= 300 then t3.transaction_id else 0 end)          as ml_txn_l271_300d               
        ,count(case when t3.diff_received_day >= 301 and t3.diff_received_day<= 330 then t3.transaction_id else 0 end)          as ml_txn_l301_330d               
        ,count(case when t3.diff_received_day >= 331 and t3.diff_received_day<= 360 then t3.transaction_id else 0 end)          as ml_txn_l331_360d               
        ,0 as ml_shop_cnt      -- 待定               
        ,count(distinct case when t3.diff_received_day<=3 then t3.buyer_id else null end )                                      as ml_buyer_l3d                   
        ,count(distinct case when t3.diff_received_day<=7 then t3.buyer_id else null end )                                      as ml_buyer_l7d                   
        ,count(distinct case when t3.diff_received_day<=14 then t3.buyer_id else null end )                                     as ml_buyer_l14d                  
        ,count(distinct case when t3.diff_received_day<=30 then t3.buyer_id else null end )                                     as ml_buyer_l30d                  
        ,count(distinct case when t3.diff_received_day >= 31 and t3.diff_received_day<= 60 then t3.buyer_id else null end)      as ml_buyer_l31_60d               
        ,count(distinct case when t3.diff_received_day >= 61 and t3.diff_received_day<= 90 then t3.buyer_id else null end)      as ml_buyer_l61_90d               
        ,count(distinct case when t3.diff_received_day >= 91 and t3.diff_received_day<= 120 then t3.buyer_id else null end)     as ml_buyer_l91_120d              
        ,count(distinct case when t3.diff_received_day >= 121 and t3.diff_received_day<= 150 then t3.buyer_id else null end)    as ml_buyer_l121_150d             
        ,count(distinct case when t3.diff_received_day >= 151 and t3.diff_received_day<= 180 then t3.buyer_id else null end)    as ml_buyer_l151_180d             
        ,count(distinct case when t3.diff_received_day >= 181 and t3.diff_received_day<= 210 then t3.buyer_id else null end)    as ml_buyer_l181_210d             
        ,count(distinct case when t3.diff_received_day >= 211 and t3.diff_received_day<= 240 then t3.buyer_id else null end)    as ml_buyer_l211_240d             
        ,count(distinct case when t3.diff_received_day >= 241 and t3.diff_received_day<= 270 then t3.buyer_id else null end)    as ml_buyer_l241_270d             
        ,count(distinct case when t3.diff_received_day >= 271 and t3.diff_received_day<= 300 then t3.buyer_id else null end)    as ml_buyer_l271_300d             
        ,count(distinct case when t3.diff_received_day >= 301 and t3.diff_received_day<= 330 then t3.buyer_id else null end)    as ml_buyer_l301_330d             
        ,count(distinct case when t3.diff_received_day >= 331 and t3.diff_received_day<= 360 then t3.buyer_id else null end)    as ml_buyer_l331_360d                           
        ,sum(case when t3.diff_received_day<=90 then  t3.nmv else 0 end)                                                        as ml_nmv_l3m                 
        ,sum(case when t3.diff_received_day<=180 then t3.nmv else 0 end)                                                        as ml_nmv_l6m                 
        ,sum(case when t3.diff_received_day<=365 then t3.nmv else 0 end)                                                        as ml_nmv_l12m                
        -- ,sum(case when floor(months_between('${grass_date}',min(t3.received_date)))<=3 and t3.nmv>0 then 1 else 0 end )         as ml_has_txn_month_l3m           
        -- ,sum(case when floor(months_between('${grass_date}',min(t3.received_date)))<=6 and t3.nmv>0 then 1 else 0 end )         as ml_has_txn_month_l6m           
        -- ,sum(case when floor(months_between('${grass_date}',min(t3.received_date)))<=12 and t3.nmv>0 then 1 else 0 end )        as ml_has_txn_month_l12m   
        ,sum(case when t3.nmv>0 then 1 else 0 end)                                                                              as ml_has_txn  
        ,count(case when t3.diff_received_day<=90 then t3.buyer_id else null end  )                                             as ml_buyer_l3m               
        ,count(case when t3.diff_received_day<=180 then t3.buyer_id else null end )                                             as ml_buyer_l6m               
        ,count(case when t3.diff_received_day<=365 then t3.buyer_id else null end )                                             as ml_buyer_l12m              
        ,0 as ml_account_status              
        ,0 as ml_main_category               
        ,0 as ml_max_inactivate_days_in_180d 
    from merchantservice.mss_merchant_info_id_db__staff_permission_tab__id_daily_s0_live t1 -- 员工角色权限表
    left join (
        select
            id             as store_id
            ,partner_id    as partner_id
        from merchantservice.mss_merchant_info_id_db__store_tab__id_daily_s0_live 
    )t2 on t1.partner_id = t2.partner_id
    left join (
                select 
                    store_id                                                              as store_id
                    ,shopeepay_user_id                                                    as buyer_id 
                    ,ows_merchant_transaction_id                                          as transaction_id
                    ,to_date(from_unixtime(create_time))                                 as received_date
                    ,datediff('${grass_date}',to_date(from_unixtime(create_time)))       as diff_received_day
                    ,sum(amount*1.0/100000)                                              as nmv
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
                where status = 3
                group by store_id 
                    ,shopeepay_user_id
                    ,ows_merchant_transaction_id
                    ,to_date(from_unixtime(create_time))
                    ,datediff('${grass_date}',to_date(from_unixtime(create_time)))
                    
    ) t3 on t2.store_id = t3.store_id
    where t1.role_id=1 -- 'role id assign with role info tab, 1-admin 2-staff'
    group by 
    t1.tob_uid     
    ,t1.partner_id 
    ,t2.store_id   
) a 
group by 
tob_uid      
,partner_id   
,store_id    
;
