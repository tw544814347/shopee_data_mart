-- 20250616 added by wei.tao 新增 SPP 相关标识字段 JIRA：https://jira.shopee.io/browse/SPFDT-52751

drop table if exists ${SCHEMA}.dwd_risk_login_di;
create external table if not exists ${SCHEMA}.dwd_risk_login_di
(
    user_id bigint comment 'shopee user id'
    ,login_from string comment 'login from wh'
    ,is_device string comment 'is device: Y mobile phone device N pc or other platform'
    ,shopee_df string comment 'shopee original device fingerprint'
    ,shopee_device_id string comment 'shopee device id'
    ,tongdun_device_id string comment 'tongdun device fingerprint'
    ,is_login string comment 'is login: Y login today N not login today'
    ,login_ip string comment 'login device ip'
    ,login_timestamp bigint comment 'login timestamp'
    ,shopee_df_temper string comment 'shopee device fingerprint before temper'
    ,is_fingerprint_tempered int comment 'the fingerprint is tempered or not'
    ,is_root int comment 'is root or not'
    ,hash_shopee_df string comment 'hashed shopee device fingerprint'
    ,sz_dfp_device_id string
    ,is_spp_update string comment 'is spp new added'
    ,shopeepay_user_id string comment 'spp uid'
)
comment 'user login record'
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dwd/dwd_risk_login_di';
msck repair table ${SCHEMA}.dwd_risk_login_di;
