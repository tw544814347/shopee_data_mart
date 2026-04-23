------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-03-13
-- Description:         Feature Station迁移， underwriting_buyer 宽表
-- Data Granularity:    platform_user_id
-- PRD:                 
------------------------------------------------------------------------
insert overwrite table ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_buyer_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t1.is_seller
    ,t1.shopee_age
    ,t1.is_phone_verified
    ,t2.login_days_cnt_90d
    ,t2.login_days_cnt_180d
    ,t3.buyer_shipping_address_district_cnt_360d
    ,t3.most_order_shipping_address_district_360d
    ,t4.cod_order_cnt_180d
    ,t4.cod_order_percent_180d
    ,t4.is_cod_customer
    ,t4.completed_order_cnt_360d
    ,t4.completed_order_cnt_by_debit_or_credit_card_90d
    ,t4.completed_order_cnt_by_shopeepay_payment_180d
    ,t4.payment_channel_used_cnt_90d
    ,t4.completed_order_cnt_by_shopeepay_payment_30d
    ,t4.completed_order_cnt_by_debit_or_credit_card_30d
    ,t4.payment_channel_used_cnt_180d
    ,t4.completed_order_cnt_by_other_payment_180d
    ,t4.completed_order_cnt_by_debit_or_credit_card_180d
    ,t4.payment_channel_used_cnt_30d
    ,t4.completed_order_cnt_by_shopeepay_payment_90d
    ,t4.completed_order_cnt_by_other_payment_30d
    ,t4.completed_order_cnt_by_other_payment_90d
    ,t4.uw_repayment_channel_flag
    ,t4.uw_payment_channel
    ,t5.buyer_abs_usd_in_90d
    ,t5.buyer_confirmed_order_in_360d
    ,t5.buyer_spl_exclude_nmv_usd_in_180d
    ,t5.buyer_spl_exclude_nmv_usd_in_90d
    ,t5.buyer_confirmed_order_in_180d
    ,t5.buyer_confirmed_order_in_90d
    ,t5.buyer_spl_exclude_nmv_usd_in_360d
    ,t5.buyer_abs_usd_in_lifetime
    ,t5.buyer_abs_usd_in_180d
    ,t6.has_completed_dp_order_180d
    ,t5.buyer_abs_usd_in_360d
from
    (
        select
            platform_user_id
            ,is_seller
            ,shopee_age
            ,is_phone_verified
        from ${SCHEMA}.dim_risk_${region}_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join (
        select
            platform_user_id
            ,login_days_cnt_90d
            ,login_days_cnt_180d
        from ${SCHEMA}.dws_risk_${region}_user_behavior_mp_login_info_df
        where grass_date = '${grass_date}'
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select
            platform_user_id
            ,buyer_shipping_address_district_cnt_360d
            ,most_order_shipping_address_district_360d
        from ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df
        where grass_date = '${grass_date}'
    ) t3 on t1.platform_user_id = t3.platform_user_id
    left join (
        select
            platform_user_id
            ,cod_order_cnt_180d
            ,case
                when completed_order_cnt_180d = 0 then 0
                else cod_order_cnt_180d / completed_order_cnt_180d
            end as cod_order_percent_180d
            ,is_cod_customer
            ,completed_order_cnt_180d
            ,completed_order_cnt_360d
            ,completed_order_cnt_by_debit_or_credit_card_90d
            ,completed_order_cnt_by_shopeepay_payment_180d
            ,payment_channel_used_cnt_90d
            ,completed_order_cnt_by_shopeepay_payment_30d
            ,completed_order_cnt_by_debit_or_credit_card_30d
            ,payment_channel_used_cnt_180d
            ,completed_order_cnt_by_other_payment_180d
            ,completed_order_cnt_by_debit_or_credit_card_180d
            ,payment_channel_used_cnt_30d
            ,completed_order_cnt_by_shopeepay_payment_90d
            ,completed_order_cnt_by_other_payment_30d
            ,completed_order_cnt_by_other_payment_90d
            ,uw_repayment_channel_flag
            ,uw_payment_channel
        from ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_payment_df
        where grass_date = '${grass_date}'
    ) t4 on t1.platform_user_id = t4.platform_user_id
    left join (
        select
            buyer_id as platform_user_id
            ,buyer_abs_usd_in_90d
            ,buyer_confirmed_order_in_360d
            ,buyer_spl_exclude_nmv_usd_in_180d
            ,buyer_spl_exclude_nmv_usd_in_90d
            ,buyer_confirmed_order_in_180d
            ,buyer_confirmed_order_in_90d
            ,buyer_spl_exclude_nmv_usd_in_360d
            ,buyer_abs_usd_in_lifetime
            ,buyer_abs_usd_in_180d
            ,buyer_abs_usd_in_360d
        from ${SCHEMA}.dws_risk_buyer_txn_df
        where
            grass_region = '${grass_region}'
            and grass_date = '${grass_date}'
    ) t5 on t1.platform_user_id = t5.platform_user_id
    left join (
        select
            platform_user_id
            ,completed_order_180d
            ,if (completed_order_180d > 0, 1, 0) as has_completed_dp_order_180d
        from ${SCHEMA}.dws_risk_${region}_user_txn_dp_order_complete_df
        where grass_date = '${grass_date}'
    ) t6 on t1.platform_user_id = t6.platform_user_id
;