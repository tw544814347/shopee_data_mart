--drop table if exists ${SCHEMA}.ads_risk_vn_spl_od_platform_feature_df;
create table if not exists ${SCHEMA}.ads_risk_vn_spl_od_platform_feature_df (
    platform_user_id string comment 'platform_user_id'
    ,user_bcard_v2_score double
    ,user_acard_v3_score double
)
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/ads/ads_risk_spl_od_platform_feature_df/grass_region=VN'
;
--msck repair table ${SCHEMA}.ads_risk_vn_spl_od_platform_feature_df;


insert overwrite table ${SCHEMA}.ads_risk_vn_spl_od_platform_feature_df partition(grass_date = '${bizdate}')
select  platform_user_id,
        max(if(model_version = 'v2.0' and biz_type='user_bcard_credit_score' and model_type = '3term_dpd30_combine', cast(get_json_object(score, '$.score') as double), null)) as user_bcard_v2_score,
        max(if(model_version = 'v3.0' and biz_type='spl_acard_credit_score' and model_type = '1term_dpd30_combine', cast(get_json_object(score, '$.score') as double), null)) as user_acard_v3_score
from risk.dws_risk_user_score_df
where grass_region = 'VN' and grass_date = '${bizdate}'
group by platform_user_id
;