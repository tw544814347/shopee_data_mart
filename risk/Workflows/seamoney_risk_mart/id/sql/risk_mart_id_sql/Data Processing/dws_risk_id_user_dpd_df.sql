--********************************************************************--
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2023-10-23T14:00:00
-- Description:         计算用户所有产品，spl/bcl/scl 逾期情况
-- Data Granularity:    user_id (credit_user_id)
-- PRD                 
-- Jira      
-- v1 Update by xiaobin.qiu@shopee.com 2023-10-31 去掉了没有用的表ods__credit_core_debt_spl_id_db__bill_tab__df， 有账单的用户，一定在User表里面
--    msck repair table risk.dws_risk_id_user_dpd_df; 修改为 msck repair table ${SCHEMA}.dws_risk_id_user_dpd_df;
-- v2  update by zongyi.lu@shopee,com 2024-04-09 新增字段
--     days_after_first_due_date_cashloan_floating -> dws_bcl_id_user_df|dws_scl_id_user_df.days_after_first_due_date_floating
--     latest_dpd_eod_cashloan  -> credit_mart.wide_bcl_id_behavior_user_df.lastest_max_dpd_eod_120d
-- v3 业务系统floating due date迭代,没有bill逻辑了,credit_mart.dws_bcl_id_user_df.days_after_first_due_date改为取'2024-04-11'历史分区的数据；业务后续切换至days_after_first_due_date_cashloan_floating指标
-- v4 1) 2024-09-10, credit_mart.tdm_id_user_dpd_df,credit_mart.dws_spl_id_user_df表因为销户再激活场景，credit_user_id有重复，加上去重逻辑
--    2) credit_mart.dws_bcl_id_user_df表2024-04-11已下线，保存替换到归档表risk.dws_bcl_id_user_df__archive
-- BAU update by chenyingying 2026-04-08 新增smetl字段
--********************************************************************--

create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

INSERT OVERWRITE TABLE ${SCHEMA}.dws_risk_id_user_dpd_df PARTITION (grass_date)
select
    t1.user_id
     ,coalesce(t3.historical_max_dpd_eod,-9999)                 as ever_max_dpd_spl_core
     ,coalesce(t3.historical_max_dpd_lite,-9999)            as ever_max_dpd_spl_lite_core
     ,coalesce(t3.historical_max_dpd_normal,-9999)          as ever_max_dpd_spl_normal_core
     ,coalesce(t5.days_after_first_due_date, -9999)            as days_after_first_due_date_spl
     ,coalesce(t5.ever_max_dpd_180d, -9999)                    as ever_max_dpd_180d_spl
     ,coalesce(t5.ever_max_dpd_360d, -9999)                    as ever_max_dpd_360d_spl
     ,coalesce(t4_1.days_after_first_due_date, -9999)            as days_after_first_due_date_cashloan
     ,coalesce(t4.ever_max_dpd_180d, -9999)                    as ever_max_dpd_180d_cashloan
     ,coalesce(t4.ever_max_dpd_360d, -9999)                    as ever_max_dpd_360d_cashloan
     ,coalesce(
        case when t4.ever_max_dpd_180d is null then t5.ever_max_dpd_180d
             when t5.ever_max_dpd_180d is null then t4.ever_max_dpd_180d
             when t4.ever_max_dpd_180d > t5.ever_max_dpd_180d then t4.ever_max_dpd_180d
             else t5.ever_max_dpd_180d
            end, -9999)                                        as ever_max_dpd_180d_user
     ,coalesce(
        case when t4.ever_max_dpd_360d is null then t5.ever_max_dpd_360d
             when t5.ever_max_dpd_360d is null then t4.ever_max_dpd_360d
             when t4.ever_max_dpd_360d > t5.ever_max_dpd_360d then t4.ever_max_dpd_360d
             else t5.ever_max_dpd_360d
            end, -9999)                                        as ever_max_dpd_360d_user
      ,coalesce(t4.ever_max_dpd_cashloan_core   ,-9999)        as ever_max_dpd_cashloan_core   
      ,coalesce(t4.last_bill_dpd_cashloan_core  ,-9999)        as last_bill_dpd_cashloan_core  
      ,coalesce(t7.ever_max_dpd_sellerloan_core ,-9999)        as ever_max_dpd_sellerloan_core 
      ,coalesce(t7.last_bill_dpd_sellerloan_core,-9999)        as last_bill_dpd_sellerloan_core
      ,coalesce(t7.ever_max_dpd_30d ,-9999) as ever_max_dpd_30d_scl
      ,coalesce(t7.ever_max_dpd_90d ,-9999) as ever_max_dpd_90d_scl
      ,coalesce(t7.ever_max_dpd_180d,-9999) as ever_max_dpd_180d_scl
      ,coalesce(t7.ever_max_dpd_360d,-9999) as ever_max_dpd_360d_scl
      ,coalesce(t5.ever_max_dpd_30d ,-9999) as ever_max_dpd_30d_spl
      ,coalesce(t5.ever_max_dpd_90d ,-9999) as ever_max_dpd_90d_spl
      ,coalesce(t4.ever_max_dpd_30d ,-9999) as ever_max_dpd_30d_bcl
      ,coalesce(t4.ever_max_dpd_90d ,-9999) as ever_max_dpd_90d_bcl    
      ,coalesce(t5.ever_max_dpd_chp ,-9999) as ever_max_dpd_chp    
      ,coalesce(t5.ever_max_dpd_chp_180d ,-9999) as ever_max_dpd_chp_180d    
      ,coalesce(t5.ever_max_dpd_chp_360d ,-9999) as ever_max_dpd_chp_360d    
      ,coalesce(t4.days_after_first_due_date_cashloan_floating ,-9999) as days_after_first_due_date_cashloan_floating 
      ,coalesce(t8.latest_dpd_eod_cashloan ,-9999) as latest_dpd_eod_cashloan
      ,coalesce(t9.latest_dpd_eod_spl ,-9999) as latest_dpd_eod_spl
      ,coalesce(t9.latest_dpd_eod_chp ,-9999) as latest_dpd_eod_chp
      ,coalesce(t5.ever_max_dpd_30d_chp ,-9999) as ever_max_dpd_30d_chp
      ,coalesce(t5.ever_max_dpd_180d_chp ,-9999) as ever_max_dpd_180d_chp
      ,coalesce(t10.latest_dpd_eod_tl ,-9999) as latest_dpd_eod_tl
      ,coalesce(t11.ever_max_dpd_30d_tl ,-9999) as ever_max_dpd_30d_tl
      ,coalesce(t11.ever_max_dpd_180d_tl ,-9999) as ever_max_dpd_180d_tl
      ,coalesce(t12.ever_max_dpd_30d_smetl, -9999)  as ever_max_dpd_30d_smetl
      ,coalesce(t12.ever_max_dpd_90d_smetl, -9999)  as ever_max_dpd_90d_smetl
      ,coalesce(t12.ever_max_dpd_180d_smetl, -9999)  as ever_max_dpd_180d_smetl
      ,coalesce(t12.ever_max_dpd_360d_smetl, -9999)  as ever_max_dpd_360d_smetl
      ,t1.grass_date
from
    (
        select
            credit_user_id as user_id
            ,grass_date
        from credit_uc.dws_aio_id_uc_user_df
        where grass_date between '${begin_ds}' and '${ds}'
        and credit_user_id is not null
        group by credit_user_id, grass_date
    )t1
        left join
    (
        select
            credit_user_id as user_id
             ,max(historical_max_dpd_eod) as historical_max_dpd_eod
             ,max(historical_max_dpd_lite) as historical_max_dpd_lite
             ,max(historical_max_dpd_normal) as historical_max_dpd_normal
             ,grass_date
        from
            credit_mart.tdm_id_user_dpd_df
        where
            grass_date between '${begin_ds}' and '${ds}'
        group by credit_user_id, grass_date
    ) t3
    on  t1.user_id = t3.user_id
        and t1.grass_date=t3.grass_date
    left join
    (
        select
            credit_user_id              as user_id
             ,ever_max_dpd_30d          as ever_max_dpd_30d
             ,ever_max_dpd_90d          as ever_max_dpd_90d
             ,ever_max_dpd_180d         as ever_max_dpd_180d
             ,ever_max_dpd_360d         as ever_max_dpd_360d
             ,historical_max_dpd_eod    as ever_max_dpd_cashloan_core
             ,last_bill_dpd             as last_bill_dpd_cashloan_core
             ,days_after_first_due_date_floating as days_after_first_due_date_cashloan_floating
             ,grass_date                as grass_date
        from credit_mart.dws_bcl_id_user_df
        where grass_date between '${begin_ds}' and '${ds}'
    ) as t4 on t1.user_id=t4.user_id and t1.grass_date=t4.grass_date
    left join
    (
        select 
            credit_user_id              as user_id
            ,days_after_first_due_date  as days_after_first_due_date
        from risk.dws_bcl_id_user_df__archive
    ) t4_1 on t1.user_id=t4_1.user_id
    left join
    (
        select
            credit_user_id as user_id
             ,max(days_after_first_due_date) as days_after_first_due_date
             ,max(ever_max_dpd_30d)         as ever_max_dpd_30d
             ,max(ever_max_dpd_90d)         as ever_max_dpd_90d
             ,max(ever_max_dpd_180d) as ever_max_dpd_180d
             ,max(ever_max_dpd_360d) as ever_max_dpd_360d
             ,max(ever_max_dpd_chp) as ever_max_dpd_chp
             ,max(ever_max_dpd_30d_chp) as ever_max_dpd_30d_chp
             ,max(ever_max_dpd_chp_180d) as ever_max_dpd_chp_180d  --老逻辑
             ,max(ever_max_dpd_chp_360d) as ever_max_dpd_chp_360d
             ,max(ever_max_dpd_180d_chp) as ever_max_dpd_180d_chp --新逻辑
             ,grass_date
        from credit_mart.dws_spl_id_user_df
        where grass_date between '${begin_ds}' and '${ds}'
        group by credit_user_id, grass_date
    ) as t5 on t1.user_id=t5.user_id and t1.grass_date=t5.grass_date
    left join 
    (
        select 
            credit_user_id           as user_id
            ,historical_max_dpd_eod  as ever_max_dpd_sellerloan_core
            ,last_bill_dpd           as last_bill_dpd_sellerloan_core
            ,ever_max_dpd_30d        as ever_max_dpd_30d
            ,ever_max_dpd_90d        as ever_max_dpd_90d
            ,ever_max_dpd_180d
            ,ever_max_dpd_360d
            ,grass_date          as grass_date
        from credit_mart.dws_scl_id_user_df 
        where grass_date between '${begin_ds}' and '${ds}'
    ) t7 on t1.user_id = t7.user_id and t1.grass_date = t7.grass_date
    left join (
        select 
            credit_user_id            as user_id
            ,lastest_max_dpd_eod_120d as latest_dpd_eod_cashloan
            ,grass_date               as grass_date
        from credit_mart.wide_bcl_id_behavior_user_df 
        where grass_date between '${begin_ds}' and '${ds}'
    ) t8 on t1.user_id =t8.user_id and t1.grass_date = t8.grass_date
    left join(
        select 
            credit_user_id            as user_id
            ,lastest_max_dpd_eod_120d_spl as latest_dpd_eod_spl
            ,lastest_max_dpd_eod_120d_chp as latest_dpd_eod_chp
            ,grass_date               as grass_date
        from credit_mart.dws_spl_id_user_risk_df 
        where grass_date between '${begin_ds}' and '${ds}'   
    ) t9 on t1.user_id =t9.user_id and t1.grass_date = t9.grass_date
    left join(
        select 
            credit_user_id            as user_id
            ,lastest_max_dpd_eod_120d as latest_dpd_eod_tl
            ,grass_date               as grass_date
        from credit_mart.dws_tl_id_user_risk_df 
        where grass_date between '${begin_ds}' and '${ds}'   
    ) t10 on t1.user_id =t10.user_id and t1.grass_date = t10.grass_date
    left join(
        select 
            credit_user_id            as user_id
            ,ever_max_dpd_30d         as ever_max_dpd_30d_tl
            ,ever_max_dpd_180d        as ever_max_dpd_180d_tl
            ,grass_date               as grass_date
        from credit_mart.dws_tl_id_user_df 
        where grass_date between '${begin_ds}' and '${ds}'   
    ) t11 on t1.user_id =t11.user_id and t1.grass_date = t11.grass_date
    left join (
        select      credit_user_id,      
                    max(if(datediff(date(grass_date), date(month_due_time)) <= 30, max_dpd_eod, null)) as ever_max_dpd_30d_smetl,     
                    max(if(datediff(date(grass_date), date(month_due_time)) <= 90, max_dpd_eod, null)) as ever_max_dpd_90d_smetl,     
                    max(if(datediff(date(grass_date), date(month_due_time)) <= 180, max_dpd_eod, null)) as ever_max_dpd_180d_smetl,    
                    max(if(datediff(date(grass_date), date(month_due_time)) <= 360, max_dpd_eod, null)) as ever_max_dpd_360d_smetl,  
                    grass_date  
        FROM credit_mart.dws_stl_id_instalment_repayment_df
        WHERE grass_date = '${ds}'     
        and biz_type = 14
        GROUP BY credit_user_id, grass_date
    ) t12 on t1.user_id = t12.credit_user_id and t1.grass_date = t12.grass_date
;



msck repair table ${SCHEMA}.dws_risk_id_user_dpd_df;

