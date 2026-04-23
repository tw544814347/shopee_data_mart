drop table if exists ${SCHEMA}.dwd_risk_mx_uw_circulo_inquiry_df;

create external table if not exists ${SCHEMA}.dwd_risk_mx_uw_circulo_inquiry_df(
    flow_no string comment ''
    ,user_id string comment ''
    ,request_date   string comment ''
    ,request_datetime   string comment ''
    ,request_id     string comment ''
    ,message_type   string comment ''
    ,message_description        string comment ''
    ,inquiry_date               string comment ''
    ,grantor_code               string comment ''
    ,grantor_name               string comment ''
    ,grantor_address            string comment ''
    ,grantor_telephone_number   string comment ''
    ,loan_type                  string comment ''
    ,currency                   string comment ''
    ,loan_amount                decimal(30, 10) comment ''
    ,liability_type             string comment ''
    ,address_id                 string comment ''
    ,service                    string comment ''
)
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd","orc.stripe.size"="268435456"
)
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_uw_circulo_inquiry_df/grass_region=MX';
msck repair table ${SCHEMA}.dwd_risk_mx_uw_circulo_inquiry_df;


