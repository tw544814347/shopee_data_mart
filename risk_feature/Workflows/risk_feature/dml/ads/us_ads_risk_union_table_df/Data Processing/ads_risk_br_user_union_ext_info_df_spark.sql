-- **************************************************************************
-- ** Theme Domain|所属业务主题: Risk ads
-- ** Functional description|功能描述: Risk feature中间表
-- ** Target table name|目标表名: ads_risk_${table_region}_user_union_ext_info_df
-- ** Create Author|创建人: hejia.an
-- ** Create time|创建日期: 2025-11-14
-- ** Modified log|修改日志:
-- **             修改日期: 2025-11-14  修改人:hejia.an  修改内容：新建表，用于拓展主流程之外的名单类字段
-- ** @extra_input=xxx
-- ** @extra_input=xxx
-- **************************************************************************

create or replace view ${SCHEMA}.ads_risk_${table_region}_user_union_ext_info_df_spark
comment 'risk user union extra info summary table'
as 
select 
    t1.*
    ,coalesce(t2.is_inner_acc, 0) as is_inner_acc -- null的填充为0
    ,coalesce(t3.is_antifraud_blacklist, 0) as is_antifraud_blacklist -- null的填充为0
from 
(
    select 
        *
    from risk_feature.ads_risk_${table_region}_user_union_info_df
    where grass_date = '${ds}'
) t1 
left join 
(
    select 
        platform_user_id
        ,1 as is_inner_acc
    from dev_smcdrisk_policy.${table_region}_spl_inneraccount_tab
    union
    select 
        platform_user_id
        ,1 as is_inner_acc
    from dev_smcdrisk_policy.${table_region}_bcl_inneraccount_tab
) t2
on t1.platform_user_id = t2.platform_user_id
left join 
(
    select 
        distinct cast(platform_user_id as string) as platform_user_id
        ,1 as is_antifraud_blacklist
    from smcdrisk_antifraud.${table_region}_blacklist_uid_uw
    where list_type = 'blacklist'
) t3 
on t1.platform_user_id = t3.platform_user_id
