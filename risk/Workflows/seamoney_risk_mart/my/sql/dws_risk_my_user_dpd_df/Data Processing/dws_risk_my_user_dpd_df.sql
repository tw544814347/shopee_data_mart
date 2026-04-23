INSERT OVERWRITE TABLE ${SCHEMA}.dws_risk_my_user_dpd_df PARTITION (grass_date)
select
    k.credit_user_id
    -- ,coalesce(a.historical_max_dpd_eod, -9999)                    as ever_max_dpd_spl
    ,coalesce(b.days_after_first_due_date, -9999)             as days_after_first_due_date_spl
    ,coalesce(b.ever_max_dpd_180d, -9999)                     as ever_max_dpd_180d_spl
    ,coalesce(b.ever_max_dpd_360d, -9999)                     as ever_max_dpd_360d_spl
    ,coalesce(c.days_after_first_due_date, -9999)             as days_after_first_due_date_cashloan
    ,coalesce(c.ever_max_dpd_180d, -9999)                     as ever_max_dpd_180d_cashloan
    ,coalesce(c.ever_max_dpd_360d, -9999)                     as ever_max_dpd_360d_cashloan
    ,coalesce(
        case when c.ever_max_dpd_180d is null then b.ever_max_dpd_180d
             when b.ever_max_dpd_180d is null then c.ever_max_dpd_180d
             when c.ever_max_dpd_180d > b.ever_max_dpd_180d then c.ever_max_dpd_180d
             else b.ever_max_dpd_180d
        end, -9999)                                           as ever_max_dpd_180d_user
    ,coalesce(
        case when c.ever_max_dpd_360d is null then b.ever_max_dpd_360d
             when b.ever_max_dpd_360d is null then c.ever_max_dpd_360d
             when c.ever_max_dpd_360d > b.ever_max_dpd_360d then c.ever_max_dpd_360d
             else b.ever_max_dpd_360d
        end, -9999)                                            as ever_max_dpd_360d_user
    ,coalesce(c.historical_max_dpd_eod   ,-9999)                   as ever_max_dpd_cashloan_core
    ,coalesce(c.last_bill_dpd  ,-9999)                         as last_bill_dpd_cashloan_core  
    ,coalesce(d.historical_max_dpd_eod ,-9999)                     as ever_max_dpd_sellerloan_core 
    ,coalesce(d.last_bill_dpd,-9999)                           as last_bill_dpd_sellerloan_core
    ,coalesce(e.repaid_bills_num    ,-9999)                    as repaid_bills_num_cashloan    
    ,coalesce(e.lastest_bill_max_dpd_120d          ,-9999)     as latest_dpd_cashloan 
    ,coalesce(b.historical_max_dpd_eod          ,-9999)            as ever_max_dpd_spl_core   
    ,coalesce(b.last_bill_dpd          ,-9999)                 as last_bill_dpd_spl_core 
    ,coalesce(d.ever_max_dpd_30d ,-9999) as ever_max_dpd_30d_scl
    ,coalesce(d.ever_max_dpd_90d ,-9999) as ever_max_dpd_90d_scl
    ,coalesce(d.ever_max_dpd_180d,-9999) as ever_max_dpd_180d_scl
    ,coalesce(d.ever_max_dpd_360d,-9999) as ever_max_dpd_360d_scl
    ,coalesce(b.ever_max_dpd_30d ,-9999) as ever_max_dpd_30d_spl
    ,coalesce(b.ever_max_dpd_90d ,-9999) as ever_max_dpd_90d_spl
    ,coalesce(c.ever_max_dpd_30d ,-9999) as ever_max_dpd_30d_bcl
    ,coalesce(c.ever_max_dpd_90d ,-9999) as ever_max_dpd_90d_bcl
    ,coalesce(c.ever_max_dpd_180d ,-9999) as ever_max_dpd_180d_bcl
    ,coalesce(f.lastest_max_dpd_eod_120d_spl ,-9999) as latest_dpd_eod_spl
    ,coalesce(g.lastest_max_dpd_eod_120d ,-9999) as latest_dpd_eod_bcl
    ,k.grass_date
from (
    select
        credit_user_id
        ,grass_date
    from credit_uc.dws_aio_my_uc_user_df
    where grass_date = '${grass_date}'
    and credit_user_id <> ''
    group by credit_user_id, grass_date
) k
-- left join credit.dim_spl_my_user_info_df__sensitive a on k.credit_user_id=a.credit_user_id and a.grass_date='${grass_date}'
left join credit_mart.dws_spl_my_user_df b on k.credit_user_id=b.credit_user_id and b.grass_date='${grass_date}'
left join credit_mart.dws_bcl_my_user_df c on k.credit_user_id=c.credit_user_id and c.grass_date='${grass_date}'
left join credit_mart.dws_scl_my_user_df d on k.credit_user_id=d.credit_user_id and d.grass_date='${grass_date}'
left join (
    select 
        credit_user_id
        ,repaid_bills_num
        ,lastest_bill_max_dpd_120d
        ,grass_date
    from credit_mart.wide_bcl_my_behavior_user_df 
    where grass_date='${grass_date}'
) e on k.credit_user_id=e.credit_user_id and k.grass_date=e.grass_date
left join credit_mart.dws_spl_my_user_risk_df f on k.credit_user_id=f.credit_user_id and f.grass_date='${grass_date}'
left join credit_mart.dws_bcl_my_user_risk_df g on k.credit_user_id=g.credit_user_id and g.grass_date='${grass_date}'
;

msck repair table risk.dws_risk_my_user_dpd_df;