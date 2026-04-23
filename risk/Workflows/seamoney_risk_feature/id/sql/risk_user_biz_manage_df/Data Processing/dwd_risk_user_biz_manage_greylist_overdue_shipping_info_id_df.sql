-- =============================================================================
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-10-14
-- Theme Domain:        Anti-Fraud
-- Data Granularity:    
-- Description:         业务侧透传表，落切片+DQC
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-10-14 - wei.tao - 初始化
-- =============================================================================

drop table if exists risk.dwd_risk_user_biz_manage_greylist_overdue_shipping_info_id_df;
create external table if not exists risk.dwd_risk_user_biz_manage_greylist_overdue_shipping_info_id_df (
json_data string
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_feature/dwd/dwd_risk_user_biz_manage_greylist_overdue_shipping_info_id_df'
;
msck repair table risk.dwd_risk_user_biz_manage_greylist_overdue_shipping_info_id_df;

insert overwrite table risk.dwd_risk_user_biz_manage_greylist_overdue_shipping_info_id_df partition(grass_date = '${grass_date}')
select
to_json(struct (*)) as json_data
from smcdrisk_antifraud.greylist_overdue_shipping_info_id
;