-- =============================================================================
-- Author:              chenyingying@shopee.com
-- Created Time:        2026-02-10
-- Theme Domain:        User Info Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-02-10 - chenyingying - 初始化
-- =============================================================================

-- drop table if exists ${SCHEMA}.dws_risk_${region}_user_info_credit_feature_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_info_credit_feature_df

(
    credit_user_id                                      string         comment 'credit user id'
    ,average_limit_utilization_90d_spl                  decimal(30,10) comment 'SPL average limit utilization in 90d'
    ,average_limit_utilization_180d_spl                 decimal(30,10) comment 'SPL average limit utilization in 180d'
    ,max_limit_utilization_90d_spl                      decimal(30,10) comment 'SPL max limit utilization in 90d'
    ,max_limit_utilization_180d_spl                     decimal(30,10) comment 'SPL max limit utilization in 180d'
    ,average_limit_utilization_30d_spl                  decimal(30,10) comment 'SPL average limit utilization in 30d'
    ,average_limit_utilization_360d_spl                 decimal(30,10) comment 'SPL average limit utilization in 360d'
    ,max_limit_utilization_30d_spl                      decimal(30,10) comment 'SPL max limit utilization in 30d'
    ,max_limit_utilization_360d_spl                     decimal(30,10) comment 'SPL max limit utilization in 360d'
    ,dpd_freeze_date                                    string         comment 'dpd freeze date'
    ,dpd_freeze_datetime_ts                             bigint         comment 'dpd freeze datetime timestamp(s)'
    ,spl_uw_freeze_date                                 string         comment 'SPL dpd freeze date'
    ,spl_uw_freeze_datetime_ts                          bigint         comment 'SPL dpd freeze date timestamp(s)'
    ,bcl_uw_freeze_date                                 string         comment 'BCL dpd freeze date'
    ,bcl_uw_freeze_datetime_ts                          bigint         comment 'BCL dpd freeze date timestamp(s)' 
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_info_credit_feature_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_info_credit_feature_df;




insert overwrite ${SCHEMA}.dws_risk_${region}_user_info_credit_feature_df partition (grass_date = '${ds}')
select  t1.credit_user_id
        ,t2.average_limit_utilization_90d_spl 
        ,t2.average_limit_utilization_180d_spl
        ,t2.max_limit_utilization_90d_spl     
        ,t2.max_limit_utilization_180d_spl    
        ,t2.average_limit_utilization_30d_spl 
        ,t2.average_limit_utilization_360d_spl
        ,t2.max_limit_utilization_30d_spl     
        ,t2.max_limit_utilization_360d_spl    
        ,t3.dpd_freeze_date          
        ,t3.dpd_freeze_datetime_ts   
        ,t3.spl_uw_freeze_date       
        ,t3.spl_uw_freeze_datetime_ts
        ,t3.bcl_uw_freeze_date       
        ,t3.bcl_uw_freeze_datetime_ts
from    (
    select  credit_user_id
    from    credit_uc.dws_all_prod_br_uc_user_df
    where   grass_date='${ds}'
    and     credit_user_id <> '0'
    and     credit_user_id is not null
    and     credit_user_id <> ''
    group by credit_user_id
) t1
left join (
    select  credit_user_id
            ,average_limit_utilization_90d_spl
            ,average_limit_utilization_180d_spl
            ,max_limit_utilization_90d_spl
            ,max_limit_utilization_180d_spl
            ,average_limit_utilization_30d_spl
            ,average_limit_utilization_360d_spl
            ,max_limit_utilization_30d_spl
            ,max_limit_utilization_360d_spl
    from    ${SCHEMA}.dws_risk_${region}_user_info_credit_limit_df
    where   grass_date = '${ds}'
) t2
on t1.credit_user_id = t2.credit_user_id
left join (
    select  credit_user_id
            ,dpd_freeze_date          
            ,dpd_freeze_datetime_ts   
            ,spl_uw_freeze_date       
            ,spl_uw_freeze_datetime_ts
            ,bcl_uw_freeze_date       
            ,bcl_uw_freeze_datetime_ts
    from    ${SCHEMA}.dws_risk_${region}_user_info_credit_freeze_df
    where   grass_date = '${ds}'
) t3
on t1.credit_user_id = t3.credit_user_id