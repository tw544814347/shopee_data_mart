drop table if exists ${SCHEMA}.dws_risk_af_user_device_login_nd;
create external table if not exists ${SCHEMA}.dws_risk_af_user_device_login_nd
(
    user_id                 string comment 'user_id'
    ,login_szdf_3d          string comment 'last 3 days login szdf list'
    ,login_szdf_7d          string comment 'last 7 days login szdf list'
    ,login_szdf_14d         string comment 'last 14 days login szdf list'
    ,login_szdf_30d         string comment 'last 30 days login szdf list'
    ,login_szdf_60d         string comment 'last 60 days login szdf list'
    ,login_bad_szdf_3d      string comment 'last 3 days login bad szdf list'
    ,login_bad_szdf_7d      string comment 'last 7 days login bad szdf list'
    ,login_bad_szdf_14d     string comment 'last 14 days login bad szdf list'
    ,login_bad_szdf_30d     string comment 'last 30 days login bad szdf list'
    ,login_bad_szdf_60d     string comment 'last 60 days login bad szdf list'
    ,login_spdf_3d          string comment 'last 3 days login spdf list'
    ,login_spdf_7d          string comment 'last 7 days login spdf list'
    ,login_spdf_14d         string comment 'last 14 days login spdf list'
    ,login_spdf_30d         string comment 'last 30 days login spdf list'
    ,login_spdf_60d         string comment 'last 60 days login spdf list'
    ,login_country_3d       string comment 'last 3 days login country list'
    ,login_country_7d       string comment 'last 7 days login country list'
    ,login_country_14d      string comment 'last 14 days login country list'
    ,login_country_30d      string comment 'last 30 days login country list'
    ,login_country_60d      string comment 'last 60 days login country list'
    ,md5_user_id            string comment 'md5_user_id'
    ,login_city_3d          string comment 'last 3 days login city list'
    ,login_city_7d          string comment 'last 7 days login city list'
    ,login_city_14d         string comment 'last 14 days login city list'
    ,login_city_30d         string comment 'last 30 days login city list'
    ,login_city_60d         string comment 'last 60 days login city list'
)
comment 'fraud user login info'
partitioned by
(
    grass_region   string         comment         'partition key'
    ,grass_date     string         comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_af_user_device_login_nd';
msck repair table ${SCHEMA}.dws_risk_af_user_device_login_nd;