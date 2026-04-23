-- 20250616 added by wei.tao 新增 SPP 相关标识字段 JIRA：https://jira.shopee.io/browse/SPFDT-52751
drop table if exists ${SCHEMA}.dws_risk_user_device_login_di;
create external table if not exists ${SCHEMA}.dws_risk_user_device_login_di
(
    user_id bigint comment 'shopee user id'
    ,shopee_df string comment 'shopee original df'
    ,tongdun_device_id string comment 'tongdun unique df'
    ,fst_login_timestamp bigint comment 'first login timestamp'
    ,lst_login_timestamp bigint comment 'last login timestamp'
    ,cnt_login_1d bigint comment 'a user login event on a device in 1d'
    ,hash_shopee_df string comment 'hashed shopee device fingerprint'
    ,sz_dfp_device_id string comment 'sz dfp device id'
    ,is_spp_update string comment 'is spp new added'
    ,shopeepay_user_id string comment 'spp uid' 
)
comment '
Tag:risk summary table
daily user device login accumulated table'
partitioned by
(
    tz_type string comment 'timezone type'
    ,grass_region string comment 'partition key'
    ,grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_device_login_di';
msck repair table ${SCHEMA}.dws_risk_user_device_login_di;