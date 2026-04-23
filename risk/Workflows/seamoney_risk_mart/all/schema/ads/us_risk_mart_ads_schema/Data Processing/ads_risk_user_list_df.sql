drop table if exists ${SCHEMA}.ads_risk_user_list_df;
create external table if not exists ${SCHEMA}.ads_risk_user_list_df
(
    user_id	                                           string   comment 'shopee user id'
    ,shop_id                                           bigint   comment 'shopee shop id'
    ,shopee_registration_timestamp                     bigint   comment 'shopee registration in unix timestamp'
    ,is_whitelist_spl                                  tinyint  comment '1 = yes;0 = no'
    ,first_whitelist_time_spl                          string   comment 'first_whitelist_time_spl'
    ,last_whitelist_date_spl                           string   comment 'last_whitelist_date_spl'
    ,is_whitelist_bcl                                  tinyint  comment '1 = yes;0 = no'
    ,first_whitelist_time_bcl                          string   comment 'first_whitelist_time_bcl'
    ,last_whitelist_date_bcl                           string   comment 'last_whitelist_date_bcl '
    ,is_whitelist_scl                                  tinyint  comment '1 = yes;0 = no'
    ,first_whitelist_time_scl                          string   comment 'first_whitelist_time_scl'
    ,last_whitelist_date_scl                           string   comment 'last_whitelist_date_scl'
    ,is_whitelist_fes                                  tinyint  comment '1 = yes;0 = no'
    ,first_whitelist_time_fes                          string   comment 'first_whitelist_time_fes'
    ,last_whitelist_date_fes                           string   comment 'last_whitelist_date_fes'
    ,is_whitelist_chp                                  tinyint  comment '1 = yes;0 = no'
    ,first_whitelist_time_chp                          string   comment 'first_whitelist_time_chp'
    ,last_whitelist_date_chp                           string   comment 'last_whitelist_date_chp'
    ,is_whitelist_cpl                                  tinyint  comment '1 = yes;0 = no'
    ,first_whitelist_time_cpl                          string   comment 'first_whitelist_time_cpl'
    ,last_whitelist_date_cpl                           string   comment 'last_whitelist_date_cpl'
    ,is_blacklist_spl                                  tinyint  comment '1 = yes;0 = no'
    ,first_blacklist_time_spl                          string   comment 'first_blacklist_time_spl'
)
comment 'Tag:risk summary table
the address user configured'
partitioned by
(
     tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_user_list_df';
msck repair table ${SCHEMA}.ads_risk_user_list_df;