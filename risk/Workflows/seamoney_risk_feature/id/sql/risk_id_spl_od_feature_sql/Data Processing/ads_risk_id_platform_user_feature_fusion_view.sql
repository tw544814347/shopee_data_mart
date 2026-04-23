drop view if exists ${SCHEMA}.ads_risk_id_platform_user_feature_fusion_view;
create view if not exists ${SCHEMA}.ads_risk_id_platform_user_feature_fusion_view as
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