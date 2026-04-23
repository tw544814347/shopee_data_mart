drop table if exists ${SCHEMA}.dws_risk_af_user_device_list_nd;
create external table if not exists ${SCHEMA}.dws_risk_af_user_device_list_nd
(
    platform_user_id         string comment 'platform_user_id'
    ,spdf_list               string comment 'dfpinfosz__securitydeviceid'
    ,szdf_list               string comment 'login_phone'
    ,web_szdf_list           string comment 'web szdf list'
)
comment 'platform user_id last190 days devicefingerprint list'
partitioned by
(
    grass_region   string         comment         'partition key'
    ,grass_date     string         comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_af_user_device_list_nd';
msck repair table ${SCHEMA}.dws_risk_af_user_device_list_nd;