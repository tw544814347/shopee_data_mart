drop table if exists ${SCHEMA}.dwd_risk_user_device_shopeepay_login_info_df;
create external table if not exists ${SCHEMA}.dwd_risk_user_device_shopeepay_login_info_df
(
    user_id                  string comment 'shopeepay user id'
    ,request_id              string comment 'request_id'
    ,szdf_device_id          string comment 'dfpinfosz__securitydeviceid'
    ,phone_no                string comment 'login_phone'
    ,login_date              string comment 'user login date (local)'
    ,is_bad_tag              string comment '1-bad szdf, 0-not bad szdf'
    ,shopee_df_plain         string comment 'spdf plain'
    ,hashed_shopee_df        string comment 'hash spdf'
    ,event_timestamp         bigint comment 'event_timestamp'
    ,login_timestamp         bigint comment 'login timestamp'
    ,dfpinfosz__tags         string comment 'szdf_tags'
    ,is_auto_login           string comment 'is_auto_login'
    ,login_channel           string comment 'login_channel'
    ,device_language         string comment 'device_language'
    ,platform_id             string comment 'platform_id'
    ,is_success              string comment 'is_success'
    ,login_result            string comment 'login_result'
    ,client_ip               string comment 'client_ip'
    ,dfpinfosz__bssid        string comment 'dfpinfosz__bssid'
    ,ipinfo_country_ip       string comment 'login ip country abbr'
    ,country_name            string comment 'login ip country full title'
    ,ipinfo__city_ip         string comment 'login ip city'
)
comment 'fraud user login info'
partitioned by
(
    grass_region   string         comment         'partition key'
    ,grass_date     string         comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_user_device_shopeepay_login_info_df';
msck repair table ${SCHEMA}.dwd_risk_user_device_shopeepay_login_info_df;

