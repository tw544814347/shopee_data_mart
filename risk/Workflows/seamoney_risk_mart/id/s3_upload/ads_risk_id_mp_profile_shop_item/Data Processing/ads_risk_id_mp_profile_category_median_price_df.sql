--********************************************************************--
-- Author:              nuo.chen@shopee.com
-- Created Time:        2026-02-25
-- Theme Domain：       
-- Description:         新增profile计算价格中位数
-- Data Granularity:    item_category
-- 文档:                 https://casement.scredit.io/78703/requirement?jiraKey=SPFDT-60500
-- 注意:                 SHCAME和SQL在一起, 新增字段记得解开drop + msck, 跑完后注释掉drop + msck (表分区多后会影响SLA)!!!              
-- 变更历史：             
-- 2026-02-25   chennuo    创建脚本
--********************************************************************--

-- drop table if exists ${SCHEMA}.ads_risk_id_mp_profile_category_median_price_df;
create external table if not exists ${SCHEMA}.ads_risk_id_mp_profile_category_median_price_df
(
    item_category                  string
    ,category_median_price          decimal(25,10)
    ,region                         string
)partitioned by(
    grass_date                      string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION '${HDFS_PATH}/risk_mart/dwd/ads_risk_id_mp_profile_category_median_price_df'
;

-- msck repair table ${SCHEMA}.ads_risk_id_mp_profile_category_median_price_df;
-- refresh table ${SCHEMA}.ads_risk_id_mp_profile_category_median_price_df;


insert overwrite ${SCHEMA}.ads_risk_id_mp_profile_category_median_price_df partition (grass_date)
select 
    concat_ws('-', level1_global_be_category_id, level2_global_be_category_id, 
            level3_global_be_category_id, level4_global_be_category_id, 
            level5_global_be_category_id)       as item_category
    ,approx_percentile(price, 0.5)              as category_median_price
    ,'ID'                                       as region
    ,'${ds}'                                    as grass_date
from mp_item.dim_item__reg_s0_live
where grass_region = 'ID'
and grass_date = '${ds}'
group by 1