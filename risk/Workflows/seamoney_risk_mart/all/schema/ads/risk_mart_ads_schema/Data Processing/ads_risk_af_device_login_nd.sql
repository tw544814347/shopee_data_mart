drop table if exists ${SCHEMA}.ads_risk_af_device_login_nd;
create external table if not exists ${SCHEMA}.ads_risk_af_device_login_nd
(
    szdf_device_id                     string comment 'dfpinfosz__securitydeviceid'
    ,login_user_3d                     string comment 'last 3 days login user_id'
    ,login_user_7d                     string comment 'last 6 days login user_id'
    ,login_user_30d                    string comment 'last 30 days login user_id'
    ,login_user_60d                    string comment 'last 60 days login user_id'
    ,login_user_90d                    string comment 'last 90 days login user_id'
    ,login_user_120d                   string comment 'last 120 days login user_id'
    ,login_user_150d                   string comment 'last 150 days login user_id'
    ,login_user_180d                   string comment 'last 180 days login user_id'
    ,login_fraud_tag_user_3d           string comment 'last 3 days login fraud_tag user_id'
    ,login_fraud_tag_user_7d           string comment 'last 6 days login fraud_tag user_id'
    ,login_fraud_tag_user_30d          string comment 'last 30 days login fraud_tag user_id'
    ,login_fraud_tag_user_60d          string comment 'last 60 days login fraud_tag user_id'
    ,login_fraud_tag_user_90d          string comment 'last 90 days login fraud_tag user_id'
    ,login_fraud_tag_user_120d         string comment 'last 120 days login fraud_tag user_id'
    ,login_fraud_tag_user_150d         string comment 'last 150 days login fraud_tag user_id'
    ,login_fraud_tag_user_180d         string comment 'last 180 days login fraud_tag user_id'
    ,login_user_bitmap64_3d            string comment 'last 3 days login user_id'
    ,login_user_bitmap64_7d            string comment 'last 6 days login user_id'
    ,login_user_bitmap64_30d           string comment 'last 30 days login user_id'
    ,login_user_bitmap64_60d           string comment 'last 60 days login user_id'
    ,login_user_bitmap64_90d           string comment 'last 90 days login user_id'
    ,login_user_bitmap64_120d          string comment 'last 120 days login user_id'
    ,login_user_bitmap64_150d          string comment 'last 150 days login user_id'
    ,login_user_bitmap64_180d          string comment 'last 180 days login user_id'
)
comment 'Tag: risk mart summary table'
partitioned by
(
    grass_region   string         comment         'partition key'
    ,grass_date     string         comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/ads/ads_risk_af_device_login_nd';
msck repair table ${SCHEMA}.ads_risk_af_device_login_nd;