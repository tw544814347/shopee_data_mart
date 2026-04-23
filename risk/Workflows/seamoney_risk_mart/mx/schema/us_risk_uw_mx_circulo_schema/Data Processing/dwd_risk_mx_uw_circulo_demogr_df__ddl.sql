drop table if exists ${SCHEMA}.dwd_risk_mx_uw_circulo_demogr_df;

create external table if not exists ${SCHEMA}.dwd_risk_mx_uw_circulo_demogr_df(
    flow_no     string comment ''
    ,user_id    string comment ''
    ,request_date   string comment ''
    ,request_datetime   string comment ''
    ,request_id string comment ''
    ,message_type   string comment ''
    ,message_description    string comment ''
    ,paternal_last_name string comment ''
    ,maternal_last_name string comment ''
    ,additional_last_name   string comment ''
    ,name   string comment ''
    ,date_of_birth  string comment ''
    ,rfc    string comment ''
    ,curp   string comment ''
    ,social_security_no string comment ''
    ,nationality    string comment ''
    ,residence  string comment ''
    ,martial_status string comment ''
    ,sex    string comment ''
    ,ife    string comment ''
    ,dependent_no   bigint comment ''
    ,date_of_death  string comment ''
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
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_uw_circulo_demogr_df/grass_region=MX';
msck repair table ${SCHEMA}.dwd_risk_mx_uw_circulo_demogr_df;

