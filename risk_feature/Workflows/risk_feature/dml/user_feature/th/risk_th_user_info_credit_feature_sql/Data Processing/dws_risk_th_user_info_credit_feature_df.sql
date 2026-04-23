-- =============================================================================
-- Author:              huangyue
-- Created Time:        2026-01-16
-- Theme Domain:        User Base Info Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         额度利用率，冻结相关指标
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-15 - chengguo.liu - 初始化
-- =============================================================================

-- drop table if exists ${SCHEMA}.dws_risk_${region}_user_info_credit_feature_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_info_credit_feature_df
(
    credit_user_id          string  comment 'credit user id'
    ,dpd_freeze_date            string  comment 'user uw freeze date'
    ,dpd_freeze_datetime_ts     bigint  comment 'user uw freeze datetimestamp'
    ,spl_uw_freeze_date         string  comment 'spl uw freeze date'
    ,spl_uw_freeze_datetime_ts  bigint  comment 'spl uw freeze datetime timestamp'
    ,bcl_uw_freeze_date         string  comment 'bcl uw freeze date'
    ,bcl_uw_freeze_datetime_ts  bigint  comment 'bcl uw freeze datetime timestamp'
    ,average_limit_utilization_in_30d_spl               decimal(30,10) comment 'SPL average limit utilization in 30d'
    ,average_limit_utilization_in_90d_spl               decimal(30,10) comment 'SPL average limit utilization in 90d'
    ,average_limit_utilization_in_180d_spl              decimal(30,10) comment 'SPL average limit utilization in 180d'
    ,max_limit_utilization_in_30d_spl                   decimal(30,10) comment 'SPL max limit utilization in 30d'
    ,max_limit_utilization_in_90d_spl                   decimal(30,10) comment 'SPL max limit utilization in 90d'
    ,max_limit_utilization_in_180d_spl                  decimal(30,10) comment 'SPL max limit utilization in 180d'
    ,average_limit_utilization_in_30d_bcl               decimal(30,10) comment 'BCL max limit utilization in 30d'
    ,average_limit_utilization_in_90d_bcl               decimal(30,10) comment 'BCL average limit utilization in 90d'
    ,average_limit_utilization_in_180d_bcl              decimal(30,10) comment 'BCL average limit utilization in 180d'
    ,max_limit_utilization_in_30d_bcl                   decimal(30,10) comment 'BCL max limit utilization in 30d'
    ,max_limit_utilization_in_90d_bcl                   decimal(30,10) comment 'BCL max limit utilization in 90d'
    ,max_limit_utilization_in_180d_bcl                  decimal(30,10) comment 'BCL max limit utilization in 180d'
    ,average_limit_utilization_in_30d_chp               decimal(30,10) comment 'SPL-X/CHP average limit utilization in 30d'
    ,average_limit_utilization_in_90d_chp               decimal(30,10) comment 'SPL-X/CHP average limit utilization in 90d'
    ,average_limit_utilization_in_180d_chp              decimal(30,10) comment 'SPL-X/CHP average limit utilization in 180d'
    ,max_limit_utilization_in_30d_chp                   decimal(30,10) comment 'SPL-X/CHP max limit utilization in 30d'
    ,max_limit_utilization_in_90d_chp                   decimal(30,10) comment 'SPL-X/CHP max limit utilization in 90d'
    ,max_limit_utilization_in_180d_chp                  decimal(30,10) comment 'SPL-X/CHP max limit utilization in 180d'
    ,average_limit_utilization_in_30d_tl                decimal(30,10) comment 'TL average limit utilization in 30d'
    ,average_limit_utilization_in_90d_tl                decimal(30,10) comment 'TL average limit utilization in 90d'
    ,average_limit_utilization_in_180d_tl               decimal(30,10) comment 'TL average limit utilization in 180d'
    ,average_limit_utilization_in_360d_tl               decimal(30,10) comment 'TL average limit utilization in 360d'
    ,max_limit_utilization_in_30d_tl                    decimal(30,10) comment 'TL max limit utilization in 30d'
    ,max_limit_utilization_in_90d_tl                    decimal(30,10) comment 'TL max limit utilization in 90d'
    ,max_limit_utilization_in_180d_tl                   decimal(30,10) comment 'TL max limit utilization in 180d'
    ,max_limit_utilization_in_360d_tl                   decimal(30,10) comment 'TL max limit utilization in 360d'
    ,chp_uw_freeze_date                                 string  comment 'chp uw freeze date'
    ,chp_uw_freeze_datetime_ts                          bigint  comment 'chp uw freeze datetime timestamp'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_info_credit_feature_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_info_credit_feature_df;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_info_credit_feature_df partition (grass_date = '${ds}')
select t1.credit_user_id
        ,t2.dpd_freeze_date
        ,t2.dpd_freeze_datetime_ts
        ,t2.spl_uw_freeze_date       
        ,t2.spl_uw_freeze_datetime_ts
        ,t2.bcl_uw_freeze_date       
        ,t2.bcl_uw_freeze_datetime_ts
        ,t3.average_limit_utilization_in_30d_spl 
        ,t3.average_limit_utilization_in_90d_spl 
        ,t3.average_limit_utilization_in_180d_spl
        ,t3.max_limit_utilization_in_30d_spl     
        ,t3.max_limit_utilization_in_90d_spl     
        ,t3.max_limit_utilization_in_180d_spl    
        ,t3.average_limit_utilization_in_30d_bcl 
        ,t3.average_limit_utilization_in_90d_bcl 
        ,t3.average_limit_utilization_in_180d_bcl
        ,t3.max_limit_utilization_in_30d_bcl     
        ,t3.max_limit_utilization_in_90d_bcl     
        ,t3.max_limit_utilization_in_180d_bcl    
        ,t3.average_limit_utilization_in_30d_chp 
        ,t3.average_limit_utilization_in_90d_chp 
        ,t3.average_limit_utilization_in_180d_chp
        ,t3.max_limit_utilization_in_30d_chp     
        ,t3.max_limit_utilization_in_90d_chp     
        ,t3.max_limit_utilization_in_180d_chp    
        ,t3.average_limit_utilization_in_30d_tl  
        ,t3.average_limit_utilization_in_90d_tl  
        ,t3.average_limit_utilization_in_180d_tl 
        ,t3.average_limit_utilization_in_360d_tl 
        ,t3.max_limit_utilization_in_30d_tl      
        ,t3.max_limit_utilization_in_90d_tl      
        ,t3.max_limit_utilization_in_180d_tl     
        ,t3.max_limit_utilization_in_360d_tl 
        ,t2.chp_uw_freeze_date
        ,t2.chp_uw_freeze_datetime_ts
from (
    select  credit_user_id
    from credit_uc.dws_all_prod_${region}_uc_user_df
    WHERE grass_date = '${ds}'
    AND credit_user_id IS NOT NULL 
    and credit_user_id <> ''
    and credit_user_id <> '0' 
    group by credit_user_id
) t1 
left join (
    select  credit_user_id
            ,dpd_freeze_date               as   dpd_freeze_date
            ,dpd_freeze_datetime_ts        as   dpd_freeze_datetime_ts
            ,spl_uw_freeze_date            as   spl_uw_freeze_date
            ,spl_uw_freeze_datetime_ts     as   spl_uw_freeze_datetime_ts 
            ,bcl_uw_freeze_date            as   bcl_uw_freeze_date      
            ,bcl_uw_freeze_datetime_ts     as   bcl_uw_freeze_datetime_ts
            ,chp_uw_freeze_date            as   chp_uw_freeze_date
            ,chp_uw_freeze_datetime_ts     as   chp_uw_freeze_datetime_ts
    from    risk_feature.dws_risk_th_user_info_credit_freeze_df
    where   grass_date = '${ds}'
) t2
on t1.credit_user_id = t2.credit_user_id
left join (
    select  credit_user_id
            ,average_limit_utilization_in_30d_spl 
            ,average_limit_utilization_in_90d_spl 
            ,average_limit_utilization_in_180d_spl
            ,max_limit_utilization_in_30d_spl     
            ,max_limit_utilization_in_90d_spl     
            ,max_limit_utilization_in_180d_spl    
            ,average_limit_utilization_in_30d_bcl 
            ,average_limit_utilization_in_90d_bcl 
            ,average_limit_utilization_in_180d_bcl
            ,max_limit_utilization_in_30d_bcl     
            ,max_limit_utilization_in_90d_bcl     
            ,max_limit_utilization_in_180d_bcl    
            ,average_limit_utilization_in_30d_chp 
            ,average_limit_utilization_in_90d_chp 
            ,average_limit_utilization_in_180d_chp
            ,max_limit_utilization_in_30d_chp     
            ,max_limit_utilization_in_90d_chp     
            ,max_limit_utilization_in_180d_chp    
            ,average_limit_utilization_in_30d_tl  
            ,average_limit_utilization_in_90d_tl  
            ,average_limit_utilization_in_180d_tl 
            ,average_limit_utilization_in_360d_tl 
            ,max_limit_utilization_in_30d_tl      
            ,max_limit_utilization_in_90d_tl      
            ,max_limit_utilization_in_180d_tl     
            ,max_limit_utilization_in_360d_tl 
    from    risk_feature.dws_risk_th_user_info_credit_limit_df
    where   grass_date = '${ds}'    
)   t3
on t1.credit_user_id = t3.credit_user_id
;