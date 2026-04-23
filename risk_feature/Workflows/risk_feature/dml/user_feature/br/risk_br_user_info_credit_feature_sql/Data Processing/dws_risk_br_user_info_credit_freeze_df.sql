-- =============================================================================
-- Author:              chenyingying@shopee.com
-- Created Time:        2026-02-10
-- Theme Domain:        User Info Limit Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-20 - chenyingying - 初始化
-- =============================================================================

--drop table if exists ${SCHEMA}.dws_risk_${region}_user_info_credit_freeze_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_info_credit_freeze_df

(
    credit_user_id                                      string         comment 'credit user id'
    ,dpd_freeze_date                                    string         comment 'dpd freeze date'
    ,dpd_freeze_datetime_ts                             bigint         comment 'dpd freeze datetime timestamp(s)'
    ,spl_uw_freeze_date                                 string         comment 'SPL dpd freeze date'
    ,spl_uw_freeze_datetime_ts                          bigint         comment 'SPL dpd freeze date timestamp(s)'
    ,bcl_uw_freeze_date                                 string         comment 'BCL dpd freeze date'
    ,bcl_uw_freeze_datetime_ts                          bigint         comment 'BCL dpd freeze date timestamp(s)'   
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_info_credit_freeze_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dws_risk_${region}_user_info_credit_freeze_df;

--dpd_freeze_datetime
with tmp1 as (
select cast(user_id as string) as credit_user_id, max(update_time)  as update_time
from credit_uc.dwd_uc_${region}_user_lock_info_df 
where lock_type=26 and lock_status=1 and grass_date = '${ds}'
group by 1
),

--spl_uw_freeze_datetime
tmp2 as (
select cast(user_id as string) as credit_user_id, max(update_time) as update_time
from credit_uc.dwd_uc_${region}_user_lock_product_info_df 
where lock_type=6 and lock_status=1 and biz_type=3 and grass_date = '${ds}'
group by 1
),

--bcl_uw_freeze_datetime
tmp3 as (
select cast(user_id as string) as credit_user_id, max(update_time)  as update_time
from credit_uc.dwd_uc_${region}_user_lock_product_info_df 
where lock_type=6 and lock_status=1 and biz_type=1 and grass_date = '${ds}'
group by 1
)

insert overwrite ${SCHEMA}.dws_risk_${region}_user_info_credit_freeze_df partition(grass_date='${ds}')
select t1.credit_user_id
        ,t2.update_time as dpd_freeze_date
        ,CAST(to_utc_timestamp(t2.update_time, 'America/Sao_Paulo') AS BIGINT) + 3600 * 8 as dpd_freeze_datetime_ts -- 验证时区是否正确
        ,substring(t3.update_time,1,10) as spl_uw_freeze_date
        ,CAST(to_utc_timestamp(t3.update_time, 'America/Sao_Paulo') AS BIGINT) + 3600 * 8 as spl_uw_freeze_datetime_ts
        ,substring(t4.update_time,1,10) as bcl_uw_freeze_date
        ,CAST(to_utc_timestamp(t4.update_time, 'America/Sao_Paulo') AS BIGINT) + 3600 * 8 as bcl_uw_freeze_datetime_ts
from (
    select credit_user_id
    from    credit_uc.dws_all_prod_${region}_uc_user_df
    where   grass_date = '${ds}' 
    and     credit_user_id is not null
    and     credit_user_id <> ''
    and     credit_user_id <> '0'
    group by credit_user_id
) t1
left join tmp1 t2
on t1.credit_user_id=t2.credit_user_id
left join tmp2 t3
on t1.credit_user_id=t3.credit_user_id
left join tmp3 t4
on t1.credit_user_id=t4.credit_user_id