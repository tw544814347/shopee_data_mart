--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2026-02-05
-- Theme Domain：       id维表
-- Description:         platform uid 转 spp uid
-- Data Granularity:    
-- 变更历史： 
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

insert overwrite table ${SCHEMA}.dim_risk_${region}_sp_to_spp_id_mapping_df partition(grass_date='${grass_date}')
select 
    shopee_user_id
    ,shopeepay_user_id
    ,create_date
from (
    select
        shopee_user_id
        ,shopeepay_user_id
        ,create_date
        -- 按照flag(wallet/unknow/delete)顺序倒排,账户更新时间倒排,账户创建时间顺排)排序取第一条
        ,row_number() over(partition by shopee_user_id order by flag desc, update_time desc,create_time) as rn
    from shopeepay.mart_dwd_us_user_shopee_uid_mapping_ds__${region}
    where grass_date = '${ds}'
) spp 
where spp.rn=1