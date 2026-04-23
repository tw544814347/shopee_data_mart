drop table if exists ${SCHEMA}.dws_risk_${region}_store_location_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_store_location_df (
    store_id string comment "store_unique_id"
    ,store_id_type string comment "store_id_type"
    ,cluster_id_list array < int > comment "prev_month_dpd_eod"
    ,lat_lng_list array < string > comment "loan_tenure 总期数"
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_mart/dws/dws_aio_store_location_df/garss_region=${upper_region}'
;

msck repair table ${SCHEMA}.dws_risk_${region}_store_location_df;