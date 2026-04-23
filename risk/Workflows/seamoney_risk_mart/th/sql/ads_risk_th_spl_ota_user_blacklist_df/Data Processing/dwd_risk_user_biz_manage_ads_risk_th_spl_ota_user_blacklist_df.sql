-- drop table if exists risk.ads_risk_th_spl_ota_user_blacklist_df;
-- drop table if exists risk.dwd_risk_user_biz_manage_ads_risk_th_spl_ota_user_blacklist_df;
-- create external table if not exists ${SCHEMA}.dwd_risk_user_biz_manage_ads_risk_th_spl_ota_user_blacklist_df
-- (
-- user_id	STRING,
-- status	STRING,
-- add_date STRING
-- )
-- stored as orc tblproperties ("orc.compress"="zstd")
-- LOCATION '${HDFS_PATH}/ads/ads_risk_th_spl_ota_user_blacklist_df';



insert overwrite table ${SCHEMA}.dwd_risk_user_biz_manage_ads_risk_th_spl_ota_user_blacklist_df
select user_id,
        status,
        add_date
from ads_risk_th_spl_ota_user_blacklist_df_monthly


