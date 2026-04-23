-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-01-14
-- Theme Domain:        Merchant GPS Info
-- Data Granularity:    merchant_identifier_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-14 - chengguo.liu - 初始化 - Jira: https://jira.shopee.io/browse/SPFDT-59104
-- =============================================================================

--drop table if exists ${SCHEMA}.ads_risk_vn_merchant_gps_info_df;
create external table if not exists ${SCHEMA}.ads_risk_vn_merchant_gps_info_df
(
    merchant_identifier_id string comment 'merchant identifier id'
    ,merchant_gps_list string comment 'merchant gps list'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/ads/ads_risk_reg_merchant_gps_info_df/grass_region=VN';
--msck repair table ${SCHEMA}.ads_risk_vn_merchant_gps_info_df;


insert overwrite table ${SCHEMA}.ads_risk_vn_merchant_gps_info_df partition (grass_date = '${grass_date}')
select
    merchant_identifier_id
    ,to_json(
        collect_set(
            named_struct('cluster_id', cluster_id, 'gps_list', array(lat, lng))
        )
    ) as merchant_gps_list
from (
    select
        bank_account_number as merchant_identifier_id
        ,cluster_id
        ,lat
        ,lng
    from rescbds_credit.vn_spp_merchant_location_cluster_p2p_bank_account_number
    where grass_date = (select max(grass_date) from rescbds_credit.vn_spp_merchant_location_cluster_p2p_bank_account_number)
    
    union all
    
    select
        bank_account_holder_name as merchant_identifier_id
        ,cluster_id
        ,lat
        ,lng
    from rescbds_credit.vn_spp_merchant_location_cluster_p2p_bank_account_holder_name
    where grass_date = (select max(grass_date) from rescbds_credit.vn_spp_merchant_location_cluster_p2p_bank_account_holder_name)
    
    union all
    
    select
        acquire_merchant_id as merchant_identifier_id
        ,cluster_id
        ,lat
        ,lng
    from rescbds_credit.vn_spp_merchant_location_cluster_acquire_merchant_id
    where grass_date = (select max(grass_date) from rescbds_credit.vn_spp_merchant_location_cluster_acquire_merchant_id)
    
    union all
    
    select
        acquire_terminal_label as merchant_identifier_id
        ,cluster_id
        ,lat
        ,lng
    from rescbds_credit.vn_spp_merchant_location_cluster_acquire_terminal_label
    where grass_date = (select max(grass_date) from rescbds_credit.vn_spp_merchant_location_cluster_acquire_terminal_label)
) t
group by merchant_identifier_id
;