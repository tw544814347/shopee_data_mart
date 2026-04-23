drop table if exists risk.dwd_risk_user_biz_manage_ads_risk_th_bcl_ota_user_blacklist_df;
create external table if not exists ${SCHEMA}.dwd_risk_user_biz_manage_ads_risk_th_bcl_ota_user_blacklist_df
(
user_id	STRING,
status	STRING,
add_date STRING
)
partitioned by
(
grass_date string
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/ads/dwd_risk_user_biz_manage_ads_risk_th_bcl_ota_user_blacklist_df';



insert overwrite table ${SCHEMA}.dwd_risk_user_biz_manage_ads_risk_th_bcl_ota_user_blacklist_df partition(grass_date = '${grass_date}')
select user_id,
        status,
        add_date
from risk.ads_risk_th_bcl_ota_user_blacklist_df_monthly