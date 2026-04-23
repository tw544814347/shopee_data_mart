-- =============================================================================
-- Author:              chenyingying@shopee.com
-- Created Time:        2026-02-03
-- Theme Domain:        User Info Limit Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-02-03 - chenyingying - 初始化
-- =============================================================================

--drop table if exists ${SCHEMA}.dws_risk_${region}_user_info_credit_limit_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_info_credit_limit_df
(
    credit_user_id                                      string         comment 'shopee user id'
    ,average_limit_utilization_90d_spl               decimal(30,10) comment 'SPL average limit utilization in 90d'
    ,average_limit_utilization_180d_spl              decimal(30,10) comment 'SPL average limit utilization in 180d'
    ,max_limit_utilization_90d_spl                   decimal(30,10) comment 'SPL max limit utilization in 90d'
    ,max_limit_utilization_180d_spl                  decimal(30,10) comment 'SPL max limit utilization in 180d'
    ,average_limit_utilization_90d_bcl               decimal(30,10) comment 'BCL average limit utilization in 90d'
    ,average_limit_utilization_180d_bcl              decimal(30,10) comment 'BCL average limit utilization in 180d'
    ,max_limit_utilization_90d_bcl                   decimal(30,10) comment 'BCL max limit utilization in 90d'
    ,max_limit_utilization_180d_bcl                  decimal(30,10) comment 'BCL max limit utilization in 180d'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_info_credit_limit_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_user_info_credit_limit_df;



create or replace temporary view tmp_spl_vn_behavior_user as
select
credit_user_id
,sum(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_spl else 0 end)      as total_limit_utilization_90d_spl
,sum(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_spl else 0 end)     as total_limit_utilization_180d_spl
,sum(case when grass_date>=date_sub('${ds}',90) then 1 else 0 end)                                 as grass_date_cnt_90d_spl
,sum(case when grass_date>=date_sub('${ds}',180) then 1 else 0 end)                                as grass_date_cnt_180d_spl
,max(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_spl else 0 end)      as max_limit_utilization_90d_spl
,max(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_spl else 0 end)     as max_limit_utilization_180d_spl
from (
select 
    credit_user_id                     as credit_user_id
    ,((COALESCE(common_perm_used_credit_amount,0))+(COALESCE(common_temp_used_credit_amount,0))+(COALESCE(installment_perm_used_credit_amount,0))                            
        +(COALESCE(common_perm_frozen_credit_amount,0))+(COALESCE(common_temp_frozen_credit_amount,0))+
        (COALESCE(installment_perm_frozen_credit_amount,0))
     )                  
     /
     ((COALESCE(common_perm_credit_limit,0))+(COALESCE(common_temp_credit_limit,0))+(COALESCE(installment_perm_credit_limit,0))
     )      as total_limit_util_spl
    ,grass_date                         as grass_date
from credit_mart.dws_spl_vn_account_df
where coalesce(common_perm_credit_limit,0) + coalesce(common_temp_credit_limit,0) + coalesce(installment_perm_credit_limit,0) > 0 
and biz_type = 3
and grass_date >=date_sub('${ds}',180)
) a 
group by credit_user_id
;

create or replace temporary view tmp_bcl_vn_behavior_user as
select
credit_user_id
,sum(case when grass_date>=date_sub('${ds}',90) then total_limit_util_bcl else 0 end)      as total_limit_utilization_90d_bcl
,sum(case when grass_date>=date_sub('${ds}',180) then total_limit_util_bcl else 0 end)     as total_limit_utilization_180d_bcl
,sum(case when grass_date>=date_sub('${ds}',90) then 1 else 0 end)                         as grass_date_cnt_90d_bcl
,sum(case when grass_date>=date_sub('${ds}',180) then 1 else 0 end)                        as grass_date_cnt_180d_bcl
,max(case when grass_date>=date_sub('${ds}',90) then total_limit_util_bcl else 0 end)      as max_limit_utilization_90d_bcl
,max(case when grass_date>=date_sub('${ds}',180) then total_limit_util_bcl else 0 end)     as max_limit_utilization_180d_bcl
from (
select 
    credit_user_id                     as credit_user_id
    ,((COALESCE(common_perm_used_credit_amount,0))+(COALESCE(common_temp_used_credit_amount,0))
        +(COALESCE(common_perm_frozen_credit_amount,0))+(COALESCE(common_temp_frozen_credit_amount,0))
     )
     /
     ((COALESCE(common_perm_credit_limit,0))+(COALESCE(common_temp_credit_limit,0))
     )      as total_limit_util_bcl
    ,grass_date                         as grass_date
from credit_mart.dws_bcl_vn_account_df
where coalesce(common_perm_credit_limit,0) + coalesce(common_temp_credit_limit,0) > 0
and biz_type = 1
and grass_date >=date_sub('${grass_date}',180)
) a 
group by credit_user_id
;

insert overwrite ${SCHEMA}.dws_risk_${region}_user_info_credit_limit_df partition (grass_date = '${ds}')
select t1.credit_user_id
        ,t2.average_limit_utilization_in_90d_spl 
        ,t2.average_limit_utilization_in_180d_spl
        ,t2.max_limit_utilization_in_90d_spl     
        ,t2.max_limit_utilization_in_180d_spl    
        ,t3.average_limit_utilization_in_90d_bcl 
        ,t3.average_limit_utilization_in_180d_bcl
        ,t3.max_limit_utilization_in_90d_bcl     
        ,t3.max_limit_utilization_in_180d_bcl 
from    (
    select credit_user_id
    from    credit_uc.dws_all_prod_vn_uc_user_df
    where   grass_date = '${ds}'
    and     credit_user_id <> ''
    and     credit_user_id is not null
    and     credit_user_id <> '0'
    group by credit_user_id
)   t1
left join (
    select  credit_user_id
            ,total_limit_utilization_90d_spl / grass_date_cnt_90d_spl as average_limit_utilization_in_90d_spl
            ,total_limit_utilization_180d_spl / grass_date_cnt_180d_spl as average_limit_utilization_in_180d_spl
            ,max_limit_utilization_90d_spl  as max_limit_utilization_in_90d_spl
            ,max_limit_utilization_180d_spl as max_limit_utilization_in_180d_spl
    from tmp_spl_vn_behavior_user

) t2
on t1.credit_user_id = t2.credit_user_id
left join (
    select  credit_user_id
            ,total_limit_utilization_90d_bcl / grass_date_cnt_90d_bcl as average_limit_utilization_in_90d_bcl
            ,total_limit_utilization_180d_bcl / grass_date_cnt_180d_bcl as average_limit_utilization_in_180d_bcl
            ,max_limit_utilization_90d_bcl  as max_limit_utilization_in_90d_bcl
            ,max_limit_utilization_180d_bcl as max_limit_utilization_in_180d_bcl
    from tmp_bcl_vn_behavior_user
) t3
on t1.credit_user_id = t3.credit_user_id