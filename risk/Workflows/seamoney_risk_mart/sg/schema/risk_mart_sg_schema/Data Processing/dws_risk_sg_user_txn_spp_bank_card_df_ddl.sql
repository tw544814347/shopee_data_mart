drop table if exists ${SCHEMA}.dws_risk_${grass_region_lower}_user_txn_spp_bank_card_df;
create external table if not exists ${SCHEMA}.dws_risk_${grass_region_lower}_user_txn_spp_bank_card_df
(
    platform_user_id                                           string   comment 'platform_user_id'
    ,earliest_days_to_bind_bankcard_among_active_cards         int      comment 'earliest_days_to_bind_bankcard_among_active_cards'
    ,latest_days_to_bind_bankcard_among_active_cards           int      comment 'latest_days_to_bind_bankcard_among_active_cards'
    --,latest_binded_bankcard_type_among_active_card             int      comment 'latest_binded_bankcard_type_among_active_card'
)
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties (
    "orc.compress" = "zstd"
    ,"orc.stripe.size" = "268435456"
)
location '${HDFS_PATH}/risk_mart/dws/dws_risk_aio_user_txn_spp_bank_card_df/garss_region=${grass_region}';

msck repair table ${SCHEMA}.dws_risk_${grass_region_lower}_user_txn_spp_bank_card_df;