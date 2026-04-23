--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-03-13
-- Theme Domain：       credit_user_id
-- Description:         credit_user_id max dpd
-- Data Granularity:    
-- 变更历史：
--********************************************************************--

DROP TABLE IF EXISTS ${SCHEMA}.ads_2cscore_id_credit_user_dpd_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_2cscore_id_credit_user_dpd_df
(
credit_user_id string
,product_type string
,dpd bigint
)
PARTITIONED BY
(
 grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_2cscore_credit_user_dpd_df/grass_region=${grass_region}';
MSCK REPAIR TABLE ${SCHEMA}.ads_2cscore_id_credit_user_dpd_df;

INSERT OVERWRITE TABLE ${SCHEMA}.ads_2cscore_id_credit_user_dpd_df PARTITION (grass_date)
select
credit_user_id,
3 product_type,
max(dpd) dpd,
grass_date
from credit_mart.dws_spl_id_bill_repayment_df
where grass_date between '${begin_ds}' and '${ds}'
group by credit_user_id,grass_date

union all
select
credit_user_id,
1 as product_type,
max(dpd) dpd,
grass_date
from credit_mart.dws_bcl_id_instalment_repayment_df
where grass_date between '${begin_ds}' and '${ds}'
and credit_user_id is not null
group by credit_user_id,grass_date

union all
select
credit_user_id,
2 as product_type,
max(dpd) dpd,
grass_date
from credit_mart.dws_scl_id_instalment_repayment_df
where grass_date between '${begin_ds}' and '${ds}'
and credit_user_id is not null
group by credit_user_id,grass_date

union all
select
credit_user_id,
4 product_type,
max(dpd) dpd,
grass_date
from credit_mart.dwd_fes_id_instalment_repayment_df
where grass_date between '${begin_ds}' and '${ds}'
group by credit_user_id,grass_date
;


