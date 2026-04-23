--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-12-25
-- Theme Domain：       risk-feature
-- Description:        
-- Data Granularity:    credit_user_id
-- 变更历史：
--  v1 by wei.tao@shopee.com，jira:https://jira.shopee.io/browse/SPFDT-58774
--********************************************************************--
-- drop table if exists ${SCHEMA}.ads_behavior_sg_underwrting_feature_df;
create external table if not exists ${SCHEMA}.ads_behavior_sg_underwrting_feature_df (
    credit_user_id string
    ,is_limit_decrease_spl int comment 'limit decrease tag in spl'
)
partitioned by
    (grass_date string comment 'YYYY-MM-dd') stored as orc tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_feature/ads/ads_behavior_underwrting_feature_df/grass_region=SG'
;

insert overwrite table risk.ads_behavior_sg_underwrting_feature_df partition(grass_date='${grass_date}')
select
    credit_user_id
    ,max(if (biz_type = 3, is_limit_decrease, null)) as is_limit_decrease_spl
from
    (
        select
            credit_user_id
            ,case
                when tag_type is null then 0
                when tag_type = 9 then 1
                else 2
            end is_limit_decrease
            ,biz_type
        from credit_uc.dwd_uc_sg_user_platform_tag_info_tab_df
        where
            grass_date = '${ds}'
            and credit_user_id <> '0'
    ) tmp
group by credit_user_id