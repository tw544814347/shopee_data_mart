
-- drop table if exists ${SCHEMA}.dwd_risk_br_openfinance_df;
create external table if not exists ${SCHEMA}.dwd_risk_br_openfinance_request_df (
    flow_no              string comment 'Online feature service flow no'
    ,shopee_user_id      string comment 'Shopee user id'
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
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_openfinance_request_df/grass_region=BR';
msck repair table ${SCHEMA}.dwd_risk_br_openfinance_request_df;