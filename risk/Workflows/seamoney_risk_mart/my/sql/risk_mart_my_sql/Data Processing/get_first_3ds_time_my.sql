-- -- spm
-- shopeepay.ods__shopee_payment_module_payment_my_db__payment_v2_tab__df
-- shopeepay.shopee_payment_module_transaction_my_db__transaction_v2_tab__my_daily_s0_live
-- shopeepay.shopee_payment_module_my_db__payment_channel_item_tab__reg_daily_s0_live
-- shopeepay.shopee_payment_module_my_db__card_tab__my_daily_s0_live
-- shopeepay.ods__shopee_payment_module_my_db__bank_identification_number_tab__df__sensitive
-- shopeepay.shopee_payment_module_my_db__issuing_bank_tab__reg_daily_s0_live
-- -- apm
-- shopeepay.ods__shopeepay_apm_payment_my_db__payment_tab__df__sensitive
-- shopeepay.ods__shopeepay_apm_transaction_my_db__transaction_tab__df    
-- MY 地区：channel id=2000102
-- ID 地区： channel id=8008200/8002050
-- PH 地区：channel id=4000700/4004000
-- SG 地区：channel id=1000102/1000800
-- TH 地区：7018100
create or replace temporary view payment_txn_view
as
select  t1.pps_payment_channel_id as channel_id
        ,t1.pps_transaction_id as transaction_id
        ,t1.payment_type as payment_type
        ,t1.payment_status as status
        ,t1.create_time as ctime
        ,t1.update_time as mtime
        ,get_json_object(t1.extra_data, '$.params.channel_item_option_info.channel_item_id') as channel_item_id
        ,get_json_object(t1.extra_data, '$.params.request_ip') as request_ip
        ,TRIM(REPLACE(get_json_object(t1.extra_data, '$.params.device_fingerprint'), '_', '-')) as spdf
        ,get_json_object(t1.extra_data, '$.use_3ds.is_enabled') as use_3ds
        ,t1.shopee_user_id as user_id
from shopeepay.mart_dwd_pps_inbound_payment_tab_df__my t1
where   t1.payment_type = 4
  and   t1.payment_status = 20
  --   my region channel_id
  and   t1.pps_payment_channel_id in (2000102)
  and   CHAR_LENGTH(cast(t1.pps_transaction_id as string)) > 0
  and   CHAR_LENGTH(cast(t1.create_time as string)) > 0
  and   t1.shopee_user_id > 0
;


-- get_first_3ds_time_by_uid_and_card
insert overwrite table risk.get_first_3ds_time_by_uid_and_card_my partition (region = 'my')
select  concat_ws('_',substr(md5(cast(user_id as string)), 0, 2), cast(user_id as string), channel_item_id) as rowkey
        ,spdf as qf
        ,(9223372036854775807 - ctime * 1000L) as version
from    payment_txn_view
where char_length(spdf) > 0
  and char_length(cast(channel_item_id as string)) > 0
  and cast(use_3ds as string) = 'true'
;




