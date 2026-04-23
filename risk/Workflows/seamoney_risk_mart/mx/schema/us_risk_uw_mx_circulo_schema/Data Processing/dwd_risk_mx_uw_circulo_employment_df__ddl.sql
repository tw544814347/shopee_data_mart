drop table if exists ${SCHEMA}.dwd_risk_mx_uw_circulo_employment_df;

create external table if not exists ${SCHEMA}.dwd_risk_mx_uw_circulo_employment_df(
    flow_no string comment ''
    ,user_id string comment ''
    ,request_date   string comment ''
    ,request_datetime   string comment ''
    ,request_id     string comment ''
    ,message_type   string comment ''
    ,message_description    string comment ''
    ,company_name   string comment ''
    ,address        string comment ''
    ,town           string comment ''
    ,district       string comment ''
    ,city           string comment ''
    ,state          string comment ''
    ,zipcode        string comment ''
    ,telephone_number       string comment ''
    ,telephone_extension    string comment ''
    ,fax_number             string comment ''
    ,position               string comment ''
    ,hiring_date            string comment ''
    ,currency               string comment ''
    ,monthly_salary         string comment ''
    ,last_employment_date   string comment ''
    ,verification_date      string comment ''
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
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_uw_circulo_employment_df/grass_region=MX';
msck repair table ${SCHEMA}.dwd_risk_mx_uw_circulo_employment_df;


