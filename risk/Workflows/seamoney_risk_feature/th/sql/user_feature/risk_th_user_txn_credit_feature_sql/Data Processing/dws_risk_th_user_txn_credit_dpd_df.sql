-- =============================================================================
-- Author:              huangyue
-- Created Time:        2026-01-16
-- Theme Domain:        User Base Info Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-15 - chengguo.liu - 初始化
-- =============================================================================

-- drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_dpd_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_dpd_df
(
    credit_user_id                          string  comment 'credit user id'
    ,shopee_user_id                         string  comment 'shopee user id'
    ,uui_dpd30_cluster_user_cnt             bigint  comment 'dpd 30 cluster user cnt'
    ,sl_max_dpd_l1m_th                      bigint  comment 'seller loan(SCL) max dpd last 1 month'
    ,sl_max_dpd_l3m_th                      bigint  comment 'seller loan(SCL) max dpd last 3 month'
    ,sl_max_dpd_l6m_th                      bigint  comment 'seller loan(SCL) max dpd last 6 month'
    ,sl_max_dpd_l12m_th                     bigint  comment 'seller loan(SCL) max dpd last 12 month'
    ,ever_max_dpd_chp                       bigint  comment 'cellphone loan(CHP) ever max dpd'
    ,ever_max_dpd_30d_chp                   bigint  comment 'cellphone loan(CHP) ever max dpd in last 30d'
    ,ever_max_dpd_90d_chp                   bigint  comment 'cellphone loan(CHP) ever max dpd in last 90d'
    ,ever_max_dpd_180d_chp                  bigint  comment 'cellphone loan(CHP) ever max dpd in last 180d'
    ,ever_max_dpd_360d_chp                  bigint  comment 'cellphone loan(CHP) ever max dpd in last 360d'
    ,days_after_first_due_date_chp          bigint  comment 'cellphone loan(CHP) days after first due date'
    ,ever_max_dpd_cashloan_core             bigint  comment 'cashloan(BCL) core ever max dpd'
    ,last_bill_dpd_cashloan_core            bigint  comment 'cashloan(BCL) core last bill dpd'
    ,ever_max_dpd_180d_cashloan             bigint  comment 'cashloan(BCL) ever max dpd in last 180d'
    ,ever_max_dpd_360d_cashloan             bigint  comment 'cashloan(BCL) ever max dpd in last 360d'
    ,ever_max_dpd_30d_bcl                   bigint  comment 'cashloan(BCL) ever max dpd in last 30d'
    ,ever_max_dpd_90d_bcl                   bigint  comment 'cashloan(BCL) ever max dpd in last 90d'
    ,latest_dpd_eod_casheloan               bigint  comment 'cashloan(BCL) latest dpd eod'
    ,days_after_first_due_date_cashloan     bigint  comment 'cahsloan(BCL) days after first due date'
    ,days_after_first_due_date_cashloan_floating    decimal(30, 10) comment 'cahsloan(BCL) days after first due date floating' 
    ,ever_max_dpd_spl_core                          bigint comment 'shopeepay later(SPL) ever max dpd'
    ,last_bill_dpd_spl_core                         bigint comment 'shopeepay later(SPL) last bill dpd'
    ,ever_max_dpd_180d_spl                          bigint comment 'shopeepay later(SPL) ever max dpd in 180d'
    ,ever_max_dpd_360d_spl                          bigint comment 'shopeepay later(SPL) ever max dpd in 360d'
    ,ever_max_dpd_30d_spl                           bigint comment 'shopeepay later(SPL) ever max dpd in 30d'
    ,ever_max_dpd_90d_spl                           bigint comment 'shopeepay later(SPL) ever max dpd in 90d'
    ,latest_dpd_eod_spl                             bigint comment 'shopeepay later(SPL) latest dpd eod'
    ,days_after_first_due_date_spl                  bigint comment 'shopeepay later(SPL) days after first due date'
    ,days_after_first_due_date_spl_floating         decimal(30,10) comment 'shopeepay later(SPL) days after first due date'
    ,ever_max_dpd_sellerloan_core                   bigint comment 'seller loan(SCL) max dpd last 3 month'
    ,last_bill_dpd_sellerloan_core                  bigint comment 'seller loan(SCL) last bill dpd'
    ,ever_max_dpd_30d_scl                           bigint comment 'seller loan(SCL) ever max dpd in last 30d'
    ,ever_max_dpd_90d_scl                           bigint comment 'seller loan(SCL) ever max dpd in last 90d'
    ,ever_max_dpd_180d_scl                          bigint comment 'seller loan(SCL) ever max dpd in last 180d'
    ,ever_max_dpd_360d_scl                          bigint comment 'seller loan(SCL) ever max dpd in last 360d'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_txn_credit_dpd_df/grass_region=${REGION}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_credit_dpd_df;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_credit_dpd_df partition (grass_date = '${ds}')
select  t1.credit_user_id
        ,t1.shopee_user_id
        ,t2.uui_dpd30_cluster_user_cnt
        ,coalesce(t3.sl_max_dpd_l1m_th, -9999)  as  sl_max_dpd_l1m
        ,coalesce(t3.sl_max_dpd_l3m_th, -9999)  as  sl_max_dpd_l3m 
        ,coalesce(t3.sl_max_dpd_l6m_th, -9999)  as  sl_max_dpd_l6m
        ,coalesce(t3.sl_max_dpd_l12m_th, -9999) as  sl_max_dpd_l12m 
        ,coalesce(t4.ever_max_dpd_chp, -9999)   as  ever_max_dpd_chp         
        ,coalesce(t4.ever_max_dpd_30d_chp, -9999)   as ever_max_dpd_30d_chp      
        ,coalesce(t4.ever_max_dpd_90d_chp, -9999)   as ever_max_dpd_90d_chp       
        ,coalesce(t4.ever_max_dpd_180d_chp, -9999)  as ever_max_dpd_180d_chp      
        ,coalesce(t4.ever_max_dpd_360d_chp, -9999)  as ever_max_dpd_360d_chp     
        ,coalesce(t4.days_after_first_due_date_chp, -9999)  as days_after_first_due_date_chp
        ,coalesce(t6.ever_max_dpd_cashloan_core, -9999)         as ever_max_dpd_cashloan_core
        ,coalesce(t6.last_bill_dpd_cashloan_core, -9999)        as last_bill_dpd_cashloan_core
        ,coalesce(t6.ever_max_dpd_180d_cashloan, -9999)         as ever_max_dpd_180d_cashloan 
        ,coalesce(t6.ever_max_dpd_360d_cashloan, -9999)         as ever_max_dpd_360d_cashloan 
        ,coalesce(t6.ever_max_dpd_30d_bcl, -9999)               as ever_max_dpd_30d_bcl
        ,coalesce(t6.ever_max_dpd_90d_bcl, -9999)               as ever_max_dpd_90d_bcl
        ,coalesce(t5.latest_dpd_eod_cashloan, -9999)            as latest_dpd_eod_cashloan
        ,coalesce(t6.days_after_first_due_date_cashloan, -9999)     as days_after_first_due_date_cashloan
        ,coalesce(t6.days_after_first_due_date_cashloan_floating, -9999)    as days_after_first_due_date_cashloan_floating 
        ,coalesce(t7.ever_max_dpd_spl_core, -9999)                      as  ever_max_dpd_spl_core
        ,coalesce(t7.last_bill_dpd_spl_core, -9999)                    as   last_bill_dpd_spl_core
        ,coalesce(t7.ever_max_dpd_180d_spl, -9999)                     as   ever_max_dpd_180d_spl
        ,coalesce(t7.ever_max_dpd_360d_spl, -9999)                   as     ever_max_dpd_360d_spl
        ,coalesce(t7.ever_max_dpd_30d_spl, -9999)                    as     ever_max_dpd_30d_spl
        ,coalesce(t7.ever_max_dpd_90d_spl, -9999)                    as     ever_max_dpd_90d_spl
        ,coalesce(t4.latest_dpd_eod_spl, -9999)                      as     latest_dpd_eod_spl
        ,coalesce(t7.days_after_first_due_date_spl, -9999)           as days_after_first_due_date_spl
        ,coalesce(t5.days_after_first_due_date_spl_floating, -9999)  as days_after_first_due_date_spl_floating
        ,coalesce(t8.ever_max_dpd_sellerloan_core, -9999)            as ever_max_dpd_sellerloan_core
        ,coalesce(t8.last_bill_dpd_sellerloan_core,-9999)            as last_bill_dpd_sellerloan_core
        ,coalesce(t8.ever_max_dpd_30d_scl, -9999)                    as ever_max_dpd_30d_scl
        ,coalesce(t8.ever_max_dpd_90d_scl, -9999)                    as ever_max_dpd_90d_scl
        ,coalesce(t8.ever_max_dpd_180d_scl, -9999)                   as ever_max_dpd_180d_scl
        ,coalesce(t8.ever_max_dpd_360d_scl, -9999)                   as ever_max_dpd_360d_scl
from (
    select credit_user_id
            ,platform_user_id   as  shopee_user_id
    from credit_uc.dws_all_prod_${region}_uc_user_df
    where grass_date = '${ds}'
    and credit_user_id  is not null 
    and credit_user_id <> '' 
    and credit_user_id <> '0'
    group by credit_user_id, shopee_user_id
) t1 left join (
    select  credit_user_id
            ,count(case when historical_max_dpd>=30 then 1 else null end) as uui_dpd30_cluster_user_cnt
    from credit_mart.wide_spl_${region}_behavior_user_df 
    where grass_date ='${ds}'
    group by credit_user_id
) t2 
on t1.credit_user_id = t2.credit_user_id
left join (
    select credit_user_id
        ,max(max_dpd)   as sl_max_dpd_l12m_th
        ,max(case when dpd_month >= trunc(current_date - interval '6' month, 'MM') then max_dpd end) as sl_max_dpd_l6m_th
        ,max(case when dpd_month >= trunc(current_date - interval '3' month, 'MM') then max_dpd end) as sl_max_dpd_l3m_th
        ,max(case when dpd_month >= trunc(current_date - interval '1' month, 'MM') then max_dpd end) as sl_max_dpd_l1m_th 
    from (
        select  credit_user_id
                ,trunc(CAST(grass_date AS DATE), 'MM') AS dpd_month
                ,max(dpd) as max_dpd
        from    credit_mart.dws_scl_${region}_loan_repayment_df
        where   cast(grass_date as date) > current_date - interval '1' year
        and     total_amount_repayable > 0
        group by credit_user_id ,  trunc(CAST(grass_date AS DATE), 'MM')
    )
    group by credit_user_id
) t3
on t1.credit_user_id = t3.credit_user_id
left join (
    select credit_user_id              
            ,ever_max_dpd_chp           
            ,ever_max_dpd_30d_chp       
            ,ever_max_dpd_90d_chp       
            ,ever_max_dpd_180d_chp      
            ,ever_max_dpd_360d_chp      
            ,days_after_first_due_date_chp
            ,lastest_max_dpd_eod_120d_spl as latest_dpd_eod_spl      
    from credit_mart.dws_spl_${region}_user_risk_df
    where grass_date = '${ds}'
) t4
on t1.credit_user_id = t4.credit_user_id
left join (
    select credit_user_id
            ,lastest_max_dpd_eod_120d_bill as latest_dpd_eod_cashloan
            ,days_after_first_due_date_floating as days_after_first_due_date_spl_floating
    from    credit_mart.dws_bcl_${region}_user_risk_df
    where   grass_date = '${ds}'
) t5
on t1.credit_user_id = t5.credit_user_id
left join (
    select  credit_user_id
            ,historical_max_dpd_eod     as ever_max_dpd_cashloan_core
            ,last_bill_dpd              as last_bill_dpd_cashloan_core
            ,ever_max_dpd_180d          as ever_max_dpd_180d_cashloan
            ,ever_max_dpd_360d          as ever_max_dpd_360d_cashloan
            ,ever_max_dpd_30d           as ever_max_dpd_30d_bcl
            ,ever_max_dpd_90d           as ever_max_dpd_90d_bcl
            ,days_after_first_due_date  as days_after_first_due_date_cashloan
            ,days_after_first_due_date_floating as days_after_first_due_date_cashloan_floating
    from    credit_mart.dws_bcl_${region}_user_df
    where   grass_date = '${ds}'
) t6
on t1.credit_user_id = t6.credit_user_id
left join (
    select  credit_user_id
            ,historical_max_dpd_eod     as ever_max_dpd_spl_core
            ,last_bill_dpd              as last_bill_dpd_spl_core
            ,ever_max_dpd_180d          as ever_max_dpd_180d_spl
            ,ever_max_dpd_360d          as ever_max_dpd_360d_spl
            ,ever_max_dpd_30d           as ever_max_dpd_30d_spl
            ,ever_max_dpd_90d           as ever_max_dpd_90d_spl
            ,days_after_first_due_date  as days_after_first_due_date_spl
    from    credit_mart.dws_spl_${region}_user_df
    where   grass_date = '${ds}'
) t7
on t1.credit_user_id = t7.credit_user_id
left join (
    select  credit_user_id
            ,historical_max_dpd_eod as  ever_max_dpd_sellerloan_core
            ,last_bill_dpd          as  last_bill_dpd_sellerloan_core
            ,ever_max_dpd_30d       as  ever_max_dpd_30d_scl
            ,ever_max_dpd_90d       as  ever_max_dpd_90d_scl
            ,ever_max_dpd_180d      as  ever_max_dpd_180d_scl
            ,ever_max_dpd_360d      as  ever_max_dpd_360d_scl
    from    credit_mart.dws_scl_${region}_user_df
    where   grass_date = '${ds}'
) t8
on t1.credit_user_id = t8.credit_user_id
;