--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2026-02-05
-- Theme Domain：       id维表
-- Description:         platform uid 转 spp uid
-- Data Granularity:    
-- 变更历史： 
-- 空跑发 marker ，TW 暂时没有 sppuid 映射 
--********************************************************************--

create table if not exists ${SCHEMA}.dim_risk_${region}_sp_to_spp_id_mapping_df (
   shopee_user_id               STRING COMMENT 'shopee_user_id',
   shopeepay_user_id            STRING COMMENT 'shopeepay_user_id',
   create_date                  STRING COMMENT 'create_date'
) comment 'spuid mapping to sppuid dimension table' 
partitioned by (
    grass_date string comment 'Date of refreshed data'
) stored as orc tblproperties (
    "orc.compress" = "ZSTD"
) location '${HDFS_PATH}/dim/dim_risk_reg_sp_to_spp_id_mapping_df/grass_region=${REGION}'
;