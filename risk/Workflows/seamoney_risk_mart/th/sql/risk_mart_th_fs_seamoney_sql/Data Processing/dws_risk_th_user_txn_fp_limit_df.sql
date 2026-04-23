-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-01-12
-- Theme Domain:        SPL Limit Utilization
-- Data Granularity:    platform_user_id
-- Description:         Feature Station迁移， user_txn_fp_limit
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-12 - chengguo.liu - 初始化 - FS逻辑: https://fs.idata.shopeemobile.com/job-management/job-edit/529
-- =============================================================================

--drop table if exists ${SCHEMA}.dws_risk_th_user_txn_fp_limit_df;
create table if not exists ${SCHEMA}.dws_risk_th_user_txn_fp_limit_df (
    platform_user_id string comment 'platform_user_id'
    ,avg_spl_limit_utilization_in_360d double comment 'average spl limit utilization in 360d'
    ,max_spl_limit_utilization_in_360d double comment 'max spl limit utilization in 360d'
    ,currnet_spl_limit_utilization double comment 'current spl limit utilization'
)
partitioned by
    (grass_date string comment 'grass_date, partition key') stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_feature/dws/dws_risk_user_txn_fp_limit_df/grass_region=TH'
;
--msck repair table ${SCHEMA}.dws_risk_th_user_txn_fp_limit_df;


with spl_limit_utilization_base as (
    select
        platform_user_id,
        credit_user_id,
        if(total_credit_limit > 0, total_user_credit_utilisation, -9998) as spl_limit_utilization,
        cast(grass_date as date) as grass_date
    from credit_mart.wide_spl_${region}_behavior_user_df
    where cast(grass_date as date) >= date_sub('${current_grass_date}', 360)
        and cast(grass_date as date) <= date '${grass_date}'
),
currnet_spl_limit_utilization as (
    select
        platform_user_id,
        credit_user_id,
        spl_limit_utilization as currnet_spl_limit_utilization
    from spl_limit_utilization_base
    where grass_date = date '${grass_date}'
),

average_spl_limit_utilization_in_360d_pre_1 as (
    select
        credit_user_id,
        avg(spl_limit_utilization) as avg_spl_limit_utilization_in_360d
    from spl_limit_utilization_base
    where grass_date >= date_sub('${current_grass_date}', 360)
        and spl_limit_utilization >= 0
    group by credit_user_id
),

average_spl_limit_utilization_in_360d_pre_2 as (
    select
        credit_user_id,
        avg(spl_limit_utilization) as avg_spl_limit_utilization_in_360d
    from spl_limit_utilization_base
    where grass_date >= date_sub('${current_grass_date}', 360)
        and spl_limit_utilization > 0
    group by credit_user_id
),
--逻辑有些冗余，跟FS逻辑保持一致，以免默认值不一致业务切换验证问题
average_spl_limit_utilization_in_360d as (
    select
        pre_1.credit_user_id,
        coalesce(pre_2.avg_spl_limit_utilization_in_360d, 0) as avg_spl_limit_utilization_in_360d
    from average_spl_limit_utilization_in_360d_pre_1 as pre_1
        left join average_spl_limit_utilization_in_360d_pre_2 as pre_2 
            on pre_1.credit_user_id = pre_2.credit_user_id
),

max_spl_limit_utilization_in_360d as (
    select
        credit_user_id,
        max(spl_limit_utilization) as max_spl_limit_utilization_in_360d
    from spl_limit_utilization_base
    where grass_date >= date_sub('${current_grass_date}', 360)
    group by credit_user_id
),

spl_metrics as (
    select
        base.platform_user_id,
        coalesce(avg_360d.avg_spl_limit_utilization_in_360d, -9998) as avg_spl_limit_utilization_in_360d,
        max_360d.max_spl_limit_utilization_in_360d,
        now.currnet_spl_limit_utilization
    from (
        select distinct platform_user_id, credit_user_id
        from spl_limit_utilization_base
    ) base
    left join average_spl_limit_utilization_in_360d as avg_360d
        on base.credit_user_id = avg_360d.credit_user_id
    left join max_spl_limit_utilization_in_360d as max_360d
        on base.credit_user_id = max_360d.credit_user_id
    left join currnet_spl_limit_utilization as now
        on base.platform_user_id = now.credit_user_id
)

insert overwrite table risk.dws_risk_th_user_txn_fp_limit_df partition (grass_date = '${grass_date}')
select
    t1.platform_user_id
    ,coalesce(t2.avg_spl_limit_utilization_in_360d, -9999) as avg_spl_limit_utilization_in_360d
    ,coalesce(t2.max_spl_limit_utilization_in_360d, -9999) as max_spl_limit_utilization_in_360d
    ,coalesce(t2.currnet_spl_limit_utilization, -9999) as currnet_spl_limit_utilization
from
    (
        select
            platform_user_id
        from ${SCHEMA}.dim_risk_th_user_info_df
        where grass_date = '${grass_date}'
    ) t1
    left join spl_metrics t2 
        on t1.platform_user_id = cast(t2.platform_user_id as string)
;