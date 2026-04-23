-- **************************************************************************
-- ** Theme Domain|所属业务主题: Risk ads
-- ** Functional description|功能描述: Risk feature中间表
-- ** Target table name|目标表名: ads_risk_${table_region}_mp_user_df
-- ** Create Author|创建人: hejia.an
-- ** Create time|创建日期: 2025-10-20
-- ** Modified log|修改日志:
-- **             修改日期: 2025-10-20  修改人:hejia.an  新建内容: 以mp user作为user base，以解决大宽表内，whitelist信息不完整的问题
-- **             修改日期: 2025-11-06  修改人:hejia.an  修改内容: 增加user level freeze status
-- **             修改日期: 2025-11-27  修改人:hejia.an  修改内容: 源表切换为credit_uc.dws_uc_${table_region}_user_lock_status_df
-- ** @extra_input=xxx
-- ** @extra_input=xxx
-- **************************************************************************

-- drop table if exists ${SCHEMA}.ads_risk_${table_region}_mp_user_df;

-- create external table if not exists ${SCHEMA}.ads_risk_${table_region}_mp_user_df (
--     platform_user_id string comment 'shopee user id'
--     ,is_whitelist_spl int comment 'Whether user is in whitelist'
--     ,whitelist_time_spl string comment 'Whitelist time'
--     ,is_whitelist_bcl int comment 'Whether user is in whitelist'
--     ,whitelist_time_bcl string comment 'Whitelist time'
--     ,is_whitelist_splx int comment 'Whether user is in whitelist'
--     ,whitelist_time_splx  string comment 'Whitelist time'
--     ,is_post_kyc_freeze                     int             comment 'Whether post kyc freeze'
--     ,is_post_fraud_freeze                   int             comment 'Whether post fraud freeze'
--     ,is_overdue_freeze                   int             comment 'Whether overdue freeze'
--     ,is_restructure_freeze                         int             comment 'Whether under restructure program'
--     ,is_dpd_freeze                         int             comment 'Whether ALL DPD 60 Freeze'
-- )
-- partitioned by (
--     grass_date string 
-- ) 
-- stored as orc 
-- comment 'whitelist & user level info of mp user summary table'
-- tblproperties
-- (
--     "orc.compress" = "zstd"
--     ,"orc.stripe.size" = "268635456"
-- )
-- location '${HDFS_PATH}/risk_feature/ads/ads_risk_${table_region}_mp_user_df/grass_region=${region}';

-- msck repair table ${SCHEMA}.ads_risk_${table_region}_mp_user_df;

insert overwrite table ${SCHEMA}.ads_risk_${table_region}_mp_user_df partition (grass_date = '${ds}')
select 
    t1.platform_user_id
    ,t2.is_whitelist_spl 
    ,t2.whitelist_time_spl
    ,t2.is_whitelist_bcl 
    ,t2.whitelist_time_bcl
    ,t2.is_whitelist_splx
    ,t2.whitelist_time_splx
    ,t3.is_post_kyc_freeze
    ,t3.is_post_fraud_freeze
    ,t3.is_overdue_freeze
    ,t3.is_restructure_freeze
    ,t3.is_dpd_freeze
from
(
    select
        distinct cast(user_id as string) as platform_user_id
    from mp_user.dim_user__reg_s0_live
    where 
        grass_region = '${region}' 
        and grass_date = '${ds}'
) t1 
left join 
(
    select 
        platform_user_id
        ,is_whitelist_spl 
        ,to_date(first_whitelist_local_time_spl) as whitelist_time_spl
        ,is_whitelist_bcl 
        ,to_date(first_whitelist_local_time_bcl) as whitelist_time_bcl
        ,is_whitelist_chp as is_whitelist_splx
        ,to_date(first_whitelist_local_time_chp) as whitelist_time_splx
    from credit_uc.ads_${table_region}_uc_user_list_wide_df -- 产品横表，splx在这张表里记为chp
    where grass_date = '${ds}' 
) t2
on t1.platform_user_id = t2.platform_user_id
left join 
(
    select 
        platform_user_id
        ,max(is_post_kyc_freeze) as is_post_kyc_freeze -- kyc冻结
        ,max(is_post_fraud_freeze) as is_post_fraud_freeze -- 反欺诈冻结
        ,max(is_overdue_freeze) as is_overdue_freeze -- overdue冻结
        ,max(is_restructure_freeze) as is_restructure_freeze -- User is under restructure program
        ,max(is_dpd_freeze) as is_dpd_freeze -- ALL DPD 60 Freeze
    from credit_uc.dws_uc_${table_region}_user_lock_status_df 
    where grass_date = '${ds}' 
    group by platform_user_id -- user粒度冻结
) t3
on t1.platform_user_id = t3.platform_user_id






