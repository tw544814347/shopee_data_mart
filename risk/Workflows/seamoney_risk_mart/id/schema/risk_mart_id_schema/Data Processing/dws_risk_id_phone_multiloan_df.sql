drop table if exists ${SCHEMA}.dws_risk_id_phone_multiloan_df;
create external table if not exists ${SCHEMA}.dws_risk_id_phone_multiloan_df
(
    phone string
    ,mh_consecutive_query_day_min_1d bigint
    ,mh_consecutive_query_day_min_3d bigint
    ,mh_consecutive_query_day_min_7d bigint
    ,mh_consecutive_query_day_min_14d bigint
    ,mh_consecutive_query_day_min_30d bigint
    ,mh_consecutive_query_day_min_90d bigint
    ,mh_consecutive_query_day_min_180d bigint
    ,mh_consecutive_query_day_min_360d bigint
    ,mh_consecutive_query_day_min_720d bigint
    ,mh_consecutive_query_day_min_ever bigint
    ,mh_attempted_institutions_month_max_90d bigint
    ,mh_attempted_institutions_month_max_180d bigint
    ,mh_attempted_institutions_month_max_360d bigint
    ,mh_attempted_institutions_month_max_720d bigint
    ,mh_attempted_institutions_month_max_ever bigint
)
partitioned by
(
    grass_region string
    ,grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="268435456")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_phone_multiloan_df';
msck repair table ${SCHEMA}.dws_risk_id_phone_multiloan_df;