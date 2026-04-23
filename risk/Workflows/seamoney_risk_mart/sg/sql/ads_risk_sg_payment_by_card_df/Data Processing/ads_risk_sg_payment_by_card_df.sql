-- shopeepay.ods__shopee_payment_module_payment_id_db__payment_v2_tab__df
-- shopeepay.ods__shopeepay_apm_payment_id_db__payment_tab__df__sensitive

-- shopeepay.ods__shopee_payment_module_payment_my_db__payment_v2_tab__df
-- shopeepay.ods__shopee_payment_module_payment_ph_db__payment_v2_tab__df
-- shopeepay.ods__shopee_payment_module_payment_sg_db__payment_tab__df__sensitive

-- shopeepay.shopee_payment_module_id_db__payment_channel_item_tab__reg_daily_s0_live
-- shopeepay.shopee_payment_module_id_db__card_tab__reg_daily_s0_live

-- shopeepay.ods__wallet_payment_module_id_db__payment_channel_item_tab__df
-- shopeepay.ods__wallet_payment_module_id_db__card_tab__df

-- shopeepay.shopee_payment_module_my_db__payment_channel_item_tab__reg_daily_s0_live
-- shopeepay.shopee_payment_module_my_db__card_tab__reg_daily_s0_live

-- shopeepay.shopee_payment_module_ph_db__payment_channel_item_tab__reg_daily_s0_live
-- shopeepay.shopee_payment_module_ph_db__card_tab__reg_daily_s0_live

-- shopeepay.ods__shopee_payment_module_sg_db__payment_channel_item_tab__df
-- shopeepay.ods__shopee_payment_module_sg_db__card_tab__df__sensitive

-- payment_tab:channel_item_id 
-- payment_channel_item_tab:item_ref
-- card_tab:card_id



create or replace temporary view card_info as
select
    t1.channel_item_id      as channel_item_id
     ,t2.fingerprint         as card_fingerprint
from shopeepay.ods__shopee_payment_module_sg_db__payment_channel_item_tab__df t1 join
     shopeepay.ods__shopee_payment_module_sg_db__card_tab__df__sensitive t2 on t1.item_ref = t2.card_id
where t2.status = 0
  and CHAR_LENGTH(t2.fingerprint)>0
;


insert overwrite table risk.get_sg_payment_amt_cnt_by_card_fingerprint partition (grass_date = '${grass_date}')
select concat_ws('_',substr(md5(cast(card_fingerprint as string)),0,2),card_fingerprint,'all',cast(ctime as string),transaction_id) as rowkey,
       cast(amount as string)  as amount
from (
         select
             t1.channel_item_id              as channel_item_id
              ,t1.card_fingerprint            as card_fingerprint
              ,t2.ctime                       as ctime
              ,t2.status                      as status
              ,t2.amount                      as amount
              ,t2.transaction_id              as transaction_id
              ,get_json_object(t2.extra_data,'$.user_id') as user_id
              ,TRIM(REPLACE(get_json_object(t2.extra_data,'$.params.device_fingerprint'),'_','-')) as spdf
         from card_info t1 join
              shopeepay.ods__shopee_payment_module_payment_sg_db__payment_tab__df__sensitive t2
              on t1.channel_item_id = get_json_object(t2.extra_data,'$.params.channel_item_option_info.channel_item_id')
         where t2.payment_type = 4
           and t2.channel_id in (1000102,1000800)
           and CHAR_LENGTH(cast(t2.transaction_id as string))>0
           and CHAR_LENGTH(cast(t2.ctime as string))>0
     )
union all
select concat_ws('_',substr(md5(cast(card_fingerprint as string)),0,2),card_fingerprint,'success',cast(ctime as string),transaction_id) as rowkey,
       cast(amount as string)  as amount
from (
         select
             t1.channel_item_id              as channel_item_id
              ,t1.card_fingerprint            as card_fingerprint
              ,t2.ctime                       as ctime
              ,t2.status                      as status
              ,t2.amount                      as amount
              ,t2.transaction_id              as transaction_id
              ,get_json_object(t2.extra_data,'$.user_id') as user_id
              ,TRIM(REPLACE(get_json_object(t2.extra_data,'$.params.device_fingerprint'),'_','-')) as spdf
         from card_info t1 join
              shopeepay.ods__shopee_payment_module_payment_sg_db__payment_tab__df__sensitive t2
              on t1.channel_item_id = get_json_object(t2.extra_data,'$.params.channel_item_option_info.channel_item_id')
         where t2.payment_type = 4
           and t2.channel_id in (1000102,1000800)
           and CHAR_LENGTH(cast(t2.transaction_id as string))>0
           and CHAR_LENGTH(cast(t2.ctime as string))>0
           and t2.status = 20
     )
;

insert overwrite table risk.get_sg_payment_userid_cnt_by_card_fingerprint partition (grass_date = '${grass_date}')
select concat_ws('_',substr(md5(cast(card_fingerprint as string)),0,2),card_fingerprint,'all',cast(ctime as string),user_id) as rowkey,
       cast(amount as string)  as amount
from (
         select
             t1.channel_item_id              as channel_item_id
              ,t1.card_fingerprint            as card_fingerprint
              ,t2.ctime                       as ctime
              ,t2.status                      as status
              ,t2.amount                      as amount
              ,t2.transaction_id              as transaction_id
              ,get_json_object(t2.extra_data,'$.user_id') as user_id
              ,TRIM(REPLACE(get_json_object(t2.extra_data,'$.params.device_fingerprint'),'_','-')) as spdf
         from card_info t1 join
              shopeepay.ods__shopee_payment_module_payment_sg_db__payment_tab__df__sensitive t2
              on t1.channel_item_id = get_json_object(t2.extra_data,'$.params.channel_item_option_info.channel_item_id')
         where t2.payment_type = 4
           and t2.channel_id in (1000102,1000800)
           and CHAR_LENGTH(cast(t2.transaction_id as string))>0
           and CHAR_LENGTH(cast(t2.ctime as string))>0
           and CHAR_LENGTH(cast(get_json_object(t2.extra_data,'$.user_id') as string))>0
     )
union all
select concat_ws('_',substr(md5(cast(card_fingerprint as string)),0,2),card_fingerprint,'success',cast(ctime as string),user_id) as rowkey,
       cast(amount as string)  as amount
from (
         select
             t1.channel_item_id              as channel_item_id
              ,t1.card_fingerprint            as card_fingerprint
              ,t2.ctime                       as ctime
              ,t2.status                      as status
              ,t2.amount                      as amount
              ,t2.transaction_id              as transaction_id
              ,get_json_object(t2.extra_data,'$.user_id') as user_id
              ,TRIM(REPLACE(get_json_object(t2.extra_data,'$.params.device_fingerprint'),'_','-')) as spdf
         from card_info t1 join
              shopeepay.ods__shopee_payment_module_payment_sg_db__payment_tab__df__sensitive t2
              on t1.channel_item_id = get_json_object(t2.extra_data,'$.params.channel_item_option_info.channel_item_id')
         where t2.payment_type = 4
           and t2.channel_id in (1000102,1000800)
           and CHAR_LENGTH(cast(t2.transaction_id as string))>0
           and CHAR_LENGTH(cast(t2.ctime as string))>0
           and CHAR_LENGTH(cast(get_json_object(t2.extra_data,'$.user_id') as string))>0
           and t2.status = 20
     )
;

insert overwrite table risk.get_sg_payment_device_cnt_by_card_fingerprint partition (grass_date = '${grass_date}')
select concat_ws('_',substr(md5(cast(card_fingerprint as string)),0,2),card_fingerprint,'all',cast(ctime as string),spdf) as rowkey,
       cast(amount as string)  as amount
from (
         select
             t1.channel_item_id              as channel_item_id
              ,t1.card_fingerprint            as card_fingerprint
              ,t2.ctime                       as ctime
              ,t2.status                      as status
              ,t2.amount                      as amount
              ,t2.transaction_id              as transaction_id
              ,get_json_object(t2.extra_data,'$.user_id') as user_id
              ,TRIM(REPLACE(get_json_object(t2.extra_data,'$.params.device_fingerprint'),'_','-')) as spdf
         from card_info t1 join
              shopeepay.ods__shopee_payment_module_payment_sg_db__payment_tab__df__sensitive t2
              on t1.channel_item_id = get_json_object(t2.extra_data,'$.params.channel_item_option_info.channel_item_id')
         where t2.payment_type = 4
           and t2.channel_id in (1000102,1000800)
           and CHAR_LENGTH(cast(t2.transaction_id as string))>0
           and CHAR_LENGTH(cast(t2.ctime as string))>0
           and CHAR_LENGTH(TRIM(REPLACE(get_json_object(t2.extra_data,'$.params.device_fingerprint'),'_','-')))>0
     )
union all
select concat_ws('_',substr(md5(cast(card_fingerprint as string)),0,2),card_fingerprint,'success',cast(ctime as string),spdf) as rowkey,
       cast(amount as string)  as amount
from (
         select
             t1.channel_item_id              as channel_item_id
              ,t1.card_fingerprint            as card_fingerprint
              ,t2.ctime                       as ctime
              ,t2.status                      as status
              ,t2.amount                      as amount
              ,t2.transaction_id              as transaction_id
              ,get_json_object(t2.extra_data,'$.user_id') as user_id
              ,TRIM(REPLACE(get_json_object(t2.extra_data,'$.params.device_fingerprint'),'_','-')) as spdf
         from card_info t1 join
              shopeepay.ods__shopee_payment_module_payment_sg_db__payment_tab__df__sensitive t2
              on t1.channel_item_id = get_json_object(t2.extra_data,'$.params.channel_item_option_info.channel_item_id')
         where t2.payment_type = 4
           and t2.channel_id in (1000102,1000800)
           and CHAR_LENGTH(cast(t2.transaction_id as string))>0
           and CHAR_LENGTH(cast(t2.ctime as string))>0
           and CHAR_LENGTH(TRIM(REPLACE(get_json_object(t2.extra_data,'$.params.device_fingerprint'),'_','-')))>0
           and t2.status = 20
     )
;

insert overwrite table risk.get_sg_payment_amt_cnt_by_card_and_device_fingerprint partition (grass_date = '${grass_date}')
select concat_ws('_',substr(md5(cast(spdf as string)),0,2),spdf,card_fingerprint,'all',cast(ctime as string),transaction_id) as rowkey,
       cast(amount as string)  as amount
from (
         select
             t1.channel_item_id              as channel_item_id
              ,t1.card_fingerprint            as card_fingerprint
              ,t2.ctime                       as ctime
              ,t2.status                      as status
              ,t2.amount                      as amount
              ,t2.transaction_id              as transaction_id
              ,get_json_object(t2.extra_data,'$.user_id') as user_id
              ,TRIM(REPLACE(get_json_object(t2.extra_data,'$.params.device_fingerprint'),'_','-')) as spdf
         from card_info t1 join
              shopeepay.ods__shopee_payment_module_payment_sg_db__payment_tab__df__sensitive t2
              on t1.channel_item_id = get_json_object(t2.extra_data,'$.params.channel_item_option_info.channel_item_id')
         where t2.payment_type = 4
           and t2.channel_id in (1000102,1000800)
           and CHAR_LENGTH(cast(t2.transaction_id as string))>0
           and CHAR_LENGTH(cast(t2.ctime as string))>0
     )
union all
select concat_ws('_',substr(md5(cast(spdf as string)),0,2),spdf,card_fingerprint,'success',cast(ctime as string),transaction_id) as rowkey,
       cast(amount as string)  as amount
from (
         select
             t1.channel_item_id              as channel_item_id
              ,t1.card_fingerprint            as card_fingerprint
              ,t2.ctime                       as ctime
              ,t2.status                      as status
              ,t2.amount                      as amount
              ,t2.transaction_id              as transaction_id
              ,get_json_object(t2.extra_data,'$.user_id') as user_id
              ,TRIM(REPLACE(get_json_object(t2.extra_data,'$.params.device_fingerprint'),'_','-')) as spdf
         from card_info t1 join
              shopeepay.ods__shopee_payment_module_payment_sg_db__payment_tab__df__sensitive t2
              on t1.channel_item_id = get_json_object(t2.extra_data,'$.params.channel_item_option_info.channel_item_id')
         where t2.payment_type = 4
           and t2.channel_id in (1000102,1000800)
           and CHAR_LENGTH(cast(t2.transaction_id as string))>0
           and CHAR_LENGTH(cast(t2.ctime as string))>0
           and t2.status = 20
     )
;