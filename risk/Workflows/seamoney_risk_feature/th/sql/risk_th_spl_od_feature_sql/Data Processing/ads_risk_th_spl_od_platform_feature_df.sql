--drop table if exists ${SCHEMA}.ads_risk_th_spl_od_platform_feature_df;
create table if not exists ${SCHEMA}.ads_risk_th_spl_od_platform_feature_df (
    platform_user_id string comment 'platform_user_id'
    ,user_bcard_credit_score_v30 double comment 'user_bcard_credit_score_v30'
    ,user_bcard_credit_score_v30_date string
)
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/ads/ads_risk_spl_od_platform_feature_df/grass_region=TH'
;
--msck repair table ${SCHEMA}.ads_risk_th_spl_od_platform_feature_df;


insert overwrite table ${SCHEMA}.ads_risk_th_spl_od_platform_feature_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t2.user_bcard_credit_score_v30
    ,t2.user_bcard_credit_score_v30_date
from
    (
        select
            platform_user_id
            ,shopee_age
        from ${SCHEMA}.dim_risk_th_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join (
        select
            platform_user_id
            ,cast(get_json_object(score, '$.score') as double) as user_bcard_credit_score_v30
            ,cast(get_json_object(score, '$.score_date') as string) as user_bcard_credit_score_v30_date
        from risk.dws_risk_user_score_df
        where
            grass_region = 'TH'
            and grass_date = '${grass_date}'
            and biz_type = 'user_bcard_credit_score'
            and model_type = '6term_dpd30_combine'
            and model_version = 'v3.0'
    ) t2 on t1.platform_user_id = t2.platform_user_id
;