--drop table if exists ${SCHEMA}.ads_risk_id_spl_od_platform_feature_df;
create table if not exists ${SCHEMA}.ads_risk_id_spl_od_platform_feature_df (
    platform_user_id string comment 'platform_user_id'
    ,user_bcard_v3_score double comment 'user_level_bcard_v3_score'
    ,user_bcard_v3_user_overdue_tag bigint comment 'user_bcard_v3_user_overdue_tag'
    ,last_spl_increment_control_live_days_from_now bigint comment 'last_spl_increment_control_live_days_from_now'
)
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") 
    location '${HDFS_PATH}/risk_mart/ads/ads_risk_spl_od_platform_feature_df/grass_region=ID'
;
--msck repair table ${SCHEMA}.ads_risk_id_spl_od_platform_feature_df;

insert overwrite table ${SCHEMA}.ads_risk_id_spl_od_platform_feature_df partition (grass_date = '${grass_date}')
select
    platform_user_id
    ,user_bcard_v3_score
    ,user_bcard_v3_user_overdue_tag
    ,last_spl_increment_control_live_days_from_now
from ${SCHEMA}.dws_risk_id_user_metrics_biz_manage1_df
where grass_date = '${grass_date}'
and (
    user_bcard_v3_score <> -999999.0
    or user_bcard_v3_user_overdue_tag is not null
    or last_spl_increment_control_live_days_from_now is not null
)
;