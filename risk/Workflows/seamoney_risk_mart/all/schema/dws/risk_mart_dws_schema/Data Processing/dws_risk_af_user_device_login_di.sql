drop table if exists ${SCHEMA}.dws_risk_af_user_device_login_di;
create external table if not exists ${SCHEMA}.dws_risk_af_user_device_login_di
(
    user_id                  string comment 'shopee user id'
    ,szdf_device_id          string comment 'dfpinfosz__securitydeviceid'
    ,phone_no                string comment 'login_phone'
    ,login_date              string comment 'user login date (local)'
    ,is_fraud_tag            string comment '1-(fraud_tag_tab.type=1 and fraud_tag_tab.severity=1) or (fraud_tag_tab.type=2) 0-not'
    ,is_bad_tag              string comment '1-bad szdf, 0-not bad szdf'
)
comment '
Tag:risk summary table
fraud user login info'
partitioned by
(
    grass_region   string         comment         'partition key'
    ,grass_date     string         comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_af_user_device_login_di';
msck repair table ${SCHEMA}.dws_risk_af_user_device_login_di;