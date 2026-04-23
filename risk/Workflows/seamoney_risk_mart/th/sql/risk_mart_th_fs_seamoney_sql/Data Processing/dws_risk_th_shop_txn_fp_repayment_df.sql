--********************************************************************--
-- Author:              chenyingying@shopee.com
-- Created Time:        2024-10-29
-- Theme Domain：       transaction
-- Description:         transaction financial product repayment info
-- 开发要求:             https://docs.google.com/spreadsheets/d/11Bpx701mGtwTHd0-TXZE5ickY4HHPFsVCnsui_cWuUM/edit?gid=524012195#gid=524012195
-- FS:                  https://fs.idata.shopeemobile.com/job-management/job-edit/381
-- FS:                  https://fs.idata.shopeemobile.com/job-management/job-edit/452
-- FS:                  https://fs.idata.shopeemobile.com/job-management/job-edit/680
-- Data Granularity:    platform_user_id, shop_id
-- 变更历史：
--********************************************************************--

create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp'
;

-- drop table if exists ${SCHEMA}.dws_risk_th_shop_txn_fp_repayment_df
-- ;

create external table if not exists ${SCHEMA}.dws_risk_th_shop_txn_fp_repayment_df (
    shop_id string comment 'shop id'
    ,platform_user_id string comment 'platform user id'
    ,spl_max_dpd_l1m bigint comment 'last 1 month spl max dpd'
    ,spl_max_dpd_l3m bigint comment 'last 3 months spl max dpd'
    ,spl_max_dpd_l6m bigint comment 'last 6 months spl max dpd'
    ,spl_max_dpd_l12m bigint comment 'last 12 months spl max dpd'
    ,sl_max_dpd_l1m bigint comment 'last month sl(seller loan) max dpd'
    ,sl_max_dpd_l3m bigint comment 'last 3 months sl max dpd'
    ,sl_max_dpd_l6m bigint comment 'last 6 months sl max dpd'
    ,sl_max_dpd_l12m bigint comment 'last 12 months sl max dpd'
    ,bcl_max_dpd_l1m bigint comment 'last month bcl(buyer cash loan) max dpd'
    ,bcl_max_dpd_l3m bigint comment 'last 3 months bcl max dpd'
    ,bcl_max_dpd_l6m bigint comment 'last 6 months bcl max dpd'
    ,bcl_max_dpd_l12m bigint comment 'last 12 months bcl max dpd'
)
partitioned by
    (grass_date string comment 'YYYY-MM-DD') 
stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/dws/dws_risk_shop_txn_fp_repayment_df/grass_region=TH' 
comment '
Tag:risk summary table
credit_mart.dws_spl_th_loan_repayment_df
credit_mart.dws_scl_th_loan_repayment_df
credit_mart.dws_bcl_th_loan_repayment_df
'
;

-- msck repair table ${SCHEMA}.dws_risk_th_shop_txn_fp_repayment_df
-- ;

create or replace temporary view shop_info as (
    select
        cast(shop_id  as string)    as shop_id
        ,cast(user_id   as string)  as user_id
    from mp_user.dim_shop__th_s0_live
    where
        grass_date = date('${ds}')
        and grass_region = 'TH'
)
;

create or replace temporary view fs_bcl_dpd as (
    select
        platform_user_id as user_id
        ,max(dpd) as bcl_max_dpd_l12m_th
        ,max(
            case
                when cast(grass_date as date) >= current_date - interval '6' month then dpd
                else 0
            end
        ) as bcl_max_dpd_l6m_th
        ,max(
            case
                when cast(grass_date as date) >= current_date - interval '3' month then dpd
                else 0
            end
        ) as bcl_max_dpd_l3m_th
        ,max(
            case
                when cast(grass_date as date) >= current_date - interval '1' month then dpd
                else 0
            end
        ) as bcl_max_dpd_l1m_th
    from credit_mart.dws_bcl_th_loan_repayment_df
    where
        cast(grass_date as date) > current_date - interval '1' year
        and total_amount_repayable > 0
    group by user_id
)
;

create or replace temporary view fs_spl_dpd as (
    select
        platform_user_id as user_id
        ,max(dpd) as spl_max_dpd_l12m_th
        ,max(
            case
                when cast(grass_date as date) >= current_date - interval '6' month then dpd
                else 0
            end
        ) as spl_max_dpd_l6m_th
        ,max(
            case
                when cast(grass_date as date) >= current_date - interval '3' month then dpd
                else 0
            end
        ) as spl_max_dpd_l3m_th
        ,max(
            case
                when cast(grass_date as date) >= current_date - interval '1' month then dpd
                else 0
            end
        ) as spl_max_dpd_l1m_th
    from credit_mart.dws_spl_th_loan_repayment_df
    where
        cast(grass_date as date) > current_date - interval '1' year
        and total_amount_repayable > 0
    group by user_id
)
;

create or replace temporary view fs_sl_dpd as (
    select
        platform_user_id as user_id
        ,max(dpd) as sl_max_dpd_l12m_th
        ,max(
            case
                when cast(grass_date as date) >= current_date - interval '6' month then dpd
                else 0
            end
        ) as sl_max_dpd_l6m_th
        ,max(
            case
                when cast(grass_date as date) >= current_date - interval '3' month then dpd
                else 0
            end
        ) as sl_max_dpd_l3m_th
        ----,MAX(CASE WHEN CAST(grass_date AS DATE) >= CURRENT_DATE - INTERVAL '2' month THEN dpd ELSE 0 END) AS sl_max_dpd_l2m_ph
        ,max(
            case
                when cast(grass_date as date) >= current_date - interval '1' month then dpd
                else 0
            end
        ) as sl_max_dpd_l1m_th
    from credit_mart.dws_scl_th_loan_repayment_df
    where
        cast(grass_date as date) > current_date - interval '1' year
        and total_amount_repayable > 0
    group by user_id
)
;

insert overwrite table ${SCHEMA}.dws_risk_th_shop_txn_fp_repayment_df partition (grass_date = '${ds}')
select
    t1.shop_id as shop_id
    ,t1.user_id as platform_user_id
    ,coalesce(t6.spl_max_dpd_l1m_th, -9999) as spl_max_dpd_l1m_th
    ,coalesce(t6.spl_max_dpd_l3m_th, -9999) as spl_max_dpd_l3m_th
    ,coalesce(t6.spl_max_dpd_l6m_th, -9999) as spl_max_dpd_l6m_th
    ,coalesce(t6.spl_max_dpd_l12m_th, -9999) as spl_max_dpd_l12m_th
    ,coalesce(t7.sl_max_dpd_l1m_th, -9999) as sl_max_dpd_l1m_th
    ,coalesce(t7.sl_max_dpd_l3m_th, -9999) as sl_max_dpd_l3m_th
    ,coalesce(t7.sl_max_dpd_l6m_th, -9999) as sl_max_dpd_l6m_th
    ,coalesce(t7.sl_max_dpd_l12m_th, -9999) as sl_max_dpd_l12m_th
    ,coalesce(t8.bcl_max_dpd_l1m_th, -9999) as bcl_max_dpd_l1m_th
    ,coalesce(t8.bcl_max_dpd_l3m_th, -9999) as bcl_max_dpd_l3m_th
    ,coalesce(t8.bcl_max_dpd_l6m_th, -9999) as bcl_max_dpd_l6m_th
    ,coalesce(t8.bcl_max_dpd_l12m_th, -9999) as bcl_max_dpd_l12m_th
from
    shop_info as t1
    left join fs_spl_dpd as t6 on t1.user_id = t6.user_id
    left join fs_sl_dpd as t7 on t1.user_id = t7.user_id
    left join fs_bcl_dpd as t8 on t1.user_id = t8.user_id
;

