--drop table if exists ${SCHEMA}.ads_risk_ph_spl_od_platform_feature_df;
create table if not exists ${SCHEMA}.ads_risk_ph_spl_od_platform_feature_df (
    platform_user_id string comment 'platform_user_id'
    ,user_bcard_credit_score_v30 double
    ,user_bcard_credit_score_v30_date string
    ,is_spl_whitelisted bigint
    ,is_chp_status_active bigint
    ,is_chp_disbursed_l3m bigint
    ,is_af_blacklist bigint
    ,is_spl_incre_control bigint
    ,is_plm_decre_control bigint
    ,is_plm_freeze_control bigint
    ,is_af_blacklist_p30d bigint
    ,lending_high_m6_cnt bigint
)
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/ads/ads_risk_spl_od_platform_feature_df/grass_region=PH'
;
--msck repair table ${SCHEMA}.ads_risk_ph_spl_od_platform_feature_df;


uncache table if exists dws_risk_ph_user_score_df;
cache table dws_risk_ph_user_score_df options ('storageLevel' 'MEMORY_AND_DISK')
select
    platform_user_id
    ,biz_type
    ,model_type
    ,model_version
    ,score
from risk.dws_risk_user_score_df
where
    grass_region = 'PH'
    and grass_date = '${grass_date}'
;

insert overwrite table ${SCHEMA}.ads_risk_ph_spl_od_platform_feature_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t3.user_bcard_credit_score_v30
    ,t3.user_bcard_credit_score_v30_date
    ,t5.is_spl_whitelisted
    ,t6.is_chp_status_active
    ,t7.is_chp_disbursed_l3m
    ,t8.is_af_blacklist
    ,t8.is_spl_incre_control
    ,t8.is_plm_decre_control
    ,t8.is_plm_freeze_control
    ,t8.is_af_blacklist_p30d
    ,t8.lending_high_m6_cnt
from
    (
        select
            platform_user_id
            ,shopee_age
            -- from ${SCHEMA}.dim_risk_ph_user_info_df
        from risk.dim_risk_ph_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join (
        select
            user_id as platform_user_id
            ,shopee_registration_timestamp
        from risk.ads_risk_profile_user_df
        where
            grass_region = 'PH'
            and grass_date = '${grass_date}'
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select
            platform_user_id
            ,cast(get_json_object(score, '$.score') as double) as user_bcard_credit_score_v30
            ,cast(get_json_object(score, '$.score_date') as string) as user_bcard_credit_score_v30_date
        from dws_risk_ph_user_score_df
        where
            biz_type = 'user_bcard_credit_score'
            and model_type = '6term_dpd30_segment'
            and model_version = 'v3.0'
    ) t3 on t1.platform_user_id = t3.platform_user_id
    left join (
        select
            platform_user_id
            ,is_whitelist_spl is_spl_whitelisted
        from credit_uc.ads_ph_uc_user_list_wide_df
        where grass_date = '${grass_date}'
    ) t5 on t1.platform_user_id = t5.platform_user_id
    left join (
        select
            platform_user_id
            ,1 as is_chp_status_active
        from credit_mart.dws_spl_ph_account_df
        where
            grass_date = '${bizdate}'
            and biz_type = 7
            and one_time_credit_limit > 0
        group by platform_user_id
    ) t6 on t1.platform_user_id = t6.platform_user_id
    left join (
        select
            platform_user_id
            ,1 as is_chp_disbursed_l3m
        from credit_mart.dws_spl_ph_loan_repayment_df
        where
            grass_date = '${grass_date}'
            and biz_type = 7
            and disburse_time >= add_months('${smd_grass_date}', -3)
        group by platform_user_id
    ) t7 on t1.platform_user_id = t7.platform_user_id
    left join
    (
        select
            platform_user_id
            ,is_af_blacklist
            ,is_spl_incre_control
            ,is_plm_decre_control
            ,is_plm_freeze_control
            ,is_af_blacklist_p30d
            ,lending_high_m6_cnt
        from
        ${SCHEMA}.dws_risk_ph_user_metrics_biz_manage_df
        where grass_date = '${grass_date}'
    ) t8 on t1.platform_user_id = t8.platform_user_id
;