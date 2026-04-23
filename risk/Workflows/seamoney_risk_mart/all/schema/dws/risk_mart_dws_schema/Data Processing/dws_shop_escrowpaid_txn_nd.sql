drop table if exists ${SCHEMA}.dws_shop_escrowpaid_txn_nd;

create external table if not exists ${SCHEMA}.dws_shop_escrowpaid_txn_nd
(
    shop_id bigint
    ,avg_escrowpaid_nmv_l3m decimal(30,10)
    ,avg_escrowpaid_nmv_l6m decimal(30,10)
    ,daily_escrow_l6m_75pctl decimal(30,10)
) 
partitioned by
(
    grass_region string
    ,grass_date string
)
comment 'Tag:risk summary table'
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
    ,"orc.stripe.size" = "2147483648"
)
location '${HDFS_PATH}/risk_mart/dws/dws_shop_escrowpaid_txn_nd';

msck repair table ${SCHEMA}.dws_shop_escrowpaid_txn_nd;

