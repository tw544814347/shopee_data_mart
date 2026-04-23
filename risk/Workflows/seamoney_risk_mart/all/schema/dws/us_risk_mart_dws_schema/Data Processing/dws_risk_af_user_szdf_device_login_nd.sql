drop table if exists ${SCHEMA}.dws_risk_af_user_szdf_device_login_nd;
create external table if not exists ${SCHEMA}.dws_risk_af_user_szdf_device_login_nd
(
     user_id             string comment 'user_id'
    ,szdf_device_id      string comment 'szdf'
    ,login_szdf_tags_3d  string comment 'last 3 days login szdf tags list'
    ,login_szdf_tags_7d  string comment 'last 7 days login szdf tags list'
    ,login_szdf_tags_14d string comment 'last 14 days login szdf tags list'
    ,login_szdf_tags_30d string comment 'last 30 days login szdf tags list'
)
comment 'fraud user login info'
partitioned by
(
    grass_region   string         comment         'partition key'
    ,grass_date     string         comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_af_user_szdf_device_login_nd';
msck repair table ${SCHEMA}.dws_risk_af_user_szdf_device_login_nd;