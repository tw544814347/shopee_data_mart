-- drop table if exists ${SCHEMA}.ads_risk_br_openfinance_request_df;
create external table if not exists ${SCHEMA}.ads_risk_br_openfinance_request_df (
        flow_no                     string  comment 'flow no'
        ,shopee_user_id             string  comment 'shopee user id'
        ,cpf                        string  comment 'BR user id card no'
        ,request_date               string  comment 'request_date'
        ,request_time               string  comment 'request_time'
        ,feature_group              string  comment 'feature group'
        ,origin_data                string  comment 'origin data from risk input'
)
partitioned by
(
    category string comment 'feature category: transaction'
    ,grass_date string comment 'grass_date, partition key'
)
comment '
ensemble feature table for BR Open Finance Data
granularity: flow_no + shopee_user_id
'
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
)
location '${HDFS_PATH}/risk_mart/ads/ads_risk_openfinance_request_df/grass_region=BR/';

insert overwrite ${SCHEMA}.ads_risk_br_openfinance_request_df partition (category, grass_date)
select  flow_no
        ,shopee_user_id
        ,cpf
        ,request_date
        ,request_time
        ,feature_group
        ,origin_data
        ,category
        ,grass_date
from risk.ads_risk_br_openfinance_request_df
where grass_date = '${ds}'
