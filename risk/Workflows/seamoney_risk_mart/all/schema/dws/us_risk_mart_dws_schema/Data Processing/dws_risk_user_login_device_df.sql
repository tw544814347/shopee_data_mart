drop table if exists ${SCHEMA}.dws_risk_user_login_device_df;
create external table if not exists ${SCHEMA}.dws_risk_user_login_device_df
(
    user_id bigint comment 'shopee user id'
    ,fst_login_shopee_df_td string comment 'the shopee df of first login time'
    ,fst_login_shopee_device_id_td string comment 'the shopee device id of first login time'
    ,fst_login_hash_shopee_df_td string comment 'the hash shopee df of first login time'
    ,fst_login_tongdun_device_id_td string comment 'the tongdun device id of first login time'
    ,fst_login_timestamp_td bigint comment 'first timestamp login'
    ,lst_login_shopee_df_td string comment 'the shopee df of last login time'
    ,lst_login_shopee_device_id_td string comment 'the shopee device id of latest login timestamp'
    ,lst_login_hash_shopee_df_td string comment 'the hash shopee df id of latest login timestamp'
    ,lst_login_tongdun_device_id_td string comment 'the tongdun device id of latest login timestamp'
    ,lst_login_timestamp_td bigint comment 'last timestamp login'
    ,fst_login_sz_dfp_device_id_td string comment 'the sz device id of first login time'
    ,lst_login_sz_dfp_device_id_td string comment 'the sz device id of last login time'
)
comment 'Tag:risk summary table
user login accumulated table'
partitioned by
(
    tz_type        string          comment         'timezone type'
    ,grass_region   string          comment         'partition key'
    ,grass_date     string            comment         'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_login_device_df';
msck repair table ${SCHEMA}.dws_risk_user_login_device_df;