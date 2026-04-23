set spark.sql.session.timeZone=GMT+7;

with product_codes as 
(
    select channel_id
           ,concat_ws(',',collect_set(code)) as codes
    from shopeepay.airpay_payment_common_th_db__product_code_tab__reg_daily_s0_live
    group by channel_id
),
transcation as
(
    select ord.uid
           ,ord.payment_channel_id                      as payment_channel_id
           ,ord.topup_channel_id                        as topup_channel_id
           ,ord.order_id                                as order_id
           ,ord.payment_payable_amount                  as payment_payable_amount
           ,ord.create_time                             as create_time
           ,ord.status                                  as status
           ,from_unixtime(ord.create_time,'yyyy-MM-dd') as create_date
           ,channel.type                                as type
           ,prd.codes                                   as codes
    from shopeepay.airpay_payment_txn_th_db__txn_order_tab__th_daily_s0_live  ord
    left join shopeepay.airpay_payment_common_th_db__channel_tab__reg_daily_s0_live channel
    on ord.topup_channel_id = channel.channel_id
    left join product_codes prd
    on ord.payment_channel_id = prd.channel_id
),
r1 as
(
    select uid, payment_channel_id, count(order_id) as cnt, sum(payment_payable_amount) as amount, topup_channel_id, type, codes, status, unix_timestamp(create_date, 'yyyy-MM-dd') as create_day_timestamp
    from transcation
    where create_date < date_sub('${bizTimeFormatter(SCHEDULED_TIME,'yyyy-MM-dd','-1d')}',30) and create_date >= date_sub('${bizTimeFormatter(SCHEDULED_TIME,'yyyy-MM-dd','-1d')}',230)
    group by uid, payment_channel_id, topup_channel_id, type, codes, status, unix_timestamp(create_date, 'yyyy-MM-dd')
)

insert overwrite table ${SCHEMA}.ads_shopeepay_${region}_txn_order_dim_df partition (grass_date = '${bizTimeFormatter(SCHEDULED_TIME,'yyyy-MM-dd')}')
select concat(substr(md5(cast(uid as string)),0,2),'_',uid,'_',create_day_timestamp,'_',status,'_',payment_channel_id,'_',topup_channel_id) as rowkey,
       payment_channel_id,
       cnt,
       amount,
       status,
       codes,
       type
from r1
;

refresh table ${SCHEMA}.ads_shopeepay_${region}_txn_order_dim_df
;

