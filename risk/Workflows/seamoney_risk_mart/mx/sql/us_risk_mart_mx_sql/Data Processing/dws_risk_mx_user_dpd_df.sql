--********************************************************************--
-- Author:              siyuan.sun@shopee.com
-- Created Time:        2026-01-20 t58:30:00
-- Description:         This script is to add mart features ever_max_dpd_180d_spl; ever_max_dpd_180d_bcl; ever_max_dpd_90d_spl; ever_max_dpd_90d_bcl; and atest_dpd_eod_cashloan.
-- Data Granularity   
-- PRD             https://docs.google.com/spreadsheets/d/1Vy-no6z3CbCII6oMIgvQda8B1O_wDiypVJXTtvnufS8/edit?gid=0#gid=0      
-- Jira            https://jira.shopee.io/browse/SPFDT-59806 
-- History         siyuan.sun added the script for adding mart table dws dws_risk_mx_user_dpd_df with required featrues above.   
--********************************************************************--

create function if not exists format_time as 'com.shopee.seamoney.udf.FromTimeStamp'
;

drop table if exists risk.dws_risk_mx_user_dpd_df;
create table if not exists risk.dws_risk_mx_user_dpd_df
(
    credit_user_id              string comment 'credit user id'
    ,ever_max_dpd_180d_spl      bigint comment 'Maximum days past due in 180 days for SPL product'
    ,ever_max_dpd_180d_bcl      bigint comment 'Maximum days past due in 180 days for BCL product'
    ,ever_max_dpd_90d_spl       bigint comment 'Maximum days past due in 90 days for SPL product'
    ,ever_max_dpd_90d_bcl       bigint comment 'Maximum days past due in 90 days for BCL product'
    ,latest_dpd_eod_cashloan    bigint comment 'Latest maximum days past due at the end of day for cash loan (120d window)'
)   partitioned by (
    grass_date string 
) 
stored as orc 
tblproperties 
(
    "orc.compress" = "zstd"
    ,"orc.stripe.size" = "268635456"
)
location '${HDFS_PATH}/risk/ads/dws_risk_mx_user_dpd_df' 
;

msck repair table risk.dws_risk_mx_user_dpd_df;

insert overwrite table risk.dws_risk_mx_user_dpd_df partition (grass_date)
select  t1.credit_user_id 
        ,coalesce(t3.ever_max_dpd_180d, -9999) as ever_max_dpd_180d_spl
        ,coalesce(t2.ever_max_dpd_180d, -9999) as ever_max_dpd_180d_bcl
        ,coalesce(t3.ever_max_dpd_90d, -9999) as ever_max_dpd_90d_spl
        ,coalesce(t2.ever_max_dpd_90d, -9999) as ever_max_dpd_90d_bcl
        ,coalesce(t4.latest_dpd_eod_cashloan, -9999) as latest_dpd_eod_cashloan
        ,t1.grass_date
from    (
        select
            credit_user_id 
            ,grass_date
        from credit_uc.dws_all_prod_mx_uc_user_df
        where grass_date = '${ds}'
        and credit_user_id <> ''
        group by credit_user_id, grass_date
    ) t1 
left join (
    select  credit_user_id
            ,ever_max_dpd_90d
            ,ever_max_dpd_180d
            ,grass_date
    from    credit_mart.dws_bcl_mx_user_df -- bcl mx table including dpd features 
    where  grass_date = '${ds}'
) t2 
    on t1.credit_user_id = t2.credit_user_id
    and t1.grass_date = t2.grass_date 
left join (
    select  credit_user_id
            ,ever_max_dpd_90d
            ,ever_max_dpd_180d
            ,grass_date
    from    credit_mart.dws_spl_mx_user_df -- spl mx user table inlcuding dpd features 
    where grass_date = '${ds}'
    ) t3
    on t1.credit_user_id = t3.credit_user_id 
    and t1.grass_date = t3.grass_date 
left join 
    (
        select 
            credit_user_id            as credit_user_id
            ,lastest_max_dpd_eod_120d as latest_dpd_eod_cashloan
            ,grass_date               as grass_date
        from credit_mart.wide_bcl_mx_behavior_user_df -- behavior table with cashloan info including dpd_eod feature
        where grass_date = '${ds}'
    ) as t4
    on t1.credit_user_id = t4.credit_user_id and t1.grass_date = t4.grass_date
;
