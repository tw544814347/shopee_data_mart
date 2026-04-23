
--********************************************************************--
-- Author:              xiukai.yu@seamoney.com
-- Created Time:        2024-11-20
-- Description:         https://docs.google.com/spreadsheets/d/1Q0kBoljyNJ_bep2f0rZ8ZIRs1JdiErZ8Z2b0zTjK53M/edit?pli=1&gid=1148389135#gid=1148389135
--********************************************************************--

--drop table if exists ${SCHEMA}.dws_risk_my_user_txn_mp_order_payment_df;
create table if not exists ${SCHEMA}.dws_risk_my_user_txn_mp_order_payment_df
(   
    platform_user_id                string,
    no_of_payment_channel_180d      bigint,
    payment_channel_used_180d       String,
    shopee_pay_used_180d            bigint,
    molpay_used_180d                bigint,
    online_banking_used_180d        bigint,
    atm_bank_transfer_used_180d     bigint,
    credit_card_installment_used_180d   bigint,
    credit_debit_card_used_180d     bigint,
    maybank_used_180d               bigint,
    shopee_credit_used_180d         bigint,
    wechat_pay_used_180d            bigint,
    cod_used_180d                   bigint,
    other_payment_used_180d         bigint,
    shopee_pay_used_pct_180d        double,
    molpay_used_pct_180d            double,
    online_banking_used_pct_180d    double,
    atm_bank_transfer_used_pct_180d double,
    credit_card_installment_used_pct_180d   double,
    credit_debit_card_used_pct_180d double,
    maybank_used_pct_180d           double,
    spl_used_pct_180d               double,
    wechat_pay_used_pct_180d        double,
    cod_used_pct_180d               double,
    other_payment_used_pct_180d     double
)  
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_my_user_txn_mp_order_payment_df/grass_region=MY';
--msck repair table ${SCHEMA}.dws_risk_my_user_txn_mp_order_payment_df;

add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


create or replace temporary view payment_channel_180_tb_tmp as 
select 
    buyer_id as userid,
    case
        when payment_be_channel_id in (20020, 20030) then 'shopee_pay'
        when payment_be_channel_id in (20040, 21121, 21122) then 'molpay'
        when payment_be_channel_id in (
            20001, 20129, 20130, 20131, 20132, 20133, 20134, 20135, 20136, 20137, 20138, 20139, 20140, 
            20141, 20142, 20143, 20144, 20145, 20146, 20147, 20148, 20149, 20150, 20151, 20152, 20153, 
            20154, 20155, 20156, 20157, 20158, 20159, 20160, 20161, 20162, 20163
        ) then 'online_banking'
        when payment_be_channel_id in (21000) then 'atm_bank_transfer'
        when payment_be_channel_id in (20012, 20013, 20014, 20015, 20016, 20017) then 'credit_card_installment'
        when payment_be_channel_id in (20000, 20002, 20200) then 'credit_debit_card'
        when payment_be_channel_id in (20300) then 'maybank'
        when payment_be_channel_id in (25000, 25001, 25002, 25003, 25004) then 'shopee_credit'
        when payment_be_channel_id in (20640, 20641) then 'wechat_pay'
        when payment_be_channel_id in (29000) then 'cod'
        else 'other_payment'
    end as payment_channel
from mp_order.dwd_order_item_all_ent_df__reg_s0_live 
where grass_region = '${upper_region}'
    and is_paid_ads_topup = 0
    and order_be_status not in (
        'invalid',
        'cancel_processing',
        'cancel_completed',
        'return_processing',
        'return_completed',
        'cancel_pending'
    )
    and format_time(shipping_confirm_timestamp, '${upper_region}') >= date_sub('${cur_date}', 180)
;


create or replace temporary view payment_channel_180_tb as 
select 
    userid,
    count(distinct payment_channel) as no_of_payment_channel_180d,
    -- listagg(distinct payment_channel, ',') as payment_channel_used_180d,
    concat_ws(',', collect_set(payment_channel)) as payment_channel_used_180d,
    count(case when payment_channel = 'shopee_pay' then 1 end) as shopee_pay_used_180d,
    count(case when payment_channel = 'molpay' then 1 end) as molpay_used_180d,
    count(case when payment_channel = 'online_banking' then 1 end) as online_banking_used_180d,
    count(case when payment_channel = 'atm_bank_transfer' then 1 end) as atm_bank_transfer_used_180d,
    count(case when payment_channel = 'credit_card_installment' then 1 end) as credit_card_installment_used_180d,
    count(case when payment_channel = 'credit_debit_card' then 1 end) as credit_debit_card_used_180d,
    count(case when payment_channel = 'maybank' then 1 end) as maybank_used_180d,
    count(case when payment_channel = 'shopee_credit' then 1 end) as shopee_credit_used_180d,
    count(case when payment_channel = 'wechat_pay' then 1 end) as wechat_pay_used_180d,
    count(case when payment_channel = 'cod' then 1 end) as cod_used_180d,
    count(case when payment_channel = 'other_payment' then 1 end) as other_payment_used_180d,

    count(case when payment_channel = 'shopee_pay' then 1 end)/cast(count(payment_channel) as double) as shopee_pay_used_pct_180d,
    count(case when payment_channel = 'molpay' then 1 end)/cast(count(payment_channel) as double) as molpay_used_pct_180d,
    count(case when payment_channel = 'online_banking' then 1 end)/cast(count(payment_channel) as double) as online_banking_used_pct_180d,
    count(case when payment_channel = 'atm_bank_transfer' then 1 end)/cast(count(payment_channel) as double) as atm_bank_transfer_used_pct_180d,
    count(case when payment_channel = 'credit_card_installment' then 1 end)/cast(count(payment_channel) as double) as credit_card_installment_used_pct_180d,
    count(case when payment_channel = 'credit_debit_card' then 1 end)/cast(count(payment_channel) as double) as credit_debit_card_used_pct_180d,
    count(case when payment_channel = 'maybank' then 1 end)/cast(count(payment_channel) as double) as maybank_used_pct_180d,
    count(case when payment_channel = 'shopee_credit' then 1 end)/cast(count(payment_channel) as double) as spl_used_pct_180d,
    count(case when payment_channel = 'wechat_pay' then 1 end)/cast(count(payment_channel) as double) as wechat_pay_used_pct_180d,
    count(case when payment_channel = 'cod' then 1 end)/cast(count(payment_channel) as double) as cod_used_pct_180d,
    count(case when payment_channel = 'other_payment' then 1 end)/cast(count(payment_channel) as double) as other_payment_used_pct_180d
from payment_channel_180_tb_tmp
group by userid
;

insert overwrite ${SCHEMA}.dws_risk_my_user_txn_mp_order_payment_df partition (grass_date = '${grass_date}')
select 
    a.platform_user_id,
    b.no_of_payment_channel_180d as no_of_payment_channel_180d,
    b.payment_channel_used_180d as payment_channel_used_180d,
    b.shopee_pay_used_180d as shopee_pay_used_180d,
    b.molpay_used_180d as molpay_used_180d,
    b.online_banking_used_180d as online_banking_used_180d,
    b.atm_bank_transfer_used_180d as atm_bank_transfer_used_180d,
    b.credit_card_installment_used_180d as credit_card_installment_used_180d,
    b.credit_debit_card_used_180d as credit_debit_card_used_180d,
    b.maybank_used_180d as maybank_used_180d,
    b.shopee_credit_used_180d as shopee_credit_used_180d,
    b.wechat_pay_used_180d as wechat_pay_used_180d,
    b.cod_used_180d as cod_used_180d,
    b.other_payment_used_180d as other_payment_used_180d,
    b.shopee_pay_used_pct_180d as shopee_pay_used_pct_180d,
    b.molpay_used_pct_180d as molpay_used_pct_180d,
    b.online_banking_used_pct_180d as online_banking_used_pct_180d,
    b.atm_bank_transfer_used_pct_180d as atm_bank_transfer_used_pct_180d,
    b.credit_card_installment_used_pct_180d as credit_card_installment_used_pct_180d,
    b.credit_debit_card_used_pct_180d as credit_debit_card_used_pct_180d,
    b.maybank_used_pct_180d as maybank_used_pct_180d,
    b.spl_used_pct_180d as spl_used_pct_180d,
    b.wechat_pay_used_pct_180d as wechat_pay_used_pct_180d,
    b.cod_used_pct_180d as cod_used_pct_180d,
    b.other_payment_used_pct_180d as other_payment_used_pct_180d
from (
    select platform_user_id
from risk.dim_risk_my_user_info_df
where grass_date = '${grass_date}'
) as a
left join payment_channel_180_tb as b
on a.platform_user_id = b.userid
;