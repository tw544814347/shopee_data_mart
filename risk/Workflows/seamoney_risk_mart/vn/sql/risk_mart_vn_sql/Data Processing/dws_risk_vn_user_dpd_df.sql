create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

INSERT OVERWRITE TABLE ${SCHEMA}.dws_risk_vn_user_dpd_df PARTITION (grass_date)
select
    t1.user_id
    ,coalesce(t3.historical_max_dpd_eod,-9999) as ever_max_dpd_cashloan_core
    ,coalesce(t3.last_bill_dpd,-9999) as last_bill_dpd_cashloan_core
    ,coalesce(t4.historical_max_dpd_eod,-9999) as ever_max_dpd_sellerloan_core
    ,coalesce(t4.last_bill_dpd,-9999) as last_bill_dpd_sellerloan_core
    ,coalesce(t5.historical_max_dpd_eod,-9999) as ever_max_dpd_spl_core
    ,coalesce(t5.last_bill_dpd,-9999) as last_bill_dpd_spl_core
    ,coalesce(t5.days_after_first_due_date, -9999) as days_after_first_due_date_spl
    ,coalesce(t5.ever_max_dpd_180d, -9999) as ever_max_dpd_180d_spl
    ,coalesce(t5.ever_max_dpd_360d, -9999) as ever_max_dpd_360d_spl
    ,coalesce(t3.days_after_first_due_date, -9999) as days_after_first_due_date_cashloan
    ,coalesce(t3.ever_max_dpd_180d, -9999) as ever_max_dpd_180d_cashloan
    ,coalesce(t3.ever_max_dpd_360d, -9999) as ever_max_dpd_360d_cashloan
    ,coalesce(
        case when t3.ever_max_dpd_180d is null then t5.ever_max_dpd_180d
            when t5.ever_max_dpd_180d is null then t3.ever_max_dpd_180d
            when t3.ever_max_dpd_180d > t5.ever_max_dpd_180d then t3.ever_max_dpd_180d
            else t5.ever_max_dpd_180d
            end, -9999) as ever_max_dpd_180d_user
    ,coalesce(
        case when t3.ever_max_dpd_360d is null then t5.ever_max_dpd_360d
            when t5.ever_max_dpd_360d is null then t3.ever_max_dpd_360d
            when t3.ever_max_dpd_360d > t5.ever_max_dpd_360d then t3.ever_max_dpd_360d
            else t5.ever_max_dpd_360d
            end, -9999) as ever_max_dpd_360d_user
    ,coalesce(t4.ever_max_dpd_30d ,-9999) as ever_max_dpd_30d_scl
    ,coalesce(t4.ever_max_dpd_90d ,-9999) as ever_max_dpd_90d_scl
    ,coalesce(t4.ever_max_dpd_180d,-9999) as ever_max_dpd_180d_scl
    ,coalesce(t4.ever_max_dpd_360d,-9999) as ever_max_dpd_360d_scl
    ,coalesce(t5.ever_max_dpd_30d ,-9999) as ever_max_dpd_30d_spl
    ,coalesce(t5.ever_max_dpd_90d ,-9999) as ever_max_dpd_90d_spl
    ,coalesce(t3.ever_max_dpd_30d ,-9999) as ever_max_dpd_30d_bcl
    ,coalesce(t3.ever_max_dpd_90d ,-9999) as ever_max_dpd_90d_bcl  
    ,coalesce(t6.latest_dpd_eod_cashloan ,-9999) as latest_dpd_eod_cashloan
    ,t1.grass_date
from
(
    select
        credit_user_id as user_id
        ,grass_date
    from credit_uc.dws_aio_vn_uc_user_df
    where grass_date = '${grass_date}'
    and credit_user_id <> ''
    group by credit_user_id, grass_date
)t1
left join
(
    select
        credit_user_id as user_id
        ,historical_max_dpd_eod
        ,last_bill_dpd
        ,days_after_first_due_date
        ,ever_max_dpd_30d
        ,ever_max_dpd_90d
        ,ever_max_dpd_180d
        ,ever_max_dpd_360d
        ,grass_date
    from credit_mart.dws_bcl_vn_user_df
    where grass_date between '${begin_ds}' and '${ds}'
) t3
on t1.user_id = t3.user_id
    and t1.grass_date = t3.grass_date
left join
(
    select
        credit_user_id as user_id
        ,historical_max_dpd_eod
        ,last_bill_dpd
        ,ever_max_dpd_30d
        ,ever_max_dpd_90d
        ,ever_max_dpd_180d
        ,ever_max_dpd_360d
        ,grass_date
    from credit_mart.dws_scl_vn_user_df
    where grass_date between '${begin_ds}' and '${ds}'
) t4
on t1.user_id = t4.user_id
    and t1.grass_date = t4.grass_date
left join
(
    select
        credit_user_id as user_id
        ,historical_max_dpd_eod
        ,last_bill_dpd
        ,days_after_first_due_date
        ,ever_max_dpd_30d
        ,ever_max_dpd_90d
        ,ever_max_dpd_180d
        ,ever_max_dpd_360d
        ,grass_date
    from credit_mart.dws_spl_vn_user_df
    where grass_date between '${begin_ds}' and '${ds}'
) t5
on t1.user_id = t5.user_id
    and t1.grass_date = t5.grass_date
left join
(
    select
        credit_user_id            as user_id
        ,lastest_max_dpd_eod_120d as latest_dpd_eod_cashloan
        ,grass_date               as grass_date
    from credit_mart.wide_bcl_vn_behavior_user_df
    where grass_date between '${begin_ds}' and '${ds}'
) t6
on t1.user_id = t6.user_id
    and t1.grass_date = t6.grass_date
;

msck repair table risk.dws_risk_vn_user_dpd_df;