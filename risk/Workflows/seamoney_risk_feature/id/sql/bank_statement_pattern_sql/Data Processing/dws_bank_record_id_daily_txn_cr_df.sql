--********************************************************************--
-- Author:              huangyue@shopee.com
-- Created Time:        2025-04-16T14:00:00
-- Description:         DWS表 bank statement tag抽取
-- Data Granularity:    
-- PRD                  https://docs.google.com/spreadsheets/d/1xDCuiPPj5c8k2Pm6OaMv4hsl9ZhRDVpJCtzVwl0Cn5M/edit?gid=639282998#gid=639282998
-- Jira                 https://jira.shopee.io/browse/
--********************************************************************--

insert overwrite table risk.dws_bank_record_id_daily_txn_cr_df partition(grass_date = '${ds}')
select  platform_user_id
        ,acct_no
        ,apply_no
        ,bank_name
        ,currency
        ,period_end_date
        ,period_start_date
        ,source_file
        ,transaction_date
        ,user_address
        ,user_name
        ,biz_type
        ,txn_type
        ,comp_or_indiv
        ,case when comp_or_indiv= 'individual' then null else company_type end as company_type
        ,sender
        ,sum(credit_amt)   as txn_amount_cr_d
        ,count(credit_amt) as  txn_times_cr_d
from risk.dwd_bank_record_id_category_cr_df
where grass_date = '${ds}'
group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
