--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-10-20
-- Theme Domain：       Anti-fraud user overdue feature
-- Description:         https://jira.shopee.io/browse/SPFDT-56370
-- Data Granularity:    
-- Change Log:
--********************************************************************--
CREATE TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_af_device_user_agg_df (
    sz_dfp_device_id                       STRING         COMMENT 'sz_dfp_device_id',

    cnt_user_cpd1_credit_l24m              BIGINT         COMMENT 'cnt credit users with current overdue >=1 day in last 24 months',
    cnt_user_cpd1_credit_l12m              BIGINT         COMMENT 'cnt credit users with current overdue >=1 day in last 12 months',
    cnt_user_cpd1_credit_l6m               BIGINT         COMMENT 'cnt credit users with current overdue >=1 day in last 6 months',
    cnt_user_cpd1_credit_l3m               BIGINT         COMMENT 'cnt credit users with current overdue >=1 day in last 3 months',
    cnt_user_cpd1_credit_l1m               BIGINT         COMMENT 'cnt credit users with current overdue >=1 day in last 1 month',
    cnt_user_cpd7_credit_l24m              BIGINT         COMMENT 'cnt credit users with current overdue >=7 days in last 24 months',
    cnt_user_cpd7_credit_l12m              BIGINT         COMMENT 'cnt credit users with current overdue >=7 days in last 12 months',
    cnt_user_cpd7_credit_l6m               BIGINT         COMMENT 'cnt credit users with current overdue >=7 days in last 6 months',
    cnt_user_cpd7_credit_l3m               BIGINT         COMMENT 'cnt credit users with current overdue >=7 days in last 3 months',
    cnt_user_cpd7_credit_l1m               BIGINT         COMMENT 'cnt credit users with current overdue >=7 days in last 1 month',
    cnt_user_cpd30_credit_l24m             BIGINT         COMMENT 'cnt credit users with current overdue >=30 days in last 24 months',
    cnt_user_cpd30_credit_l12m             BIGINT         COMMENT 'cnt credit users with current overdue >=30 days in last 12 months',
    cnt_user_cpd30_credit_l6m              BIGINT         COMMENT 'cnt credit users with current overdue >=30 days in last 6 months',
    cnt_user_cpd30_credit_l3m              BIGINT         COMMENT 'cnt credit users with current overdue >=30 days in last 3 months',
    cnt_user_cpd30_credit_l1m              BIGINT         COMMENT 'cnt credit users with current overdue >=30 days in last 1 month',
    cnt_user_dpd30_l2y_limit90_credit_l24m BIGINT         COMMENT 'cnt credit users with max overdue >=30 days in last 2 years and limit >=90 within last 24 months',
    cnt_user_dpd30_l2y_limit90_credit_l12m BIGINT         COMMENT 'cnt credit users with max overdue >=30 days in last 2 years and limit >=90 within last 12 months',
    cnt_user_dpd30_l2y_limit90_credit_l6m  BIGINT         COMMENT 'cnt credit users with max overdue >=30 days in last 2 years and limit >=90 within last 6 months',
    cnt_user_dpd30_l2y_limit90_credit_l3m  BIGINT         COMMENT 'cnt credit users with max overdue >=30 days in last 2 years and limit >=90 within last 3 months',
    cnt_user_dpd30_l2y_limit90_credit_l1m  BIGINT         COMMENT 'cnt credit users with max overdue >=30 days in last 2 years and limit >=90 within last 1 month'
) 
COMMENT 'risk mart summary table'
PARTITIONED BY (grass_date string)
stored as orc tblproperties ("orc.compress" = "zstd")
location '${HDFS_PATH}/ads/dws_risk_${reg}_aio_af_device_user_agg_df/product_id = ${biz_type_code}'
;


create or replace temp view ${biz_type_string}_act_trx_login_agg as (
    select 
        sz_dfp_device_id,
        sum(has_cpd1) as cnt_user_cpd1_credit_l24m,
        sum(has_cpd1_12m) as cnt_user_cpd1_credit_l12m,
        sum(has_cpd1_6m) as cnt_user_cpd1_credit_l6m,
        sum(has_cpd1_3m) as cnt_user_cpd1_credit_l3m,
        sum(has_cpd1_1m) as cnt_user_cpd1_credit_l1m,
        sum(has_cpd7) as cnt_user_cpd7_credit_l24m,
        sum(has_cpd7_12m) as cnt_user_cpd7_credit_l12m,
        sum(has_cpd7_6m) as cnt_user_cpd7_credit_l6m,
        sum(has_cpd7_3m) as cnt_user_cpd7_credit_l3m,
        sum(has_cpd7_1m) as cnt_user_cpd7_credit_l1m,
        sum(has_cpd30) as cnt_user_cpd30_credit_l24m,
        sum(has_cpd30_12m) as cnt_user_cpd30_credit_l12m,
        sum(has_cpd30_6m) as cnt_user_cpd30_credit_l6m,
        sum(has_cpd30_3m) as cnt_user_cpd30_credit_l3m,
        sum(has_cpd30_1m) as cnt_user_cpd30_credit_l1m,
        sum(has_dpd30_l2y_limit90) as cnt_user_dpd30_l2y_limit90_credit_l24m,
        sum(has_dpd30_l2y_limit90_12m) as cnt_user_dpd30_l2y_limit90_credit_l12m,
        sum(has_dpd30_l2y_limit90_6m) as cnt_user_dpd30_l2y_limit90_credit_l6m,
        sum(has_dpd30_l2y_limit90_3m) as cnt_user_dpd30_l2y_limit90_credit_l3m,
        sum(has_dpd30_l2y_limit90_1m) as cnt_user_dpd30_l2y_limit90_credit_l1m
    from ${SCHEMA}.dws_risk_mid_${reg}_${risk_tab_biz_type}_af_device_user_info_df
    where grass_date = '${ds}' and sz_dfp_device_id is not null and sz_dfp_device_id <> ''
    group by sz_dfp_device_id
);

insert overwrite table ${SCHEMA}.dws_risk_${reg}_${risk_tab_biz_type}_af_device_user_agg_df partition(grass_date = '${ds}')
select 
  ${biz_type_string}_act_trx_login_agg.sz_dfp_device_id as sz_dfp_device_id
  ,cnt_user_cpd1_credit_l24m
  ,cnt_user_cpd1_credit_l12m
  ,cnt_user_cpd1_credit_l6m
  ,cnt_user_cpd1_credit_l3m
  ,cnt_user_cpd1_credit_l1m
  ,cnt_user_cpd7_credit_l24m
  ,cnt_user_cpd7_credit_l12m
  ,cnt_user_cpd7_credit_l6m
  ,cnt_user_cpd7_credit_l3m
  ,cnt_user_cpd7_credit_l1m
  ,cnt_user_cpd30_credit_l24m
  ,cnt_user_cpd30_credit_l12m
  ,cnt_user_cpd30_credit_l6m
  ,cnt_user_cpd30_credit_l3m
  ,cnt_user_cpd30_credit_l1m
  ,cnt_user_dpd30_l2y_limit90_credit_l24m
  ,cnt_user_dpd30_l2y_limit90_credit_l12m
  ,cnt_user_dpd30_l2y_limit90_credit_l6m
  ,cnt_user_dpd30_l2y_limit90_credit_l3m
  ,cnt_user_dpd30_l2y_limit90_credit_l1m
from ${biz_type_string}_act_trx_login_agg
DISTRIBUTE BY sz_dfp_device_id
;
