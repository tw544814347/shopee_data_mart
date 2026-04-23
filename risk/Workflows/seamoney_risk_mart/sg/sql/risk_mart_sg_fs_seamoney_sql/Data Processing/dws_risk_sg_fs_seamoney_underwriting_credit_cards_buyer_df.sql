-- updated by wei.tao marketplace.shopee_checkout_v2_db__checkout_v2_tab__sg_df -> mp_order.dwd_checkout_all_ent_snapshot_df__{xx}_live
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
        user_id as userid
        ,cast(get_json_object(get_json_object(checkout_info,'$.checkout_payment_info.channel_item_option_info'),'$.credit_card_data.card_number') as string) as card_number
        ,substring(
            cast(get_json_object(get_json_object(checkout_info,'$.checkout_payment_info.channel_item_option_info'),'$.credit_card_data.card_number') as string)
            ,1
            ,6
        ) as card_bin
        ,cast(get_json_object(get_json_object(checkout_info,'$.checkout_payment_info.channel_item_option_info'),'$.credit_card_data.bank_id') as string) as bank_id
    from mp_order.dwd_checkout_all_ent_snapshot_df__sg_live
    where grass_region = 'SG' and grass_date = date('${grass_date}')
)
;

create or replace temporary view net_order_df as (
    select distinct
        card_number
        ,userid
        ,card_type
        --count (distinct order_id)
    from
        card_info_df A
        left join card_type_df B on A.card_bin = B.card_bin
    where card_type = 'credit_card'
)
;

create or replace temporary view final_full_list as (
    select
        A.userid
        ,if (count(distinct card_number) > 0, 1, 0) as have_a_creditcard_among_active_cards
    from net_order_df A
    group by 1
)
;

drop table if exists ${SCHEMA}.dws_risk_sg_fs_seamoney_underwriting_credit_cards_buyer_df
;

create table ${SCHEMA}.dws_risk_sg_fs_seamoney_underwriting_credit_cards_buyer_df stored as orc as
select
    t1.userid as platform_user_id
    ,coalesce(t2.have_a_creditcard_among_active_cards, 0) as have_a_creditcard_among_active_cards
from
    user_full_list t1
    left join final_full_list t2 on t1.userid = t2.userid
;