------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-05-21
-- Description:         业务维护的指标，user维度的融合成一张dws表
-- Data Granularity:    platform_user_id
-- PRD:                 
------------------------------------------------------------------------
--drop table if exists ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df (
    platform_user_id string comment 'platform_user_id'
    ,uw_is_bad_user_sg bigint comment 'uw_is_bad_user_sg'
    ,uw_acard_score_sg_v1_0 double comment 'uw_acard_score_sg_v1_0'
)
partitioned by
    (grass_date string comment "YYYY-MM-DD") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_mart/dws/dws_risk_user_metrics_biz_manage_df/garss_region=${upper_region}'
;
--msck repair table ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df;

create temporary view black_list as (
    select
        userid as platform_user_id
        ,case
            when level in ('Black') then 1
            when level in ('Grey') then 2
            else 0
        end as uw_is_bad_user_sg
    from smcdrisk_antifraud.f_sg_uw_blacklist
)
;

create temporary view acard_score_cl as (
    select
        userid as platform_user_id
        ,score as uw_acard_score_sg_v1_0
    from rescbds_credit.rescbds_credit_prod_sg__application_credit_score
    where
        grass_date = (
            select
                max(grass_date)
            from rescbds_credit.rescbds_credit_prod_sg__application_credit_score
            where model_version = 'v1.0'
        )
        and model_version = 'v1.0'
        and userid is not null
)
;


insert overwrite table
    ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,coalesce(t2.uw_is_bad_user_sg, -9999) as uw_is_bad_user_sg
    ,coalesce(t3.uw_acard_score_sg_v1_0, -9999) as uw_acard_score_sg_v1_0
from
    (
        select
            platform_user_id
        from ${SCHEMA}.dim_risk_${region}_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join black_list t2 on t1.platform_user_id = t2.platform_user_id
    left join acard_score_cl t3 on t1.platform_user_id = t3.platform_user_id
;