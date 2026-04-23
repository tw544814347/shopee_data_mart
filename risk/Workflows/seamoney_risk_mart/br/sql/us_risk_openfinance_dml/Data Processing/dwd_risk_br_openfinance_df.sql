--********************************************************************--
-- Author:              huangyue@shopee.com
-- Created Time:        2025-09-15T14:00:00
-- Theme Domain：       openfinance data
-- Description:         openfinance data receive, 聚合为risk开发的input feature格式
-- Data Granularity:    cpf
-- 变更历史：
--********************************************************************--

-- drop table if exists ${SCHEMA}.dwd_risk_br_openfinance_df;
create external table if not exists ${SCHEMA}.dwd_risk_br_openfinance_df (
    shopee_user_id      string comment 'Shopee user id'
    ,cpf                string comment 'BR user id card no'
    ,request_date       string comment 'request date'
    ,request_time       string comment 'request time'
    ,data               string comment 'grouped identity data, as risk feature input'
)
partitioned by
(
    feature_name string comment 'risk feature name: get_open_finance_personal_xx_data'
    ,grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd","orc.stripe.size"="268435456"
)
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_openfinance_df/grass_region=BR';
msck repair table ${SCHEMA}.dwd_risk_br_openfinance_df;