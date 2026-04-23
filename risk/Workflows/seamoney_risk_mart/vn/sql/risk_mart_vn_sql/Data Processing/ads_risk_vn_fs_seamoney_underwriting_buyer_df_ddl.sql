drop table if exists ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_buyer_df
;

create table if not exists ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_buyer_df (
    platform_user_id string comment 'platform_user_id'
    ,is_seller bigint comment 'is_seller'
    ,shopee_age bigint comment 'days cnt since shopee account create'
    ,is_phone_verified bigint comment 'is_phone_verified'
    ,login_days_cnt_90d bigint comment 'login days cnt in the past 90 days'
    ,login_days_cnt_180d bigint comment 'login days cnt in the past 180 days'
    ,buyer_shipping_address_district_cnt_360d bigint comment 'buyer shipping address district cnt 360d'
    ,most_order_shipping_address_district_360d string comment 'most_order_shipping_address_district_360d'
    ,cod_order_cnt_180d bigint comment 'num_cod_order_in_180d'
    ,cod_order_percent_180d double comment 'COD orders percentage in the past 180 days'
    ,is_cod_customer bigint comment 'is_cod_customer'
    ,completed_order_cnt_360d bigint comment 'completed_order_cnt_360d'
    ,completed_order_cnt_by_debit_or_credit_card_90d bigint comment 'debit_or_credit_card_orders_used_90d'
    ,completed_order_cnt_by_shopeepay_payment_180d bigint comment 'shopeepay_orders_used_180d'
    ,payment_channel_used_cnt_90d bigint comment 'no_of_payment_channel_90d'
    ,completed_order_cnt_by_shopeepay_payment_30d bigint comment 'shopeepay_orders_used_30d'
    ,completed_order_cnt_by_debit_or_credit_card_30d bigint comment 'debit_or_credit_card_orders_used_30d'
    ,payment_channel_used_cnt_180d bigint comment 'payment_channel_used_cnt_180d'
    ,completed_order_cnt_by_other_payment_180d bigint comment 'no_of_payment_channel_180d'
    ,completed_order_cnt_by_debit_or_credit_card_180d bigint comment 'debit_or_credit_card_orders_used_180d'
    ,payment_channel_used_cnt_30d bigint comment 'no_of_payment_channel_30d'
    ,completed_order_cnt_by_shopeepay_payment_90d bigint comment 'shopeepay_orders_used_90d'
    ,completed_order_cnt_by_other_payment_30d bigint comment 'other_payment_orders_used_30d'
    ,completed_order_cnt_by_other_payment_90d bigint comment 'other_payment_orders_used_90d'
    ,uw_repayment_channel_flag bigint comment 'User has used supported repayment channel in past 180 days or not'
    ,uw_payment_channel string comment 'uw_payment_channel'
    ,buyer_abs_usd_in_90d decimal(30, 10) comment 'buyer_abs_usd_in_90d'
    ,buyer_confirmed_order_in_360d bigint comment 'buyer_confirmed_order_in_360d'
    ,buyer_spl_exclude_nmv_usd_in_180d decimal(30, 10) comment 'buyer_spl_exclude_nmv_usd_in_180d'
    ,buyer_spl_exclude_nmv_usd_in_90d decimal(30, 10) comment 'buyer_spl_exclude_nmv_usd_in_90d'
    ,buyer_confirmed_order_in_180d bigint comment 'buyer_confirmed_order_in_180d'
    ,buyer_confirmed_order_in_90d bigint comment 'buyer_confirmed_order_in_90d'
    ,buyer_spl_exclude_nmv_usd_in_360d decimal(30, 10) comment 'buyer_spl_exclude_nmv_usd_in_360d'
    ,buyer_abs_usd_in_lifetime decimal(30, 10) comment 'buyer_abs_usd_in_lifetime'
    ,buyer_abs_usd_in_180d decimal(30, 10) comment 'buyer_abs_usd_in_180d'
    ,has_completed_dp_order_180d bigint comment ''
    ,buyer_abs_usd_in_360d decimal(30, 10) comment 'buyer_abs_usd_in_360d'
) partitioned by (
    grass_date string comment 'grass_date, partition key'
) stored as orc tblproperties (
    "orc.compress" = "zstd"
    ,"orc.stripe.size" = "268435456"
) location '${HDFS_PATH}/risk_mart/ads/ads_risk_fs_seamoney_underwriting_buyer_df/grass_region=${grass_region}'
;

msck repair table ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_buyer_df
;