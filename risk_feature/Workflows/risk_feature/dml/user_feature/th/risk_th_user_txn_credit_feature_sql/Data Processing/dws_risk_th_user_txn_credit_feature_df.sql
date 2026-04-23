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
    ,first_spl_disburse_time                            string         comment 'first_spl_disburse_time'
    ,repaid_bills_num_spl                               bigint         comment 'repaid_bills_num_spl'
    ,repaid_bills_num_bcl                               bigint         comment 'repaid_bills_num_bcl'
    ,has_repaid_bcl_bills_flag                          bigint         comment 'has repaid bcl bills flag'
    ,month_due_spl                                      bigint         comment 'month due spl cnt'
    ,preloan_reject_cnt_chp                             bigint         comment 'preloan_reject_cnt_chp'
    ,preloan_reject_cnt_90d_chp                         bigint         comment 'preloan_reject_cnt_90d_chp'
    ,preloan_reject_cnt_180d_chp                        bigint         comment 'preloan_reject_cnt_180d_chp'
    ,first_postloan_reject_date_chp                     string         comment 'first_postloan_reject_date_chp'
    ,uui_dpd30_cluster_user_cnt                     bigint  comment 'dpd 30 cluster user cnt'
    ,sl_max_dpd_l1m                              bigint  comment 'seller loan(SCL) max dpd last 1 month'
    ,sl_max_dpd_l3m                              bigint  comment 'seller loan(SCL) max dpd last 3 month'
    ,sl_max_dpd_l6m                              bigint  comment 'seller loan(SCL) max dpd last 6 month'
    ,sl_max_dpd_l12m                             bigint  comment 'seller loan(SCL) max dpd last 12 month'
    ,ever_max_dpd_chp                               bigint  comment 'cellphone loan(CHP) ever max dpd'
    ,ever_max_dpd_30d_chp                           bigint  comment 'cellphone loan(CHP) ever max dpd in last 30d'
    ,ever_max_dpd_90d_chp                           bigint  comment 'cellphone loan(CHP) ever max dpd in last 90d'
    ,ever_max_dpd_180d_chp                          bigint  comment 'cellphone loan(CHP) ever max dpd in last 180d'
    ,ever_max_dpd_360d_chp                          bigint  comment 'cellphone loan(CHP) ever max dpd in last 360d'
    ,days_after_first_due_date_chp                  bigint  comment 'cellphone loan(CHP) days after first due date'
    ,ever_max_dpd_cashloan_core                     bigint  comment 'cashloan(BCL) core ever max dpd'
    ,last_bill_dpd_cashloan_core                    bigint  comment 'cashloan(BCL) core last bill dpd'
    ,ever_max_dpd_180d_cashloan                     bigint  comment 'cashloan(BCL) ever max dpd in last 180d'
    ,ever_max_dpd_360d_cashloan                     bigint  comment 'cashloan(BCL) ever max dpd in last 360d'
    ,ever_max_dpd_30d_cashloan                           bigint  comment 'cashloan(BCL) ever max dpd in last 30d'
    ,ever_max_dpd_90d_cashloan                           bigint  comment 'cashloan(BCL) ever max dpd in last 90d'
    ,latest_dpd_eod_cashloan                       bigint  comment 'cashloan(BCL) latest dpd eod'
    ,days_after_first_due_date_cashloan             bigint  comment 'cahsloan(BCL) days after first due date'
    ,days_after_first_due_date_cashloan_floating    decimal(30, 10) comment 'cahsloan(BCL) days after first due date floating' 
    ,ever_max_dpd_spl_core                          bigint comment 'shopeepay later(SPL) ever max dpd'
    ,last_bill_dpd_spl_core                         bigint comment 'shopeepay later(SPL) last bill dpd'
    ,ever_max_dpd_180d_spl                          bigint comment 'shopeepay later(SPL) ever max dpd in 180d'
    ,ever_max_dpd_360d_spl                          bigint comment 'shopeepay later(SPL) ever max dpd in 360d'
    ,ever_max_dpd_30d_spl                           bigint comment 'shopeepay later(SPL) ever max dpd in 30d'
    ,ever_max_dpd_90d_spl                           bigint comment 'shopeepay later(SPL) ever max dpd in 90d'
    ,latest_dpd_eod_spl                             bigint comment 'shopeepay later(SPL) latest dpd eod'
    ,days_after_first_due_date_spl                  bigint comment 'shopeepay later(SPL) days after first due date'
    ,days_after_first_due_date_spl_floating         decimal(30,10) comment 'shopeepay later(SPL) days after first due date'
    ,ever_max_dpd_sellerloan_core                   bigint comment 'seller loan(SCL) max dpd last 3 month'
    ,last_bill_dpd_sellerloan_core                  bigint comment 'seller loan(SCL) last bill dpd'
    ,ever_max_dpd_30d_sellerloan                           bigint comment 'seller loan(SCL) ever max dpd in last 30d'
    ,ever_max_dpd_90d_sellerloan                           bigint comment 'seller loan(SCL) ever max dpd in last 90d'
    ,ever_max_dpd_180d_sellerloan                          bigint comment 'seller loan(SCL) ever max dpd in last 180d'
    ,ever_max_dpd_360d_sellerloan                          bigint comment 'seller loan(SCL) ever max dpd in last 360d'
    ,ever_max_dpd_30d_tl                            bigint comment 'term loan(TL) ever max dpd in last 30d'
    ,ever_max_dpd_90d_tl                            bigint comment 'term loan(TL) ever max dpd in last 90d'
    ,ever_max_dpd_180d_tl                           bigint comment 'term laon(TL) ever max dpd in last 180d'
    ,ever_max_dpd_360d_tl                           bigint comment 'term laon(TL) ever max dpd in last 360d'
    ,ever_max_dpd_tl                                bigint comment 'term laon(TL) ever max dpd in last 360d'     
    ,postloan_reject_cnt_bcl                            bigint comment 'BCL post-loan reject cnt'
    ,preloan_reject_cnt_bcl                             bigint comment 'BCL pre-loan reject cnt'
    ,postloan_reject_cnt_90d_bcl                        bigint comment 'BCL post-loan reject cnt in 90 days'
    ,preloan_reject_cnt_90d_bcl                         bigint comment 'BCL pre-loan reject cnt in 90 days'
    ,postloan_reject_cnt_180d_bcl                       bigint comment 'BCL post-loan reject cnt in 180 days'
    ,preloan_reject_cnt_180d_bcl                        bigint comment 'BCL pre-loan reject cnt in 180 days'
    ,rejected_num_90d_bcl                               bigint comment 'BCL rejected num in 90 days'
    ,postloan_reject_cnt_spl                            bigint comment 'SPL post-loan reject cnt'
    ,preloan_reject_cnt_spl                             bigint comment 'SPL pre-loan reject cnt'
    ,postloan_reject_cnt_90d_spl                        bigint comment 'SPL post-loan reject cnt in 90 days'
    ,preloan_reject_cnt_90d_spl                         bigint comment 'SPL pre-loan reject cnt in 90 days'
    ,postloan_reject_cnt_180d_spl                       bigint comment 'SPL post-loan reject cnt in 180 days'
    ,preloan_reject_cnt_180d_spl                        bigint comment 'SPL pre-loan reject cnt in 180 days' 
    ,mp_buyer_id_array                                  string comment 'buyer id list of CsB user used SPL as payment method for MP COD order'       
    ,ever_max_dpd_30d_user                              bigint comment 'user ever max dpd in last 30d'      
    ,ever_max_dpd_90d_user                              bigint comment 'user ever max dpd in last 90d'      
    ,ever_max_dpd_180d_user                             bigint comment 'user ever max dpd in last 180d'      
    ,ever_max_dpd_360d_user                             bigint comment 'user ever max dpd in last 360d'               
)
comment 'risk feature summary table'
partitioned by
(
    grass_date string comment 'partition key, yyyy-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_feature/dws/dws_risk_reg_user_txn_credit_feature_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_credit_feature_df;


insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_credit_feature_df partition (grass_date = '${grass_date}')
select
    t1.credit_user_id
    ,t3.is_spl_disbursed
    ,t3.is_bcl_disbursed
    ,t3.first_spl_disburse_time
    ,t4.repaid_bills_num_spl
    ,t4.repaid_bills_num_bcl
    ,t4.has_repaid_bcl_bills_flag
    ,t4.month_due_spl
    ,t4.preloan_reject_cnt_chp
    ,t4.preloan_reject_cnt_90d_chp
    ,t4.preloan_reject_cnt_180d_chp
    ,t4.first_postloan_reject_date_chp

    ,t2.uui_dpd30_cluster_user_cnt                   
    ,t2.sl_max_dpd_l1m                            
    ,t2.sl_max_dpd_l3m                            
    ,t2.sl_max_dpd_l6m                            
    ,t2.sl_max_dpd_l12m                           
    ,t2.ever_max_dpd_chp                             
    ,t2.ever_max_dpd_30d_chp                         
    ,t2.ever_max_dpd_90d_chp                         
    ,t2.ever_max_dpd_180d_chp                        
    ,t2.ever_max_dpd_360d_chp                        
    ,t2.days_after_first_due_date_chp                
    ,t2.ever_max_dpd_cashloan_core                   
    ,t2.last_bill_dpd_cashloan_core                  
    ,t2.ever_max_dpd_180d_cashloan                   
    ,t2.ever_max_dpd_360d_cashloan                   
    ,t2.ever_max_dpd_30d_cashloan                         
    ,t2.ever_max_dpd_90d_cashloan                         
    ,t2.latest_dpd_eod_cashloan                     
    ,t2.days_after_first_due_date_cashloan           
    ,t2.days_after_first_due_date_cashloan_floating  
    ,t2.ever_max_dpd_spl_core                        
    ,t2.last_bill_dpd_spl_core                       
    ,t2.ever_max_dpd_180d_spl                        
    ,t2.ever_max_dpd_360d_spl                        
    ,t2.ever_max_dpd_30d_spl                         
    ,t2.ever_max_dpd_90d_spl                         
    ,t2.latest_dpd_eod_spl                           
    ,t2.days_after_first_due_date_spl                
    ,t2.days_after_first_due_date_spl_floating       
    ,t2.ever_max_dpd_sellerloan_core                 
    ,t2.last_bill_dpd_sellerloan_core                
    ,t2.ever_max_dpd_30d_sellerloan                         
    ,t2.ever_max_dpd_90d_sellerloan                        
    ,t2.ever_max_dpd_180d_sellerloan                        
    ,t2.ever_max_dpd_360d_sellerloan  

    ,t2.ever_max_dpd_30d_tl 
    ,t2.ever_max_dpd_90d_tl 
    ,t2.ever_max_dpd_180d_tl
    ,t2.ever_max_dpd_360d_tl
    ,t2.ever_max_dpd_tl

    ,t4.postloan_reject_cnt_bcl     
    ,t4.preloan_reject_cnt_bcl      
    ,t4.postloan_reject_cnt_90d_bcl 
    ,t4.preloan_reject_cnt_90d_bcl  
    ,t4.postloan_reject_cnt_180d_bcl
    ,t4.preloan_reject_cnt_180d_bcl 
    ,t4.rejected_num_90d_bcl        
    ,t4.postloan_reject_cnt_spl     
    ,t4.preloan_reject_cnt_spl      
    ,t4.postloan_reject_cnt_90d_spl 
    ,t4.preloan_reject_cnt_90d_spl  
    ,t4.postloan_reject_cnt_180d_spl
    ,t4.preloan_reject_cnt_180d_spl       

    ,t5.mp_buyer_id_array 

    ,t2.ever_max_dpd_30d_user 
    ,t2.ever_max_dpd_90d_user 
    ,t2.ever_max_dpd_180d_user
    ,t2.ever_max_dpd_360d_user               
from 
(
    select
        credit_user_id
    from credit_uc.dws_all_prod_${region}_uc_user_df
    where
        grass_date = '${grass_date}'
        and credit_user_id <> ''
        and credit_user_id <> '0'
        and credit_user_id is not null
    group by credit_user_id
) t1
left join (
    select  credit_user_id
            ,uui_dpd30_cluster_user_cnt                 
            ,sl_max_dpd_l1m                          
            ,sl_max_dpd_l3m                          
            ,sl_max_dpd_l6m                          
            ,sl_max_dpd_l12m                         
            ,ever_max_dpd_chp                           
            ,ever_max_dpd_30d_chp                       
            ,ever_max_dpd_90d_chp                       
            ,ever_max_dpd_180d_chp                      
            ,ever_max_dpd_360d_chp                      
            ,days_after_first_due_date_chp              
            ,ever_max_dpd_cashloan_core                 
            ,last_bill_dpd_cashloan_core                
            ,ever_max_dpd_180d_cashloan                 
            ,ever_max_dpd_360d_cashloan                 
            ,ever_max_dpd_30d_cashloan                       
            ,ever_max_dpd_90d_cashloan                       
            ,latest_dpd_eod_cashloan                   
            ,days_after_first_due_date_cashloan         
            ,days_after_first_due_date_cashloan_floating
            ,ever_max_dpd_spl_core                      
            ,last_bill_dpd_spl_core                     
            ,ever_max_dpd_180d_spl                      
            ,ever_max_dpd_360d_spl                      
            ,ever_max_dpd_30d_spl                       
            ,ever_max_dpd_90d_spl                       
            ,latest_dpd_eod_spl                         
            ,days_after_first_due_date_spl              
            ,days_after_first_due_date_spl_floating     
            ,ever_max_dpd_sellerloan_core               
            ,last_bill_dpd_sellerloan_core              
            ,ever_max_dpd_30d_sellerloan                       
            ,ever_max_dpd_90d_sellerloan                       
            ,ever_max_dpd_180d_sellerloan                      
            ,ever_max_dpd_360d_sellerloan
            ,ever_max_dpd_30d_tl 
            ,ever_max_dpd_90d_tl 
            ,ever_max_dpd_180d_tl
            ,ever_max_dpd_360d_tl
            ,ever_max_dpd_tl
            ,ever_max_dpd_30d_user                          
            ,ever_max_dpd_90d_user                          
            ,ever_max_dpd_180d_user                         
            ,ever_max_dpd_360d_user                              
    from    risk_feature.dws_risk_${region}_user_txn_credit_dpd_df
    where   grass_date = '${ds}'                     

) t2
on t1.credit_user_id = t2.credit_user_id
left join (
    select
        credit_user_id
        ,is_spl_disbursed
        ,is_bcl_disbursed
        ,first_spl_disburse_time
    from risk_feature.dws_risk_th_user_txn_credit_loan_info_df
    where
        grass_date = '${ds}'
) t3
on t1.credit_user_id = t3.credit_user_id
left join
(
    select
        credit_user_id
        ,preloan_reject_cnt_chp
        ,preloan_reject_cnt_90d_chp
        ,preloan_reject_cnt_180d_chp
        ,first_postloan_reject_date_chp
        ,repaid_bills_num_spl
        ,repaid_bills_num_bcl
        ,has_repaid_bcl_bills_flag 
        ,month_due_spl
        ,postloan_reject_cnt_bcl     
        ,preloan_reject_cnt_bcl      
        ,postloan_reject_cnt_90d_bcl 
        ,preloan_reject_cnt_90d_bcl  
        ,postloan_reject_cnt_180d_bcl
        ,preloan_reject_cnt_180d_bcl 
        ,rejected_num_90d_bcl        
        ,postloan_reject_cnt_spl     
        ,preloan_reject_cnt_spl      
        ,postloan_reject_cnt_90d_spl 
        ,preloan_reject_cnt_90d_spl  
        ,postloan_reject_cnt_180d_spl
        ,preloan_reject_cnt_180d_spl              
    from risk_feature.dws_risk_${region}_user_txn_credit_loan_repayment_df
    where   grass_date = '${ds}'
) t4
on t1.credit_user_id = t4.credit_user_id
left join (
    select credit_user_id
            ,mp_buyer_id_array
    from risk_feature.dws_risk_${region}_user_txn_credit_payment_method_df
    where   grass_date = '${ds}'
) t5
on t1.credit_user_id = t5.credit_user_id
;