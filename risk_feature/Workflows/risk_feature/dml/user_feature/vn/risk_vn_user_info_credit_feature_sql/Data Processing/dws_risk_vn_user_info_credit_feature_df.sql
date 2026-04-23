-- =============================================================================
-- Author:              chenyingying@shopee.com
-- Created Time:        2026-02-03
-- Theme Domain:        User Info Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-02-03 - chenyingying - 初始化
-- =============================================================================

--drop table if exists ${SCHEMA}.dws_risk_${region}_user_info_credit_feature_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_info_credit_feature_df
(
    credit_user_id                                      string         comment 'shopee user id'
    ,average_limit_utilization_90d_spl                  decimal(30,10) comment 'SPL average limit utilization in 90d'
    ,average_limit_utilization_180d_spl                 decimal(30,10) comment 'SPL average limit utilization in 180d'
    ,max_limit_utilization_90d_spl                      decimal(30,10) comment 'SPL max limit utilization in 90d'
    ,max_limit_utilization_180d_spl                     decimal(30,10) comment 'SPL max limit utilization in 180d'
    ,average_limit_utilization_90d_bcl                  decimal(30,10) comment 'BCL average limit utilization in 90d'
    ,average_limit_utilization_180d_bcl                 decimal(30,10) comment 'BCL average limit utilization in 180d'
    ,max_limit_utilization_90d_bcl                      decimal(30,10) comment 'BCL max limit utilization in 90d'
    ,max_limit_utilization_180d_bcl                     decimal(30,10) comment 'BCL max limit utilization in 180d'
    ,account_label                                      bigint         comment 'Account label identifier'
    ,credit_user_status                                 bigint         comment 'user status'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_info_credit_feature_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_user_info_credit_limit_df;


insert overwrite ${SCHEMA}.dws_risk_${region}_user_info_credit_feature_df partition(grass_date='${grass_date}')
select  t1.credit_user_id
        ,t2.average_limit_utilization_90d_spl 
        ,t2.average_limit_utilization_180d_spl
        ,t2.max_limit_utilization_90d_spl     
        ,t2.max_limit_utilization_180d_spl    
        ,t2.average_limit_utilization_90d_bcl 
        ,t2.average_limit_utilization_180d_bcl
        ,t2.max_limit_utilization_90d_bcl     
        ,t2.max_limit_utilization_180d_bcl 
        ,t3.account_label     
        ,t3.credit_user_status 
from (
    select credit_user_id
    from    credit_uc.dws_all_prod_${region}_uc_user_df
    where   grass_date = '${ds}'
    and     credit_user_id is not null
    and     credit_user_id <> '0'
    and     credit_user_id <> ''
    group by credit_user_id
)   t1
left join (
    select  credit_user_id
            ,average_limit_utilization_90d_spl 
            ,average_limit_utilization_180d_spl
            ,max_limit_utilization_90d_spl     
            ,max_limit_utilization_180d_spl    
            ,average_limit_utilization_90d_bcl 
            ,average_limit_utilization_180d_bcl
            ,max_limit_utilization_90d_bcl     
            ,max_limit_utilization_180d_bcl 
    from    risk_feature.dws_risk_${region}_user_info_credit_limit_df
    where   grass_date = '${ds}'
) t2
on t1.credit_user_id = t2.credit_user_id
left join (
    select  credit_user_id
            ,account_label     
            ,credit_user_status 
    from    risk_feature.dws_risk_${region}_user_info_credit_activate_df
    where   grass_date = '${ds}'
) t3
on t1.credit_user_id = t3.credit_user_id