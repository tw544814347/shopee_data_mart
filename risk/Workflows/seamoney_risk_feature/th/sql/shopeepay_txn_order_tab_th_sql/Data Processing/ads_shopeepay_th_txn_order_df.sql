set spark.sql.session.timeZone=GMT+7;

with transcation as
(
    select uid
           ,payment_channel_id
           ,topup_channel_id
           ,order_id
           ,payment_payable_amount
           ,create_time
           ,status
           ,from_unixtime(create_time,'yyyy-MM-dd') as create_date
    from shopeepay.airpay_payment_txn_th_db__txn_order_tab__th_daily_s0_live
),
r1 as
(
    select uid, payment_channel_id, count(order_id) as cnt, sum(payment_payable_amount) as amount, status, unix_timestamp(create_date, 'yyyy-MM-dd') as create_day_timestamp
    from transcation
    where create_date < date_sub('${bizTimeFormatter(SCHEDULED_TIME,'yyyy-MM-dd','-1d')}',30) and create_date >= date_sub('${bizTimeFormatter(SCHEDULED_TIME,'yyyy-MM-dd','-1d')}',230)
    group by uid, payment_channel_id, status, unix_timestamp(create_date, 'yyyy-MM-dd')
)
insert overwrite table ${SCHEMA}.ads_shopeepay_${region}_txn_order_df partition (grass_date = '${bizTimeFormatter(SCHEDULED_TIME,'yyyy-MM-dd')}')
select concat(substr(md5(cast(uid as string)),0,2),'_',uid,'_',payment_channel_id,'_',create_day_timestamp,'_',status) as rowkey,
       cnt,
       amount,
       status
from r1
;

refresh table ${SCHEMA}.ads_shopeepay_${region}_txn_order_df
;

