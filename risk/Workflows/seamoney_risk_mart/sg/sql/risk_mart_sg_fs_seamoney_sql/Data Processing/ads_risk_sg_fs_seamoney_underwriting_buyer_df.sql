drop table ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_buyer_df;
create external table if not exists ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_buyer_df (
    platform_user_id                                              string          comment 'Shopee platform user ID'
    ,is_phone_verified                                            bigint          comment 'Whether the user phone is verified, 1=yes 0=no'
    ,sum_180d_net_gmv_with_credit_cards                           decimal(30,10)  comment 'Total net GMV paid with credit cards in past 180 days'
    ,have_a_creditcard_among_active_cards                          bigint          comment 'Whether user has a credit card among active cards, 1=yes 0=no'
    ,completed_order_cnt_360d                                      bigint          comment 'Number of completed orders in past 360 days'
    ,uw_is_bad_user_sg                                             bigint          comment 'Underwriting bad user flag for SG, 1=bad 0=normal'
    ,uw_acard_score_sg_v1_0                                        double          comment 'Underwriting A-card score for SG, version 1.0'
    ,latest_days_to_bind_bankcard_among_active_cards               bigint          comment 'Days since the most recently bound bank card among active cards'
    ,earliest_days_to_bind_bankcard_among_active_cards              bigint          comment 'Days since the earliest bound bank card among active cards'
    ,latest_months_to_bind_bankcard_among_active_cards              bigint          comment 'Months since the most recently bound bank card among active cards'
    ,earliest_months_to_bind_bankcard_among_active_cards            bigint          comment 'Months since the earliest bound bank card among active cards'
    ,latest_binded_bankcard_type_among_active_card                  bigint          comment 'Card type of the most recently bound bank card among active cards'
    ,latest_months_to_unbind_bankcards                              bigint          comment 'Months since the most recent bank card unbinding'
    ,num_of_unbind_bankcards_in_the_past_one_month                  bigint          comment 'Number of bank cards unbound in past 1 month'
    ,num_of_unbind_bankcards_in_the_past_three_months               bigint          comment 'Number of bank cards unbound in past 3 months'
    ,is_only_have_non_sg_card                                       bigint          comment 'Whether user only has non-SG cards, 1=yes 0=no'
    ,num_debit_cards_purchased_more_than_50_in_past_one_month       bigint          comment 'Number of debit cards with purchase amount > 50 in past 1 month'
    ,num_debit_cards_purchased_more_than_50_in_past_three_month     bigint          comment 'Number of debit cards with purchase amount > 50 in past 3 months'
    ,num_debit_cards_purchased_more_than_50_in_past_six_month       bigint          comment 'Number of debit cards with purchase amount > 50 in past 6 months'
    ,num_debit_cards_purchased_more_than_100_in_past_one_month      bigint          comment 'Number of debit cards with purchase amount > 100 in past 1 month'
    ,num_debit_cards_purchased_more_than_100_in_past_three_month    bigint          comment 'Number of debit cards with purchase amount > 100 in past 3 months'
    ,num_debit_cards_purchased_more_than_100_in_past_six_month      bigint          comment 'Number of debit cards with purchase amount > 100 in past 6 months'
    ,num_debit_cards_purchased_more_than_300_in_past_one_month      bigint          comment 'Number of debit cards with purchase amount > 300 in past 1 month'
    ,num_debit_cards_purchased_more_than_300_in_past_three_month    bigint          comment 'Number of debit cards with purchase amount > 300 in past 3 months'
    ,num_debit_cards_purchased_more_than_300_in_past_six_month      bigint          comment 'Number of debit cards with purchase amount > 300 in past 6 months'
    ,num_debit_cards_purchased_more_than_500_in_past_one_month      bigint          comment 'Number of debit cards with purchase amount > 500 in past 1 month'
    ,num_debit_cards_purchased_more_than_500_in_past_three_month    bigint          comment 'Number of debit cards with purchase amount > 500 in past 3 months'
    ,num_debit_cards_purchased_more_than_500_in_past_six_month      bigint          comment 'Number of debit cards with purchase amount > 500 in past 6 months'
    ,num_debit_cards_purchased_more_than_1000_in_past_one_month     bigint          comment 'Number of debit cards with purchase amount > 1000 in past 1 month'
    ,num_debit_cards_purchased_more_than_1000_in_past_three_month   bigint          comment 'Number of debit cards with purchase amount > 1000 in past 3 months'
    ,num_debit_cards_purchased_more_than_1000_in_past_six_month     bigint          comment 'Number of debit cards with purchase amount > 1000 in past 6 months'
    ,num_credit_cards_purchased_more_than_50_in_past_one_month      bigint          comment 'Number of credit cards with purchase amount > 50 in past 1 month'
    ,num_credit_cards_purchased_more_than_50_in_past_three_month    bigint          comment 'Number of credit cards with purchase amount > 50 in past 3 months'
    ,num_credit_cards_purchased_more_than_50_in_past_six_month      bigint          comment 'Number of credit cards with purchase amount > 50 in past 6 months'
    ,num_credit_cards_purchased_more_than_100_in_past_one_month     bigint          comment 'Number of credit cards with purchase amount > 100 in past 1 month'
    ,num_credit_cards_purchased_more_than_100_in_past_three_month   bigint          comment 'Number of credit cards with purchase amount > 100 in past 3 months'
    ,num_credit_cards_purchased_more_than_100_in_past_six_month     bigint          comment 'Number of credit cards with purchase amount > 100 in past 6 months'
    ,num_credit_cards_purchased_more_than_300_in_past_one_month     bigint          comment 'Number of credit cards with purchase amount > 300 in past 1 month'
    ,num_credit_cards_purchased_more_than_300_in_past_three_month   bigint          comment 'Number of credit cards with purchase amount > 300 in past 3 months'
    ,num_credit_cards_purchased_more_than_300_in_past_six_month     bigint          comment 'Number of credit cards with purchase amount > 300 in past 6 months'
    ,num_credit_cards_purchased_more_than_500_in_past_one_month     bigint          comment 'Number of credit cards with purchase amount > 500 in past 1 month'
    ,num_credit_cards_purchased_more_than_500_in_past_three_month   bigint          comment 'Number of credit cards with purchase amount > 500 in past 3 months'
    ,num_credit_cards_purchased_more_than_500_in_past_six_month     bigint          comment 'Number of credit cards with purchase amount > 500 in past 6 months'
    ,num_credit_cards_purchased_more_than_1000_in_past_one_month    bigint          comment 'Number of credit cards with purchase amount > 1000 in past 1 month'
    ,num_credit_cards_purchased_more_than_1000_in_past_three_month  bigint          comment 'Number of credit cards with purchase amount > 1000 in past 3 months'
    ,num_credit_cards_purchased_more_than_1000_in_past_six_month    bigint          comment 'Number of credit cards with purchase amount > 1000 in past 6 months'
    ,num_debit_cards_used_in_past_one_month                         bigint          comment 'Number of distinct debit cards used in past 1 month'
    ,num_debit_cards_used_in_past_six_month                         bigint          comment 'Number of distinct debit cards used in past 6 months'
    ,num_debit_cards_used_in_past_three_month                       bigint          comment 'Number of distinct debit cards used in past 3 months'
    ,num_orders_with_debit_card_in_past_one_month                   bigint          comment 'Number of orders paid with debit card in past 1 month'
    ,num_orders_with_debit_card_in_past_three_month                 bigint          comment 'Number of orders paid with debit card in past 3 months'
    ,num_orders_with_debit_card_in_past_six_month                   bigint          comment 'Number of orders paid with debit card in past 6 months'
    ,num_credit_cards_used_in_past_one_month                        bigint          comment 'Number of distinct credit cards used in past 1 month'
    ,num_credit_cards_used_in_past_three_month                      bigint          comment 'Number of distinct credit cards used in past 3 months'
    ,num_credit_cards_used_in_past_six_month                        bigint          comment 'Number of distinct credit cards used in past 6 months'
    ,num_orders_with_credit_card_in_past_one_month                  bigint          comment 'Number of orders paid with credit card in past 1 month'
    ,num_orders_with_credit_card_in_past_three_month                bigint          comment 'Number of orders paid with credit card in past 3 months'
    ,num_orders_with_credit_card_in_past_six_month                  bigint          comment 'Number of orders paid with credit card in past 6 months'
    ,num_orders_with_shopeepay_in_past_1_month                      bigint          comment 'Number of orders paid with ShopeePay in past 1 month'
    ,num_orders_with_shopeepay_in_past_three_month                  bigint          comment 'Number of orders paid with ShopeePay in past 3 months'
    ,num_orders_with_shopeepay_in_past_six_month                    bigint          comment 'Number of orders paid with ShopeePay in past 6 months'
    ,sum_180d_gmv_per_credit_card_in_past_one_month                 double          comment 'Total 180-day GMV per credit card in past 1 month'
    ,max_180d_gmv_per_credit_card_in_past_one_month                 double          comment 'Max 180-day GMV per credit card in past 1 month'
    ,max_180d_gmv_per_debit_card_in_past_1m                         double          comment 'Max 180-day GMV per debit card in past 1 month'
    ,sum_180d_gmv_per_debit_card_in_past_1m                         double          comment 'Total 180-day GMV per debit card in past 1 month'
    ,sum_180d_net_gmv                                               double          comment 'Total net GMV in past 180 days'
    ,uw_confirmed_gmv_usd_90d                                       double          comment 'Underwriting confirmed GMV in USD in past 90 days'
    ,uw_confirmed_gmv_usd_360d                                      double          comment 'Underwriting confirmed GMV in USD in past 360 days'
    ,uw_confirmed_order_360d                                         bigint          comment 'Underwriting confirmed order count in past 360 days'
)
partitioned by
    (grass_date string comment "YYYY-MM-DD") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/ads/ads_risk_reg_fs_seamoney_underwriting_buyer_df/garss_region=${upper_region}'
;
msck repair table ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_buyer_df;

insert overwrite table
    ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_buyer_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t1.is_phone_verified
    ,t2.sum_180d_net_gmv_with_credit_cards
    ,t3.have_a_creditcard_among_active_cards
    ,t4.completed_order_cnt_360d
    ,t5.uw_is_bad_user_sg
    ,t5.uw_acard_score_sg_v1_0
    ,t6.latest_days_to_bind_bankcard_among_active_cards
    ,t6.earliest_days_to_bind_bankcard_among_active_cards
    ,t6.latest_months_to_bind_bankcard_among_active_cards
    ,t6.earliest_months_to_bind_bankcard_among_active_cards
    ,t6.latest_binded_bankcard_type_among_active_card
    ,t6.latest_months_to_unbind_bankcards
    ,t6.num_of_unbind_bankcards_in_the_past_one_month
    ,t6.num_of_unbind_bankcards_in_the_past_three_months
    ,t6.is_only_have_non_sg_card
    ,t7.num_debit_cards_purchased_more_than_50_in_past_one_month
    ,t7.num_debit_cards_purchased_more_than_50_in_past_three_month
    ,t7.num_debit_cards_purchased_more_than_50_in_past_six_month
    ,t7.num_debit_cards_purchased_more_than_100_in_past_one_month
    ,t7.num_debit_cards_purchased_more_than_100_in_past_three_month
    ,t7.num_debit_cards_purchased_more_than_100_in_past_six_month
    ,t7.num_debit_cards_purchased_more_than_300_in_past_one_month
    ,t7.num_debit_cards_purchased_more_than_300_in_past_three_month
    ,t7.num_debit_cards_purchased_more_than_300_in_past_six_month
    ,t7.num_debit_cards_purchased_more_than_500_in_past_one_month
    ,t7.num_debit_cards_purchased_more_than_500_in_past_three_month
    ,t7.num_debit_cards_purchased_more_than_500_in_past_six_month
    ,t7.num_debit_cards_purchased_more_than_1000_in_past_one_month
    ,t7.num_debit_cards_purchased_more_than_1000_in_past_three_month
    ,t7.num_debit_cards_purchased_more_than_1000_in_past_six_month
    ,t7.num_credit_cards_purchased_more_than_50_in_past_one_month
    ,t7.num_credit_cards_purchased_more_than_50_in_past_three_month
    ,t7.num_credit_cards_purchased_more_than_50_in_past_six_month
    ,t7.num_credit_cards_purchased_more_than_100_in_past_one_month
    ,t7.num_credit_cards_purchased_more_than_100_in_past_three_month
    ,t7.num_credit_cards_purchased_more_than_100_in_past_six_month
    ,t7.num_credit_cards_purchased_more_than_300_in_past_one_month
    ,t7.num_credit_cards_purchased_more_than_300_in_past_three_month
    ,t7.num_credit_cards_purchased_more_than_300_in_past_six_month
    ,t7.num_credit_cards_purchased_more_than_500_in_past_one_month
    ,t7.num_credit_cards_purchased_more_than_500_in_past_three_month
    ,t7.num_credit_cards_purchased_more_than_500_in_past_six_month
    ,t7.num_credit_cards_purchased_more_than_1000_in_past_one_month
    ,t7.num_credit_cards_purchased_more_than_1000_in_past_three_month
    ,t7.num_credit_cards_purchased_more_than_1000_in_past_six_month
    ,t7.num_debit_cards_used_in_past_one_month
    ,t7.num_debit_cards_used_in_past_six_month
    ,t7.num_debit_cards_used_in_past_three_month
    ,t7.num_orders_with_debit_card_in_past_one_month
    ,t7.num_orders_with_debit_card_in_past_three_month
    ,t7.num_orders_with_debit_card_in_past_six_month
    ,t7.num_credit_cards_used_in_past_one_month
    ,t7.num_credit_cards_used_in_past_three_month
    ,t7.num_credit_cards_used_in_past_six_month
    ,t7.num_orders_with_credit_card_in_past_one_month
    ,t7.num_orders_with_credit_card_in_past_three_month
    ,t7.num_orders_with_credit_card_in_past_six_month
    ,t7.num_orders_with_shopeepay_in_past_1_month
    ,t7.num_orders_with_shopeepay_in_past_three_month
    ,t7.num_orders_with_shopeepay_in_past_six_month
    ,t7.sum_180d_gmv_per_credit_card_in_past_one_month
    ,t7.max_180d_gmv_per_credit_card_in_past_one_month
    ,t7.max_180d_gmv_per_debit_card_in_past_1m
    ,t7.sum_180d_gmv_per_debit_card_in_past_1m
    ,t7.sum_180d_net_gmv
    ,t8.uw_confirmed_gmv_usd_90d
    ,t8.uw_confirmed_gmv_usd_360d
    ,t8.uw_confirmed_order_360d
from
    (
        select
            platform_user_id
            ,is_phone_verified
        from ${SCHEMA}.dim_risk_${region}_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join (
        select
            platform_user_id
            ,sum_180d_net_gmv_with_credit_cards
        from ${SCHEMA}.dws_risk_sg_fs_seamoney_underwriting_txn_buyer_df
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select
            platform_user_id
            ,have_a_creditcard_among_active_cards
        from ${SCHEMA}.dws_risk_sg_fs_seamoney_underwriting_credit_cards_buyer_df
    ) t3 on t1.platform_user_id = t3.platform_user_id
    left join (
        select
            platform_user_id
            ,completed_order_cnt_360d
        from ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_complete_df
        where grass_date = '${grass_date}'
    ) t4 on t1.platform_user_id = t4.platform_user_id
    left join (
        select
            platform_user_id
            ,uw_is_bad_user_sg
            ,uw_acard_score_sg_v1_0
        from ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df
        where grass_date = '${grass_date}'
    ) t5 on t1.platform_user_id = t5.platform_user_id
    left join (
        select
            platform_user_id
            ,latest_days_to_bind_bankcard_among_active_cards
            ,earliest_days_to_bind_bankcard_among_active_cards
            ,latest_months_to_bind_bankcard_among_active_cards
            ,earliest_months_to_bind_bankcard_among_active_cards
            ,latest_binded_bankcard_type_among_active_card
            ,latest_months_to_unbind_bankcards
            ,num_of_unbind_bankcards_in_the_past_one_month
            ,num_of_unbind_bankcards_in_the_past_three_months
            ,is_only_have_non_sg_card
        from ${SCHEMA}.dws_risk_${region}_user_txn_spp_bank_card_df
        where grass_date = '${grass_date}'
    ) t6 on t1.platform_user_id = t6.platform_user_id
    left join (
        select
            platform_user_id
            ,num_debit_cards_purchased_more_than_300_in_past_one_month
            ,num_credit_cards_purchased_more_than_50_in_past_six_month
            ,num_orders_with_debit_card_in_past_three_month
            ,num_debit_cards_purchased_more_than_300_in_past_six_month
            ,num_credit_cards_purchased_more_than_500_in_past_six_month
            ,num_credit_cards_purchased_more_than_50_in_past_three_month
            ,num_credit_cards_purchased_more_than_300_in_past_one_month
            ,num_debit_cards_used_in_past_six_month
            ,num_credit_cards_purchased_more_than_1000_in_past_three_month
            ,num_debit_cards_purchased_more_than_500_in_past_six_month
            ,num_debit_cards_purchased_more_than_500_in_past_three_month
            ,num_debit_cards_purchased_more_than_1000_in_past_three_month
            ,num_debit_cards_purchased_more_than_100_in_past_three_month
            ,num_debit_cards_purchased_more_than_300_in_past_three_month
            ,num_debit_cards_purchased_more_than_50_in_past_three_month
            ,num_credit_cards_purchased_more_than_50_in_past_one_month
            ,num_credit_cards_purchased_more_than_100_in_past_one_month
            ,num_credit_cards_purchased_more_than_500_in_past_one_month
            ,num_orders_with_debit_card_in_past_six_month
            ,num_credit_cards_purchased_more_than_500_in_past_three_month
            ,num_credit_cards_used_in_past_three_month
            ,num_orders_with_credit_card_in_past_six_month
            ,num_debit_cards_purchased_more_than_1000_in_past_six_month
            ,num_credit_cards_used_in_past_six_month
            ,num_credit_cards_purchased_more_than_300_in_past_six_month
            ,num_credit_cards_purchased_more_than_1000_in_past_six_month
            ,num_credit_cards_purchased_more_than_1000_in_past_one_month
            ,num_credit_cards_purchased_more_than_100_in_past_three_month
            ,num_orders_with_shopeepay_in_past_three_month
            ,num_orders_with_credit_card_in_past_one_month
            ,num_debit_cards_purchased_more_than_50_in_past_six_month
            ,num_debit_cards_purchased_more_than_50_in_past_one_month
            ,num_debit_cards_purchased_more_than_100_in_past_six_month
            ,num_orders_with_shopeepay_in_past_six_month
            ,num_debit_cards_purchased_more_than_500_in_past_one_month
            ,num_orders_with_credit_card_in_past_three_month
            ,num_credit_cards_used_in_past_one_month
            ,num_orders_with_debit_card_in_past_one_month
            ,num_credit_cards_purchased_more_than_300_in_past_three_month
            ,num_debit_cards_purchased_more_than_100_in_past_one_month
            ,num_debit_cards_purchased_more_than_1000_in_past_one_month
            ,num_orders_with_shopeepay_in_past_1_month
            ,num_debit_cards_used_in_past_three_month
            ,num_credit_cards_purchased_more_than_100_in_past_six_month
            ,num_debit_cards_used_in_past_one_month
            ,sum_180d_gmv_per_credit_card_in_past_one_month
            ,max_180d_gmv_per_credit_card_in_past_one_month
            ,max_180d_gmv_per_debit_card_in_past_1m
            ,sum_180d_gmv_per_debit_card_in_past_1m
            ,sum_180d_net_gmv
            ,sum_180d_net_gmv_with_credit_cards
        from ${SCHEMA}.dws_risk_${region}_user_txn_mp_order_payment_df
        where grass_date = '${grass_date}'
    ) t7 on t1.platform_user_id = t7.platform_user_id
    left join (
        select
            shopee_user_id
            ,uw_confirmed_gmv_usd_90d
            ,uw_confirmed_gmv_usd_360d
            ,uw_confirmed_order_360d
        from risk_feature.dws_risk_${region}_user_txn_mp_feature_df
        where grass_date = '${grass_date}'
    ) t8 on t1.platform_user_id = t8.shopee_user_id
;