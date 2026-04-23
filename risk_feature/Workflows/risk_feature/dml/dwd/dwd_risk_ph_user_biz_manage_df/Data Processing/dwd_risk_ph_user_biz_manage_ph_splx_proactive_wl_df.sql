-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-08-20
-- Theme Domain:        user biz manage table sync
-- Data Granularity:    
-- Description:         业务侧透传表，落切片+DQC
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-08-20 - chengguo.liu - 初始化
-- =============================================================================

--drop table if exists ${SCHEMA}.dwd_risk_${region}_user_biz_manage_${biz_manage_table_name}_df;
create external table if not exists ${SCHEMA}.dwd_risk_${region}_user_biz_manage_${biz_manage_table_name}_df (
json_data string
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_feature/dwd/dwd_risk_${region}_user_biz_manage_${biz_manage_table_name}_df'
;
--msck repair table ${SCHEMA}.dwd_risk_${region}_user_biz_manage_${biz_manage_table_name}_df;

insert overwrite table ${SCHEMA}.dwd_risk_${region}_user_biz_manage_${biz_manage_table_name}_df partition(grass_date = '${grass_date}')
select
to_json(struct (*)) as json_data
from ${biz_manage_table_schema}.${biz_manage_table_name}
;