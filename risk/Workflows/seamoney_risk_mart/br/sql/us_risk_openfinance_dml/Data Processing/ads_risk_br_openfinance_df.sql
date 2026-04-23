-- drop table if exists ${SCHEMA}.ads_risk_br_openfinance_df;
create external table if not exists ${SCHEMA}.ads_risk_br_openfinance_df (
        shopee_user_id          string  comment 'shopee user id'
        ,cpf                    string  comment 'BR user id card no'
        ,request_date           string  comment 'request_date'
        ,request_time           string  comment 'request_time'
        ,feature_group          string  comment 'feature group'
        ,origin_data            string  comment 'origin data from risk input'
)
comment 'Tag:risk mart summary table'
partitioned by
(
    category string comment 'feature category'
    ,grass_date string comment 'grass_date, partition key'
)
stored as parquet tblproperties (
    "parquet.compress" = "SNAPPY",
    "parquet.stripe.size" = "2147483648"
)
location '${HDFS_PATH}/risk_mart/ads/ads_risk_openfinance_df/grass_region=BR/';

insert overwrite ${SCHEMA}.ads_risk_br_openfinance_df partition (category, grass_date)
select shopee_user_id
        ,cpf
        ,request_date
        ,request_time
        ,feature_group
        ,origin_data
        ,category
        ,grass_date
from risk.ads_risk_br_openfinance_df
where grass_date = '${ds}'

