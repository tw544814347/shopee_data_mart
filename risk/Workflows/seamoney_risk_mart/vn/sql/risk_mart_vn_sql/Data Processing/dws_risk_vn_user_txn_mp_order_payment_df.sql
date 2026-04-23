with user_full_list as (
     select
         userid as platform_user_id
     from marketplace.shopee_account_v2_db__account_tab__${region}_df
 ),
order_detail_tab as (
    select
         platform_user_id
        ,order_id
        ,payment_be_channel
        ,from_unixtime(shipping_confirm_timestamp - 3600) as shipping_confirm_time
        ,case when payment_be_channel = 'label_credit_debit_card' then 'bankcard_channel'
              when payment_be_channel in ('label_airpay_giro','label_airpay_wallet') then 'shopeepay_channel'
              else 'other_channel'
         end as channel
    from risk.dwd_risk_${region}_user_txn_mp_order_complete_df
    where grass_date = '${ds}'
        and order_be_status_id in (4, 11, 12, 13, 14, 15)
        and shipping_confirm_timestamp > 0
        and is_bi_excluded = 0
),
order_features_tab as (
    select
          platform_user_id
         ,sum(completed_order_cnt_30d)                                                             as completed_order_cnt_30d
         ,sum(completed_order_cnt_90d)                                                             as completed_order_cnt_90d
         ,sum(completed_order_cnt_180d)                                                            as completed_order_cnt_180d
         ,sum(completed_order_cnt_360d)                                                            as completed_order_cnt_360d
         ,sum(cod_order_cnt_30d)                                                                   as cod_order_cnt_30d
         ,sum(cod_order_cnt_90d)                                                                   as cod_order_cnt_90d
         ,sum(cod_order_cnt_180d)                                                                  as cod_order_cnt_180d
         ,case when sum(cod_order_cnt_180d) / sum(completed_order_cnt_180d) >= 1 then 1 else 0 end as is_cod_customer
         ,sum(completed_order_cnt_by_debit_or_credit_card_30d)                                     as completed_order_cnt_by_debit_or_credit_card_30d
         ,sum(completed_order_cnt_by_debit_or_credit_card_90d)                                     as completed_order_cnt_by_debit_or_credit_card_90d
         ,sum(completed_order_cnt_by_debit_or_credit_card_180d)                                    as completed_order_cnt_by_debit_or_credit_card_180d
         ,sum(completed_order_cnt_by_shopeepay_payment_30d)                                        as completed_order_cnt_by_shopeepay_payment_30d
         ,sum(completed_order_cnt_by_shopeepay_payment_90d)                                        as completed_order_cnt_by_shopeepay_payment_90d
         ,sum(completed_order_cnt_by_shopeepay_payment_180d)                                       as completed_order_cnt_by_shopeepay_payment_180d
         ,sum(completed_order_cnt_by_other_payment_30d)                                            as completed_order_cnt_by_other_payment_30d
         ,sum(completed_order_cnt_by_other_payment_90d)                                            as completed_order_cnt_by_other_payment_90d
         ,sum(completed_order_cnt_by_other_payment_180d)                                           as completed_order_cnt_by_other_payment_180d
         ,count(if(payment_channel_used_cnt_30d > 0, 1, null))                                     as payment_channel_used_cnt_30d
         ,count(if(payment_channel_used_cnt_90d > 0, 1, null))                                     as payment_channel_used_cnt_90d
         ,count(if(payment_channel_used_cnt_180d > 0, 1, null))                                    as payment_channel_used_cnt_180d
         ,case when sum(payment_channel_flag1) + sum(payment_channel_flag2) >= 1 then 1 else 0 end as uw_repayment_channel_flag
         ,case when sum(payment_channel_flag1) >= 1 then 'shopeepay_channel'
            when sum(payment_channel_flag2) >= 1 then 'ibanking_channel'
            else 'other_channel'
          end                                                                                      as uw_payment_channel
    from
        (select
             platform_user_id
            ,payment_be_channel
            ,count(case when return_id is null and datediff(current_date, date(shipping_confirm_time)) between 0 and 30 then order_id else null end)                                       as completed_order_cnt_30d
            ,count(case when return_id is null and datediff(current_date, date(shipping_confirm_time)) between 0 and 90 then order_id else null end)                                       as completed_order_cnt_90d
            ,count(case when return_id is null and datediff(current_date, date(shipping_confirm_time)) between 0 and 180 then order_id else null end)                                      as completed_order_cnt_180d
            ,count(case when return_id is null and datediff(current_date, date(shipping_confirm_time)) between 0 and 360 then order_id else null end)                                      as completed_order_cnt_360d
            ,count(case when return_id is null and datediff(current_date, date(shipping_confirm_time)) between 0 and 30 and payment_be_channel = 'label_cod' then order_id else null end)  as cod_order_cnt_30d
            ,count(case when return_id is null and datediff(current_date, date(shipping_confirm_time)) between 0 and 90 and payment_be_channel = 'label_cod' then order_id else null end)  as cod_order_cnt_90d
            ,count(case when return_id is null and datediff(current_date, date(shipping_confirm_time)) between 0 and 180 and payment_be_channel = 'label_cod' then order_id else null end) as cod_order_cnt_180d

            ,count(case when datediff(current_date, date(shipping_confirm_time)) between 0 and 30 and channel='bankcard_channel' then order_id else null end)                              as completed_order_cnt_by_debit_or_credit_card_30d
            ,count(case when datediff(current_date, date(shipping_confirm_time)) between 0 and 90 and channel='bankcard_channel' then order_id else null end)                              as completed_order_cnt_by_debit_or_credit_card_90d
            ,count(case when datediff(current_date, date(shipping_confirm_time)) between 0 and 180 and channel='bankcard_channel' then order_id else null end)                             as completed_order_cnt_by_debit_or_credit_card_180d
            ,count(case when datediff(current_date, date(shipping_confirm_time)) between 0 and 30 and channel='shopeepay_channel' then order_id else null end)                             as completed_order_cnt_by_shopeepay_payment_30d
            ,count(case when datediff(current_date, date(shipping_confirm_time)) between 0 and 90 and channel='shopeepay_channel' then order_id else null end)                             as completed_order_cnt_by_shopeepay_payment_90d
            ,count(case when datediff(current_date, date(shipping_confirm_time)) between 0 and 180 and channel='shopeepay_channel' then order_id else null end)                            as completed_order_cnt_by_shopeepay_payment_180d
            ,count(case when datediff(current_date, date(shipping_confirm_time)) between 0 and 30 and channel='other_channel' then order_id else null end)                                 as completed_order_cnt_by_other_payment_30d
            ,count(case when datediff(current_date, date(shipping_confirm_time)) between 0 and 90 and channel='other_channel' then order_id else null end)                                 as completed_order_cnt_by_other_payment_90d
            ,count(case when datediff(current_date, date(shipping_confirm_time)) between 0 and 180 and channel='other_channel' then order_id else null end)                                as completed_order_cnt_by_other_payment_180d
            ,count(case when datediff(current_date, date(shipping_confirm_time)) between 0 and 30 then payment_be_channel else null end)                                                   as payment_channel_used_cnt_30d
            ,count(case when datediff(current_date, date(shipping_confirm_time)) between 0 and 90 then payment_be_channel else null end)                                                   as payment_channel_used_cnt_90d
            ,count(case when datediff(current_date, date(shipping_confirm_time)) between 0 and 180 then payment_be_channel else null end)                                                  as payment_channel_used_cnt_180d

            ,sum(case when datediff(current_date, date(shipping_confirm_time)) between 0 and 180 and payment_be_channel in ('label_airpay_giro', 'label_airpay_wallet') then 1 else 0 end) as payment_channel_flag1
            ,sum(case when datediff(current_date, date(shipping_confirm_time)) between 0 and 180 and payment_be_channel = 'label_ibanking'then 1 else 0 end)                               as payment_channel_flag2
        from
            order_detail_tab a
        left join
            (select
                 orderid
                ,return_id
            from marketplace.shopee_return_v2_db__return_v2_tab__reg_daily_s0_live
            where grass_region = '${region_uppercase}'
                and status in (2, 5)
            group by 1, 2
            ) b
        on a.order_id = b.orderid
        group by 1, 2
        ) t
    group by 1
)

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_payment_df partition (grass_date = '${ds}')
select
     a.platform_user_id
    ,nvl(completed_order_cnt_30d, 0)                          as completed_order_cnt_30d
    ,nvl(completed_order_cnt_90d, 0)                          as completed_order_cnt_90d
    ,nvl(completed_order_cnt_180d, 0)                         as completed_order_cnt_180d
    ,nvl(completed_order_cnt_360d, 0)                         as completed_order_cnt_360d
    ,nvl(cod_order_cnt_30d, 0)                                as cod_order_cnt_30d
    ,nvl(cod_order_cnt_90d, 0)                                as cod_order_cnt_90d
    ,nvl(cod_order_cnt_180d, 0)                               as cod_order_cnt_180d
    ,nvl(is_cod_customer, 0)                                  as is_cod_customer
    ,nvl(completed_order_cnt_by_debit_or_credit_card_30d, 0)  as completed_order_cnt_by_debit_or_credit_card_30d
    ,nvl(completed_order_cnt_by_debit_or_credit_card_90d, 0)  as completed_order_cnt_by_debit_or_credit_card_90d
    ,nvl(completed_order_cnt_by_debit_or_credit_card_180d, 0) as completed_order_cnt_by_debit_or_credit_card_180d
    ,nvl(completed_order_cnt_by_shopeepay_payment_30d, 0)     as completed_order_cnt_by_shopeepay_payment_30d
    ,nvl(completed_order_cnt_by_shopeepay_payment_90d, 0)     as completed_order_cnt_by_shopeepay_payment_90d
    ,nvl(completed_order_cnt_by_shopeepay_payment_180d, 0)    as completed_order_cnt_by_shopeepay_payment_180d
    ,nvl(completed_order_cnt_by_other_payment_30d, 0)         as completed_order_cnt_by_other_payment_30d
    ,nvl(completed_order_cnt_by_other_payment_90d, 0)         as completed_order_cnt_by_other_payment_90d
    ,nvl(completed_order_cnt_by_other_payment_180d, 0)        as completed_order_cnt_by_other_payment_180d
    ,nvl(payment_channel_used_cnt_30d, 0)                     as payment_channel_used_cnt_30d
    ,nvl(payment_channel_used_cnt_90d, 0)                     as payment_channel_used_cnt_90d
    ,nvl(payment_channel_used_cnt_180d, 0)                    as payment_channel_used_cnt_180d
    ,nvl(uw_repayment_channel_flag, 0)                        as uw_repayment_channel_flag
    ,nvl(uw_payment_channel, 'other_channel')                 as uw_payment_channel
from
    user_full_list a
left join
    order_features_tab b
on a.platform_user_id = b.platform_user_id
