--********************************************************************--
-- Author:              wei.tao@shopee.com
-- Created Time:        2025-07-09
-- Theme Domain：       risk-feature
-- Description:         spl/bcl/scl user_behavior underwirting feature
-- Data Granularity:    credit_user_id
-- 变更历史：
--  v1 by wei.tao@shopee.com，jira:https://jira.shopee.io/browse/SPFDT-48311
--  v2 chengguo.liu@shopee.com, 新增max_limit_utilization相关字段, jira: https://jira.shopee.io/browse/SPFDT-53386
--  v3 chengguo.liu@shopee.com, base表切换为全量credit_user_id, 同步hbase也要空值覆盖更新. Jira: https://casement.scredit.io/78703/requirement?jiraKey=SPFDT-61623
--********************************************************************--
--drop table if exists ${SCHEMA}.ads_behavior_my_underwrting_feature_df;
create external table if not exists ${SCHEMA}.ads_behavior_my_underwrting_feature_df (
    credit_user_id string
    ,first_billed_from_now_bcl int comment 'bcl The number of months from bill term'
    ,credit_user_status int comment 'user status'
    ,is_limit_decrease_spl int comment 'limit decrease tag in spl'
    ,is_limit_decrease_bcl int comment 'limit decrease tag in bcl'
    ,is_cashloan_activated int
    ,current_credit_limit_cashloan decimal(30,10)
    ,is_account_freeze_user int
    ,current_credit_limit_spl int
    ,max_limit_utilization_30d_spl decimal(30,10)
    ,max_limit_utilization_60d_spl decimal(30,10)
    ,max_limit_utilization_90d_spl decimal(30,10)
    ,max_limit_utilization_180d_spl decimal(30,10)
    ,max_limit_utilization_360d_spl decimal(30,10)
    ,max_limit_utilization_30d_bcl decimal(30,10)
    ,max_limit_utilization_60d_bcl decimal(30,10)
    ,max_limit_utilization_90d_bcl decimal(30,10)
    ,max_limit_utilization_180d_bcl decimal(30,10)
    ,max_limit_utilization_360d_bcl decimal(30,10)
)
partitioned by
    (grass_date string comment 'YYYY-MM-dd') stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/risk_feature/ads/ads_behavior_underwrting_feature_df/grass_region=MY'
;
--msck repair table ${SCHEMA}.ads_behavior_my_underwrting_feature_df;

create or replace temporary view tmp_spl_my_behavior_user as
select
credit_user_id
,sum(case when grass_date>=date_sub('${grass_date}',30) then total_limit_util_spl else 0 end)      as total_limit_utilization_30d_spl
,sum(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_spl else 0 end)      as total_limit_utilization_90d_spl
,sum(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_spl else 0 end)     as total_limit_utilization_180d_spl
,count(distinct case when grass_date>=date_sub('${grass_date}',30) then grass_date else null end)  as grass_date_cnt_30d_spl
,count(distinct case when grass_date>=date_sub('${grass_date}',90) then grass_date else null end)  as grass_date_cnt_90d_spl
,count(distinct case when grass_date>=date_sub('${grass_date}',180) then grass_date else null end) as grass_date_cnt_180d_spl
,max(case when grass_date>=date_sub('${grass_date}',30) then total_limit_util_spl else 0 end)      as max_limit_utilization_30d_spl
,max(case when grass_date>=date_sub('${grass_date}',60) then total_limit_util_spl else 0 end)      as max_limit_utilization_60d_spl
,max(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_spl else 0 end)      as max_limit_utilization_90d_spl  
,max(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_spl else 0 end)     as max_limit_utilization_180d_spl 
,max(case when grass_date>=date_sub('${grass_date}',360) then total_limit_util_spl else 0 end)     as max_limit_utilization_360d_spl
from (
select 
    credit_user_id                     as credit_user_id
    ,   (
            COALESCE(common_perm_used_credit_amount, 0) +
            COALESCE(common_temp_used_credit_amount, 0) +
            COALESCE(installment_perm_used_credit_amount, 0) +
            COALESCE(common_perm_frozen_credit_amount, 0) +
            COALESCE(common_temp_frozen_credit_amount, 0) +
            COALESCE(installment_perm_frozen_credit_amount, 0) 
        ) / (
            COALESCE(common_perm_credit_limit, 0) +
            COALESCE(common_temp_credit_limit, 0) +
            COALESCE(installment_perm_credit_limit, 0) 
        )
    as total_limit_util_spl
    ,grass_date                         as grass_date
from credit_mart.dws_spl_my_account_df
where coalesce(common_perm_credit_limit,0) + coalesce(common_temp_credit_limit,0) + coalesce(installment_perm_credit_limit,0)
    > 0
    and biz_type = 3
    and grass_date >=date_sub('${grass_date}',180)
) a 
group by credit_user_id
;

create or replace temporary view tmp_bcl_my_behavior_user as
select
credit_user_id
,sum(case when grass_date>=date_sub('${grass_date}',30) then total_limit_util_bcl else 0 end)  as total_limit_utilization_30d_bcl
,sum(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_bcl else 0 end)  as total_limit_utilization_90d_bcl
,sum(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_bcl else 0 end) as total_limit_utilization_180d_bcl
,count(distinct case when grass_date>=date_sub('${grass_date}',30) then grass_date else null end)  as grass_date_cnt_30d_bcl
,count(distinct case when grass_date>=date_sub('${grass_date}',90) then grass_date else null end)  as grass_date_cnt_90d_bcl
,count(distinct case when grass_date>=date_sub('${grass_date}',180) then grass_date else null end) as grass_date_cnt_180d_bcl
,max(case when grass_date>=date_sub('${grass_date}',30) then total_limit_util_bcl else 0 end)  as max_limit_utilization_30d_bcl
,max(case when grass_date>=date_sub('${grass_date}',60) then total_limit_util_bcl else 0 end)  as max_limit_utilization_60d_bcl
,max(case when grass_date>=date_sub('${grass_date}',90) then total_limit_util_bcl else 0 end)  as max_limit_utilization_90d_bcl
,max(case when grass_date>=date_sub('${grass_date}',180) then total_limit_util_bcl else 0 end) as max_limit_utilization_180d_bcl
,max(case when grass_date>=date_sub('${grass_date}',360) then total_limit_util_bcl else 0 end) as max_limit_utilization_360d_bcl
from (
select 
    credit_user_id                     as credit_user_id
    ,((COALESCE(common_perm_used_credit_amount,0))+(COALESCE(common_temp_used_credit_amount,0))
        +(COALESCE(common_perm_frozen_credit_amount,0))+(COALESCE(common_temp_frozen_credit_amount,0))
     )
     /
     ((COALESCE(common_perm_credit_limit,0))+(COALESCE(common_temp_credit_limit,0))
     )      as total_limit_util_bcl
    ,grass_date                         as grass_date
from credit_mart.dws_bcl_my_account_df
where coalesce(common_perm_credit_limit,0) + coalesce(common_temp_credit_limit,0) > 0
and biz_type = 1
and grass_date >=date_sub('${grass_date}',180)
) a 
group by credit_user_id
;

insert overwrite table
    ${SCHEMA}.ads_behavior_my_underwrting_feature_df partition (grass_date = '${ds}')
select
    t0.credit_user_id
    ,null as first_billed_from_now_bcl -- 暂不开发
    ,t1.user_status as credit_user_status
    ,t7.is_limit_decrease_spl as is_limit_decrease_spl
    ,t7.is_limit_decrease_bcl as is_limit_decrease_bcl
    ,null as is_cashloan_activated -- 暂不开发
    ,t6.current_credit_limit_cashloan as current_credit_limit_cashloan
    ,t2.is_user_level_frozen as is_account_freeze_user
    ,t5.common_credit_limit as current_credit_limit_spl
    ,t8.max_limit_utilization_30d_spl as max_limit_utilization_30d_spl
    ,t8.max_limit_utilization_60d_spl as max_limit_utilization_60d_spl
    ,t8.max_limit_utilization_90d_spl as max_limit_utilization_90d_spl
    ,t8.max_limit_utilization_180d_spl as max_limit_utilization_180d_spl
    ,t8.max_limit_utilization_360d_spl as max_limit_utilization_360d_spl
    ,t9.max_limit_utilization_30d_bcl as max_limit_utilization_30d_bcl
    ,t9.max_limit_utilization_60d_bcl as max_limit_utilization_60d_bcl
    ,t9.max_limit_utilization_90d_bcl as max_limit_utilization_90d_bcl
    ,t9.max_limit_utilization_180d_bcl as max_limit_utilization_180d_bcl
    ,t9.max_limit_utilization_360d_bcl as max_limit_utilization_360d_bcl
from
    (
        select
            credit_user_id
        from credit_uc.dws_all_prod_my_uc_user_df
        where
            grass_date = '${ds}'
            and credit_user_id <> ''
            and credit_user_id <> '0'
        group by credit_user_id
    ) t0
    left join (
        select
            credit_user_id
            ,user_status
        from
            (
                select
                    credit_user_id
                    ,user_status
                    ,row_number() over (
                        partition by credit_user_id
                        order by activation_time desc
                    ) as rn
                from credit_uc.dws_spl_my_uc_user_df
                where grass_date = '${ds}'
            ) tmp
        where rn = 1
        union
        select
            credit_user_id
            ,user_status
        from
            (
                select
                    credit_user_id
                    ,user_status
                    ,row_number() over (
                        partition by credit_user_id
                        order by activation_time desc
                    ) as rn
                from credit_uc.dws_bcl_my_uc_user_df
                where grass_date = '${ds}'
            ) tmp
        where rn = 1
    ) t1 on t0.credit_user_id = t1.credit_user_id
    left join (
        select distinct
            cast(user_id as string) as credit_user_id
            ,1 as is_user_level_frozen
        from credit_uc.dwd_uc_my_user_lock_info_df
        where
            lock_status = 1
            and platform_user_id is not null
            and platform_user_id <> ''
            and grass_date = '${ds}'
    ) t2 on t0.credit_user_id = t2.credit_user_id
    left join (
        select
            sum(
                coalesce(common_temp_credit_limit, 0) + coalesce(common_perm_credit_limit, 0)
            ) as common_credit_limit
            ,credit_user_id
        from credit_mart.dws_spl_my_account_df
        where
            grass_date = '${ds}'
            and credit_user_id is not null
            and credit_user_id <> ''
        group by credit_user_id
    ) t5 on t0.credit_user_id = t5.credit_user_id
    left join (
        select
            sum(
                coalesce(common_temp_credit_limit, 0) + coalesce(common_perm_credit_limit, 0)
            ) as current_credit_limit_cashloan
            ,credit_user_id
        from credit_mart.dws_bcl_my_account_df
        where
            grass_date = '${ds}'
            and credit_user_id is not null
            and credit_user_id <> ''
        group by credit_user_id
    ) t6 on t0.credit_user_id = t6.credit_user_id
    left join (
        select
            credit_user_id
            ,max(if (biz_type = 1, is_limit_decrease, null)) as is_limit_decrease_bcl
            ,max(if (biz_type = 3, is_limit_decrease, null)) as is_limit_decrease_spl
        from
            (
                select
                    credit_user_id
                    ,case
                        when tag_type is null then 0
                        when tag_type = 9 then 1
                        else 2
                    end is_limit_decrease
                    ,biz_type
                from credit_uc.dwd_uc_my_user_platform_tag_info_tab_df
                where
                    grass_date = '${ds}'
                    and credit_user_id <> '0'
            ) tmp
        group by credit_user_id
    ) t7 on t0.credit_user_id = t7.credit_user_id
    left join (
        select
            credit_user_id
            ,max_limit_utilization_30d_spl
            ,max_limit_utilization_60d_spl
            ,max_limit_utilization_90d_spl
            ,max_limit_utilization_180d_spl
            ,max_limit_utilization_360d_spl
        from tmp_spl_my_behavior_user
    ) t8 on t0.credit_user_id = t8.credit_user_id
    left join (
        select
            credit_user_id
            ,max_limit_utilization_30d_bcl
            ,max_limit_utilization_60d_bcl
            ,max_limit_utilization_90d_bcl
            ,max_limit_utilization_180d_bcl
            ,max_limit_utilization_360d_bcl
        from tmp_bcl_my_behavior_user
    ) t9 on t0.credit_user_id = t9.credit_user_id
;