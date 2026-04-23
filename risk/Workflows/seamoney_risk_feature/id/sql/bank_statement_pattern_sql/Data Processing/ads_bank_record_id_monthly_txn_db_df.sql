--********************************************************************--
-- Author:              huangyue@shopee.com
-- dbeated Time:        2025-04-16T14:00:00
-- Description:         ADS表 bank statement tag抽取
-- Data Granularity:    
-- PRD                  https://docs.google.com/spreadsheets/d/1xDCuiPPj5c8k2Pm6OaMv4hsl9ZhRDVpJCtzVwl0Cn5M/edit?gid=639282998#gid=639282998
-- Jira                 https://jira.shopee.io/browse/
--********************************************************************--

insert overwrite table ${SCHEMA}.ads_bank_record_id_monthly_txn_db_df partition(grass_date = '${ds}')
select  platform_user_id
        ,acct_no
        ,apply_no
        ,bank_name
        ,currency
        ,source_file
        ,user_address
        ,user_name
        ,biz_type
        ,txn_type
        ,comp_or_indiv
        ,company_type
        ,receiver
        ,txn_month
        ,txn_times_db_m
        ,txn_amount_db_m
        ,CONCAT(ROUND((txn_amount_db_m/ SUM(txn_amount_db_m) OVER (PARTITION BY txn_month, txn_type,comp_or_indiv))*100, 2),'%' ) as ratio_amt_coi_m
        ,CONCAT(ROUND((txn_times_db_m/ SUM(txn_times_db_m) OVER (PARTITION BY txn_month, txn_type,comp_or_indiv))*100, 2),'%' ) as ratio_times_coi_m
        ,CONCAT(ROUND((txn_amount_db_m/ SUM(txn_amount_db_m) OVER (PARTITION BY txn_month, txn_type))*100, 2),'%' ) as ratio_amt_within_type_m
        ,CONCAT(ROUND((txn_times_db_m/ SUM(txn_times_db_m) OVER (PARTITION BY txn_month, txn_type))*100, 2),'%' ) as ratio_times_within_type_m
        ,CONCAT(ROUND((txn_amount_db_m /SUM(txn_amount_db_m) OVER (PARTITION BY txn_month))*100, 2),'%' ) as ratio_amt_overall_m
        ,CONCAT(ROUND((txn_times_db_m/ SUM(txn_times_db_m) OVER (PARTITION BY txn_month))*100, 2),'%' ) as ratio_times_overall_m
from (
        select  platform_user_id
                ,acct_no
                ,apply_no
                ,bank_name
                ,currency
                ,source_file
                ,user_address
                ,user_name
                ,biz_type
                ,txn_type
                ,comp_or_indiv
                ,company_type
                ,receiver
                ,DATE_FORMAT(period_start_date, 'yyyyMM') as txn_month
                ,sum(txn_amount_db_d) as txn_amount_db_m
                ,sum(txn_times_db_d) as  txn_times_db_m
        from risk.dws_bank_record_id_daily_txn_db_df
        where grass_date = '${ds}'
        group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14
) t1