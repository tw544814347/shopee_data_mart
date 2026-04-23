insert
overwrite table risk.ads_risk_my_ccdc_card 
select rowkey , value
from (
        select card_id  as rowkey
        ,concat(cast(card_number as string),'_',cast(expiry_date as string),'_',cast(ctime as string),'_',cast(status as string)) as value
        from shopeepay.shopee_payment_module_my_db__card_tab__reg_daily_s0_live 
     )
;

insert
overwrite table risk.ads_risk_my_ccdc_bindtime 
select concat(substring(md5(cast(user_id as string)), 0, 2),'_',cast(user_id as string),'_',cast(channel_item_id as string),'_',cast(ctime as string)) as rowkey
        ,'1' as value
from (
        select 
            t1.user_id              as user_id
            ,t1.channel_item_id     as channel_item_id
            ,t2.ctime               as ctime    
            ,t2.status   
        from shopeepay.shopee_payment_module_my_db__payment_channel_item_tab__reg_daily_s0_live t1 join
             shopeepay.shopee_payment_module_my_db__card_tab__reg_daily_s0_live t2 on t1.item_ref = t2.card_id
        where t2.status = 0
     )
;

insert
overwrite table risk.ads_risk_my_pre_ccdc_binduser_cnt 
select concat(substring(md5(cast(user_id as string)), 0, 2),'_',cast(user_id as string),'_',cast(channel_item_id as string)) as rowkey
        ,concat(cast(card_number as string),'_',cast(expiry_date as string)) as value
from (
        select 
            t1.user_id              as user_id
            ,t1.channel_item_id     as channel_item_id
            ,t2.card_number               as card_number      
            ,t2.expiry_date               as expiry_date  
            ,t2.status
        from shopeepay.shopee_payment_module_my_db__payment_channel_item_tab__reg_daily_s0_live t1 join
             shopeepay.shopee_payment_module_my_db__card_tab__reg_daily_s0_live t2 on t1.item_ref = t2.card_id
        where t2.status = 0
     )
;

insert
overwrite table risk.ads_risk_my_ccdc_binduser_cnt
select concat(substring(md5(concat(cast(card_number as string),'_',cast(expiry_date as string))), 0, 2),'_',cast(card_number as string),'_',cast(expiry_date as string),'_',cast(user_id as string)) as rowkey
        ,'1' as value
from (
        select 
            user_id             
            ,card_number  
            ,expiry_date       
        from shopeepay.shopee_payment_module_my_db__card_tab__reg_daily_s0_live
     )
;

     