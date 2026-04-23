-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-01-20
-- Theme Domain:        User Info Freeze Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         用户交易信贷冻结特征表
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-20 - chengguo.liu - 初始化
-- =============================================================================


--drop table if exists ${SCHEMA}.dws_risk_${region}_user_info_credit_freeze_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_info_credit_freeze_df (
    credit_user_id              string  comment 'credit_user_id'
    ,dpd_freeze_date            string  comment 'dpd freeze date'
    ,dpd_freeze_datetime_ts     bigint  comment 'dpd freeze datetime timestamp'
    ,spl_uw_freeze_date         string  comment 'spl uw freeze date'
    ,spl_uw_freeze_datetime_ts  bigint  comment 'spl uw freeze datetime timestamp'
    ,bcl_uw_freeze_date         string  comment 'bcl uw freeze date'
    ,bcl_uw_freeze_datetime_ts  bigint  comment 'bcl uw freeze datetime timestamp'
)
partitioned by
    (grass_date string) stored as orc 
tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_info_credit_freeze_df/grass_region=${grass_region}'
;
--msck repair table ${SCHEMA}.dws_risk_${region}_user_info_credit_freeze_df;

with 
--dpd_freeze_datetime
user_dpd_freeze as (
select user_id as credit_user_id, update_time 
from credit_uc.dwd_uc_${region}_user_lock_info_df 
where lock_type=26 and lock_status=1 and grass_date = '${ds}'
),

--spl_uw_freeze_datetime
user_spl_uw_freeze as (
select user_id as credit_user_id, update_time 
from credit_uc.dwd_uc_${region}_user_lock_product_info_df 
where lock_type=6 and lock_status=1 and biz_type=3 and grass_date = '${ds}'
),

--bcl_uw_freeze_datetime
user_bcl_uw_freeze as (
select user_id as credit_user_id, update_time 
from credit_uc.dwd_uc_${region}_user_lock_product_info_df 
where lock_type=6 and lock_status=1 and biz_type=1 and grass_date = '${ds}'
)


INSERT OVERWRITE TABLE ${SCHEMA}.dws_risk_${region}_user_info_credit_freeze_df PARTITION (grass_date = '${ds}')
select t1.credit_user_id,
        substring(t2.update_time,1,10) as dpd_freeze_date,
        unix_timestamp(to_utc_timestamp(t2.update_time, 'Asia/Jakarta')) as dpd_freeze_datetime_ts,
        substring(t3.update_time,1,10) as spl_uw_freeze_date,
        unix_timestamp(to_utc_timestamp(t3.update_time, 'Asia/Jakarta')) as spl_uw_freeze_datetime_ts,
        substring(t4.update_time,1,10) as bcl_uw_freeze_date,
        unix_timestamp(to_utc_timestamp(t4.update_time, 'Asia/Jakarta')) as bcl_uw_freeze_datetime_ts
from (
    select
        credit_user_id
    from credit_uc.dws_all_prod_${region}_uc_user_df
    where
        grass_date = '${grass_date}'
        and credit_user_id <> ''
        and credit_user_id <> '0'
        and credit_user_id is not null
    group by credit_user_id
) t1
left join user_dpd_freeze t2 on t1.credit_user_id = t2.credit_user_id
left join user_spl_uw_freeze t3 on t1.credit_user_id = t3.credit_user_id
left join user_bcl_uw_freeze t4 on t1.credit_user_id = t4.credit_user_id
;
