--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-06-13
-- Theme Domain：       list
-- Description:         smcdrisk_antifraud 名单同步到s3,不需要跟其他project表有关联处理逻辑
-- Data Granularity:    
-- 变更历史：          
-- 2024-06-13 zongyi.lu 1.新增 Bureau  https://jira.shopee.io/browse/SPFDT-41292
--********************************************************************--

-- 由于需要频繁变更字段,因此直接将ddl放在dml中便于修改
drop table if exists ${SCHEMA}.ads_risk_sg_smcdrisk_antifraud_list_df;
create external table if not exists ${SCHEMA}.ads_risk_sg_smcdrisk_antifraud_list_df
(
    platform_user_id        string comment 'platform_user_id'
    ,id_no                  string comment 'id_no'
    ,customer_name          string comment 'customer_name'
    ,id_type                string comment 'id_type'
    ,product                string comment 'product'
)
partitioned by
(
    source_table_name string comment 'source table_name '
    ,grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_aio_smcdrisk_antifraud_list_df/grass_region=SG';
;

insert overwrite table ${SCHEMA}.ads_risk_sg_smcdrisk_antifraud_list_df partition(source_table_name,grass_date)
select 
platform_user_id  
,id_no            
,customer_name    
,id_type          
,product                    
,'smcdrisk_policy.sg_external_data_bureau_batch_inquiry' as source_table_name
,'${grass_date}' as grass_date 
from smcdrisk_policy.sg_external_data_bureau_batch_inquiry
where date='2024/8/5'
;

msck repair table ${SCHEMA}.ads_risk_sg_smcdrisk_antifraud_list_df;