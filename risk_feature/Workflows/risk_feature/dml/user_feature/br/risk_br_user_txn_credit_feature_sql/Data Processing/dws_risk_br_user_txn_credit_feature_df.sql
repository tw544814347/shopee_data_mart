-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2026-01-20
-- Theme Domain:        User Txn Credit Feature汇总主题表
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-20 - chengguo.liu - 初始化
-- =============================================================================


-- drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_feature_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_feature_df
(
    credit_user_id                                      string         comment 'shopee user id'
    ,is_spl_disbursed                                   bigint         comment 'is_spl_disbursed'
    ,is_bcl_disbursed                                   bigint         comment 'is_bcl_disbursed'
    ,current_dpd_eod_bcl                                bigint         comment 'BCL current dpd eod'  
    ,latest_dpd_eod_cashloan                            bigint         comment 'BCL latest dpd eod'
    ,ever_max_dpd_cashloan_core                         bigint         comment 'BCL ever max dpd core'
    ,last_bill_dpd_cashloan_core                        bigint         comment 'BCL last bill dpd'
    ,days_after_first_due_date_cashloan                 bigint         comment 'BCL Days after first due date'
    ,ever_max_dpd_30d_cashloan                          bigint         comment 'BCL ever max dpd in last 30 days'
    ,ever_max_dpd_90d_cashloan                          bigint         comment 'BCL ever max dpd in last 90 days'
    ,ever_max_dpd_180d_cashloan                         bigint         comment 'BCL ever max dpd in last 180 days'
    ,ever_max_dpd_360d_cashloan                         bigint         comment 'BCL ever max dpd in last 360 days'
    ,latest_dpd_spl                                     bigint         comment 'SPL latest dpd'      
    ,current_dpd_spl                                    bigint         comment 'SPL current dpd'
    ,ever_max_dpd_30d_spl                               bigint         comment 'SPL ever max dpd in last 30 days'
    ,ever_max_dpd_90d_spl                               bigint         comment 'SPL ever max dpd in last 90 days'
    ,ever_max_dpd_180d_spl                              bigint         comment 'SPL ever max dpd in last 180 days'
    ,ever_max_dpd_360d_spl                              bigint         comment 'SPL ever max dpd in last 360 days'
    ,ever_max_dpd_spl_core                              bigint         comment 'SPL ever max dpd core'
    ,last_bill_dpd_spl_core                             bigint         comment 'SPL last bill dpd'
    ,days_after_first_due_date_spl                      bigint         comment 'SPL days after first due day'
    ,ever_max_dpd_180d_user                             bigint         comment 'User ever max dpd in last 180 days'
    ,ever_max_dpd_360d_user                             bigint         comment 'User ever max dpd in last 360 days'
    ,repaid_bills_num_spl                               bigint         comment 'has repaid bcl bills flag'
    ,postloan_reject_cnt_bcl                            bigint         comment 'BCL post-loan reject count'
    ,postloan_reject_cnt_spl                            bigint         comment 'SPL post-loan reject count'
    ,preloan_reject_cnt_bcl                             bigint         comment 'BCL pre-loan reject count'
    ,preloan_reject_cnt_spl                             bigint         comment 'SPL pre-loan reject count in 90d'
    ,postloan_reject_cnt_90d_bcl                        bigint         comment 'BCL post-loan reject count in 90d'
    ,postloan_reject_cnt_90d_spl                        bigint         comment 'SPL post-loan reject count in 90d'
    ,preloan_reject_cnt_90d_bcl                         bigint         comment 'BCL pre-loan reject count in 90d'
    ,preloan_reject_cnt_90d_spl                         bigint         comment 'SPL pre-loan reject count in 90d'
    ,postloan_reject_cnt_180d_bcl                       bigint         comment 'BCL post-loan reject count in 180d'
    ,postloan_reject_cnt_180d_spl                       bigint         comment 'SPL post-loan reject count in 180d'
    ,preloan_reject_cnt_180d_bcl                        bigint         comment 'BCL pre-loan reject count in 180d'
    ,preloan_reject_cnt_180d_spl                        bigint         comment 'BCL pre-loan reject count in 180d'
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_txn_credit_feature_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_credit_feature_df;


insert overwrite ${SCHEMA}.dws_risk_${region}_user_txn_credit_feature_df partition(grass_date='${ds}')
select  t1.credit_user_id
        ,t3.is_spl_disbursed                  
        ,t3.is_bcl_disbursed                  
        ,t2.current_dpd_eod_bcl               
        ,t2.latest_dpd_eod_cashloan           
        ,t2.ever_max_dpd_cashloan_core        
        ,t2.last_bill_dpd_cashloan_core       
        ,t2.days_after_first_due_date_cashloan
        ,t2.ever_max_dpd_30d_cashloan         
        ,t2.ever_max_dpd_90d_cashloan         
        ,t2.ever_max_dpd_180d_cashloan        
        ,t2.ever_max_dpd_360d_cashloan        
        ,t2.latest_dpd_spl                    
        ,t2.current_dpd_spl                   
        ,t2.ever_max_dpd_30d_spl              
        ,t2.ever_max_dpd_90d_spl              
        ,t2.ever_max_dpd_180d_spl             
        ,t2.ever_max_dpd_360d_spl             
        ,t2.ever_max_dpd_spl_core             
        ,t2.last_bill_dpd_spl_core            
        ,t2.days_after_first_due_date_spl     
        ,t2.ever_max_dpd_180d_user            
        ,t2.ever_max_dpd_360d_user            
        ,t4.repaid_bills_num_spl              
        ,t4.postloan_reject_cnt_bcl           
        ,t4.postloan_reject_cnt_spl           
        ,t4.preloan_reject_cnt_bcl            
        ,t4.preloan_reject_cnt_spl            
        ,t4.postloan_reject_cnt_90d_bcl       
        ,t4.postloan_reject_cnt_90d_spl       
        ,t4.preloan_reject_cnt_90d_bcl        
        ,t4.preloan_reject_cnt_90d_spl        
        ,t4.postloan_reject_cnt_180d_bcl      
        ,t4.postloan_reject_cnt_180d_spl      
        ,t4.preloan_reject_cnt_180d_bcl       
        ,t4.preloan_reject_cnt_180d_spl       
from (
    select  credit_user_id
    from    credit_uc.dws_all_prod_br_uc_user_df
    where   grass_date = '${ds}'
    and     credit_user_id <> '0'
    and     credit_user_id is not null
    and     credit_user_id <> ''
    group by 1
) t1
left join (
    select  credit_user_id
            ,current_dpd_eod_bcl                
            ,latest_dpd_eod_cashloan            
            ,ever_max_dpd_cashloan_core         
            ,last_bill_dpd_cashloan_core        
            ,days_after_first_due_date_cashloan 
            ,ever_max_dpd_30d_cashloan          
            ,ever_max_dpd_90d_cashloan          
            ,ever_max_dpd_180d_cashloan         
            ,ever_max_dpd_360d_cashloan         
            ,latest_dpd_spl                     
            ,current_dpd_spl                    
            ,ever_max_dpd_30d_spl               
            ,ever_max_dpd_90d_spl               
            ,ever_max_dpd_180d_spl              
            ,ever_max_dpd_360d_spl              
            ,ever_max_dpd_spl_core              
            ,last_bill_dpd_spl_core             
            ,days_after_first_due_date_spl      
            ,ever_max_dpd_180d_user             
            ,ever_max_dpd_360d_user   
    from    ${SCHEMA}.dws_risk_${region}_user_txn_credit_dpd_df
    where   grass_date = '${ds}'          
) t2
on t1.credit_user_id = t2.credit_user_id
left join (
    select  credit_user_id              
            ,is_bcl_disbursed           
            ,is_spl_disbursed
    from    ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_info_df
    where   grass_date = '${ds}'
) t3
on t1.credit_user_id = t3.credit_user_id
left join (
    select  credit_user_id
            ,repaid_bills_num_spl        
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
    from    ${SCHEMA}.dws_risk_${region}_user_txn_credit_loan_repayment_df
    where   grass_date = '${ds}'
) t4
on t1.credit_user_id = t4.credit_user_id