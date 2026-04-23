-- =============================================================================
-- Author:              chenyingying@shopee.com
-- Created Time:        2026-02-03
-- Theme Domain:        User Info Activate Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-02-03 - chenyingying - 初始化
-- =============================================================================

drop table if exists ${SCHEMA}.dws_risk_${region}_user_info_credit_activate_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_info_credit_activate_df
(
    credit_user_id                                      string         comment 'creidt user id'
    ,account_label                                      bigint         comment 'SPL Account Label Identifier'
    ,credit_user_status                                 bigint         comment 'User Status'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_info_credit_activate_df/grass_region=${grass_region}';
msck repair table ${SCHEMA}.dws_risk_${region}_user_info_credit_activate_df;


create or replace temporary view tmp_spl_vn_user_account_status as
    select 
    user_id as platform_user_id
    ,status as shopee_account_status
    from mp_user.dim_user__reg_s0_live
    where tz_type = 'local'
    and grass_region = 'VN'
    and grass_date = '${ds}'
;


insert overwrite ${SCHEMA}.dws_risk_${region}_user_info_credit_activate_df partition (grass_date = '${ds}')
select t1.credit_user_id
        ,t2.account_label   as account_label
        ,t3.credit_user_status  as credit_user_status
from (
    select  credit_user_id
    from    credit_uc.dws_all_prod_vn_uc_user_df
    where   grass_date = '${ds}'
    and     credit_user_id <> ''
    and     credit_user_id is not null
    and     credit_user_id <> '0'
    group   by credit_user_id
) t1
left join (
    select 
        a.credit_user_id,
        max(a.account_label)         as account_label,
        max(b.shopee_account_status) as shopee_account_status
    from(
        select credit_user_id,account_label,platform_user_id from credit_uc.dws_spl_vn_uc_user_df where grass_date='${ds}' 
        union 
        select credit_user_id,null as account_label,platform_user_id from credit_uc.dws_bcl_vn_uc_user_df where grass_date='${ds}'
    ) a 
    left join tmp_spl_vn_user_account_status b on a.platform_user_id = b.platform_user_id
    where  a.credit_user_id <> '0'
    group  by a.credit_user_id
) t2
on t1.credit_user_id = t2.credit_user_id
left join (
    select credit_user_id
            ,credit_user_status
    from (
        select credit_user_id
            ,user_status as credit_user_status
            ,row_number() over (partition by credit_user_id order by activation_time desc) as rn
        from credit_uc.dws_spl_vn_uc_user_df    
        where grass_date = '${ds}'
    )
    where rn = 1
) t3
on t1.credit_user_id = t3.credit_user_id
;