--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-04-17
-- Theme Domain：       platform_user_id
-- Description:         platform_user_id max dpd
-- Data Granularity:    
-- 变更历史：
-- update by zongyi.lu@shopee.com 1. bcl/scl改成instalment表  2.新增注释
--********************************************************************--

INSERT OVERWRITE TABLE ${SCHEMA}.ads_2cscore_id_user_dpd_df PARTITION (grass_date)
select
platform_user_id,
3 Product_type,
max(dpd) dpd,
grass_date
from credit_mart.dws_spl_id_bill_repayment_df
where grass_date between '${begin_ds}' and '${ds}'
group by platform_user_id,grass_date

union all
select
platform_user_id,
1 as product_type,
max(dpd) dpd,
grass_date
from credit_mart.dws_bcl_id_instalment_repayment_df
where grass_date between '${begin_ds}' and '${ds}'
and platform_user_id is not null
group by platform_user_id,grass_date

union all
select
platform_user_id,
2 as product_type,
max(dpd) dpd,
grass_date
from credit_mart.dws_scl_id_instalment_repayment_df
where grass_date between '${begin_ds}' and '${ds}'
and platform_user_id is not null
group by platform_user_id,grass_date

union all
select
platform_user_id,
4 Product_type,
max(dpd) dpd,
grass_date
from credit_mart.dwd_fes_id_instalment_repayment_df
where grass_date between '${begin_ds}' and '${ds}'
group by platform_user_id,grass_date
;