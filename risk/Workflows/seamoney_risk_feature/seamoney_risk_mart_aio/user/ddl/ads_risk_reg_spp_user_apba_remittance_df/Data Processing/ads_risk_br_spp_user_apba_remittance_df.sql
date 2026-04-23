drop table if exists ${SCHEMA}.ads_risk_${region_lower}_spp_user_apba_remittance_df;
create external table if not exists ${SCHEMA}.ads_risk_${region_lower}_spp_user_apba_remittance_df
(
key string,
alltime_order bigint, 
alltime_success_order bigint,									
alltime_notsuccess_order bigint,									
alltime_success_order_1m bigint,									
alltime_notsuccess_order_1m bigint,									
alltime_success_order_3m bigint,									
alltime_notsuccess_order_3m bigint
) 
partitioned by
(
    grass_date string comment 'YYYY-MM-dd'
)
comment 'Tag:risk summary table'
stored as orc
tblproperties
(
    "orc.compress" = "zstd",
    "orc.stripe.size" = "268435456"

)
location '${HDFS_PATH}/risk_mart/ads/ads_risk_reg_spp_user_apba_remittance_df/grass_region=${region_upper}';
msck repair table ${SCHEMA}.ads_risk_${region_lower}_spp_user_apba_remittance_df;

