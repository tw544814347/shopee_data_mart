--********************************************************************--
-- Author:              huangyue@shopee.com
-- Created Time:        2025-04-16T14:00:00
-- Description:         DWS表 bank statement tag抽取
-- Data Granularity:    
-- PRD                  https://docs.google.com/spreadsheets/d/1xDCuiPPj5c8k2Pm6OaMv4hsl9ZhRDVpJCtzVwl0Cn5M/edit?gid=639282998#gid=639282998
-- Jira                 https://jira.shopee.io/browse/
--********************************************************************--

drop view if exists risk.dwd_bank_record_id_category_cr_df;
create view if not exists risk.dwd_bank_record_id_category_cr_df as 
select acct_no	    
      ,apply_no	
      ,bank_name	
      ,bs_index	
      ,amount	as credit_amt    
      ,currency	
      ,description	
      ,extra_infos	
      ,page_index	
      ,period_end_date	
      ,period_start_date	
      ,platform_user_id	
      ,remaining_balance	
      ,row_index	
      ,source_file	
      ,total_balance	
      ,total_credit_amt	
      ,total_credit_cnt	
      ,total_debit_amt	
      ,total_debit_cnt	
      ,transaction_date	
      ,transaction_type	
      ,user_address	
      ,user_name	
      ,biz_type	
      ,txn_type	
      ,comp_or_indiv	
      ,sender	
      ,company_type	
      ,ecommerce_platform	
      ,cr_db       
      ,grass_date
from risk.dwd_bank_record_id_category_df
where grass_date = '${ds}'
  and cr_db = 'CR'
;


drop view if exists risk.dwd_bank_record_id_category_db_df;
create view if not exists risk.dwd_bank_record_id_category_db_df as 
select acct_no	    
      ,apply_no	
      ,bank_name	
      ,bs_index	
      ,amount	as debit_amt    
      ,currency	
      ,description	
      ,extra_infos	
      ,page_index	
      ,period_end_date	
      ,period_start_date	
      ,platform_user_id	
      ,remaining_balance	
      ,row_index	
      ,source_file	
      ,total_balance	
      ,total_credit_amt	
      ,total_credit_cnt	
      ,total_debit_amt	
      ,total_debit_cnt	
      ,transaction_date	
      ,transaction_type	
      ,user_address	
      ,user_name	
      ,biz_type	
      ,txn_type	
      ,comp_or_indiv	
      ,sender	as receiver
      ,company_type	
      ,ecommerce_platform	
      ,cr_db       
      ,grass_date 
from risk.dwd_bank_record_id_category_df
where grass_date = '${ds}'
  and cr_db = 'DB'
;