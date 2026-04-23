--drop table if exists ${SCHEMA}.ads_risk_br_spl_od_platform_feature_df;
create external table if not exists ${SCHEMA}.ads_risk_br_spl_od_platform_feature_df (
    platform_user_id string
    ,user_bcard_credit_score_v20 double
    ,is_plm_neg_action bigint
    ,is_plm_incre_control bigint
)
partitioned by
    (grass_date string comment 'YYYY-MM-dd') stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/ads/ads_risk_spl_od_platform_feature_df/grass_region=BR'
;
--msck repair table ${SCHEMA}.ads_risk_br_spl_od_platform_feature_df;

insert overwrite table ${SCHEMA}.ads_risk_br_spl_od_platform_feature_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t2.user_bcard_credit_score_v20
    ,t3.is_plm_neg_action
    ,t4.is_plm_incre_control
from
    (
        select
            user_id as platform_user_id
        from mp_user.dim_user__reg_s0_live
        where
            tz_type = 'local'
            and grass_region = 'BR'
            and grass_date = '${grass_date}'
    ) t1
    left join (
        select
            platform_user_id
            ,cast(get_json_object(score, '$.score') as double) as user_bcard_credit_score_v20
        from risk.dws_risk_user_score_df
        where
            grass_region = 'BR'
            and grass_date = '${grass_date}'
            and biz_type = 'user_bcard_credit_score'
            and model_type = '1term_dpd30'
            and model_version = 'v2.0'
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select
            userid as platform_user_id
            ,1 as is_plm_neg_action
        from smcdrisk_policy.br_spl_postloan_negative_user_list_tab
        where datediff('${smd_grass_date}', action_date) <= 180
        group by userid
    ) t3 on t1.platform_user_id = t3.platform_user_id
    left join (
        select
            userid as platform_user_id
            ,1 as is_plm_incre_control
        from smcdrisk_policy.br_spl_plm_incre_control_list
        where datediff('${smd_grass_date}', release_date) <= 30
        group by userid
    ) t4 on t1.platform_user_id = t4.platform_user_id
where
    (
        t2.user_bcard_credit_score_v20 <> -999999.0
        or t3.is_plm_neg_action is not null
        or t4.is_plm_incre_control is not null
    )
;