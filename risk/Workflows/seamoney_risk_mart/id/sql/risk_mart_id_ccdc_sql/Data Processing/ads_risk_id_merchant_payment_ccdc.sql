-- id merchant ccdc
-- shopeepay.ods__shopeepay_acquiring_order_id_db__order_tab__df
-- shopeepay.ods__shopeepay_acquiring_transaction_id_db__transaction_tab__df
-- shopeepay.ods__shopeepay_acquiring_action_id_db__action_tab__df
-- shopeepay.ods__shopeepay_apm_provision_id_db__provision_tab__df
-- shopeepay.ods__shopeepay_apm_transaction_id_db__transaction_tab__df
-- shopeepay.ods__shopeepay_apm_payment_id_db__payment_tab__df__sensitive


create or replace temporary view transaction_info as
select s.transaction_id,
       s.action_id,
       t.order_id,
       t.merchant_id,
       t.store_id,
       t.order_info
from (
         select t1.transaction_id,
                t2.order_id,
                t2.order_info,
                get_json_object(t2.order_info, '$.merchant_info.merchant_id') as merchant_id,
                get_json_object(t2.order_info, '$.merchant_info.store_id')    as store_id
         from shopeepay.ods__shopeepay_acquiring_transaction_id_db__transaction_tab__df t1
                  join shopeepay.ods__shopeepay_acquiring_order_id_db__order_tab__df t2
                       on t1.order_id = t2.order_id
         where t1.order_id is not null
              and t1.sppd_c_date > date_sub('${ds}', 120)
              and t2.sppd_c_date > date_sub('${ds}', 120)
     ) t
         join shopeepay.ods__shopeepay_acquiring_action_id_db__action_tab__df s
              on s.transaction_id = t.transaction_id
where s.transaction_id is not null
  and s.action_id is not null
  and t.merchant_id is not null
  and t.store_id is not null
  and s.sppd_c_date > date_sub('${ds}', 120)
;

create or replace temporary view payment_info as
select t.payment_id,
       t.transaction_id,
       t.channel_id,
       t.payment_type,
       t.amount,
       t.status,
       t.ctime,
       t.client_id,
       t.card_number,
       t.expiry_date,
       t.channel_item_id,
       t.spdf,
       t.szdf,
       t.user_id,
       s.entity_id
from (
         select t1.payment_id                                                                          as payment_id,
                t1.transaction_id                                                                      as transaction_id,
                t1.channel_id                                                                          as channel_id,
                t1.payment_type                                                                        as payment_type,
                t1.amount                                                                              as amount,
                t1.status                                                                              as status,
                t1.ctime                                                                               as ctime,
                get_json_object(t1.extra_data, '$.client_id')                                          as client_id,
                get_json_object(t1.extra_data,
                                '$.params.channel_item_option_info.credit_card_data.card_number')      as card_number,
                get_json_object(t1.extra_data,
                                '$.params.channel_item_option_info.credit_card_data.expiry_date')      as expiry_date,
                get_json_object(t1.extra_data,
                                '$.params.channel_item_option_info.channel_item_id')                   as channel_item_id,
                TRIM(REPLACE(get_json_object(t1.extra_data, '$.params.device_fingerprint'), '_', '-')) as spdf,
                TRIM(REPLACE(get_json_object(t1.extra_data, '$.sz_df'), '_', '-'))                     as szdf,
                t2.user_id                                                                             as user_id
         from shopeepay.ods__shopeepay_apm_payment_id_db__payment_tab__df__sensitive t1
                  inner join shopeepay.ods__shopeepay_apm_transaction_id_db__transaction_tab__df t2
                             on t1.transaction_id = t2.transaction_id
         where t1.payment_type = 4
           --   id region channel_id
           and t1.channel_id in (8008200, 8002050)
           and CHAR_LENGTH(cast(t1.transaction_id as string)) > 0
           and CHAR_LENGTH(cast(t1.ctime as string)) > 0
           and char_length(cast(t1.payment_id as string)) > 0
           and t1.sppd_c_date > date_sub('${ds}', 120)
           and t2.sppd_c_date > date_sub('${ds}', 120)
     ) t
         inner join shopeepay.ods__shopeepay_apm_provision_id_db__provision_tab__df s
                    on t.transaction_id = s.transaction_id
where s.entity_id is not null
    and s.sppd_c_date > date_sub('${ds}', 120)
;

create or replace temporary view final_join as
select t1.merchant_id
     , t1.store_id
     , t2.payment_id
     , t2.transaction_id
     , t2.channel_id
     , t2.payment_type
     , t2.amount
     , t2.status
     , t2.ctime
     , t2.client_id
     , t2.card_number
     , t2.expiry_date
     , t2.channel_item_id
     , t2.spdf
     , t2.szdf
     , t2.user_id
from transaction_info t1
         join payment_info t2
              on t1.action_id = t2.entity_id
;








insert overwrite  table risk.get_merchant_payment_amt_cnt_by_card partition (region = '${region}')
(
    select  concat_ws('_',substr(md5(card_number),0,2),card_number,expiry_date,'all','merchant',cast(merchant_id as string),ctime,payment_id)  as rowkey,          
            cast(amount as string)  as amount
    from final_join
    where char_length(card_number) > 0
        and char_length(expiry_date) > 0
        and char_length(cast(merchant_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(card_number),0,2),card_number,expiry_date,'all','store',cast(store_id as string),ctime,payment_id)  as rowkey,          
            cast(amount as string)  as amount
    from final_join
    where char_length(card_number) > 0
        and char_length(expiry_date) > 0
        and char_length(cast(store_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(card_number),0,2),card_number,expiry_date,'success','merchant',cast(merchant_id as string),ctime,payment_id)  as rowkey,         
            cast(amount as string)  as amount
    from final_join
    where status = 20
        and char_length(card_number) > 0
        and char_length(expiry_date) > 0
        and char_length(cast(merchant_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(card_number),0,2),card_number,expiry_date,'success','store',cast(store_id as string),ctime,payment_id)  as rowkey,         
            cast(amount as string)  as amount
    from final_join
    where status = 20
        and char_length(card_number) > 0
        and char_length(expiry_date) > 0
        and char_length(cast(store_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(card_number),0,2),card_number,expiry_date,'unfailed','merchant',cast(merchant_id as string),ctime,payment_id)  as rowkey,         
            cast(amount as string)  as amount
    from final_join
    where status not in (22, 24, 26, 52, 51, 50, 54, 100, 999)
        and char_length(card_number) > 0
        and char_length(expiry_date) > 0
        and char_length(cast(merchant_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(card_number),0,2),card_number,expiry_date,'unfailed','store',cast(store_id as string),ctime,payment_id)  as rowkey,         
            cast(amount as string)  as amount
    from final_join
    where status not in (22, 24, 26, 52, 51, 50, 54, 100, 999)
        and char_length(card_number) > 0
        and char_length(expiry_date) > 0
        and char_length(cast(store_id as string)) > 0
)
;






insert overwrite  table risk.get_merchant_payment_amt_cnt_by_card_userid partition (region = '${region}')
(
    select  concat_ws('_',substr(md5(cast(user_id as string)),0,2),cast(user_id as string),channel_item_id,'all','merchant',cast(merchant_id as string),ctime,payment_id)  as rowkey,          
            cast(amount as string)  as amount
    from final_join
    where char_length(cast(user_id as string)) > 0
        and char_length(cast(channel_item_id as string)) > 0
        and char_length(cast(merchant_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(cast(user_id as string)),0,2),cast(user_id as string),channel_item_id,'all','store',cast(store_id as string),ctime,payment_id)  as rowkey,          
            cast(amount as string)  as amount
    from final_join
    where char_length(cast(user_id as string)) > 0
        and char_length(cast(channel_item_id as string)) > 0
        and char_length(cast(store_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(cast(user_id as string)),0,2),cast(user_id as string),channel_item_id,'success','merchant',cast(merchant_id as string),ctime,payment_id)  as rowkey,            
            cast(amount as string)  as amount
    from final_join
    where status = 20
        and char_length(cast(user_id as string)) > 0
        and char_length(cast(channel_item_id as string)) > 0
        and char_length(cast(merchant_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(cast(user_id as string)),0,2),cast(user_id as string),channel_item_id,'success','store',cast(store_id as string),ctime,payment_id)  as rowkey,            
            cast(amount as string)  as amount
    from final_join
    where status = 20
        and char_length(cast(user_id as string)) > 0
        and char_length(cast(channel_item_id as string)) > 0
        and char_length(cast(store_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(cast(user_id as string)),0,2),cast(user_id as string),channel_item_id,'unfailed','merchant',cast(merchant_id as string),ctime,payment_id)  as rowkey,            
            cast(amount as string)  as amount
    from final_join
    where status not in (22, 24, 26, 52, 51, 50, 54, 100, 999)
        and char_length(cast(user_id as string)) > 0
        and char_length(cast(channel_item_id as string)) > 0
        and char_length(cast(merchant_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(cast(user_id as string)),0,2),cast(user_id as string),channel_item_id,'unfailed','store',cast(store_id as string),ctime,payment_id)  as rowkey,            
            cast(amount as string)  as amount
    from final_join
    where status not in (22, 24, 26, 52, 51, 50, 54, 100, 999)
        and char_length(cast(user_id as string)) > 0
        and char_length(cast(channel_item_id as string)) > 0
        and char_length(cast(store_id as string)) > 0
)
;







insert overwrite  table risk.get_merchant_payment_amt_cnt_by_userid partition (region = '${region}')
(
    select  concat_ws('_',substr(md5(cast(user_id as string)),0,2),cast(user_id as string),'all','merchant',cast(merchant_id as string),ctime,payment_id)  as rowkey,          
            cast(amount as string)  as amount
    from final_join
    where char_length(cast(user_id as string)) > 0
    and char_length(cast(merchant_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(cast(user_id as string)),0,2),cast(user_id as string),'all','store',cast(store_id as string),ctime,payment_id)  as rowkey,          
            cast(amount as string)  as amount
    from final_join
    where char_length(cast(user_id as string)) > 0
    and char_length(cast(store_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(cast(user_id as string)),0,2),cast(user_id as string),'success','merchant',cast(merchant_id as string),ctime,payment_id)  as rowkey,            
            cast(amount as string)  as amount
    from final_join
    where status = 20
        and char_length(cast(user_id as string)) > 0
        and char_length(cast(merchant_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(cast(user_id as string)),0,2),cast(user_id as string),'success','store',cast(store_id as string),ctime,payment_id)  as rowkey,            
            cast(amount as string)  as amount
    from final_join
    where status = 20
        and char_length(cast(user_id as string)) > 0
        and char_length(cast(store_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(cast(user_id as string)),0,2),cast(user_id as string),'unfailed','merchant',cast(merchant_id as string),ctime,payment_id)  as rowkey,            
            cast(amount as string)  as amount
    from final_join
    where status not in (22, 24, 26, 52, 51, 50, 54, 100, 999)
        and char_length(cast(user_id as string)) > 0
        and char_length(cast(merchant_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(cast(user_id as string)),0,2),cast(user_id as string),'unfailed','store',cast(store_id as string),ctime,payment_id)  as rowkey,            
            cast(amount as string)  as amount
    from final_join
    where status not in (22, 24, 26, 52, 51, 50, 54, 100, 999)
        and char_length(cast(user_id as string)) > 0
        and char_length(cast(store_id as string)) > 0
)
;






insert overwrite  table risk.get_merchant_payment_amt_cnt_by_szdf partition (region = '${region}')
(
    select  concat_ws('_',substr(md5(cast(szdf as string)),0,2),cast(szdf as string),'all','merchant',cast(merchant_id as string),ctime,payment_id)  as rowkey,          
            cast(amount as string)  as amount
    from final_join
    where char_length(cast(szdf as string)) > 0
    and char_length(cast(merchant_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(cast(szdf as string)),0,2),cast(szdf as string),'all','store',cast(store_id as string),ctime,payment_id)  as rowkey,          
            cast(amount as string)  as amount
    from final_join
    where char_length(cast(szdf as string)) > 0
    and char_length(cast(store_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(cast(szdf as string)),0,2),cast(szdf as string),'success','merchant',cast(merchant_id as string),ctime,payment_id)  as rowkey,            
            cast(amount as string)  as amount
    from final_join
    where status = 20
        and char_length(cast(szdf as string)) > 0
        and char_length(cast(merchant_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(cast(szdf as string)),0,2),cast(szdf as string),'success','store',cast(store_id as string),ctime,payment_id)  as rowkey,            
            cast(amount as string)  as amount
    from final_join
    where status = 20
        and char_length(cast(szdf as string)) > 0
        and char_length(cast(store_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(cast(szdf as string)),0,2),cast(szdf as string),'unfailed','merchant',cast(merchant_id as string),ctime,payment_id)  as rowkey,            
            cast(amount as string)  as amount
    from final_join
    where status not in (22, 24, 26, 52, 51, 50, 54, 100, 999)
        and char_length(cast(szdf as string)) > 0
        and char_length(cast(merchant_id as string)) > 0
)
union all 
(
    select  concat_ws('_',substr(md5(cast(szdf as string)),0,2),cast(szdf as string),'unfailed','store',cast(store_id as string),ctime,payment_id)  as rowkey,            
            cast(amount as string)  as amount
    from final_join
    where status not in (22, 24, 26, 52, 51, 50, 54, 100, 999)
        and char_length(cast(szdf as string)) > 0
        and char_length(cast(store_id as string)) > 0
)
;