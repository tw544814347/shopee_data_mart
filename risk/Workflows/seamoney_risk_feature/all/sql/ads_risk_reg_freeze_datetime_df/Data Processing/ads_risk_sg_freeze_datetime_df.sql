-- drop table if exists risk.ads_risk_${region}_freeze_datetime_df
-- ;

create table if not exists risk.ads_risk_${region}_freeze_datetime_df (
    user_id string
    
    ,dpd_freeze_date string 
    ,dpd_freeze_datetime_ts bigint 

    ,spl_uw_freeze_date string 
    ,spl_uw_freeze_datetime_ts bigint 
)
partitioned by
    (grass_date string) stored as orc 
tblproperties ("orc.compress" = "zstd") 
location '${HDFS_PATH}/risk_feature/ads/ads_risk_${region}_freeze_datetime_df'
;

-- msck repair table risk.ads_risk_${region}_freeze_datetime_df
-- ;

with 
user_lock_info_df_all_user as (
    select cast(user_id as string) as user_id
    from credit_uc.dwd_uc_${region}_user_lock_info_df 
    where grass_date = '${ds}'
    group by user_id
),

user_lock_product_info_df_all_user as (
    select cast(user_id as string) as user_id
    from credit_uc.dwd_uc_${region}_user_lock_product_info_df 
    where grass_date = '${ds}'
    group by user_id
),

tmp0 as (
    select user_id
    from user_lock_info_df_all_user 
    union 
    select user_id
    from user_lock_product_info_df_all_user
),

--dpd_freeze_datetime
tmp1 as (
select cast(user_id as string) as user_id, max(update_time) as update_time
from credit_uc.dwd_uc_${region}_user_lock_info_df 
where lock_type=26 and lock_status=1 and grass_date = '${ds}'
group by cast(user_id as string)
),


--spl_uw_freeze_datetime
tmp2 as (
select cast(user_id as string) as user_id, update_time 
from credit_uc.dwd_uc_${region}_user_lock_product_info_df 
where lock_type=6 and lock_status=1 and biz_type=3 and grass_date = '${ds}'
)


INSERT OVERWRITE TABLE risk.ads_risk_${region}_freeze_datetime_df PARTITION (grass_date = '${ds}')
select 
    tmp0.user_id,
    substring(tmp1.update_time,1,10) as dpd_freeze_date,
    unix_timestamp(to_utc_timestamp(tmp1.update_time, 'Asia/Singapore')) as dpd_freeze_datetime_ts,
    substring(tmp2.update_time,1,10) as spl_uw_freeze_date,
    unix_timestamp(to_utc_timestamp(tmp2.update_time, 'Asia/Singapore')) as spl_uw_freeze_datetime_ts
from tmp0 
left join tmp1 on tmp0.user_id = tmp1.user_id
left join tmp2 on tmp0.user_id = tmp2.user_id