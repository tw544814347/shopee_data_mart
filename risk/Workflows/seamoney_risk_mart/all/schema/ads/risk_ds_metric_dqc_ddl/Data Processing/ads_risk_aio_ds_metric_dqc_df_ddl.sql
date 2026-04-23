--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-05-01
-- Theme Domain：       ds metric相关的拉链表监控
-- Description:         ds metric相关的拉链表监控
-- Data Granularity:    bill_id/instalment_id/loan_id
-- 变更历史
--********************************************************************--
drop table if exists ${SCHEMA}.ads_risk_aio_ds_metric_dqc_df;
create external table if not exists ${SCHEMA}.ads_risk_aio_ds_metric_dqc_df
(
dqc_type                  string              comment "Unique id of repay loancore生成唯一id"
,grass_region             string              comment "region"
,product_id               string              comment "product_id" 
) partitioned by (
grass_date string 
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_aio_ds_metric_dqc_df';
msck repair table ${SCHEMA}.ads_risk_aio_ds_metric_dqc_df;
