create or replace temporary view card_info as
select 
    payment_channel_item_id   as channel_item_id  
    ,fingerprint    as card_fingerprint
    ,item_ref  as  card_id
    ,linkage_status as status
from shopeepay.mart_dim_payment_channel_item_df__ph
where CHAR_LENGTH(fingerprint) > 0
    and  item_ref is not null 
    and  linkage_status = 0
;


create or replace temporary view payment_tab as
select payment_type
     ,pps_payment_channel_id as channel_id
     ,create_time as ctime
     ,payment_status as status
     ,amount
     ,pps_transaction_id as transaction_id
     ,extra_data 
from shopeepay.mart_dwd_pps_inbound_payment_tab_df__ph
where grass_date >= date_sub('${ds}', 100)
union all 
select payment_type
     ,spm_payment_channel_id as channel_id
     ,create_time as ctime
     ,payment_status as status
     ,amount
     ,spm_transaction_id as transaction_id
     ,extra_data 
from shopeepay.mart_dwd_outbound_spm_payment_tab_df__ph
where grass_date >= date_sub('${ds}', 100)
;


insert overwrite table risk.get_ph_payment_amt_cnt_by_card_fingerprint partition (grass_date = '${grass_date}')
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
         from card_info t1 join payment_tab t2
              on t1.channel_item_id = get_json_object(t2.extra_data,'$.params.channel_item_option_info.channel_item_id')
         where t2.payment_type = 4
           and t2.channel_id in (4000700,4004000)
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
         from card_info t1 join payment_tab t2
              on t1.channel_item_id = get_json_object(t2.extra_data,'$.params.channel_item_option_info.channel_item_id')
         where t2.payment_type = 4
           and t2.channel_id in (4000700,4004000)
           and CHAR_LENGTH(cast(t2.transaction_id as string))>0
           and CHAR_LENGTH(cast(t2.ctime as string))>0
           and t2.status = 20
     )
;

insert overwrite table risk.get_ph_payment_userid_cnt_by_card_fingerprint partition (grass_date = '${grass_date}')
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
         from card_info t1 join payment_tab t2
              on t1.channel_item_id = get_json_object(t2.extra_data,'$.params.channel_item_option_info.channel_item_id')
         where t2.payment_type = 4
           and t2.channel_id in (4000700,4004000)
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
         from card_info t1 join payment_tab t2
              on t1.channel_item_id = get_json_object(t2.extra_data,'$.params.channel_item_option_info.channel_item_id')
         where t2.payment_type = 4
           and t2.channel_id in (4000700,4004000)
           and CHAR_LENGTH(cast(t2.transaction_id as string))>0
           and CHAR_LENGTH(cast(t2.ctime as string))>0
           and CHAR_LENGTH(cast(get_json_object(t2.extra_data,'$.user_id') as string))>0
           and t2.status = 20
     )
;

insert overwrite table risk.get_ph_payment_device_cnt_by_card_fingerprint partition (grass_date = '${grass_date}')
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
         from card_info t1 join payment_tab t2
              on t1.channel_item_id = get_json_object(t2.extra_data,'$.params.channel_item_option_info.channel_item_id')
         where t2.payment_type = 4
           and t2.channel_id in (4000700,4004000)
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
         from card_info t1 join payment_tab t2
              on t1.channel_item_id = get_json_object(t2.extra_data,'$.params.channel_item_option_info.channel_item_id')
         where t2.payment_type = 4
           and t2.channel_id in (4000700,4004000)
           and CHAR_LENGTH(cast(t2.transaction_id as string))>0
           and CHAR_LENGTH(cast(t2.ctime as string))>0
           and CHAR_LENGTH(TRIM(REPLACE(get_json_object(t2.extra_data,'$.params.device_fingerprint'),'_','-')))>0
           and t2.status = 20
     )
;

insert overwrite table risk.get_ph_payment_amt_cnt_by_card_and_device_fingerprint partition (grass_date = '${grass_date}')
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
         from card_info t1 join payment_tab t2
              on t1.channel_item_id = get_json_object(t2.extra_data,'$.params.channel_item_option_info.channel_item_id')
         where t2.payment_type = 4
           and t2.channel_id in (4000700,4004000)
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
         from card_info t1 join payment_tab t2
              on t1.channel_item_id = get_json_object(t2.extra_data,'$.params.channel_item_option_info.channel_item_id')
         where t2.payment_type = 4
           and t2.channel_id in (4000700,4004000)
           and CHAR_LENGTH(cast(t2.transaction_id as string))>0
           and CHAR_LENGTH(cast(t2.ctime as string))>0
           and t2.status = 20
     )
;