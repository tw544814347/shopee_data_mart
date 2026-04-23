create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp'
;

insert overwrite table ${SCHEMA}.dws_risk_br_user_dpd_df partition (grass_date)
select  t1.user_id
        ,coalesce(t3.historical_max_dpd_eod, -9999) as ever_max_dpd_cashloan_core
        ,coalesce(t3.last_bill_dpd, -9999) as last_bill_dpd_cashloan_core
        ,null as ever_max_dpd_sellerloan_core
        ,null as last_bill_dpd_sellerloan_core
        ,coalesce(t5.historical_max_dpd_eod, -9999) as ever_max_dpd_spl_core
        ,coalesce(t5.last_bill_dpd, -9999) as last_bill_dpd_spl_core
        ,coalesce(t5.days_after_first_due_date, -9999) as days_after_first_due_date_spl
        ,coalesce(t5.ever_max_dpd_180d, -9999) as ever_max_dpd_180d_spl
        ,coalesce(t5.ever_max_dpd_360d, -9999) as ever_max_dpd_360d_spl
        ,coalesce(t3.days_after_first_due_date, -9999) as days_after_first_due_date_cashloan
        ,coalesce(t3.ever_max_dpd_180d, -9999) as ever_max_dpd_180d_cashloan
        ,coalesce(t3.ever_max_dpd_360d, -9999) as ever_max_dpd_360d_cashloan
        ,coalesce(case when t3.ever_max_dpd_180d is null then t5.ever_max_dpd_180d
            when t5.ever_max_dpd_180d is null then t3.ever_max_dpd_180d
            when t3.ever_max_dpd_180d > t5.ever_max_dpd_180d then t3.ever_max_dpd_180d
            else t5.ever_max_dpd_180d
            end, -9999) as ever_max_dpd_180d_user
        ,coalesce(case when t3.ever_max_dpd_360d is null then t5.ever_max_dpd_360d
            when t5.ever_max_dpd_360d is null then t3.ever_max_dpd_360d
            when t3.ever_max_dpd_360d > t5.ever_max_dpd_360d then t3.ever_max_dpd_360d
            else t5.ever_max_dpd_360d
            end, -9999) as ever_max_dpd_360d_user
        ,null as ever_max_dpd_30d_scl
        ,null as ever_max_dpd_90d_scl
        ,null as ever_max_dpd_180d_scl
        ,null as ever_max_dpd_360d_scl
        ,coalesce(t5.ever_max_dpd_30d, -9999) as ever_max_dpd_30d_spl
        ,coalesce(t5.ever_max_dpd_90d, -9999) as ever_max_dpd_90d_spl
        ,coalesce(t3.ever_max_dpd_30d, -9999) as ever_max_dpd_30d_bcl
        ,coalesce(t3.ever_max_dpd_90d, -9999) as ever_max_dpd_90d_bcl
        ,coalesce(t5.current_max_dpd, -9999) as current_dpd_spl
        ,coalesce(t6.latest_dpd_spl, -9999) as latest_dpd_spl
        ,coalesce(ads_tab.latest_dpd_eod_cashloan ,-9999) as latest_dpd_eod_cashloan
        ,t3.current_dpd_eod_bcl
        ,t1.grass_date
from    (
    select
        credit_user_id as user_id
        ,grass_date
    from credit_uc.dws_aio_br_uc_user_df
    where grass_date = '${grass_date}'
    and credit_user_id <> ''
    group by credit_user_id, grass_date
) t1
left join (
    select  credit_user_id as user_id
            ,historical_max_dpd_eod
            ,last_bill_dpd
            ,days_after_first_due_date
            ,ever_max_dpd_30d
            ,ever_max_dpd_90d
            ,ever_max_dpd_180d
            ,ever_max_dpd_360d
            ,current_dpd_eod as current_dpd_eod_bcl
            ,grass_date
    from    credit_mart.dws_bcl_br_user_df
    where   grass_date between '${begin_ds}'
      and   '${ds}'
) t3
on      t1.user_id = t3.user_id
  and   t1.grass_date = t3.grass_date
left join (
    select  credit_user_id as user_id
            ,historical_max_dpd_eod
            ,last_bill_dpd
            ,days_after_first_due_date
            ,ever_max_dpd_30d
            ,ever_max_dpd_90d
            ,ever_max_dpd_180d
            ,ever_max_dpd_360d
            ,current_max_dpd
            ,grass_date
    from    credit_mart.dws_spl_br_user_df
    where   grass_date between '${begin_ds}'
      and   '${ds}'
) t5
on      t1.user_id = t5.user_id
  and   t1.grass_date = t5.grass_date
left join (
    select  credit_user_id
            ,grass_date
            ,dpd as latest_dpd_spl
    from    (
        select  credit_user_id
                ,dpd
                ,grass_date
                ,ROW_NUMBER() OVER (PARTITION BY credit_user_id ORDER BY rownum) AS rank
        from    (
            select  credit_user_id
                    ,bill_id
                    ,case   when grass_date < substr(month_due_time, 1, 10) and clear_time is null then -1
                            else dpd
                     end as dpd
                    ,grass_date
                    ,rownum
            from    (
                select  credit_user_id
                        ,bill_id
                        ,total_amount_os
                        ,dpd
                        ,clear_time
                        ,month_due_time
                        ,total_amount_repayable
                        ,total_amount_refund
                        ,total_amount_deduct
                        ,ROW_NUMBER() OVER (PARTITION BY credit_user_id ORDER BY month_due_time desc) AS rownum
                        ,grass_date
                from    credit_mart.dws_spl_br_bill_repayment_df
                where   grass_date = '${ds}'
                  and   bill_status in(2, 3)
                  and   biz_type = 3
            ) t1
            where   rownum <= 4
              and   total_amount_repayable - total_amount_refund - total_amount_deduct  > 0 
        ) t2
        where   dpd >= 0
    ) t3
    where   rank = 1
) t6 
on      t1.user_id = t6.credit_user_id
  and   t1.grass_date = t6.grass_date
-- left join risk.ads_behavior_underwrting_feature_df ads_tab
-- on t1.user_id = ads_tab.credit_user_id and t1.grass_date = ads_tab.grass_date
-- WHERE ads_tab.grass_region = 'BR'

left join
    (
        select 
            credit_user_id            as credit_user_id
            ,lastest_max_dpd_eod_120d as latest_dpd_eod_cashloan
            ,grass_date               as grass_date
        from credit_mart.wide_bcl_${region_lower}_behavior_user_df 
        where grass_date between '${ds}' and '${ds}'
    ) as ads_tab
    on t1.user_id = ads_tab.credit_user_id and t1.grass_date = ads_tab.grass_date
-- WHERE ads_tab.grass_region = 'BR'
;

