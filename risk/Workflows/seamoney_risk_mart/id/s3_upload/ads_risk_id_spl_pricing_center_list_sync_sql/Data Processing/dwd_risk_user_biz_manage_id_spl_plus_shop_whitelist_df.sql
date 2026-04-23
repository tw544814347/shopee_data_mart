--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-07-23
-- Theme Domain：       pricing center shop whitelist
-- Description:         https://jira.shopee.io/browse/SPFDT-42323  (同时维护ads_risk_spl_pricing_center_list_index脚本，BE用于判断是否有数据更新)
-- Data Granularity:    
-- 变更历史：
--      update by 2024-05-08 zongyi.lu@shopee.com 1.https://confluence.shopee.io/pages/viewpage.action?pageId=2181906399
--      update by wei.tao 20251015 切换 hive 表名，但是外表路径不变，且发 ads 的 marker，因为下游同步 s3 依赖 marker，且 s3 文件名历史约定不好改
--********************************************************************--

DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_user_biz_manage_id_spl_plus_shop_whitelist_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_user_biz_manage_id_spl_plus_shop_whitelist_df
(
    data      string 
    ,datatype string 
)
comment 'spl_plus'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="ZSTD")
location '${HDFS_PATH}/risk_mart/dwd/ads_risk_id_spl_plus_pricing_center_shop_whitelist_df';

insert overwrite table risk.dwd_risk_user_biz_manage_id_spl_plus_shop_whitelist_df partition(grass_date='${grass_date}')
select 
data 
,datatype 
from smcdrisk_antifraud.id_spl_plus_shop_whitelist
;

create or replace view risk.ads_risk_id_spl_plus_pricing_center_shop_whitelist_df
as select * from risk.dwd_risk_user_biz_manage_id_spl_plus_shop_whitelist_df;

MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_user_biz_manage_id_spl_plus_shop_whitelist_df;