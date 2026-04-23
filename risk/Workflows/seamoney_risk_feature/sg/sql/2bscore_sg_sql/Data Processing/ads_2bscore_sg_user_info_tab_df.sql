--drop table if exists ${SCHEMA}.ads_2bscore_sg_user_info_tab_df;
create external table if not exists ${SCHEMA}.ads_2bscore_sg_user_info_tab_df (
    platform_user_id string comment 'platform_user_id'
    ,is_userid_matched int
    ,score int
    ,is_blacklist_hit int
    ,list_type int
    ,reason_code int
    ,score_v3 int
    ,reason_code_list string
)
partitioned by
    (grass_date string comment "YYYY-MM-DD") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_feature/ads/ads_2bscore_sg_user_info_tab_df'
;
--msck repair table ${SCHEMA}.ads_2bscore_sg_user_info_tab_df;

insert overwrite table ${SCHEMA}.ads_2bscore_sg_user_info_tab_df partition(grass_date = '${grass_date}')
select
    cast(t1.platform_user_id as string) platform_user_id
    ,1 as is_userid_matched
    ,cast(t2.score as int) as score
    ,coalesce(t3.is_blacklist_hit, 0) as is_blacklist_hit
    ,t3.list_type
    ,cast(t3.reason_code as int) as reason_code
    ,cast(t4.score_v3 as int) as score_v3
    ,t3.reason_code_list
from
    (
        select
            user_id as platform_user_id
        from mp_user.dim_user__reg_s0_live
        where
            tz_type = 'local'
            and grass_region = 'SG'
            and grass_date = '${grass_date}'
    ) t1
    left join (
        select
            a.userid as platform_user_id
            ,round(a.score) score
        from rescbds_credit.sg_spl_acard_credit_score a
        where
            a.model_version = 'v3.0'
            and a.grass_date = (
                select
                    max(grass_date) max_grass_date
                from rescbds_credit.sg_spl_acard_credit_score
                where model_version = 'v3.0'
            )
    ) t2 on t1.platform_user_id = t2.platform_user_id
    left join (
        select
            a.userid as platform_user_id
            ,a.ifmatched as is_blacklist_hit
            ,a.list_type
            ,a.reason_code
            ,a.reason_code_list
        from rescbds_credit.rescbds_credit_prod_sg__das_user_blacklist a
        where
            grass_date = (
                select
                    max(grass_date)
                from rescbds_credit.rescbds_credit_prod_sg__das_user_blacklist
            )
    ) t3 on t1.platform_user_id = t3.platform_user_id
    left join (
        select
            userid as platform_user_id
            ,round(score) as score_v3
        from rescbds_credit.sg_tob_credit_score
        where
            grass_date = (
                select
                    max(grass_date)
                from rescbds_credit.sg_tob_credit_score
                where model_version = 'v3.0'
            )
            and model_version = 'v3.0'
    ) t4 on t1.platform_user_id = t4.platform_user_id
;