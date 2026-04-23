--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-11-11
-- Theme Domain：       risk-feature
-- Description:         spl/bcl/chp user_behavior underwirting feature
-- Data Granularity:    credit_user_id, jira https://jira.shopee.io/browse/SPFDT-46025
--                      prd： https://docs.google.com/spreadsheets/d/1taFFfk6IzhYmSkpO2LYZ9wT72iPI4pLKLamuEviTfjM/edit?gid=903859448#gid=903859448
-- 变更历史：
--  update by zongyi.lu@shopee.com 2024-11-11 由于credit mart 还没加上chp相关的字段 historical_max_dpd_eod_chp之后的字段都先给null,等业务上线后再添加
--  update by chenyingying  2026-03-19 DFS迁移重构
--********************************************************************--
create or replace temporary view tmp_th_user_account_status as
    select 
    user_id as platform_user_id
    ,status as shopee_account_status
    from mp_user.dim_user__reg_s0_live
    where tz_type = 'local'
    and grass_region = 'TH'
    and grass_date = '${grass_date}'
;


insert overwrite table ${SCHEMA}.ads_behavior_th_underwrting_feature_df partition(grass_date='${ds}')
select t1.credit_user_id
        ,t1.shopee_account_status   as shopee_account_status
        ,t2.average_limit_utilization_in_30d_spl 
        ,t2.average_limit_utilization_in_90d_spl 
        ,t2.average_limit_utilization_in_180d_spl
        ,t2.max_limit_utilization_in_30d_spl     
        ,t2.max_limit_utilization_in_90d_spl     
        ,t2.max_limit_utilization_in_180d_spl    
        ,t2.average_limit_utilization_in_30d_bcl 
        ,t2.average_limit_utilization_in_90d_bcl 
        ,t2.average_limit_utilization_in_180d_bcl
        ,t2.max_limit_utilization_in_30d_bcl     
        ,t2.max_limit_utilization_in_90d_bcl     
        ,t2.max_limit_utilization_in_180d_bcl    
        ,t2.average_limit_utilization_in_30d_chp 
        ,t2.average_limit_utilization_in_90d_chp 
        ,t2.average_limit_utilization_in_180d_chp
        ,t2.max_limit_utilization_in_30d_chp     
        ,t2.max_limit_utilization_in_90d_chp     
        ,t2.max_limit_utilization_in_180d_chp 
        ,t3.ever_max_dpd_chp              
        ,t3.preloan_reject_cnt_chp        
        ,t3.preloan_reject_cnt_90d_chp    
        ,t3.preloan_reject_cnt_180d_chp   
        ,t3.days_after_first_due_date_chp 
        ,t3.ever_max_dpd_180d_chp         
        ,t3.ever_max_dpd_360d_chp         
        ,t3.first_postloan_reject_date_chp
        ,t2.average_limit_utilization_in_30d_tl 
        ,t2.average_limit_utilization_in_90d_tl 
        ,t2.average_limit_utilization_in_180d_tl
        ,t2.average_limit_utilization_in_360d_tl
        ,t2.max_limit_utilization_in_30d_tl     
        ,t2.max_limit_utilization_in_90d_tl     
        ,t2.max_limit_utilization_in_180d_tl    
        ,t2.max_limit_utilization_in_360d_tl    
from (
    select 
        tt1.credit_user_id
        ,max(tt2.shopee_account_status) as shopee_account_status
    from
    ( 
    select credit_user_id,account_label,platform_user_id from credit_uc.dws_spl_th_uc_user_df where grass_date='${grass_date}' 
    union 
    select credit_user_id,null as account_label,platform_user_id from credit_uc.dws_bcl_th_uc_user_df where grass_date='${grass_date}'
    ) tt1 
    left join tmp_th_user_account_status tt2 on tt1.platform_user_id = tt2.platform_user_id 
    where tt1.credit_user_id is not null 
    group  by credit_user_id
) t1
left join (
    select credit_user_id
            ,average_limit_utilization_in_30d_spl 
            ,average_limit_utilization_in_90d_spl 
            ,average_limit_utilization_in_180d_spl
            ,max_limit_utilization_in_30d_spl     
            ,max_limit_utilization_in_90d_spl     
            ,max_limit_utilization_in_180d_spl    
            ,average_limit_utilization_in_30d_bcl 
            ,average_limit_utilization_in_90d_bcl 
            ,average_limit_utilization_in_180d_bcl
            ,max_limit_utilization_in_30d_bcl     
            ,max_limit_utilization_in_90d_bcl     
            ,max_limit_utilization_in_180d_bcl    
            ,average_limit_utilization_in_30d_chp 
            ,average_limit_utilization_in_90d_chp 
            ,average_limit_utilization_in_180d_chp
            ,max_limit_utilization_in_30d_chp     
            ,max_limit_utilization_in_90d_chp     
            ,max_limit_utilization_in_180d_chp    
            ,average_limit_utilization_in_30d_tl 
            ,average_limit_utilization_in_90d_tl 
            ,average_limit_utilization_in_180d_tl
            ,average_limit_utilization_in_360d_tl
            ,max_limit_utilization_in_30d_tl     
            ,max_limit_utilization_in_90d_tl     
            ,max_limit_utilization_in_180d_tl    
            ,max_limit_utilization_in_360d_tl    
    from    risk_feature.dws_risk_th_user_info_credit_feature_df
    where   grass_date = '${ds}'   
) t2
on t1.credit_user_id = t2.credit_user_id
left join (
    select  credit_user_id
            ,ever_max_dpd_chp              
            ,preloan_reject_cnt_chp        
            ,preloan_reject_cnt_90d_chp    
            ,preloan_reject_cnt_180d_chp   
            ,days_after_first_due_date_chp 
            ,ever_max_dpd_180d_chp         
            ,ever_max_dpd_360d_chp         
            ,first_postloan_reject_date_chp
    from    risk_feature.dws_risk_th_user_txn_credit_feature_df
    where   grass_date = '${ds}'
) t3
on t1.credit_user_id = t3.credit_user_id