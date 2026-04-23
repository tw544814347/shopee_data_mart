drop table if exists ${SCHEMA}.ads_risk_${region_lower}_seller_feature_df
;

create table ${SCHEMA}.ads_risk_${region_lower}_seller_feature_df
(
    row_key STRING
    ,seller_id STRING
    ,total_order_count_7d bigint
    ,total_order_count_15d bigint
    ,total_order_count_30d bigint
    ,total_gmv_paid_7d decimal(30, 10)
    ,total_gmv_paid_15d decimal(30, 10)
    ,total_gmv_paid_30d decimal(30, 10)
    ,abs_paid_7d decimal(30, 10)

    ,abs_paid_15d decimal(30, 10)
    ,abs_paid_30d decimal(30, 10)
    ,refund_gmv_paid_7d decimal(30, 10)
    ,refund_gmv_paid_15d decimal(30, 10)
    ,refund_gmv_paid_30d decimal(30, 10)
    ,gmv_refund_rate_7d decimal(30, 2)
    ,gmv_refund_rate_15d decimal(30, 2)
    ,gmv_refund_rate_30d decimal(30, 2)
    ,shop_type STRING
    
-- added by wei.tao   jira: https://jira.shopee.io/browse/SPFDT-46843 
    ,abs_paid_6d decimal(30, 10)
    ,abs_paid_5d decimal(30, 10)
    ,abs_paid_4d decimal(30, 10)
    ,abs_paid_3d decimal(30, 10)
    ,abs_paid_2d decimal(30, 10)
    ,abs_paid_1d decimal(30, 10)
 
    ,abs_paid_7d_7d decimal(30, 10)
    ,abs_paid_6d_7d decimal(30, 10)
    ,abs_paid_5d_7d decimal(30, 10)
    ,abs_paid_4d_7d decimal(30, 10)
    ,abs_paid_3d_7d decimal(30, 10)
    ,abs_paid_2d_7d decimal(30, 10)
    ,abs_paid_1d_7d decimal(30, 10)

    ,abs_paid_7d_wow decimal(30, 10)
    ,abs_paid_6d_wow decimal(30, 10)
    ,abs_paid_5d_wow decimal(30, 10)
    ,abs_paid_4d_wow decimal(30, 10)
    ,abs_paid_3d_wow decimal(30, 10)
    ,abs_paid_2d_wow decimal(30, 10)
    ,abs_paid_1d_wow decimal(30, 10)
--
) 
partitioned by
(
    grass_date string comment 'YYYY-MM-dd'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
    ,"orc.stripe.size" = "268435456"
)
location '${HDFS_PATH}/risk_feature/ads/ads_risk_${region_lower}_seller_feature_df'
;

msck repair table ${SCHEMA}.ads_risk_${region_lower}_seller_feature_df
;

