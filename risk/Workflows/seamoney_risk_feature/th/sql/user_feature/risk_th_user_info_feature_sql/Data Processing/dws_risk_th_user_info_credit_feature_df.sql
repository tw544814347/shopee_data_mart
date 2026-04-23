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

--drop table if exists ${SCHEMA}.dws_risk_${region}_user_info_credit_feature_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_info_credit_feature_df
(
    credit_user_id          string  comment 'credit user id'
    ,shopee_user_id         string  comment 'shopee user id'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_info_credit_feature_df/grass_region=${REGION}';
--msck repair table ${SCHEMA}.dws_risk_${region}_user_info_credit_feature_df;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_info_credit_feature_df partition (grass_date = '${grass_date}')
select t1.credit_user_id
from (
    select  credit_user_id
    from credit_uc.dws_all_prod_${region}_uc_user_df
    WHERE grass_date = '${ds}'
    AND credit_user_id IS NOT NULL 
    and credit_user_id <> ''
    and credit_user_id <> '0' 
) t1 
;