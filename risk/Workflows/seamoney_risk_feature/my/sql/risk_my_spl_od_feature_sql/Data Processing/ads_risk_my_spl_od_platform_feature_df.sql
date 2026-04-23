--drop table if exists ${SCHEMA}.ads_risk_my_spl_od_platform_feature_df;
create table if not exists ${SCHEMA}.ads_risk_my_spl_od_platform_feature_df (
    platform_user_id string comment 'platform_user_id'
    ,shopee_age        bigint comment 'How long a user has been with Shopee'
    ,user_bcard_v3_score double comment 'user_level_bcard_v3_score'
    ,user_bcard_v3_user_overdue_tag bigint comment 'user_bcard_v3_user_overdue_tag'
    ,is_bad_user bigint comment 'is_bad_user'
    ,last_spl_increment_control_live_days_from_now bigint comment 'last_spl_increment_control_live_days_from_now'
    ,is_low_limit_users bigint comment 'is_low_limit_users'
    ,is_recoverd_users bigint comment 'is_recoverd_users'
    ,ctos_model_v2 double comment 'ctos_model_v2'
    ,ctos_credit_card_max_limit double comment 'ctos_credit_card_max_limit'
)
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") 
    location '${HDFS_PATH}/risk_mart/ads/ads_risk_spl_od_platform_feature_df/grass_region=MY'
;
--msck repair table ${SCHEMA}.ads_risk_my_spl_od_platform_feature_df;

insert overwrite table ${SCHEMA}.ads_risk_my_spl_od_platform_feature_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t1.shopee_age
    ,t2.user_bcard_v3_score
    ,t2.user_bcard_v3_user_overdue_tag
    ,t2.is_bad_user
    ,t2.last_spl_increment_control_live_days_from_now
    ,t2.is_low_limit_users
    ,t2.is_recoverd_users
    ,t2.ctos_model_v2
    ,t2.ctos_credit_card_max_limit
from
    (
        select
            platform_user_id
            ,shopee_age
        from ${SCHEMA}.dim_risk_my_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join (
        select
            *
        from ${SCHEMA}.dws_risk_my_user_metrics_biz_manage_df
        where grass_date = '${grass_date}'
    ) t2 on t1.platform_user_id = t2.platform_user_id
;