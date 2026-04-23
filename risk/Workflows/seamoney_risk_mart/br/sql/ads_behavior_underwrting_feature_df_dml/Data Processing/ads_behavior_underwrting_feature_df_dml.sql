--      update by chenyingying  2026-03-19 DFS迁移重构


insert overwrite table ${SCHEMA}.ads_behavior_underwrting_feature_df partition (grass_region='BR',grass_date='${ds}')
select   t1.credit_user_id
        ,t2.latest_dpd_eod_cashloan    
        ,t2.postloan_reject_cnt_bcl    
        ,t2.postloan_reject_cnt_spl    
        ,t2.preloan_reject_cnt_bcl     
        ,t2.preloan_reject_cnt_spl     
        ,t2.postloan_reject_cnt_90d_bcl
        ,t2.postloan_reject_cnt_90d_spl
        ,t2.preloan_reject_cnt_90d_bcl 
        ,t2.preloan_reject_cnt_90d_spl 
        ,t2.postloan_reject_cnt_180d_bcl
        ,t2.postloan_reject_cnt_180d_spl
        ,t2.preloan_reject_cnt_180d_bcl
        ,t2.preloan_reject_cnt_180d_spl
        ,t3.average_limit_utilization_90d_spl 
        ,t3.average_limit_utilization_180d_spl
        ,t3.max_limit_utilization_90d_spl     
        ,t3.max_limit_utilization_180d_spl    
        ,t3.average_limit_utilization_30d_spl 
        ,t3.average_limit_utilization_360d_spl
        ,t3.max_limit_utilization_30d_spl     
        ,t3.max_limit_utilization_360d_spl    
from (
    select  credit_user_id
    from    credit_uc.dws_all_prod_br_uc_user_df
    where   grass_date = '${ds}'
    and     credit_user_id is not null
    and     credit_user_id <> ''
    group by credit_user_id
) t1
left join (
    select  credit_user_id
            ,latest_dpd_eod_cashloan     
            ,postloan_reject_cnt_bcl     
            ,postloan_reject_cnt_spl     
            ,preloan_reject_cnt_bcl      
            ,preloan_reject_cnt_spl      
            ,postloan_reject_cnt_90d_bcl 
            ,postloan_reject_cnt_90d_spl 
            ,preloan_reject_cnt_90d_bcl  
            ,preloan_reject_cnt_90d_spl  
            ,postloan_reject_cnt_180d_bcl
            ,postloan_reject_cnt_180d_spl
            ,preloan_reject_cnt_180d_bcl 
            ,preloan_reject_cnt_180d_spl 
    from    risk_feature.dws_risk_br_user_txn_credit_feature_df
    where   grass_date = '${ds}'
) t2 
on t1.credit_user_id = t2.credit_user_id
left join (
    select  credit_user_id
            ,average_limit_utilization_90d_spl 
            ,average_limit_utilization_180d_spl
            ,max_limit_utilization_90d_spl     
            ,max_limit_utilization_180d_spl    
            ,average_limit_utilization_30d_spl 
            ,average_limit_utilization_360d_spl
            ,max_limit_utilization_30d_spl     
            ,max_limit_utilization_360d_spl    
    from    risk_feature.dws_risk_br_user_info_credit_feature_df
    where   grass_date = '${ds}'
) t3
on t1.credit_user_id = t3.credit_user_id
;


create or replace view ${SCHEMA}.ads_behavior_br_underwrting_feature_df as
select
    *
from ${SCHEMA}.ads_behavior_underwrting_feature_df
where
    grass_region = upper('${region_lower}')
    and grass_date = '${grass_date}'
;