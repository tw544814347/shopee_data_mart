-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-03-24
-- Theme Domain:        FS迁移,underwriting_seller 宽表
-- Data Granularity:    platform_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-03-24 - chengguo.liu - 初始化
-- =============================================================================


--drop table if exists ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_seller_df;
create table if not exists ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_seller_df (
    shopee_user_id string comment 'shopee_user_id'
    ,shop_id string comment 'shop_id'
    ,days_has_txn_30days bigint comment 'days_has_txn_30days'
    ,days_has_txn_90days bigint comment 'days_has_txn_90days'
    ,days_has_txn_180days bigint comment 'days_has_txn_180days'
    ,days_has_txn_360days bigint comment 'days_has_txn_360days'
    ,daily_avg_escrow decimal(30,10) comment 'daily_avg_escrow'
    ,daily_escrow_percentile50 decimal(30,10) comment 'daily_escrow_percentile50'
    ,daily_escrow_percentile75 decimal(30,10) comment 'daily_escrow_percentile75'
    ,daily_escrow_percentile90 decimal(30,10) comment 'daily_escrow_percentile90'
    ,shopee_open_month bigint comment 'shopee_open_month'
)
partitioned by (grass_date string comment 'grass_date, partition key') 
stored as orc tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_mart/ads/ads_risk_reg_fs_seamoney_underwriting_seller_df/grass_region=${grass_region}'
;
--msck repair table ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_seller_df;

insert overwrite table ${SCHEMA}.ads_risk_${region}_fs_seamoney_underwriting_seller_df partition (grass_date = '${grass_date}')
select
    t1.shopee_user_id
    ,t1.shop_id
    ,t2.days_has_txn_30days
    ,t2.days_has_txn_90days
    ,t2.days_has_txn_180days
    ,t2.days_has_txn_360days
    ,t2.daily_avg_escrow
    ,t2.daily_escrow_percentile50
    ,t2.daily_escrow_percentile75
    ,t2.daily_escrow_percentile90
    ,t2.shopee_open_month
from
    (
        select
            user_id as shopee_user_id
            ,shop_id
        from mp_user.dim_shop__reg_s0_live
        where tz_type = 'local'
        and grass_region = '${grass_region}'
        and grass_date = '${grass_date}'
    ) t1
    left join (
        select
            shop_id
            ,days_has_txn_30days
            ,days_has_txn_90days
            ,days_has_txn_180days
            ,days_has_txn_360days
            ,daily_avg_escrow
            ,daily_escrow_percentile50
            ,daily_escrow_percentile75
            ,daily_escrow_percentile90
            ,shopee_open_month
        from ${SCHEMA}.dws_risk_br_shop_escrow_txn_df
        where grass_date = '${grass_date}'
    ) t2 on t1.shop_id = t2.shop_id
;