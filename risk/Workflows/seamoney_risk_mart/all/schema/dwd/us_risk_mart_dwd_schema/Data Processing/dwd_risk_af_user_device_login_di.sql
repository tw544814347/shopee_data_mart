drop table if exists ${SCHEMA}.dwd_risk_af_user_device_login_di;
create external table if not exists ${SCHEMA}.dwd_risk_af_user_device_login_di
(
    user_id                  string comment 'shopee user id'
    ,szdf_device_id          string comment 'dfpinfosz__securitydeviceid'
    ,phone_no                string comment 'login_phone'
    ,login_date              string comment 'user login date (local)'
    ,is_fraud_tag            string comment '1-(fraud_tag_tab.type=1 and fraud_tag_tab.severity=1) or (fraud_tag_tab.type=2) 0-not'
    ,is_bad_tag              string comment '1-bad szdf, 0-not bad szdf'
    ,shopee_df_plain         string comment 'spdf plain'
    ,hashed_shopee_df        string comment 'hash spdf'
    ,ipinfo_country_ip       string comment 'login ip country'
    ,login_timestamp         bigint comment 'login timestamp'
    ,dfpinfosz__tags         string comment 'szdf_tags'
    ,is_auto_login           string comment 'is_auto_login'
    ,client_ip               string comment 'client_ip'
    ,dfpinfosz__bssid        string comment 'dfpinfosz__bssid'
    ,ipinfo__city_ip         string comment 'login ip city'
)
comment 'fraud user login info'
partitioned by
(
    grass_region   string         comment         'partition key'
    ,grass_date     string         comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_af_user_device_login_di';
msck repair table ${SCHEMA}.dwd_risk_af_user_device_login_di;

