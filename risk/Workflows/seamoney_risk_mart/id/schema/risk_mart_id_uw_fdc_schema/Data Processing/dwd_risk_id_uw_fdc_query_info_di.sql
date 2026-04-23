DROP TABLE IF EXISTS ${schema}.dwd_risk_id_uw_fdc_query_info_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${schema}.dwd_risk_id_uw_fdc_query_info_di
(
    ktp_inquiry_time  STRING
    ,ktp_number       STRING
    ,inquiry_by       STRING
    ,inquiry_name     STRING
    ,member_id        STRING
    ,member_name      STRING
    ,inquiry_date     STRING
    ,status           STRING
    ,platform_user_id STRING
)
PARTITIONED BY (
    grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/dwd/dwd_risk_uw_fdc_query_info_di/grass_region=ID';
MSCK REPAIR TABLE ${schema}.dwd_risk_id_uw_fdc_query_info_di;
