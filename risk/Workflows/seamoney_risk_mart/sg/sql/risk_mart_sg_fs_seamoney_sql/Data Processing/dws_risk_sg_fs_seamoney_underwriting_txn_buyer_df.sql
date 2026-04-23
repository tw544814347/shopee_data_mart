--updated by wei.tao marketplace.shopee_checkout_v2_db__checkout_v2_tab__sg_df -> mp_order.dwd_checkout_all_ent_snapshot_df__sg_live

create or replace temporary view user_full_list as (
    select
        userid
    from marketplace.shopee_account_v2_db__account_tab__sg_df
)
;

create or replace temporary view card_type_df as (
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
)
;

create or replace temporary view card_info_df as (
    select
        O.buyer_id as userid
        ,O.payment_transaction_id
        ,O.order_id
        ,O.gmv_usd
        ,cast(from_unixtime(O.create_timestamp) as date) as order_creation_date
        ,case
            when (O.shipping_confirm_timestamp > 0)
                and cast(from_unixtime(O.shipping_confirm_timestamp) as date) < current_date
                and (O.order_be_status_id in (4, 11, 12, 13, 14, 15))
                and (O.has_return_item = 0)
                and (O.is_net_order = 1)
                then 1
            else 0
        end as is_net_order
        ,case
            when O.payment_be_channel_id in (10111, 10112, 10113, 10114, 10115, 10116, 10117, 10118) then 'cc_installment'
            when O.payment_be_channel_id in (10020, 10030) then 'shopee_wallet'
            when O.payment_be_channel_id in (10200, 10650) then 'credit_debit_card'
            when O.payment_be_channel_id in (10810) then 'gov_tech'
            when O.payment_be_channel_id in (10300) then 'dbs_paylah'
            when O.payment_be_channel_id in (10680) then 'uob_paynow'
            when O.payment_be_channel_id in (11000) then 'offline_bank_transfer'
            else 'other'
        end as payment_method
        ,cast(get_json_object(get_json_object(C.checkout_info,'$.checkout_payment_info.channel_item_option_info'),'$.credit_card_data.card_number') as string) as card_number
        ,substring(
            cast(get_json_object(get_json_object(C.checkout_info,'$.checkout_payment_info.channel_item_option_info'),'$.credit_card_data.card_number') as string)
            ,1
            ,6
        ) as card_bin
        ,cast(get_json_object(get_json_object(C.checkout_info,'$.checkout_payment_info.channel_item_option_info'),'$.credit_card_data.bank_id') as string) as bank_id 
    from
        mp_order.dwd_order_all_ent_df__reg_s0_live as O
        left join mp_order.dwd_checkout_all_ent_snapshot_df__sg_live as C on O.checkout_id = C.checkout_id
    where
        O.grass_region = 'SG'
        and C.grass_region = 'SG'
        and date(from_unixtime(O.shipping_confirm_timestamp)) < current_date
        and date(from_unixtime(O.shipping_confirm_timestamp)) >= current_date - interval '180' day
        and O.tz_type = 'local'
        and O.is_bi_excluded = 0
        and C.grass_date = date('${grass_date}')
)
;

create or replace temporary view card_gmv_usd_L180D_info as (
    select
        A.userid
        ,A.card_number
        ,A.card_bin
        ,B.card_type
        ,sum(A.gmv_usd) as card_gmv_usd_L180D
    from
        card_info_df A
        left join card_type_df B on A.card_bin = B.card_bin
    where is_net_order = 1
    group by A.userid, A.card_number, A.card_bin, B.card_type
)
;

create or replace temporary view final_full_list as (
    select
        userid
        ,sum(
            case
                when card_type = 'credit_card' then card_gmv_usd_L180D
                else null
            end
        ) as sum_180d_net_gmv_with_credit_cards
        ,sum(card_gmv_usd_L180D) as sum_180d_net_gmv
    from card_gmv_usd_L180D_info
    group by userid
)
;

drop table if exists ${SCHEMA}.dws_risk_sg_fs_seamoney_underwriting_txn_buyer_df
;

create table ${SCHEMA}.dws_risk_sg_fs_seamoney_underwriting_txn_buyer_df stored as orc as
select
    t1.userid as platform_user_id
    ,coalesce(t2.sum_180d_net_gmv_with_credit_cards, 0) as sum_180d_net_gmv_with_credit_cards
    ,coalesce(t2.sum_180d_net_gmv, 0) as sum_180d_net_gmv
from
    user_full_list t1
    left join final_full_list t2 on t1.userid = t2.userid
;