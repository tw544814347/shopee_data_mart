drop table if exists ${SCHEMA}.dws_risk_sg_user_txn_mp_order_payment_df;
create external table if not exists ${SCHEMA}.dws_risk_sg_user_txn_mp_order_payment_df (
    platform_user_id                                                 string comment 'platform user id'
    ,num_debit_cards_purchased_more_than_50_in_past_one_month        bigint comment ''
    ,num_debit_cards_purchased_more_than_50_in_past_three_month      bigint comment ''
    ,num_debit_cards_purchased_more_than_50_in_past_six_month        bigint comment ''
    
    ,num_debit_cards_purchased_more_than_100_in_past_one_month       bigint comment ''
    ,num_debit_cards_purchased_more_than_100_in_past_three_month     bigint comment ''
    ,num_debit_cards_purchased_more_than_100_in_past_six_month       bigint comment ''

    ,num_debit_cards_purchased_more_than_300_in_past_one_month       bigint comment ''
    ,num_debit_cards_purchased_more_than_300_in_past_three_month     bigint comment ''
    ,num_debit_cards_purchased_more_than_300_in_past_six_month       bigint comment ''

    ,num_debit_cards_purchased_more_than_500_in_past_one_month       bigint comment ''
    ,num_debit_cards_purchased_more_than_500_in_past_three_month     bigint comment ''
    ,num_debit_cards_purchased_more_than_500_in_past_six_month       bigint comment ''
    
    ,num_debit_cards_purchased_more_than_1000_in_past_one_month      bigint comment ''
    ,num_debit_cards_purchased_more_than_1000_in_past_three_month    bigint comment ''
    ,num_debit_cards_purchased_more_than_1000_in_past_six_month      bigint comment ''

    ,num_credit_cards_purchased_more_than_50_in_past_one_month       bigint comment ''
    ,num_credit_cards_purchased_more_than_50_in_past_three_month     bigint comment ''
    ,num_credit_cards_purchased_more_than_50_in_past_six_month       bigint comment ''

    ,num_credit_cards_purchased_more_than_100_in_past_one_month      bigint comment ''
    ,num_credit_cards_purchased_more_than_100_in_past_three_month    bigint comment ''
    ,num_credit_cards_purchased_more_than_100_in_past_six_month      bigint comment ''

    ,num_credit_cards_purchased_more_than_300_in_past_one_month      bigint comment ''
    ,num_credit_cards_purchased_more_than_300_in_past_three_month    bigint comment ''
    ,num_credit_cards_purchased_more_than_300_in_past_six_month      bigint comment ''

    ,num_credit_cards_purchased_more_than_500_in_past_one_month      bigint comment ''
    ,num_credit_cards_purchased_more_than_500_in_past_three_month    bigint comment ''
    ,num_credit_cards_purchased_more_than_500_in_past_six_month      bigint comment ''

    ,num_credit_cards_purchased_more_than_1000_in_past_one_month     bigint comment ''
    ,num_credit_cards_purchased_more_than_1000_in_past_three_month   bigint comment ''
    ,num_credit_cards_purchased_more_than_1000_in_past_six_month     bigint comment ''
    
    ,num_debit_cards_used_in_past_one_month                          bigint comment ''
    ,num_debit_cards_used_in_past_six_month                          bigint comment ''
    ,num_debit_cards_used_in_past_three_month                        bigint comment ''

    ,num_orders_with_debit_card_in_past_one_month                    bigint comment ''
    ,num_orders_with_debit_card_in_past_three_month                  bigint comment ''
    ,num_orders_with_debit_card_in_past_six_month                    bigint comment ''

    ,num_credit_cards_used_in_past_one_month                         bigint comment ''
    ,num_credit_cards_used_in_past_three_month                       bigint comment ''
    ,num_credit_cards_used_in_past_six_month                         bigint comment ''

    ,num_orders_with_credit_card_in_past_one_month                   bigint comment ''
    ,num_orders_with_credit_card_in_past_three_month                 bigint comment ''
    ,num_orders_with_credit_card_in_past_six_month                   bigint comment ''

    ,num_orders_with_shopeepay_in_past_1_month                       bigint comment ''
    ,num_orders_with_shopeepay_in_past_three_month                   bigint comment ''
    ,num_orders_with_shopeepay_in_past_six_month                     bigint comment ''
    
    ,sum_180d_gmv_per_credit_card_in_past_one_month                  double comment ''
    ,max_180d_gmv_per_credit_card_in_past_one_month                  double comment ''
    ,max_180d_gmv_per_debit_card_in_past_1m                          double comment ''
    ,sum_180d_gmv_per_debit_card_in_past_1m                          double comment ''
    ,sum_180d_net_gmv                                                double comment ''
    ,sum_180d_net_gmv_with_credit_cards                              double comment ''
)
partitioned by (
    grass_date                                        string     comment "Partition, YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_aio_user_txn_mp_order_payment_df/grass_region=SG';

msck repair table ${SCHEMA}.dws_risk_sg_user_txn_mp_order_payment_df;