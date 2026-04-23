------------------------------------------------------------------------
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2024-03-11
-- Description:         业务维护的指标，user维度的融合成一张dws表
-- Data Granularity:    platform_user_id
-- PRD:                 
------------------------------------------------------------------------

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_metrics_biz_manage_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,t3.hit_rule_bad_user_in_cluster_v2
from
    (
        select
            platform_user_id
        from ${SCHEMA}.dim_risk_${region}_user_info_df
        where grass_date = '${grass_date}'
    ) t1
left join (
    select
        platform_user_id
        ,hit_rule_bad_user_in_cluster as hit_rule_bad_user_in_cluster_v2
    from regsm_riskmgmt.user_graph_community_risk_antifraud_v1
    where grass_region = '${grass_region}'
    and grass_date = (select max(grass_date) from regsm_riskmgmt.user_graph_community_risk_antifraud_v1 where grass_region = '${grass_region}')
) t3 on t1.platform_user_id = t3.platform_user_id
;