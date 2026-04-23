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

drop table if exists risk.dwd_risk_user_biz_manage_ph_offus_to_de_store_id_and_tier_df_df;
create external table if not exists risk.dwd_risk_user_biz_manage_ph_offus_to_de_store_id_and_tier_df_df (
json_data string
) partitioned by (
    grass_date string comment "YYYY-MM-DD"
) stored as orc tblproperties (
    "orc.compress" = "zstd"
) location '${HDFS_PATH}/risk_feature/dwd/dwd_risk_user_biz_manage_ph_offus_to_de_store_id_and_tier_df_df'
;
msck repair table risk.dwd_risk_user_biz_manage_ph_offus_to_de_store_id_and_tier_df_df;

insert overwrite table risk.dwd_risk_user_biz_manage_ph_offus_to_de_store_id_and_tier_df_df partition(grass_date = '${grass_date}')
select
to_json(struct (*)) as json_data
from smcdrisk_antifraud.ph_offus_to_de_store_id_and_tier_df
where grass_date = (select max(grass_date) from smcdrisk_antifraud.ph_offus_to_de_store_id_and_tier_df)
;