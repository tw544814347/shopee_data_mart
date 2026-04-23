-- =============================================================================
-- Author:              chenyingying
-- Created Time:        2026-01-16
-- Theme Domain:        User Txn DPD Info Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-02-14 - chenyingying - 初始化
-- =============================================================================

-- drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_dpd_df;

create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_dpd_df
(
    credit_user_id                                  string  comment 'credit user id'
    
    ,ever_max_dpd_cashloan_core                     bigint  comment 'cash loan(BCL) ever max dpd'
    ,last_bill_dpd_cashloan_core                    bigint  comment 'cash loan(BCL) latest bill dpd'
    ,days_after_first_due_date_cashloan             bigint  comment 'cash loan(BCL) days after first due date'
    ,ever_max_dpd_180d_cashloan                     bigint  comment 'cash loan(BCL) ever max dpd in 180 days'
    ,ever_max_dpd_360d_cashloan                     bigint  comment 'cash loan(BCL) ever max dpd in 360 days'
    ,ever_max_dpd_30d_bcl                           bigint  comment 'cash loan(BCL) ever max dpd in 30 days'
    ,ever_max_dpd_90d_bcl                           bigint  comment 'cash loan(BCL) ever max dpd in 90 days'
    
    ,ever_max_dpd_180d_user                         bigint  comment 'User ever max dpd in 180 days'
    ,ever_max_dpd_360d_user                         bigint  comment 'User ever max dpd in 360 days'
    
    ,ever_max_dpd_sellerloan_core                   bigint  comment 'seller loan(SCL) ever max dpd'
    ,last_bill_dpd_sellerloan_core                  bigint  comment 'seller loan(SCL) latest bill dpd'
    ,ever_max_dpd_30d_scl                           bigint  comment 'seller loan(SCL) ever max dpd in 30 days'
    ,ever_max_dpd_90d_scl                           bigint  comment 'seller loan(SCL) ever max dpd in 90 days'
    ,ever_max_dpd_180d_scl                          bigint  comment 'seller loan(SCL) ever max dpd in 180 days'
    ,ever_max_dpd_360d_scl                          bigint  comment 'seller loan(SCL) ever max dpd in 30 days'
    
    ,ever_max_dpd_spl_core                          bigint  comment 'shopeepay later(SPL) ever max dpd'
    ,last_bill_dpd_spl_core                         bigint  comment 'shopeepay later(SPL) last bill dpd'
    ,days_after_first_due_date_spl                  bigint  comment 'shopeepay later(SPL) days after first due date'
    ,ever_max_dpd_180d_spl                          bigint  comment 'shopeepay later(SPL) ever max dpd in 180 days'
    ,ever_max_dpd_360d_spl                          bigint  comment 'shopeepay later(SPL) ever max dpd in 360 days'
    ,ever_max_dpd_30d_spl                           bigint  comment 'shopeepay later(SPL) ever max dpd in 30 days'
    ,ever_max_dpd_90d_spl                           bigint  comment 'shopeepay later(SPL) ever max dpd in 90 days'
    
    ,latest_dpd_eod_cashloan                        bigint  comment 'cash loan(BCL) latest dpd eod'
    ,latest_dpd_eod_spl                             bigint  comment 'shopeepay later(SPL) latest dpd eod'


)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_txn_credit_dpd_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_credit_dpd_df;

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_credit_dpd_df partition(grass_date='${ds}')
select  t1.credit_user_id
        -- bcl
        ,coalesce(t3.historical_max_dpd_eod,-9999) as ever_max_dpd_cashloan_core
        ,coalesce(t3.last_bill_dpd,-9999) as last_bill_dpd_cashloan_core
        ,coalesce(t3.days_after_first_due_date, -9999) as days_after_first_due_date_cashloan
        ,coalesce(t3.ever_max_dpd_180d, -9999) as ever_max_dpd_180d_cashloan
        ,coalesce(t3.ever_max_dpd_360d, -9999) as ever_max_dpd_360d_cashloan
        ,coalesce(t3.ever_max_dpd_30d ,-9999) as ever_max_dpd_30d_bcl
        ,coalesce(t3.ever_max_dpd_90d ,-9999) as ever_max_dpd_90d_bcl 
        -- user
        ,coalesce(
            case when t3.ever_max_dpd_180d is null then t5.ever_max_dpd_180d
                when t5.ever_max_dpd_180d is null then t3.ever_max_dpd_180d
                when t3.ever_max_dpd_180d > t5.ever_max_dpd_180d then t3.ever_max_dpd_180d
                else t5.ever_max_dpd_180d
                end, -9999) as ever_max_dpd_180d_user
        ,coalesce(
            case when t3.ever_max_dpd_360d is null then t5.ever_max_dpd_360d
                when t5.ever_max_dpd_360d is null then t3.ever_max_dpd_360d
                when t3.ever_max_dpd_360d > t5.ever_max_dpd_360d then t3.ever_max_dpd_360d
                else t5.ever_max_dpd_360d
                end, -9999) as ever_max_dpd_360d_user

        --SCL
        ,coalesce(t4.historical_max_dpd_eod,-9999) as ever_max_dpd_sellerloan_core
        ,coalesce(t4.last_bill_dpd,-9999) as last_bill_dpd_sellerloan_core
        ,coalesce(t4.ever_max_dpd_30d ,-9999) as ever_max_dpd_30d_scl
        ,coalesce(t4.ever_max_dpd_90d ,-9999) as ever_max_dpd_90d_scl
        ,coalesce(t4.ever_max_dpd_180d,-9999) as ever_max_dpd_180d_scl
        ,coalesce(t4.ever_max_dpd_360d,-9999) as ever_max_dpd_360d_scl
        -- SPL
        ,coalesce(t5.historical_max_dpd_eod,-9999) as ever_max_dpd_spl_core
        ,coalesce(t5.last_bill_dpd,-9999) as last_bill_dpd_spl_core
        ,coalesce(t5.days_after_first_due_date, -9999) as days_after_first_due_date_spl
        ,coalesce(t5.ever_max_dpd_180d, -9999) as ever_max_dpd_180d_spl
        ,coalesce(t5.ever_max_dpd_360d, -9999) as ever_max_dpd_360d_spl
        ,coalesce(t5.ever_max_dpd_30d ,-9999) as ever_max_dpd_30d_spl
        ,coalesce(t5.ever_max_dpd_90d ,-9999) as ever_max_dpd_90d_spl 

        ,coalesce(t6.latest_dpd_eod_cashloan ,-9999) as latest_dpd_eod_cashloan
        ,coalesce(t7.latest_dpd_eod_spl, -9999)      as latest_dpd_eod_spl
from (
    select credit_user_id
    from    credit_uc.dws_all_prod_${region}_uc_user_df
    where   grass_date = '${ds}'
    and     credit_user_id <> '0'
    and     credit_user_id is not null
    and     credit_user_id <> ''
    group by 1
) t1
left join
(
    select  credit_user_id
            ,historical_max_dpd_eod
            ,last_bill_dpd
            ,days_after_first_due_date
            ,ever_max_dpd_30d
            ,ever_max_dpd_90d
            ,ever_max_dpd_180d
            ,ever_max_dpd_360d
    from credit_mart.dws_bcl_vn_user_df
    where grass_date = '${ds}'
) t3
on t1.credit_user_id = t3.credit_user_id
left join   (
    select  credit_user_id
            ,historical_max_dpd_eod
            ,last_bill_dpd
            ,ever_max_dpd_30d
            ,ever_max_dpd_90d
            ,ever_max_dpd_180d
            ,ever_max_dpd_360d
            ,grass_date
    from credit_mart.dws_scl_vn_user_df
    where grass_date = '${ds}'
) t4
on t1.credit_user_id = t4.credit_user_id
left join   (
    select
        credit_user_id
        ,historical_max_dpd_eod
        ,last_bill_dpd
        ,days_after_first_due_date
        ,ever_max_dpd_30d
        ,ever_max_dpd_90d
        ,ever_max_dpd_180d
        ,ever_max_dpd_360d
        ,grass_date
    from credit_mart.dws_spl_vn_user_df
    where grass_date = '${ds}'
) t5
on t1.credit_user_id = t5.credit_user_id
left join
(
    select
        credit_user_id           
        ,lastest_max_dpd_eod_120d as latest_dpd_eod_cashloan
        ,grass_date               as grass_date
    from credit_mart.wide_bcl_vn_behavior_user_df
    where grass_date = '${ds}'
) t6
on t1.credit_user_id = t6.credit_user_id
left join (
    select credit_user_id
            ,lastest_max_dpd_eod_120d_spl   as latest_dpd_eod_spl
    from    credit_mart.dws_spl_vn_user_risk_df
    where   grass_date = '${ds}'
) t7
on t1.credit_user_id = t7.credit_user_id
;