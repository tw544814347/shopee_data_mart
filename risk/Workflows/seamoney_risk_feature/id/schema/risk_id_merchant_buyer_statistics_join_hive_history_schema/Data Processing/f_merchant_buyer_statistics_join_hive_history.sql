drop table if exists ${SCHEMA}.merchant_buyer_statistics_join_hive_history_incr;
create table if not exists ${SCHEMA}.merchant_buyer_statistics_join_hive_history_incr
(
    rowkey string
    ,kredit_10045_c2b string
    ,kredit_10045_b2c string
    ,kredit_10045_jumpapp string
    ,kredit_10055_c2b string
    ,kredit_10055_b2c string
    ,kredit_10055_jumpapp string
    ,kredit_30013_c2b string
    ,kredit_30013_b2c string
    ,kredit_30013_jumpapp string
    ,ts bigint
)
partitioned by
(
    grass_region   string          comment         'partition key'
    ,grass_date    string          comment         'partition key'
)
stored as parquet;
msck repair table ${SCHEMA}.merchant_buyer_statistics_join_hive_history_incr;

drop table if exists ${SCHEMA}.dimension_merchant_buyer_statistics_join_hive_history_full;
create table if not exists ${SCHEMA}.dimension_merchant_buyer_statistics_join_hive_history_full
(
    flag                 string
    ,flag_key            string
    ,flag_object         string
    ,latest_grass_date   string
)
partitioned by
(
    grass_region   string          comment         'partition key'
    ,grass_date    string          comment         'partition key'
)
stored as parquet;
msck repair table ${SCHEMA}.dimension_merchant_buyer_statistics_join_hive_history_full;

drop table if exists ${SCHEMA}.dimension_merchant_buyer_statistics_join_hive_history_incr;
create table if not exists ${SCHEMA}.dimension_merchant_buyer_statistics_join_hive_history_incr
(
    flag                 string
    ,flag_key            string
    ,flag_object         string
    ,change_type         int -- add: 1; delete: 0, -1: change
)
partitioned by
(
    grass_region   string          comment         'partition key'
    ,grass_date    string          comment         'partition key'
)
stored as parquet;
msck repair table ${SCHEMA}.dimension_merchant_buyer_statistics_join_hive_history_incr;

drop table if exists ${SCHEMA}.spp_merchant_buyer_statistics_join_hive_history_incr;
create table if not exists ${SCHEMA}.spp_merchant_buyer_statistics_join_hive_history_incr
(
    rowkey string
    ,spp_80016 string
    ,ts bigint
)
partitioned by
(
    grass_region   string          comment         'partition key'
    ,grass_date    string          comment         'partition key'
)
stored as parquet;
msck repair table ${SCHEMA}.spp_merchant_buyer_statistics_join_hive_history_incr;