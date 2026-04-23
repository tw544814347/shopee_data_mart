--********************************************************************--
-- Author:              huangwei@shopee.com
-- Created Time:        2024-02-19
-- Theme Domain：       risk-feature
-- Description:         vn spl/bcl/scl user_behavior underwirting feature
-- Data Granularity:    credit_user_id
-- 变更历史：
--      update by zongyi.lu@shopee.com，2024-02-19 新增vn spl相关feature  https://jira.shopee.io/browse/SPFDT-30849
--      vn 没有bill 因此 first_billed_from_now_spl/repaid_bills_num_user 给null
--      update by chenyingying  2026-03-19 DFS迁移重构
--********************************************************************--
create or replace temporary view tmp_spl_vn_user_account_status as
    select 
    user_id as platform_user_id
    ,status as shopee_account_status
    from mp_user.dim_user__reg_s0_live
    where tz_type = 'local'
    and grass_region = 'VN'
    and grass_date = '${ds}'
;

insert overwrite table ${SCHEMA}.ads_behavior_underwrting_feature_df partition (grass_region='VN',grass_date='${ds}')
select t1.credit_user_id

        ,t2.account_label spl_user_tag  

        ,t3.first_billed_from_now_spl        
        ,t3.first_billed_from_now_bcl

        ,null first_billed_from_now            
        ,null repaid_bills_num_user  

        ,t2.credit_user_status  credit_user_status          
        ,null is_limit_decrease_spl            
        ,null is_limit_decrease_bcl

        ,t3.os_spl os_spl                           
        ,t3.os_bcl os_bcl 

        ,t3.eir_tenure2_bcl     eir_tenure2_bcl                  
        ,t3.eir_tenure3_bcl     eir_tenure3_bcl                  
        ,t3.eir_tenure6_bcl     eir_tenure6_bcl                  
        ,t3.eir_tenure12_bcl    eir_tenure12_bcl                 
        ,t3.eir_tenure1_spl     eir_tenure1_spl                  
        ,t3.eir_tenure2_spl     eir_tenure2_spl                  
        ,t3.eir_tenure3_spl     eir_tenure3_spl                  
        ,t3.eir_tenure6_spl     eir_tenure6_spl                  
        ,t3.eir_tenure12_spl    eir_tenure12_spl                 
        ,t3.eir_tenure18_spl    eir_tenure18_spl                 
        ,t3.eir_tenure24_spl    eir_tenure24_spl  

        ,t3.repaid_bills_num_cashloan as repaid_bills_num_cashloan     -- original not null   
        ,t3.latest_dpd_eod_cashloan latest_dpd_cashloan -- original not null             
        
        ,t2.average_limit_utilization_90d_spl
        ,t2.average_limit_utilization_180d_spl
        ,t2.max_limit_utilization_90d_spl    
        ,t2.max_limit_utilization_180d_spl   
        ,t2.average_limit_utilization_90d_bcl
        ,t2.average_limit_utilization_180d_bcl
        ,t2.max_limit_utilization_90d_bcl    
        ,t2.max_limit_utilization_180d_bcl   

        ,t1.shopee_account_status    shopee_account_status  -- 已转换
        
        ,case when t3.eir_tenure1_spl >0  or t3.eir_tenure1_spl  is not null then 1 else 0 end   as eligible_tenure1_spl 
        ,case when t3.eir_tenure2_spl >0  or t3.eir_tenure2_spl  is not null then 1 else 0 end   as eligible_tenure2_spl 
        ,case when t3.eir_tenure3_spl >0  or t3.eir_tenure3_spl  is not null then 1 else 0 end   as eligible_tenure3_spl 
        ,case when t3.eir_tenure6_spl >0  or t3.eir_tenure6_spl  is not null then 1 else 0 end   as eligible_tenure6_spl 
        ,case when t3.eir_tenure12_spl >0 or t3.eir_tenure12_spl is not null then 1 else 0 end   as eligible_tenure12_spl
        ,case when t3.eir_tenure18_spl >0 or t3.eir_tenure18_spl is not null then 1 else 0 end   as eligible_tenure18_spl
        ,case when t3.eir_tenure24_spl >0 or t3.eir_tenure24_spl is not null then 1 else 0 end   as eligible_tenure24_spl    
        ,null    first_billed_from_now_bcl_floatin
        ,null    first_billed_from_now_floating   
        ,null    repaid_bills_num_user_floating   
        ,null    last_chp_disburse_time           
        ,null    first_spl_disburse_time          
        ,null    is_bcl_disbursed                 
        ,null    repaid_bills_num_bcl             
        ,null    repaid_bills_num_chp             
        ,null    repaid_bills_num_spl             
        ,null    is_spl_disbursed                 
        ,null    is_chp_disbursed                 

        ,null   average_limit_utilization_1d_spl 
        ,null   average_limit_utilization_3d_spl 
        ,null   average_limit_utilization_7d_spl 
        ,null   average_limit_utilization_14d_spl
        ,null   average_limit_utilization_30d_spl
        ,null   max_limit_utilization_1d_spl     
        ,null   max_limit_utilization_3d_spl     
        ,null   max_limit_utilization_7d_spl     
        ,null   max_limit_utilization_14d_spl    
        ,null   max_limit_utilization_30d_spl    
        ,null   average_limit_utilization_1d_bcl 
        ,null   average_limit_utilization_3d_bcl 
        ,null   average_limit_utilization_7d_bcl 
        ,null   average_limit_utilization_14d_bcl
        ,null   average_limit_utilization_30d_bcl
        ,null   max_limit_utilization_1d_bcl     
        ,null   max_limit_utilization_3d_bcl     
        ,null   max_limit_utilization_7d_bcl     
        ,null   max_limit_utilization_14d_bcl    
        ,null   max_limit_utilization_30d_bcl       
from (
    select 
        a.credit_user_id,
        max(a.account_label)         as account_label,
        max(b.shopee_account_status) as shopee_account_status
    from
    (
    select credit_user_id,account_label,platform_user_id from credit_uc.dws_spl_vn_uc_user_df where grass_date='${ds}' 
    union 
    select credit_user_id,null as account_label,platform_user_id from credit_uc.dws_bcl_vn_uc_user_df where grass_date='${ds}'
    ) a 
    left join tmp_spl_vn_user_account_status b on a.platform_user_id = b.platform_user_id
    where  a.credit_user_id <> '0'
    group  by a.credit_user_id
) t1
left join (
    select credit_user_id
            ,account_label
            ,credit_user_status
            ,average_limit_utilization_90d_spl
            ,average_limit_utilization_180d_spl
            ,max_limit_utilization_90d_spl
            ,max_limit_utilization_180d_spl
            ,average_limit_utilization_90d_bcl
            ,average_limit_utilization_180d_bcl
            ,max_limit_utilization_90d_bcl
            ,max_limit_utilization_180d_bcl
    from    risk_feature.dws_risk_vn_user_info_credit_feature_df
    where   grass_date = '${ds}'
) t2
on t1.credit_user_id = t2.credit_user_id
left join (
    select  credit_user_id
            ,first_billed_from_now_spl
            ,first_billed_from_now_bcl
            ,os_spl
            ,os_bcl
            ,eir_tenure2_bcl
            ,eir_tenure3_bcl
            ,eir_tenure6_bcl
            ,eir_tenure12_bcl
            ,eir_tenure1_spl
            ,eir_tenure2_spl
            ,eir_tenure3_spl
            ,eir_tenure6_spl
            ,eir_tenure12_spl
            ,eir_tenure18_spl
            ,eir_tenure24_spl
            ,latest_dpd_eod_cashloan
            ,repaid_bills_num_cashloan
    from    risk_feature.dws_risk_vn_user_txn_credit_feature_df
    where   grass_date = '${ds}'
) t3
on t1.credit_user_id = t3.credit_user_id
;

create or replace view ${SCHEMA}.ads_behavior_vn_underwrting_feature_df as
select
    *
from ${SCHEMA}.ads_behavior_underwrting_feature_df
where
    grass_region = upper('${region}')
    and grass_date = '${grass_date}'
;