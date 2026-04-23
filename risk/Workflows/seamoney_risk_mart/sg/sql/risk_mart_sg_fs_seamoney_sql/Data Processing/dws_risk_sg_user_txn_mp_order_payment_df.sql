--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-10-31
-- Theme Domain：       feature station 迁移
-- Description:         feature station 迁移
-- Data Granularity:    https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit?gid=1104704143#gid=1104704143
-- 变更历史
-- udpate by wei.tao shopee_checkout_v2_db__checkout_v2_tab__sg_hf -> mp_order.dwd_checkout_all_ent_snapshot_df__{xx}_live
-- by wei.tao SPP ODS -> mart_dim_card_bin_df__sg
--********************************************************************--
add jar hdfs://R2/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


create or replace temporary view sg_user_order_info_tab_tmp as 
select
   t3.userid
   ,t3.payment_transaction_id
   ,t3.order_id
   ,t3.gmv_usd
   ,t3.order_creation_date
   ,t3.shipping_confirm_date
   ,t3.is_net_order
   ,t3.payment_method
   ,t3.card_number
   ,t3.card_bin
   ,t3.bank_id 
   ,t4.card_type
from(
    select 
        t1.buyer_id                                                   as userid
        ,t1.payment_transaction_id                                    as payment_transaction_id
        ,t1.order_id                                                  as order_id
        ,t1.gmv_usd                                                   as gmv_usd
        ,to_date(format_time(t1.create_timestamp,'SG'))               as order_creation_date
        ,to_date(format_time(t1.shipping_confirm_timestamp,'SG'))     as shipping_confirm_date
        ,case when (t1.shipping_confirm_timestamp > 0) and to_date(format_time(t1.shipping_confirm_timestamp,'SG')) <= '${grass_date}' 
                and (t1.order_be_status_id in (4, 11, 12, 13, 14, 15))  and (t1.has_return_item = 0) and (t1.is_net_order = 1) then 1
            else 0 end                                                as is_net_order
        ,case when t1.payment_be_channel_id in (10111, 10112, 10113, 10114, 10115, 10116, 10117, 10118) then 'cc_installment'
            when t1.payment_be_channel_id in (10020, 10030) then 'shopee_wallet'
            when t1.payment_be_channel_id in (10200, 10650) then 'credit_debit_card'
            when t1.payment_be_channel_id in (10810) then 'gov_tech'
            when t1.payment_be_channel_id in (10300) then 'dbs_paylah'
            when t1.payment_be_channel_id in (10680) then 'uob_paynow'
            when t1.payment_be_channel_id in (11000) then 'offline_bank_transfer'
            else 'other' end                                          as payment_method
        ,cast(get_json_object(t2.checkout_info,'$.checkout_payment_info.channel_item_option_info.credit_card_data.card_number')  as string)                as card_number
        ,substring(cast(get_json_object(t2.checkout_info,'$.checkout_payment_info.channel_item_option_info.credit_card_data.card_number')  as string),1,6) as card_bin
        ,cast(get_json_object(t2.checkout_info,'$.checkout_payment_info.channel_item_option_info.credit_card_data.bank_id')  as string)                    as bank_id   
    from mp_order.dwd_order_all_ent_df__sg_s0_live as t1
    left join (
        select 
        checkout_id as checkoutid
        ,checkout_info
        from mp_order.dwd_checkout_all_ent_snapshot_df__sg_live
        where grass_region = 'SG' and grass_date = date('${grass_date}')
    ) t2 on t1.checkout_id = t2.checkoutid
    where to_date(format_time(t1.shipping_confirm_timestamp,'SG')) < '${grass_date}' 
    and to_date(format_time(t1.shipping_confirm_timestamp,'SG')) >= date_sub('${grass_date}' ,180)
    and t1.tz_type = 'local'
    and t1.is_bi_excluded = 0
) t3 
left join (
    select 
        cast(bank_id as string ) as bank_id, 
        cast(card_bin as string )     as card_bin,
        case when card_type = 0 then 'cash_card'
            when card_type = 1 then 'credit_card'
            when card_type = 2 then 'debit_card'
            when card_type = 3 then 'unknown'
            else 'others'end    as card_type
    from shopeepay.mart_dim_card_bin_df__sg
    where card_status = 1 
) t4 on t3.card_bin = t4.card_bin
where t3.is_net_order = 1
; 


insert overwrite table risk.dws_risk_sg_user_txn_mp_order_payment_df partition(grass_date ='${grass_date}') 
select
    t1.userid as platform_user_id 
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',30) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') and (t1.gmv_usd > 50) then t1.card_number else null end))     as num_debit_cards_purchased_more_than_50_in_past_one_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',90) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') and (t1.gmv_usd > 50) then t1.card_number else null end))     as num_debit_cards_purchased_more_than_50_in_past_three_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',180) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') and (t1.gmv_usd > 50) then t1.card_number else null end))    as num_debit_cards_purchased_more_than_50_in_past_six_month

    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',30) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') and (t1.gmv_usd > 100) then t1.card_number else null end))    as num_debit_cards_purchased_more_than_100_in_past_one_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',90) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') and (t1.gmv_usd > 100) then t1.card_number else null end))    as num_debit_cards_purchased_more_than_100_in_past_three_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',180) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') and (t1.gmv_usd > 100) then t1.card_number else null end))   as num_debit_cards_purchased_more_than_100_in_past_six_month

    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',30) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') and (t1.gmv_usd > 300) then t1.card_number else null end))    as num_debit_cards_purchased_more_than_300_in_past_one_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',90) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') and (t1.gmv_usd > 300) then t1.card_number else null end))    as num_debit_cards_purchased_more_than_300_in_past_three_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',180) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') and (t1.gmv_usd > 300) then t1.card_number else null end))   as num_debit_cards_purchased_more_than_300_in_past_six_month

    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',30) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') and (t1.gmv_usd > 500) then t1.card_number else null end))     as num_debit_cards_purchased_more_than_500_in_past_one_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',90) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') and (t1.gmv_usd > 500) then t1.card_number else null end))     as num_debit_cards_purchased_more_than_500_in_past_three_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',180) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') and (t1.gmv_usd > 500) then t1.card_number else null end))    as num_debit_cards_purchased_more_than_500_in_past_six_month

    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',30) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') and (t1.gmv_usd > 1000) then t1.card_number else null end))    as num_debit_cards_purchased_more_than_1000_in_past_one_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',90) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') and (t1.gmv_usd > 1000) then t1.card_number else null end))    as num_debit_cards_purchased_more_than_1000_in_past_three_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',180) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') and (t1.gmv_usd > 1000) then t1.card_number else null end))   as num_debit_cards_purchased_more_than_1000_in_past_six_month

    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',30) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') and (t1.gmv_usd > 50) then t1.card_number else null end))           as num_credit_cards_purchased_more_than_50_in_past_one_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',90) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') and (t1.gmv_usd > 50) then t1.shipping_confirm_date else null end)) as num_credit_cards_purchased_more_than_50_in_past_three_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',180) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') and (t1.gmv_usd > 50) then t1.card_number else null end))          as num_credit_cards_purchased_more_than_50_in_past_six_month

    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',30) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') and (t1.gmv_usd > 100) then t1.card_number else null end))  as num_credit_cards_purchased_more_than_100_in_past_one_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',90) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') and (t1.gmv_usd > 100) then t1.card_number else null end))  as num_credit_cards_purchased_more_than_100_in_past_three_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',180) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') and (t1.gmv_usd > 100) then t1.card_number else null end)) as num_credit_cards_purchased_more_than_100_in_past_six_month

    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',30) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') and (t1.gmv_usd > 300) then t1.card_number else null end))  as num_credit_cards_purchased_more_than_300_in_past_one_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',90) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') and (t1.gmv_usd > 300) then t1.card_number else null end))  as num_credit_cards_purchased_more_than_300_in_past_three_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',180) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') and (t1.gmv_usd > 300) then t1.card_number else null end)) as num_credit_cards_purchased_more_than_300_in_past_six_month

    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',30) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') and (t1.gmv_usd > 500) then t1.card_number else null end))  as num_credit_cards_purchased_more_than_500_in_past_one_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',90) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') and (t1.gmv_usd > 500) then t1.card_number else null end))  as num_credit_cards_purchased_more_than_500_in_past_three_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',180) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') and (t1.gmv_usd > 500) then t1.card_number else null end)) as num_credit_cards_purchased_more_than_500_in_past_six_month

    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',30) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') and (t1.gmv_usd > 1000) then t1.card_number else null end))  as num_credit_cards_purchased_more_than_1000_in_past_one_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',90) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') and (t1.gmv_usd > 1000) then t1.card_number else null end))  as num_credit_cards_purchased_more_than_1000_in_past_three_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',180) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') and (t1.gmv_usd > 1000) then t1.card_number else null end)) as num_credit_cards_purchased_more_than_1000_in_past_six_month

    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',30) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') then t1.card_number else null end))  as num_debit_cards_used_in_past_one_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',90) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') then t1.card_number else null end))  as num_debit_cards_used_in_past_three_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',180) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') then t1.card_number else null end)) as num_debit_cards_used_in_past_six_month

    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',30) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') then t1.order_id else null end))  as num_orders_with_debit_card_in_past_one_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',90) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') then t1.order_id else null end))  as num_orders_with_debit_card_in_past_three_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',180) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'debit_card') then t1.order_id else null end)) as num_orders_with_debit_card_in_past_six_month

    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',30) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') then t1.card_number else null end)) as num_credit_cards_used_in_past_one_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',90) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') then t1.card_number else null end)) as num_credit_cards_used_in_past_three_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',180) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') then t1.card_number else null end)) as num_credit_cards_used_in_past_six_month

    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',30) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') then t1.order_id else null end)) as num_orders_with_credit_card_in_past_one_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',90) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') then t1.order_id else null end)) as num_orders_with_credit_card_in_past_three_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',180) and shipping_confirm_date<='${grass_date}' and (t1.card_type = 'credit_card') then t1.order_id else null end)) as num_orders_with_credit_card_in_past_six_month

    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',30) and shipping_confirm_date<='${grass_date}' and (t1.payment_method = 'shopee_wallet') then t1.order_id else null end)) as num_orders_with_shopeepay_in_past_1_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',90) and shipping_confirm_date<='${grass_date}' and (t1.payment_method = 'shopee_wallet') then t1.order_id else null end)) as num_orders_with_shopeepay_in_past_three_month
    ,count(distinct(case when shipping_confirm_date>=date_sub('${grass_date}',180) and shipping_confirm_date<='${grass_date}' and (t1.payment_method = 'shopee_wallet') then t1.order_id else null end)) as num_orders_with_shopeepay_in_past_six_month
    ,sum(case when card_type = 'credit_card'  then  gmv_usd else null end) as sum_180d_gmv_per_credit_card_in_past_one_month
    ,max(case when card_type = 'credit_card'  then  gmv_usd else null end) as max_180d_gmv_per_credit_card_in_past_one_month
    ,max(case when card_type = 'debit_card' then  gmv_usd else null end)   as max_180d_gmv_per_debit_card_in_past_1m
    ,sum(case when card_type = 'debit_card' then  gmv_usd else null end)   as sum_180d_gmv_per_debit_card_in_past_1m
    ,sum(gmv_usd)                                                          as sum_180d_net_gmv
    ,sum(case when card_type = 'credit_card'  then  gmv_usd else null end) as sum_180d_net_gmv_with_credit_cards
from sg_user_order_info_tab_tmp t1 
group by t1.userid