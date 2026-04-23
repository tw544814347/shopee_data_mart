-- =============================================================================
-- Author:              chenyingying@shopee.com
-- Created Time:        2026-02-05
-- Theme Domain:        User Txn Credit Feature
-- Data Granularity:    credit_user_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2026-01-20 - chenyingying - 初始化
-- =============================================================================


-- drop table if exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_feature_df;
create external table if not exists ${SCHEMA}.dws_risk_${region}_user_txn_credit_feature_df (
    credit_user_id                      string comment 'credit_user_id'
    ,eir_tenure2_bcl                    decimal(30,10) comment 'BCL User tenure2 EIR'   
    ,eir_tenure3_bcl                    decimal(30,10) comment 'BCL User tenure3 EIR'
    ,eir_tenure6_bcl                    decimal(30,10) comment 'BCL User tenure6 EIR'
    ,eir_tenure12_bcl                   decimal(30,10) comment 'BCL User tenure12 EIR'
    ,eir_tenure1_spl                    decimal(30,10) comment 'SPL User tenure1 EIR'
    ,eir_tenure2_spl                    decimal(30,10) comment 'SPL User tenure2 EIR'
    ,eir_tenure3_spl                    decimal(30,10) comment 'SPL User tenure3 EIR'
    ,eir_tenure6_spl                    decimal(30,10) comment 'SPL User tenure6 EIR'
    ,eir_tenure12_spl                   decimal(30,10) comment 'SPL User tenure12 EIR'
    ,eir_tenure18_spl                   decimal(30,10) comment 'SPL User tenure18 EIR'
    ,eir_tenure24_spl                   decimal(30,10) comment 'SPL User tenure24 EIR'
    ,os_bcl                             decimal(30,10) comment 'BCL Outstanding Balance'
    ,os_spl                             decimal(30,10) comment 'SPL Outstanding Balance'
    ,first_billed_from_now_spl          bigint comment 'First Billed Date From Now SPL'
    ,first_billed_from_now_bcl          bigint comment 'First Billed Date From Now BCL'
    ,postloan_reject_cnt_bcl            bigint comment 'BCL post-loan reject count'
    ,postloan_reject_cnt_spl            bigint comment 'SPL post-loan reject count'
    ,preloan_reject_cnt_bcl             bigint comment 'BCL pre-loan reject count'
    ,preloan_reject_cnt_spl             bigint comment 'SPL pre-loan reject count in 90d'
    ,postloan_reject_cnt_90d_bcl        bigint comment 'BCL post-loan reject count in 90d'
    ,postloan_reject_cnt_90d_spl        bigint comment 'SPL post-loan reject count in 90d'
    ,preloan_reject_cnt_90d_bcl         bigint comment 'BCL pre-loan reject count in 90d'
    ,preloan_reject_cnt_90d_spl         bigint comment 'SPL pre-loan reject count in 90d'
    ,postloan_reject_cnt_180d_bcl       bigint comment 'BCL post-loan reject count in 180d'
    ,postloan_reject_cnt_180d_spl       bigint comment 'SPL post-loan reject count in 180d'
    ,preloan_reject_cnt_180d_bcl        bigint comment 'BCL pre-loan reject count in 180d'
    ,preloan_reject_cnt_180d_spl        bigint comment 'BCL pre-loan reject count in 180d'
    ,rejected_num_90d_bcl               bigint comment 'BCL reject num 90d'
    ,ever_max_dpd_cashloan_core                     bigint  comment 'cash loan(BCL) ever max dpd'
    ,last_bill_dpd_cashloan_core                    bigint  comment 'cash loan(BCL) latest bill dpd'
    ,days_after_first_due_date_cashloan             bigint  comment 'cash loan(BCL) days after first due date'
    ,ever_max_dpd_180d_cashloan                     bigint  comment 'cash loan(BCL) ever max dpd in 180 days'
    ,ever_max_dpd_360d_cashloan                     bigint  comment 'cash loan(BCL) ever max dpd in 360 days'
    ,ever_max_dpd_30d_bcl                           bigint  comment 'cash loan(BCL) ever max dpd in 30 days'
    ,ever_max_dpd_90d_bcl                           bigint  comment 'cash loan(BCL) ever max dpd in 90 days'
    ,ever_max_dpd_180d_user                         bigint  comment 'User ever max dpd in 180 days'
    ,ever_max_dpd_360d_user                         bigint  comment 'User ever max dpd in 360 days'
    ,ever_max_dpd_sellerloan_core                   bigint  comment 'seller loan(SCL) ever max dpd'
    ,last_bill_dpd_sellerloan_core                  bigint  comment 'seller loan(SCL) latest bill dpd'
    ,ever_max_dpd_30d_scl                           bigint  comment 'seller loan(SCL) ever max dpd in 30 days'
    ,ever_max_dpd_90d_scl                           bigint  comment 'seller loan(SCL) ever max dpd in 90 days'
    ,ever_max_dpd_180d_scl                          bigint  comment 'seller loan(SCL) ever max dpd in 180 days'
    ,ever_max_dpd_360d_scl                          bigint  comment 'seller loan(SCL) ever max dpd in 30 days'
    ,ever_max_dpd_spl_core                          bigint  comment 'shopeepay later(SPL) ever max dpd'
    ,last_bill_dpd_spl_core                         bigint  comment 'shopeepay later(SPL) last bill dpd'
    ,days_after_first_due_date_spl                  bigint  comment 'shopeepay later(SPL) days after first due date'
    ,ever_max_dpd_180d_spl                          bigint  comment 'shopeepay later(SPL) ever max dpd in 180 days'
    ,ever_max_dpd_360d_spl                          bigint  comment 'shopeepay later(SPL) ever max dpd in 360 days'
    ,ever_max_dpd_30d_spl                           bigint  comment 'shopeepay later(SPL) ever max dpd in 30 days'
    ,ever_max_dpd_90d_spl                           bigint  comment 'shopeepay later(SPL) ever max dpd in 90 days'
    ,latest_dpd_eod_cashloan                        bigint  comment 'cash loan(BCL) latest dpd eod'
    ,repaid_bills_num_cashloan                      bigint comment 'Number of repaid bills BCL'
    ,repaid_bills_num_spl                           bigint comment 'Number of repaid bills SPL'
    ,latest_dpd_eod_spl                             bigint  comment 'shopeepay later(SPL) latest dpd eod'
)
partitioned by (grass_date string comment 'grass_date, partition key')
stored as orc tblproperties ("orc.compress" = "zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_risk_reg_user_txn_user_txn_credit_feature_df/grass_region=${grass_region}';
-- msck repair table ${SCHEMA}.dws_risk_${region}_user_txn_credit_feature_df;

insert overwrite table ${SCHEMA}.dws_risk_${region}_user_txn_credit_feature_df partition(grass_date='${ds}')
select  t1.credit_user_id               
        ,t2.eir_tenure2_bcl             
        ,t2.eir_tenure3_bcl             
        ,t2.eir_tenure6_bcl             
        ,t2.eir_tenure12_bcl            
        ,t2.eir_tenure1_spl             
        ,t2.eir_tenure2_spl             
        ,t2.eir_tenure3_spl             
        ,t2.eir_tenure6_spl             
        ,t2.eir_tenure12_spl            
        ,t2.eir_tenure18_spl            
        ,t2.eir_tenure24_spl            
        ,t2.os_bcl                      
        ,t2.os_spl                      
        ,t2.first_billed_from_now_spl   
        ,t2.first_billed_from_now_bcl   
        ,t3.postloan_reject_cnt_bcl     
        ,t3.postloan_reject_cnt_spl     
        ,t3.preloan_reject_cnt_bcl      
        ,t3.preloan_reject_cnt_spl      
        ,t3.postloan_reject_cnt_90d_bcl 
        ,t3.postloan_reject_cnt_90d_spl 
        ,t3.preloan_reject_cnt_90d_bcl  
        ,t3.preloan_reject_cnt_90d_spl  
        ,t3.postloan_reject_cnt_180d_bcl
        ,t3.postloan_reject_cnt_180d_spl
        ,t3.preloan_reject_cnt_180d_bcl 
        ,t3.preloan_reject_cnt_180d_spl 
        ,t3.rejected_num_90d_bcl        
        ,t4.ever_max_dpd_cashloan_core         
        ,t4.last_bill_dpd_cashloan_core        
        ,t4.days_after_first_due_date_cashloan 
        ,t4.ever_max_dpd_180d_cashloan         
        ,t4.ever_max_dpd_360d_cashloan         
        ,t4.ever_max_dpd_30d_bcl               
        ,t4.ever_max_dpd_90d_bcl               
        ,t4.ever_max_dpd_180d_user             
        ,t4.ever_max_dpd_360d_user             
        ,t4.ever_max_dpd_sellerloan_core       
        ,t4.last_bill_dpd_sellerloan_core      
        ,t4.ever_max_dpd_30d_scl               
        ,t4.ever_max_dpd_90d_scl               
        ,t4.ever_max_dpd_180d_scl              
        ,t4.ever_max_dpd_360d_scl              
        ,t4.ever_max_dpd_spl_core              
        ,t4.last_bill_dpd_spl_core             
        ,t4.days_after_first_due_date_spl      
        ,t4.ever_max_dpd_180d_spl              
        ,t4.ever_max_dpd_360d_spl              
        ,t4.ever_max_dpd_30d_spl               
        ,t4.ever_max_dpd_90d_spl               
        ,t4.latest_dpd_eod_cashloan
        ,t2.repaid_bills_num_cashloan
        ,t2.repaid_bills_num_spl
        ,t4.latest_dpd_eod_spl

from    (
    select credit_user_id
    from    credit_uc.dws_all_prod_${region}_uc_user_df
    where   grass_date = '${ds}'
    and     credit_user_id is not null
    and     credit_user_id <> ''
    and     credit_user_id <> '0'
    group by credit_user_id
)   t1
left join (
    select  credit_user_id
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
            ,os_bcl                   
            ,os_spl                   
            ,first_billed_from_now_spl
            ,first_billed_from_now_bcl
            ,repaid_bills_num_cashloan
            ,repaid_bills_num_spl
    from    ${SCHEMA}.dws_risk_vn_user_txn_credit_loan_info_df
    where   grass_date = '${ds}'
) t2
on      t1.credit_user_id = t2.credit_user_id
left join (
    select credit_user_id
        ,postloan_reject_cnt_bcl
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
        ,rejected_num_90d_bcl   
    from    ${SCHEMA}.dws_risk_vn_user_txn_credit_loan_repayment_df
    where   grass_date = '${ds}'     
) t3
on      t1.credit_user_id = t3.credit_user_id
left join (
    select  credit_user_id                      
            ,ever_max_dpd_cashloan_core         
            ,last_bill_dpd_cashloan_core        
            ,days_after_first_due_date_cashloan 
            ,ever_max_dpd_180d_cashloan         
            ,ever_max_dpd_360d_cashloan         
            ,ever_max_dpd_30d_bcl               
            ,ever_max_dpd_90d_bcl               
            ,ever_max_dpd_180d_user             
            ,ever_max_dpd_360d_user             
            ,ever_max_dpd_sellerloan_core       
            ,last_bill_dpd_sellerloan_core      
            ,ever_max_dpd_30d_scl               
            ,ever_max_dpd_90d_scl               
            ,ever_max_dpd_180d_scl              
            ,ever_max_dpd_360d_scl              
            ,ever_max_dpd_spl_core              
            ,last_bill_dpd_spl_core             
            ,days_after_first_due_date_spl      
            ,ever_max_dpd_180d_spl              
            ,ever_max_dpd_360d_spl              
            ,ever_max_dpd_30d_spl               
            ,ever_max_dpd_90d_spl               
            ,latest_dpd_eod_cashloan 
            ,latest_dpd_eod_spl           
    from ${SCHEMA}.dws_risk_vn_user_txn_credit_dpd_df
    where   grass_date = '${ds}'
) t4
on t1.credit_user_id = t4.credit_user_id