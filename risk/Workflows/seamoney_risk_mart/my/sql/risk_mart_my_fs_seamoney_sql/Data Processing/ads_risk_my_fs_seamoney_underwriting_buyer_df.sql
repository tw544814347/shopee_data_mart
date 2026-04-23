--drop table if exists ${SCHEMA}.ads_risk_my_fs_seamoney_underwriting_buyer_df;
create external table if not exists ${SCHEMA}.ads_risk_my_fs_seamoney_underwriting_buyer_df (
    platform_user_id string comment 'platform_user_id'
    ,is_phone_verified bigint comment 'is_phone_verified'
    ,app_flag bigint comment 'app_flag'
    ,is_bad_user bigint
    ,repayment_channel_flag bigint
    ,login_days_cnt_90d bigint comment 'login days cnt in the past 30 days'
    ,login_days_cnt_180d bigint comment 'login days cnt in the past 180 days'
    ,login_days_cnt_360d bigint comment 'login days cnt in the past 360 days'
    ,no_of_payment_channel_180d bigint
    ,payment_channel_used_180d string
    ,shopee_pay_used_180d bigint
    ,molpay_used_180d bigint
    ,online_banking_used_180d bigint
    ,atm_bank_transfer_used_180d bigint
    ,credit_card_installment_used_180d bigint
    ,credit_debit_card_used_180d bigint
    ,maybank_used_180d bigint
    ,shopee_credit_used_180d bigint
    ,wechat_pay_used_180d bigint
    ,cod_used_180d bigint
    ,other_payment_used_180d bigint
    ,shopee_pay_used_pct_180d double
    ,molpay_used_pct_180d double
    ,online_banking_used_pct_180d double
    ,atm_bank_transfer_used_pct_180d double
    ,credit_card_installment_used_pct_180d double
    ,credit_debit_card_used_pct_180d double
    ,maybank_used_pct_180d double
    ,spl_used_pct_180d double
    ,wechat_pay_used_pct_180d double
    ,cod_used_pct_180d double
    ,other_payment_used_pct_180d double
    ,latest_buyer_shipping_address_state_360d string
    ,latest_buyer_shipping_address_zipcode_360d string
    ,latest_buyer_shipping_address_district_360d string
    ,latest_buyer_shipping_address_town_360d string
    ,latest_buyer_shipping_address_city_360d string
    ,no_of_district_360d bigint
    ,no_of_zipcode_360d bigint
    ,no_of_city_360d bigint
    ,no_of_town_360d bigint
    ,no_of_address_360d bigint
    ,no_of_state_360d bigint
    ,no_of_level_1_cat_90d bigint
    ,no_of_level_2_cat_90d bigint
    ,no_of_level_3_cat_90d bigint
    ,no_of_level_1_cat_180d bigint
    ,no_of_level_2_cat_180d bigint
    ,no_of_level_3_cat_180d bigint
    ,sl_max_dpd_l1m bigint comment 'last 1 months sl max dpd'
    ,sl_max_dpd_l2m bigint comment 'last 2 months sl max dpd'
    ,sl_max_dpd_l3m bigint comment 'last 3 months sl max dpd'
    ,sl_max_dpd_l6m bigint comment 'last 6 months sl max dpd'
    ,sl_max_dpd_l12m bigint comment 'last 12 months sl max dpd'
)
partitioned by
    (grass_date string comment "YYYY-MM-DD") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/ads/ads_risk_reg_fs_seamoney_underwriting_buyer_df/grass_region=${grass_region}'
;
--msck repair table ${SCHEMA}.ads_risk_my_fs_seamoney_underwriting_buyer_df;

insert overwrite table
    ${SCHEMA}.ads_risk_my_fs_seamoney_underwriting_buyer_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t1.is_phone_verified
    ,t2.app_flag
    ,t3.is_bad_user
    ,t3.repayment_channel_flag
    ,t4.login_days_cnt_90d
    ,t4.login_days_cnt_180d
    ,t4.login_days_cnt_360d
    ,t5.no_of_payment_channel_180d
    ,t5.payment_channel_used_180d
    ,t5.shopee_pay_used_180d
    ,t5.molpay_used_180d
    ,t5.online_banking_used_180d
    ,t5.atm_bank_transfer_used_180d
    ,t5.credit_card_installment_used_180d
    ,t5.credit_debit_card_used_180d
    ,t5.maybank_used_180d
    ,t5.shopee_credit_used_180d
    ,t5.wechat_pay_used_180d
    ,t5.cod_used_180d
    ,t5.other_payment_used_180d
    ,t5.shopee_pay_used_pct_180d
    ,t5.molpay_used_pct_180d
    ,t5.online_banking_used_pct_180d
    ,t5.atm_bank_transfer_used_pct_180d
    ,t5.credit_card_installment_used_pct_180d
    ,t5.credit_debit_card_used_pct_180d
    ,t5.maybank_used_pct_180d
    ,t5.spl_used_pct_180d
    ,t5.wechat_pay_used_pct_180d
    ,t5.cod_used_pct_180d
    ,t5.other_payment_used_pct_180d
    ,t6.latest_buyer_shipping_address_state_360d
    ,t6.latest_buyer_shipping_address_zipcode_360d
    ,t6.latest_buyer_shipping_address_district_360d
    ,t6.latest_buyer_shipping_address_town_360d
    ,t6.latest_buyer_shipping_address_city_360d
    ,t6.no_of_district_360d
    ,t6.no_of_zipcode_360d
    ,t6.no_of_city_360d
    ,t6.no_of_town_360d
    ,t6.no_of_address_360d
    ,t6.no_of_state_360d
    ,t7.no_of_level_1_cat_90d
    ,t7.no_of_level_2_cat_90d
    ,t7.no_of_level_3_cat_90d
    ,t7.no_of_level_1_cat_180d
    ,t7.no_of_level_2_cat_180d
    ,t7.no_of_level_3_cat_180d
    ,t8.sl_max_dpd_l1m
    ,t8.sl_max_dpd_l2m
    ,t8.sl_max_dpd_l3m
    ,t8.sl_max_dpd_l6m
    ,t8.sl_max_dpd_l12m
from
    (
        select
            platform_user_id
            ,is_phone_verified
        from ${SCHEMA}.dim_risk_my_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join (
        select
            platform_user_id
            ,app_type
            ,app_version
            ,app_flag
        from ${SCHEMA}.dws_risk_my_user_behavior_app_info_df
        where grass_date = '${grass_date}'
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select
            platform_user_id
            ,is_bad_user
            ,repayment_channel_flag
        from ${SCHEMA}.dws_risk_my_user_metrics_biz_manage_df
        where grass_date = '${grass_date}'
    ) t3 on t1.platform_user_id = t3.platform_user_id
    left join (
        select
            platform_user_id
            ,login_days_cnt_90d
            ,login_days_cnt_180d
            ,login_days_cnt_360d
        from ${SCHEMA}.dws_risk_my_user_behavior_mp_login_info_df
        where grass_date = '${grass_date}'
    ) t4 on t1.platform_user_id = t4.platform_user_id
    left join (
        select
            platform_user_id
            ,no_of_payment_channel_180d
            ,payment_channel_used_180d
            ,shopee_pay_used_180d
            ,molpay_used_180d
            ,online_banking_used_180d
            ,atm_bank_transfer_used_180d
            ,credit_card_installment_used_180d
            ,credit_debit_card_used_180d
            ,maybank_used_180d
            ,shopee_credit_used_180d
            ,wechat_pay_used_180d
            ,cod_used_180d
            ,other_payment_used_180d
            ,shopee_pay_used_pct_180d
            ,molpay_used_pct_180d
            ,online_banking_used_pct_180d
            ,atm_bank_transfer_used_pct_180d
            ,credit_card_installment_used_pct_180d
            ,credit_debit_card_used_pct_180d
            ,maybank_used_pct_180d
            ,spl_used_pct_180d
            ,wechat_pay_used_pct_180d
            ,cod_used_pct_180d
            ,other_payment_used_pct_180d
        from ${SCHEMA}.dws_risk_my_user_txn_mp_order_payment_df
        where grass_date = '${grass_date}'
    ) t5 on t1.platform_user_id = t5.platform_user_id
    left join (
        select
            platform_user_id
            ,latest_buyer_shipping_address_state_360d
            ,latest_buyer_shipping_address_zipcode_360d
            ,latest_buyer_shipping_address_district_360d
            ,latest_buyer_shipping_address_town_360d
            ,latest_buyer_shipping_address_city_360d
            ,no_of_district_360d
            ,no_of_zipcode_360d
            ,no_of_city_360d
            ,no_of_town_360d
            ,no_of_address_360d
            ,no_of_state_360d
        from ${SCHEMA}.dws_risk_my_user_txn_mp_order_complete_df
        where grass_date = '${grass_date}'
    ) t6 on t1.platform_user_id = t6.platform_user_id
    left join (
        select
            platform_user_id
            ,no_of_level_1_cat_90d
            ,no_of_level_2_cat_90d
            ,no_of_level_3_cat_90d
            ,no_of_level_1_cat_180d
            ,no_of_level_2_cat_180d
            ,no_of_level_3_cat_180d
        from ${SCHEMA}.dws_risk_my_user_txn_mp_order_item_complete_df
        where grass_date = '${grass_date}'
    ) t7 on t1.platform_user_id = t7.platform_user_id
    left join (
        select
            platform_user_id
            ,sl_max_dpd_l1m
            ,sl_max_dpd_l2m
            ,sl_max_dpd_l3m
            ,sl_max_dpd_l6m
            ,sl_max_dpd_l12m
        from ${SCHEMA}.dws_risk_my_user_txn_fp_repayment_df
        where grass_date = '${grass_date}'
    ) t8 on t1.platform_user_id = t8.platform_user_id
;