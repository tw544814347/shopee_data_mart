-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-08-12
-- Theme Domain:        Anti-Fraud
-- Data Granularity:    
-- Description:         业务侧透传表，落切片+DQC
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-08-12 - chengguo.liu - 初始化
-- =============================================================================

drop table if exists risk.dwd_risk_user_biz_manage_rescbds_credit_prod_my__user_graph_linkage_info_df;
create external table if not exists risk.dwd_risk_user_biz_manage_rescbds_credit_prod_my__user_graph_linkage_info_df (
json_data string
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_feature/dwd/dwd_risk_user_biz_manage_rescbds_credit_prod_my__user_graph_linkage_info_df'
;
msck repair table risk.dwd_risk_user_biz_manage_rescbds_credit_prod_my__user_graph_linkage_info_df;

insert overwrite table risk.dwd_risk_user_biz_manage_rescbds_credit_prod_my__user_graph_linkage_info_df partition(grass_date = '${grass_date}')
select
to_json(struct (*)) as json_data
from rescbds_credit.rescbds_credit_prod_my__user_graph_linkage_info
where grass_date = (select max(grass_date) from rescbds_credit.rescbds_credit_prod_my__user_graph_linkage_info)
;