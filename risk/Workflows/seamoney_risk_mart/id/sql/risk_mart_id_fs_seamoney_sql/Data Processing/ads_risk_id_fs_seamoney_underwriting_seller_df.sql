------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-10-15
-- Description:         FS迁移，underwriting seller 指标
-- Data Granularity:    platform_user_id
-- PRD:                 https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit?gid=899753510#gid=899753510
------------------------------------------------------------------------
--drop table if exists ${SCHEMA}.ads_risk_id_fs_seamoney_underwriting_seller_df;
create table if not exists ${SCHEMA}.ads_risk_id_fs_seamoney_underwriting_seller_df (
    platform_user_id string comment 'platform_user_id'
    ,shop_id string comment 'shop_id'
    ,is_seller_active bigint comment '"  Is an active seller"'
    ,is_eligible_12m bigint comment 'whether the customer is eligible for 12 month tenor'
    ,first_sales_date string comment 'first selling transaction happened date'
    ,escrow_normal_pmt_30d decimal(30,10) comment 'escrow amount of non-cod order in 30 days'
    ,escrow_normal_pmt_31_60d decimal(30,10) comment 'escrow amount of non-cod order in 151-180 days'
    ,escrow_normal_pmt_61_90d decimal(30,10) comment 'escrow amount of non-cod order in 151-180 days'
    ,escrow_normal_pmt_91_120d decimal(30,10) comment 'escrow amount of non-cod order in 151-180 days'
    ,escrow_normal_pmt_121_150d decimal(30,10) comment 'escrow amount of non-cod order in 151-180 days'
    ,escrow_normal_pmt_151_180d decimal(30,10) comment 'escrow amount of non-cod order in 151-180 days'
    ,txn_escrow_normal_pmt_30d bigint comment 'non-cod & escrow amount > 0 order in last 30 days'
    ,txn_escrow_normal_pmt_31_60d bigint comment 'non-cod & escrow amount > 0 order in 31-60 days'
    ,txn_escrow_normal_pmt_61_90d bigint comment 'non-cod & escrow amount > 0 order in 61-90 days'
    ,txn_escrow_normal_pmt_91_120d bigint comment 'non-cod & escrow amount > 0 order in 91-120 days'
    ,txn_escrow_normal_pmt_121_150d bigint comment 'non-cod & escrow amount > 0 order in 121-150 days'
    ,txn_escrow_normal_pmt_151_180d bigint comment 'non-cod & escrow amount > 0 order in 151-180 days'
    ,txn_shipout_normal_pmt_30d bigint comment 'non-cod order in last 30 days'
    ,txn_shipout_normal_pmt_31_60d bigint comment 'non-cod order in 31-60 days'
    ,txn_shipout_normal_pmt_61_90d bigint comment 'non-cod order in 61-90 days'
    ,txn_shipout_normal_pmt_91_120d bigint comment 'non-cod order in 91-120 days'
    ,txn_shipout_normal_pmt_121_150d bigint comment 'non-cod order in 121-150 days'
    ,txn_shipout_normal_pmt_151_180d bigint comment 'non-cod order in 151-180 days'
    ,escrow_cod_pmt_30d bigint comment 'cod & escrow amount > 0 order in last 30 days'
    ,escrow_cod_pmt_31_60d bigint comment 'cod & escrow amount > 0 order in 31-60 days'
    ,escrow_cod_pmt_61_90d bigint comment 'cod & escrow amount > 0 order in 61-90 days'
    ,escrow_cod_pmt_91_120d bigint comment 'cod & escrow amount > 0 order in 91-120 days'
    ,escrow_cod_pmt_121_150d bigint comment 'cod & escrow amount > 0 order in 121-150 days'
    ,escrow_cod_pmt_151_180d bigint comment 'cod & escrow amount > 0 order in 151-180 days'
    ,gmv_shipout_cod_pmt_30d decimal(30,10) comment 'gmv of cod order in last 30 days'
    ,gmv_shipout_cod_pmt_31_60d decimal(30,10) comment 'gmv of cod order in 31-60 days'
    ,gmv_shipout_cod_pmt_61_90d decimal(30,10) comment 'gmv of cod order in 61-90 days'
    ,gmv_shipout_cod_pmt_91_120d decimal(30,10) comment 'gmv of cod order in 91-120 days'
    ,gmv_shipout_cod_pmt_121_150d decimal(30,10) comment 'gmv of cod order in 121-150 days'
    ,gmv_shipout_cod_pmt_151_180d decimal(30,10) comment 'gmv of cod order in 151-180 days'
    ,gmv_shipout_normal_pmt_30d decimal(30,10) comment 'gmv of non-cod order in last 30 days'
    ,gmv_shipout_normal_pmt_31_60d decimal(30,10) comment 'gmv of non-cod order in 31-60 days'
    ,gmv_shipout_normal_pmt_61_90d decimal(30,10) comment 'gmv of non-cod order in 61-90 days'
    ,gmv_shipout_normal_pmt_91_120d decimal(30,10) comment 'gmv of non-cod order in 91-120 days'
    ,gmv_shipout_normal_pmt_121_150d decimal(30,10) comment 'gmv of non-cod order in 121-150 days'
    ,gmv_shipout_normal_pmt_151_180d decimal(30,10) comment 'gmv of non-cod order in 151-180 days'
    ,txn_escrow_cod_pmt_30d bigint comment 'cod & escrow amount > 0 order in last 30 days'
    ,txn_escrow_cod_pmt_31_60d bigint comment 'cod & escrow amount > 0 order in 31-60 days'
    ,txn_escrow_cod_pmt_61_90d bigint comment 'cod & escrow amount > 0 order in 61-90 days'
    ,txn_escrow_cod_pmt_91_120d bigint comment 'cod & escrow amount > 0 order in 91-120 days'
    ,txn_escrow_cod_pmt_121_150d bigint comment 'cod & escrow amount > 0 order in 121-150 days'
    ,txn_escrow_cod_pmt_151_180d bigint comment 'cod & escrow amount > 0 order in 151-180 days'
    ,txn_shipout_cod_pmt_30d bigint comment 'cod order in last 30 days'
    ,txn_shipout_cod_pmt_31_60d bigint comment 'cod order in 31-60 days'
    ,txn_shipout_cod_pmt_61_90d bigint comment 'cod order in 61-90 days'
    ,txn_shipout_cod_pmt_91_120d bigint comment 'cod order in 91-120 days'
    ,txn_shipout_cod_pmt_121_150d bigint comment 'cod order in 121-150 days'
    ,txn_shipout_cod_pmt_151_180d bigint comment 'cod order in 151-180 days'
    ,days_has_txn_30days bigint comment 'days has txn in last 30days'
    ,days_has_txn_90days bigint comment 'days has txn in last 90days'
    ,days_has_txn_180days bigint comment 'days has txn in last 180days'
    ,days_has_txn_360days bigint comment 'days has txn in last 360days'
    ,daily_avg_escrow decimal(30,10) comment 'average daily escrow amount'
    ,daily_escrow_percentile50 decimal(30,10) comment '50 percentile of daily escrow amount'
    ,daily_escrow_percentile75 decimal(30,10) comment '75 percentile of daily escrow amount'
    ,daily_escrow_percentile90 decimal(30,10) comment '90 percentile of daily escrow amount'
    ,spl_max_dpd_l3m bigint comment 'spl max dpd in the past 3 month'
    ,spl_max_dpd_l12m bigint comment 'spl max dpd in the past 12 month'
    ,number_of_curr_loans bigint comment 'number of uncleared loans the seller has'
    ,sl_max_dpd_l1m bigint comment 'seller loan max dpd in the past 1 month'
    ,sl_max_dpd_l2m bigint comment 'seller loan max dpd in the past 2 month'
    ,sl_max_dpd_l3m bigint comment 'seller loan max dpd in the past 3 month'
    ,sl_max_dpd_l6m bigint comment 'seller loan max dpd in the past 6 month'
    ,sl_max_dpd_l12m bigint comment 'seller loan max dpd in the past 12 month'
)
partitioned by (grass_date string comment 'grass_date, partition key') 
stored as orc tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_mart/ads/ads_risk_fs_seamoney_underwriting_seller_df/grass_region=ID'
;
--msck repair table ${SCHEMA}.ads_risk_id_fs_seamoney_underwriting_seller_df;

insert overwrite table
    ${SCHEMA}.ads_risk_id_fs_seamoney_underwriting_seller_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t1.shop_id
    ,t1.is_seller_active
    ,t2.is_eligible_12m
    ,t2.first_sales_date
    ,t2.escrow_normal_pmt_30d
    ,t2.escrow_normal_pmt_31_60d
    ,t2.escrow_normal_pmt_61_90d
    ,t2.escrow_normal_pmt_91_120d
    ,t2.escrow_normal_pmt_121_150d
    ,t2.escrow_normal_pmt_151_180d
    ,t2.txn_escrow_normal_pmt_30d
    ,t2.txn_escrow_normal_pmt_31_60d
    ,t2.txn_escrow_normal_pmt_61_90d
    ,t2.txn_escrow_normal_pmt_91_120d
    ,t2.txn_escrow_normal_pmt_121_150d
    ,t2.txn_escrow_normal_pmt_151_180d
    ,t2.txn_shipout_normal_pmt_30d
    ,t2.txn_shipout_normal_pmt_31_60d
    ,t2.txn_shipout_normal_pmt_61_90d
    ,t2.txn_shipout_normal_pmt_91_120d
    ,t2.txn_shipout_normal_pmt_121_150d
    ,t2.txn_shipout_normal_pmt_151_180d
    ,t2.escrow_cod_pmt_30d
    ,t2.escrow_cod_pmt_31_60d
    ,t2.escrow_cod_pmt_61_90d
    ,t2.escrow_cod_pmt_91_120d
    ,t2.escrow_cod_pmt_121_150d
    ,t2.escrow_cod_pmt_151_180d
    ,t2.gmv_shipout_cod_pmt_30d
    ,t2.gmv_shipout_cod_pmt_31_60d
    ,t2.gmv_shipout_cod_pmt_61_90d
    ,t2.gmv_shipout_cod_pmt_91_120d
    ,t2.gmv_shipout_cod_pmt_121_150d
    ,t2.gmv_shipout_cod_pmt_151_180d
    ,t2.gmv_shipout_normal_pmt_30d
    ,t2.gmv_shipout_normal_pmt_31_60d
    ,t2.gmv_shipout_normal_pmt_61_90d
    ,t2.gmv_shipout_normal_pmt_91_120d
    ,t2.gmv_shipout_normal_pmt_121_150d
    ,t2.gmv_shipout_normal_pmt_151_180d
    ,t2.txn_escrow_cod_pmt_30d
    ,t2.txn_escrow_cod_pmt_31_60d
    ,t2.txn_escrow_cod_pmt_61_90d
    ,t2.txn_escrow_cod_pmt_91_120d
    ,t2.txn_escrow_cod_pmt_121_150d
    ,t2.txn_escrow_cod_pmt_151_180d
    ,t2.txn_shipout_cod_pmt_30d
    ,t2.txn_shipout_cod_pmt_31_60d
    ,t2.txn_shipout_cod_pmt_61_90d
    ,t2.txn_shipout_cod_pmt_91_120d
    ,t2.txn_shipout_cod_pmt_121_150d
    ,t2.txn_shipout_cod_pmt_151_180d
    ,t2.days_has_txn_30days
    ,t2.days_has_txn_90days
    ,t2.days_has_txn_180days
    ,t2.days_has_txn_360days
    ,t2.daily_avg_escrow
    ,t2.daily_escrow_percentile50
    ,t2.daily_escrow_percentile75
    ,t2.daily_escrow_percentile90
    ,t3.spl_max_dpd_l3m
    ,t3.spl_max_dpd_l12m
    ,t3.number_of_curr_loans
    ,t3.sl_max_dpd_l1m
    ,t3.sl_max_dpd_l2m
    ,t3.sl_max_dpd_l3m
    ,t3.sl_max_dpd_l6m
    ,t3.sl_max_dpd_l12m
from
    (
        select
            user_id as platform_user_id
            ,shop_id
            ,1 as is_seller_active
        from mp_user.dim_shop__reg_s0_live
        where tz_type = 'local'
        and grass_region = 'ID'
        and grass_date = '${ds}'
    ) t1
    left join (
        select
            shop_id
            ,is_eligible_12m
            ,first_sales_date
            ,escrow_normal_pmt_30d
            ,escrow_normal_pmt_31_60d
            ,escrow_normal_pmt_61_90d
            ,escrow_normal_pmt_91_120d
            ,escrow_normal_pmt_121_150d
            ,escrow_normal_pmt_151_180d
            ,txn_escrow_normal_pmt_30d
            ,txn_escrow_normal_pmt_31_60d
            ,txn_escrow_normal_pmt_61_90d
            ,txn_escrow_normal_pmt_91_120d
            ,txn_escrow_normal_pmt_121_150d
            ,txn_escrow_normal_pmt_151_180d
            ,txn_shipout_normal_pmt_30d
            ,txn_shipout_normal_pmt_31_60d
            ,txn_shipout_normal_pmt_61_90d
            ,txn_shipout_normal_pmt_91_120d
            ,txn_shipout_normal_pmt_121_150d
            ,txn_shipout_normal_pmt_151_180d
            ,escrow_cod_pmt_30d
            ,escrow_cod_pmt_31_60d
            ,escrow_cod_pmt_61_90d
            ,escrow_cod_pmt_91_120d
            ,escrow_cod_pmt_121_150d
            ,escrow_cod_pmt_151_180d
            ,gmv_shipout_cod_pmt_30d
            ,gmv_shipout_cod_pmt_31_60d
            ,gmv_shipout_cod_pmt_61_90d
            ,gmv_shipout_cod_pmt_91_120d
            ,gmv_shipout_cod_pmt_121_150d
            ,gmv_shipout_cod_pmt_151_180d
            ,gmv_shipout_normal_pmt_30d
            ,gmv_shipout_normal_pmt_31_60d
            ,gmv_shipout_normal_pmt_61_90d
            ,gmv_shipout_normal_pmt_91_120d
            ,gmv_shipout_normal_pmt_121_150d
            ,gmv_shipout_normal_pmt_151_180d
            ,txn_escrow_cod_pmt_30d
            ,txn_escrow_cod_pmt_31_60d
            ,txn_escrow_cod_pmt_61_90d
            ,txn_escrow_cod_pmt_91_120d
            ,txn_escrow_cod_pmt_121_150d
            ,txn_escrow_cod_pmt_151_180d
            ,txn_shipout_cod_pmt_30d
            ,txn_shipout_cod_pmt_31_60d
            ,txn_shipout_cod_pmt_61_90d
            ,txn_shipout_cod_pmt_91_120d
            ,txn_shipout_cod_pmt_121_150d
            ,txn_shipout_cod_pmt_151_180d
            ,days_has_txn_30days
            ,days_has_txn_90days
            ,days_has_txn_180days
            ,days_has_txn_360days
            ,daily_avg_escrow
            ,daily_escrow_percentile50
            ,daily_escrow_percentile75
            ,daily_escrow_percentile90
        from ${SCHEMA}.dws_risk_id_shop_escrow_txn_df
        where grass_date = '${grass_date}'
    ) t2 on t1.shop_id = t2.shop_id
    left join (
        select
            platform_user_id
            ,spl_max_dpd_l3m
            ,spl_max_dpd_l12m
            ,number_of_curr_loans
            ,sl_max_dpd_l1m
            ,sl_max_dpd_l2m
            ,sl_max_dpd_l3m
            ,sl_max_dpd_l6m
            ,sl_max_dpd_l12m
        from ${SCHEMA}.dws_risk_id_user_txn_fp_repayment_df
        where grass_date = '${grass_date}'
    ) t3 on t1.platform_user_id = t3.platform_user_id
;