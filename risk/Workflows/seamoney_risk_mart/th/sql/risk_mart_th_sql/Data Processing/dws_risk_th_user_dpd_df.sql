--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-11-15
-- Theme Domain：       risk-user-dpd
-- Description:         
-- Data Granularity:    https://docs.google.com/spreadsheets/d/1taFFfk6IzhYmSkpO2LYZ9wT72iPI4pLKLamuEviTfjM/edit?gid=903859448#gid=903859448
-- 变更历史：
--  update by zongyi.lu@shopee.com 2024-11-15 新增chp相关字段,由于credit mart 还没上，因此先留null 后续再加逻辑
--********************************************************************--
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

INSERT OVERWRITE TABLE ${SCHEMA}.dws_risk_th_user_dpd_df PARTITION (grass_date)
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
    ,coalesce(greatest(t3.ever_max_dpd_180d,t5.ever_max_dpd_180d,t7.ever_max_dpd_180d_chp), -9999) as ever_max_dpd_180d_user
    ,coalesce(greatest(t3.ever_max_dpd_360d,t5.ever_max_dpd_360d,t7.ever_max_dpd_360d_chp), -9999) as ever_max_dpd_360d_user
    ,coalesce(t4.ever_max_dpd_30d ,-9999) as ever_max_dpd_30d_scl
    ,coalesce(t4.ever_max_dpd_90d ,-9999) as ever_max_dpd_90d_scl
    ,coalesce(t4.ever_max_dpd_180d,-9999) as ever_max_dpd_180d_scl
    ,coalesce(t4.ever_max_dpd_360d,-9999) as ever_max_dpd_360d_scl
    ,coalesce(t5.ever_max_dpd_30d ,-9999) as ever_max_dpd_30d_spl
    ,coalesce(t5.ever_max_dpd_90d ,-9999) as ever_max_dpd_90d_spl
    ,coalesce(t3.ever_max_dpd_30d ,-9999) as ever_max_dpd_30d_bcl
    ,coalesce(t3.ever_max_dpd_90d ,-9999) as ever_max_dpd_90d_bcl  
    ,coalesce(t3.days_after_first_due_date_floating ,-9999) as days_after_first_due_date_cashloan_floating
    ,coalesce(t6.days_after_first_due_date_spl_floating ,-9999) as days_after_first_due_date_spl_floating
    ,coalesce(t6.latest_dpd_eod_cashloan ,-9999) as latest_dpd_eod_cashloan
    ,coalesce(t7.latest_dpd_eod_spl ,-9999) as latest_dpd_eod_spl
    ,t7.ever_max_dpd_chp
    ,t7.days_after_first_due_date_chp
    ,t7.ever_max_dpd_30d_chp
    ,t7.ever_max_dpd_90d_chp
    ,t7.ever_max_dpd_180d_chp 
    ,t7.ever_max_dpd_360d_chp
    ,coalesce(greatest(t3.ever_max_dpd_30d,t5.ever_max_dpd_30d,t7.ever_max_dpd_30d_chp), -9999) as ever_max_dpd_30d_user
    ,coalesce(greatest(t3.ever_max_dpd_90d,t5.ever_max_dpd_90d,t7.ever_max_dpd_90d_chp), -9999) as ever_max_dpd_90d_user
    ,t8.ever_max_dpd_30d_tl
    ,t8.ever_max_dpd_90d_tl
    ,t8.ever_max_dpd_180d_tl
    ,t8.ever_max_dpd_360d_tl
    ,t8.ever_max_dpd_tl
    ,t1.grass_date
from
(
    select
        credit_user_id as user_id
        ,grass_date
    from credit_uc.dws_aio_th_uc_user_df
    where grass_date between '${begin_ds}' and '${ds}'
    and credit_user_id is not null
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
        ,days_after_first_due_date_floating
        ,grass_date
    from credit_mart.dws_bcl_th_user_df
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
    from credit_mart.dws_scl_th_user_df
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
    from credit_mart.dws_spl_th_user_df
    where grass_date between '${begin_ds}' and '${ds}'
) t5
on t1.user_id = t5.user_id
    and t1.grass_date = t5.grass_date
left join
(
    select
        credit_user_id as user_id
        ,days_after_first_due_date_floating as days_after_first_due_date_spl_floating
        ,lastest_max_dpd_eod_120d_bill as latest_dpd_eod_cashloan
        ,grass_date
    from credit_mart.dws_bcl_th_user_risk_df
    where grass_date between '${begin_ds}' and '${ds}'
) t6
on t1.user_id = t6.user_id
    and t1.grass_date = t6.grass_date
left join
(
    select
        credit_user_id as user_id
        ,lastest_max_dpd_eod_120d_spl as latest_dpd_eod_spl
        ,ever_max_dpd_30d_chp
        ,ever_max_dpd_90d_chp
        ,ever_max_dpd_180d_chp
        ,ever_max_dpd_360d_chp
        ,ever_max_dpd_chp
        ,days_after_first_due_date_chp
        ,grass_date
    from credit_mart.dws_spl_th_user_risk_df
    where grass_date between '${begin_ds}' and '${ds}'
) t7
on t1.user_id = t7.user_id
    and t1.grass_date = t7.grass_date
left join
(
    select
        credit_user_id as user_id
        ,ever_max_dpd_30d as ever_max_dpd_30d_tl
        ,ever_max_dpd_90d as ever_max_dpd_90d_tl
        ,ever_max_dpd_180d as ever_max_dpd_180d_tl
        ,ever_max_dpd_360d as ever_max_dpd_360d_tl
        ,historical_max_dpd_eod as ever_max_dpd_tl
        ,grass_date
    from credit_mart.dws_tl_th_user_risk_df
    where grass_date between '${begin_ds}' and '${ds}'
) t8
on t1.user_id = t8.user_id
    and t1.grass_date = t8.grass_date
;

