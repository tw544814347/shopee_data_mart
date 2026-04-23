drop table if exists ${SCHEMA}.dwd_risk_mx_uw_circulo_address_df;

create external table if not exists ${SCHEMA}.dwd_risk_mx_uw_circulo_address_df(
    flow_no string comment ''
    ,user_id string comment ''
    ,request_date   string comment ''
    ,request_datetime   string comment ''
    ,request_id     string comment ''
    ,message_type   string comment ''
    ,message_description    string comment ''
    ,address    string comment ''
    ,town       string comment ''
    ,district   string comment ''
    ,city       string comment ''
    ,state      string comment ''
    ,zipcode    string comment ''
    ,residence_date string comment ''
    ,telephone_number   string comment ''
    ,address_type       string comment ''
    ,establishment_type string comment ''
    ,address_registration_date  string comment ''
    ,address_registration_type  string comment ''
    ,no_of_grantor_in_loan_registration string comment ''
    ,no_of_grantor_in_request   string comment ''
    ,address_id string comment ''
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
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_uw_circulo_address_df/grass_region=MX';
msck repair table ${SCHEMA}.dwd_risk_mx_uw_circulo_address_df;


