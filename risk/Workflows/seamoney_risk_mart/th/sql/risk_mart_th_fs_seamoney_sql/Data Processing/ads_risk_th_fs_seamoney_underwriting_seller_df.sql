--********************************************************************--
-- Author:              chenyingying@shopee.com
-- Created Time:        2024-10-29
-- Theme Domain：       seller 
-- Description:         underwriting info for shopee seller in TH
-- 开发要求:             https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit?gid=524012195#gid=524012195
-- Data Granularity:    shop_id
-- 变更历史：
--********************************************************************--

-- drop table if exists ${SCHEMA}.ads_risk_th_fs_seamoney_underwriting_seller_df
-- ;

create external table if not exists ${SCHEMA}.ads_risk_th_fs_seamoney_underwriting_seller_df (
    shop_id             string comment ''
    ,platform_user_id   string comment ''
    ,is_seller_active   bigint comment ''
    ,is_eligible_12m    bigint comment ''
    ,first_sales_date   string comment ''
    ,txn_escrow_normal_pmt_30d      bigint comment ''
    ,txn_escrow_normal_pmt_31_60d   bigint comment ''
    ,txn_escrow_normal_pmt_61_90d   bigint comment ''
    ,txn_escrow_normal_pmt_91_120d  bigint comment ''
    ,txn_escrow_normal_pmt_121_150d bigint comment ''
    ,txn_escrow_normal_pmt_151_180d bigint comment ''
    ,txn_shipout_normal_pmt_30d     bigint comment ''
    ,txn_shipout_normal_pmt_31_60d  bigint comment ''
    ,txn_shipout_normal_pmt_61_90d  bigint comment ''
    ,txn_shipout_normal_pmt_91_120d bigint comment ''
    ,txn_shipout_normal_pmt_121_150d    bigint comment ''
    ,txn_shipout_normal_pmt_151_180d    bigint comment ''
    ,days_has_txn_30days    bigint comment ''
    ,days_has_txn_90days    bigint comment ''
    ,days_has_txn_180days   bigint comment ''
    ,days_has_txn_360days   bigint comment ''
    ,daily_avg_escrow           decimal(30,10) comment ''
    ,daily_escrow_percentile50  decimal(30,10) comment ''
    ,daily_escrow_percentile75  decimal(30,10) comment ''
    ,daily_escrow_percentile90  decimal(30,10) comment ''
    ,spl_max_dpd_l1m    bigint comment ''
    ,spl_max_dpd_l3m    bigint comment ''
    ,spl_max_dpd_l6m    bigint comment ''
    ,spl_max_dpd_l12m   bigint comment ''
    ,sl_max_dpd_l1m     bigint comment ''
    ,sl_max_dpd_l3m     bigint comment ''
    ,sl_max_dpd_l6m     bigint comment ''
    ,sl_max_dpd_l12m    bigint comment ''
    ,bcl_max_dpd_l1m    bigint comment ''
    ,bcl_max_dpd_l3m    bigint comment ''
    ,bcl_max_dpd_l6m    bigint comment ''
    ,bcl_max_dpd_l12m   bigint comment ''
)
partitioned by (grass_date string comment 'YYYY-MM-DD') 
stored as orc tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_mart/ads/ads_risk_th_fs_seamoney_underwriting_seller_df/' 
comment 
'
Tag:risk summary table
'
;
-- msck repair table ${SCHEMA}.ads_risk_th_fs_seamoney_underwriting_seller_df;

create or replace temporary view shop_info as (
    select  shop_id
            ,user_id
            -- ,1  as is_seller_active
    from    mp_user.dim_shop__th_s0_live 
    where   grass_date = date('${ds}')
    and     grass_region = 'TH'
    and     shop_id <> 0
)
;


insert overwrite ${SCHEMA}.ads_risk_th_fs_seamoney_underwriting_seller_df partition (grass_date = '${ds}')
select  t1.shop_id              as shop_id
        ,t1.user_id             as platform_user_id
        ,t2.is_seller_active   
        ,t2.is_eligible_12m    
        ,t2.first_sales_date   
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
        ,t2.days_has_txn_30days   
        ,t2.days_has_txn_90days    
        ,t2.days_has_txn_180days   
        ,t2.days_has_txn_360days   
        ,t2.daily_avg_escrow   
        ,t2.daily_escrow_percentile50  
        ,t2.daily_escrow_percentile75  
        ,t2.daily_escrow_percentile90  
        ,t3.spl_max_dpd_l1m    
        ,t3.spl_max_dpd_l3m    
        ,t3.spl_max_dpd_l6m    
        ,t3.spl_max_dpd_l12m   
        ,t3.sl_max_dpd_l1m 
        ,t3.sl_max_dpd_l3m 
        ,t3.sl_max_dpd_l6m 
        ,t3.sl_max_dpd_l12m    
        ,t3.bcl_max_dpd_l1m    
        ,t3.bcl_max_dpd_l3m    
        ,t3.bcl_max_dpd_l6m    
        ,t3.bcl_max_dpd_l12m
from    shop_info as t1
left join risk.dws_risk_th_shop_escrow_txn_df as t2 
on  t1.shop_id = cast(t2.shop_id as bigint)
left join risk.dws_risk_th_shop_txn_fp_repayment_df as t3
on  t1.user_id = cast(t3.platform_user_id as bigint)
where t2.grass_date = '${ds}'
and   t3.grass_date = '${ds}'