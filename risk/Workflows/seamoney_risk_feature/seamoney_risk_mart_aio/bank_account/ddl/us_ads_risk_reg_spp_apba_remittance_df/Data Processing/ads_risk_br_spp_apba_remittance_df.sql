drop table if exists ${SCHEMA}.ads_risk_${region_lower}_spp_apba_remittance_df;
create external table if not exists ${SCHEMA}.ads_risk_${region_lower}_spp_apba_remittance_df
(
key string,
alltime_order_cnt bigint ,
alltime_user_cnt bigint ,								
alltime_success_order_cnt bigint ,
alltime_success_user_cnt bigint ,								
alltime_notsuccess_order_cnt bigint ,
alltime_notsuccess_user_cnt bigint ,								
alltime_order_cnt_1m bigint ,								
alltime_user_cnt_1m bigint ,								
alltime_success_order_cnt_1m bigint ,								
alltime_success_user_cnt_1m bigint ,								
alltime_notsuccess_order_cnt_1m bigint ,								
alltime_notsuccess_user_cnt_1m bigint ,								
alltime_order_cnt_3m bigint ,								
alltime_user_cnt_3m bigint ,								
alltime_success_order_cnt_3m bigint ,								
alltime_success_user_cnt_3m bigint ,								
alltime_notsuccess_order_cnt_3m bigint ,								
alltime_notsuccess_user_cnt_3m bigint
) 
partitioned by
(
    grass_date string comment 'YYYY-MM-dd'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd",
    "orc.stripe.size" = "268435456"

)
location '${HDFS_PATH}/risk_mart/ads/ads_risk_reg_spp_apba_remittance_df/grass_region=${region_upper}';
msck repair table ${SCHEMA}.ads_risk_${region_lower}_spp_apba_remittance_df;

