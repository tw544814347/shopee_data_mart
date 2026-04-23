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

drop table if exists risk.dwd_risk_user_biz_manage_id_external_data_slik_batch_inquiry_df;
create external table if not exists risk.dwd_risk_user_biz_manage_id_external_data_slik_batch_inquiry_df (
json_data string
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_feature/dwd/dwd_risk_user_biz_manage_id_external_data_slik_batch_inquiry_df'
;
msck repair table risk.dwd_risk_user_biz_manage_id_external_data_slik_batch_inquiry_df;

insert overwrite table risk.dwd_risk_user_biz_manage_id_external_data_slik_batch_inquiry_df partition(grass_date = '${grass_date}')
select
to_json(struct (*)) as json_data
from smcdrisk_policy.id_external_data_slik_batch_inquiry
where grass_date = (select max(grass_date) from smcdrisk_policy.id_external_data_slik_batch_inquiry)
;