DROP TABLE IF EXISTS ${SCHEMA}.ads_behavior_underwrting_feature_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_behavior_underwrting_feature_df
(
    credit_user_id                       string 
    ,spl_user_tag                        int           comment 'spl status'
    ,first_billed_from_now_spl           int           comment 'spl The number of months from bill term'
    ,first_billed_from_now_bcl           int           comment 'bcl The number of months from bill term'
    ,first_billed_from_now               int           comment 'max(bcl/bcl The number of months from bill term)'
    ,repaid_bills_num_user               int           comment 'repaid bills'
    ,credit_user_status                  int           comment 'user status'
    ,is_limit_decrease_spl               int           comment 'limit decrease tag in spl'
    ,is_limit_decrease_bcl               int           comment 'limit decrease tag in bcl'
    ,os_spl                              int           comment 'spl quota'
    ,os_bcl                              int           comment 'bcl quota'   
    ,eir_tenure2_bcl                     decimal(30,5)       comment 'User tenure2 EIR In bcl'        
    ,eir_tenure3_bcl                     decimal(30,5)       comment 'User tenure3 EIR In bcl'          
    ,eir_tenure6_bcl                     decimal(30,5)       comment 'User tenure6 EIR In bcl'           
    ,eir_tenure12_bcl                    decimal(30,5)       comment 'User tenure12 EIR In bcl'       
    ,eir_tenure1_spl                     decimal(30,5)       comment 'User tenure1 EIR In spl'              
    ,eir_tenure2_spl                     decimal(30,5)       comment 'User tenure2 EIR In spl'              
    ,eir_tenure3_spl                     decimal(30,5)       comment 'User tenure3 EIR In spl'        
    ,eir_tenure6_spl                     decimal(30,5)       comment 'User tenure6 EIR In spl'        
    ,eir_tenure12_spl                    decimal(30,5)       comment 'User tenure12 EIR In spl'        
    ,eir_tenure18_spl                    decimal(30,5)       comment 'User tenure18 EIR In spl'         
    ,eir_tenure24_spl                    decimal(30,5)       comment 'User tenure24 EIR In spl'           
    ,repaid_bills_num_cashloan           int           comment 'repaid bill num IN CL'  
    ,latest_dpd_cashloan                 int           comment 'latest dpd IN CL'  
    ,average_limit_utilization_90d_spl   decimal(30,5) comment 'spl 90days avg limit_utilization'
    ,average_limit_utilization_180d_spl  decimal(30,5) comment 'spl 180days avg limit_utilization'
    ,max_limit_utilization_90d_spl       decimal(30,5) comment 'spl 90days max limit_utilization'
    ,max_limit_utilization_180d_spl      decimal(30,5) comment 'spl 180days max limit_utilization'
    ,average_limit_utilization_90d_bcl   decimal(30,5) comment 'bcl 90days avg limit_utilization'
    ,average_limit_utilization_180d_bcl  decimal(30,5) comment 'bcl 180days avg limit_utilization'
    ,max_limit_utilization_90d_bcl       decimal(30,5) comment 'bcl 90days max limit_utilization'
    ,max_limit_utilization_180d_bcl      decimal(30,5) comment 'bcl 180days max limit_utilization'
    ,shopee_account_status               int           comment '0-ACCOUNT_DELETE,1-ACCOUNT_NORMAL,2-ACCOUNT_BANNED,3-ACCOUNT_FROZEN'
    ,eligible_tenure1_spl                int           comment 'Whether the user can use tenure1'
    ,eligible_tenure2_spl                int           comment 'Whether the user can use tenure2'
    ,eligible_tenure3_spl                int           comment 'Whether the user can use tenure3'
    ,eligible_tenure6_spl                int           comment 'Whether the user can use tenure6'
    ,eligible_tenure12_spl               int           comment 'Whether the user can use tenure12'
    ,eligible_tenure18_spl               int           comment 'Whether the user can use tenure18'
    ,eligible_tenure24_spl               int           comment 'Whether the user can use tenure24'
    ,first_billed_from_now_bcl_floating  bigint        comment 'first_billed_from_now_bcl_floating'
    ,first_billed_from_now_floating      bigint        comment 'first_billed_from_now_floating'
    ,repaid_bills_num_user_floating      bigint        comment 'repaid_bills_num_user_floating'
    ,last_chp_disburse_time string comment 'last_chp_disburse_time'
    ,first_spl_disburse_time string comment 'first_spl_disburse_time'
    ,is_bcl_disbursed int comment 'is_bcl_disbursed'
    ,repaid_bills_num_bcl int comment 'repaid_bills_num_bcl'
    ,repaid_bills_num_chp int comment 'repaid_bills_num_chp'
    ,repaid_bills_num_spl int comment 'repaid_bills_num_spl'
    ,is_spl_disbursed int comment 'is_spl_disbursed'
    ,is_chp_disbursed int comment 'is_chp_disbursed'
    
    ,average_limit_utilization_1d_spl   DECIMAL(30,5) COMMENT ''
    ,average_limit_utilization_3d_spl   DECIMAL(30,5) COMMENT ''
    ,average_limit_utilization_7d_spl   DECIMAL(30,5) COMMENT ''
    ,average_limit_utilization_14d_spl  DECIMAL(30,5) COMMENT ''
    ,average_limit_utilization_30d_spl  DECIMAL(30,5) COMMENT ''

    ,max_limit_utilization_1d_spl       DECIMAL(30,5) COMMENT ''
    ,max_limit_utilization_3d_spl       DECIMAL(30,5) COMMENT ''
    ,max_limit_utilization_7d_spl       DECIMAL(30,5) COMMENT ''
    ,max_limit_utilization_14d_spl      DECIMAL(30,5) COMMENT ''
    ,max_limit_utilization_30d_spl      DECIMAL(30,5) COMMENT ''

    ,average_limit_utilization_1d_bcl   DECIMAL(30,5) COMMENT ''
    ,average_limit_utilization_3d_bcl   DECIMAL(30,5) COMMENT ''
    ,average_limit_utilization_7d_bcl   DECIMAL(30,5) COMMENT ''
    ,average_limit_utilization_14d_bcl  DECIMAL(30,5) COMMENT ''
    ,average_limit_utilization_30d_bcl  DECIMAL(30,5) COMMENT ''

    ,max_limit_utilization_1d_bcl       DECIMAL(30,5) COMMENT ''
    ,max_limit_utilization_3d_bcl       DECIMAL(30,5) COMMENT ''
    ,max_limit_utilization_7d_bcl       DECIMAL(30,5) COMMENT ''
    ,max_limit_utilization_14d_bcl      DECIMAL(30,5) COMMENT ''
    ,max_limit_utilization_30d_bcl      DECIMAL(30,5) COMMENT ''

)
partitioned by
(
    grass_region string comment 'ID/TH/MY/PH/VN',
	grass_date   string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="SNAPPY")
LOCATION '${HDFS_PATH}/risk_feature/ads/ads_behavior_underwrting_feature_df';
MSCK REPAIR TABLE ${SCHEMA}.ads_behavior_underwrting_feature_df;
