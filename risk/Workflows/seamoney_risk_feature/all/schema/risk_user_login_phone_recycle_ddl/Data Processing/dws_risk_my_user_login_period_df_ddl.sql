DROP TABLE IF EXISTS ${SCHEMA}.dws_risk_${region}_user_login_period_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dws_risk_${region}_user_login_period_df
(
    user_id                               string comment 'user_id'
    ,login_date                           string comment 'login_date'
    ,previous_login_date                  string comment 'previous_login_date'
    ,next_login_date                      string comment 'next_login_date'
    ,login_timestamp                      bigint comment 'login_date的最后一次登录'
    ,previous_login_timestamp             bigint comment 'previous_login_date的当前最后一次登录'
    ,next_login_timestamp                 bigint comment 'next_login_date的当前最后一次登录'
    ,login_shopee_device_id               array<string> comment 'login_date的string'
    ,previous_login_shopee_device_id      array<string> comment 'previous_login_date的string'
    ,next_login_shopee_device_id          array<string> comment 'next_login_date的string'
    ,login_from                           string comment '本次登录登录来源'
    ,previous_login_from                  string comment '上一次登录来源'
    ,next_login_from                      string comment '下一次登录来源'
)
PARTITIONED BY
(
	grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_feature/dws/dws_risk_aio_user_login_period_df/grass_region=${upper_region}';
MSCK REPAIR TABLE ${SCHEMA}.dws_risk_${region}_user_login_period_df;
