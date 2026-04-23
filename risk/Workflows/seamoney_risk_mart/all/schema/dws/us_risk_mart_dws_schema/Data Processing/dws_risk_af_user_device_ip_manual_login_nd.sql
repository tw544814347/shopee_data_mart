drop table if exists ${SCHEMA}.dws_risk_af_user_device_ip_manual_login_nd;
create external table if not exists ${SCHEMA}.dws_risk_af_user_device_ip_manual_login_nd
(
    user_id                  string comment 'shopee user id'
    ,md5_user_id             string comment 'shopee user id md5(2)'
    ,login_szdf_3d           string comment 'user login szdf in 3 d'
    ,login_szdf_7d           string comment 'user login szdf in 7 d'
    ,login_szdf_14d          string comment 'user login szdf in 14 d'
    ,login_ip_3d             string comment 'user login ip in 3 d'
    ,login_ip_7d             string comment 'user login ip in 7 d'
    ,login_ip_14d            string comment 'user login ip in 14 d'
    ,login_ipc_3d            string comment 'user login ipc in 3 d'
    ,login_ipc_7d            string comment 'user login ipc in 7 d'
    ,login_ipc_14d           string comment 'user login ipc in 14 d'
    ,login_bssid_3d          string comment 'user login bssid in 3 d'
    ,login_bssid_7d          string comment 'user login bssid in 7 d'
    ,login_bssid_14d         string comment 'user login bssid in 14 d'
)
comment 'fraud user login info'
partitioned by
(
    grass_region   string         comment         'partition key'
    ,grass_date     string         comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_af_user_device_ip_manual_login_nd';
msck repair table ${SCHEMA}.dws_risk_af_user_device_ip_manual_login_nd;