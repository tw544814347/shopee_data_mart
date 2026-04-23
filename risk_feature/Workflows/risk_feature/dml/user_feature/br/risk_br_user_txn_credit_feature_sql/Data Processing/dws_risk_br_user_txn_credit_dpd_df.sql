-- =============================================================================
-- Author:              chenyingying
-- Created Time:        2026-01-16
-- Theme Domain:        User Txn DPD Info Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-02-14 - chenyingying - 初始化
-- =============================================================================

-- drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_dpd_df;

create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_dpd_df
(
    credit_user_id                                  string  comment 'credit user id'
    ,current_dpd_eod_bcl                            bigint     comment 'BCL current dpd eod'  
    ,latest_dpd_eod_cashloan                        bigint    comment 'BCL latest dpd eod'
    ,ever_max_dpd_cashloan_core                     bigint    comment 'BCL ever max dpd core'
    ,last_bill_dpd_cashloan_core                     bigint    comment 'BCL last bill dpd'
    ,days_after_first_due_date_cashloan              bigint    comment 'BCL Days after first due date'
    ,ever_max_dpd_30d_cashloan                       bigint    comment 'BCL ever max dpd in last 30 days'
    ,ever_max_dpd_90d_cashloan                       bigint     comment 'BCL ever max dpd in last 90 days'
    ,ever_max_dpd_180d_cashloan                      bigint    comment 'BCL ever max dpd in last 180 days'
    ,ever_max_dpd_360d_cashloan                      bigint    comment 'BCL ever max dpd in last 360 days'
    ,latest_dpd_spl                                 bigint     comment 'SPL latest dpd'      
    ,current_dpd_spl                                bigint     comment 'SPL current dpd'
    ,ever_max_dpd_30d_spl                           bigint     comment 'SPL ever max dpd in last 30 days'
    ,ever_max_dpd_90d_spl                           bigint     comment 'SPL ever max dpd in last 90 days'
    ,ever_max_dpd_180d_spl                          bigint     comment 'SPL ever max dpd in last 180 days'
    ,ever_max_dpd_360d_spl                          bigint     comment 'SPL ever max dpd in last 360 days'
    ,ever_max_dpd_spl_core                          bigint     comment 'SPL ever max dpd core'
    ,last_bill_dpd_spl_core                         bigint     comment 'SPL last bill dpd'
    ,days_after_first_due_date_spl                  bigint     comment 'SPL days after first due day'
    ,ever_max_dpd_180d_user                         bigint     comment 'User ever max dpd in last 180 days'
    ,ever_max_dpd_360d_user                         bigint     comment 'User ever max dpd in last 360 days'

)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_txn_credit_dpd_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_credit_dpd_df;

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_credit_dpd_df partition(grass_date='${ds}')
select  t1.credit_user_id
        ,t2.current_dpd_eod_bcl               
        ,coalesce(t3.latest_dpd_eod_cashloan, -9999)        
        ,coalesce(t2.ever_max_dpd_cashloan_core, -9999)        
        ,coalesce(t2.last_bill_dpd_cashloan_core, -9999)       
        ,coalesce(t2.days_after_first_due_date_cashloan, -9999)
        ,coalesce(t2.ever_max_dpd_30d_cashloan, -9999)        
        ,coalesce(t2.ever_max_dpd_90d_cashloan, -9999)
        ,coalesce(t2.ever_max_dpd_180d_cashloan, -9999)        
        ,coalesce(t2.ever_max_dpd_360d_cashloan, -9999)        
        ,coalesce(t4.latest_dpd_spl, -9999)                    
        ,coalesce(t5.current_dpd_spl, -9999)                   
        ,coalesce(t5.ever_max_dpd_30d_spl, -9999)              
        ,coalesce(t5.ever_max_dpd_90d_spl, -9999)              
        ,coalesce(t5.ever_max_dpd_180d_spl, -9999)             
        ,coalesce(t5.ever_max_dpd_360d_spl, -9999)             
        ,coalesce(t5.ever_max_dpd_spl_core, -9999)             
        ,coalesce(t5.last_bill_dpd_spl_core, -9999)            
        ,coalesce(t5.days_after_first_due_date_spl, -9999)     
        ,coalesce(case when t2.ever_max_dpd_180d_cashloan is null then t5.ever_max_dpd_180d_spl
            when t5.ever_max_dpd_180d_spl is null then t2.ever_max_dpd_180d_cashloan
            when t2.ever_max_dpd_180d_cashloan > t5.ever_max_dpd_180d_spl then t2.ever_max_dpd_180d_cashloan
            else t5.ever_max_dpd_180d_spl
            end, -9999) as ever_max_dpd_180d_user
        ,coalesce(case when t2.ever_max_dpd_360d_cashloan is null then t5.ever_max_dpd_360d_spl
            when t5.ever_max_dpd_360d_spl is null then t2.ever_max_dpd_360d_cashloan
            when t2.ever_max_dpd_360d_cashloan > t5.ever_max_dpd_360d_spl then t2.ever_max_dpd_360d_cashloan
            else t5.ever_max_dpd_360d_spl
            end, -9999) as ever_max_dpd_360d_user
from (
    select credit_user_id
    from    credit_uc.dws_all_prod_br_uc_user_df
    where   grass_date = '${ds}'
    and     credit_user_id <> '0'
    and     credit_user_id is not null
    and     credit_user_id <> ''
    group by 1
) t1
left join (
    select  credit_user_id
            ,historical_max_dpd_eod     as ever_max_dpd_cashloan_core
            ,last_bill_dpd              as last_bill_dpd_cashloan_core
            ,days_after_first_due_date  as days_after_first_due_date_cashloan
            ,ever_max_dpd_30d   as ever_max_dpd_30d_cashloan
            ,ever_max_dpd_90d   as ever_max_dpd_90d_cashloan
            ,ever_max_dpd_180d  as ever_max_dpd_180d_cashloan
            ,ever_max_dpd_360d  as ever_max_dpd_360d_cashloan
            ,current_dpd_eod as current_dpd_eod_bcl
    from    credit_mart.dws_bcl_br_user_df
    where   grass_date = '${ds}'
) t2
on t1.credit_user_id = t2.credit_user_id
left join (
    select 
            credit_user_id            as credit_user_id
            ,lastest_max_dpd_eod_120d as latest_dpd_eod_cashloan
    from credit_mart.wide_bcl_br_behavior_user_df 
    where grass_date = '${ds}'
) t3
on t1.credit_user_id = t3.credit_user_id
left join (
    select  credit_user_id
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
) t4
on t1.credit_user_id = t4.credit_user_id
left join (
    select  credit_user_id
            ,historical_max_dpd_eod as ever_max_dpd_spl_core
            ,last_bill_dpd          as last_bill_dpd_spl_core
            ,days_after_first_due_date  as days_after_first_due_date_spl
            ,ever_max_dpd_30d       as  ever_max_dpd_30d_spl
            ,ever_max_dpd_90d       as  ever_max_dpd_90d_spl
            ,ever_max_dpd_180d      as  ever_max_dpd_180d_spl
            ,ever_max_dpd_360d      as  ever_max_dpd_360d_spl
            ,current_max_dpd        as  current_dpd_spl
    from    credit_mart.dws_spl_br_user_df
    where   grass_date = '${ds}'
) t5
on t1.credit_user_id = t5.credit_user_id
