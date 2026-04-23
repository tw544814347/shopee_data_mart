--********************************************************************--
-- Author:              huangyue@shopee.com
-- dbeated Time:        2025-08-12T14:00:00
-- Description:         ADS表 bank statement tag抽取
-- Data Granularity:    
-- PRD                  https://docs.google.com/spreadsheets/d/1nhQcG2aseeeNw6KJZLzHEeIBg17AFc9EsQqFBEApoF4/edit?gid=2145025778#gid=2145025778
-- Jira                 https://jira.shopee.io/browse/
--********************************************************************--

WITH monthly_gmv AS (
    SELECT  platform_user_id
            ,DATE_FORMAT(transaction_date, 'yyyyMM') AS month
            ,SUM(case when ecommerce_platform is not null then credit_amt end) AS gmv
            ,DENSE_RANK() OVER (ORDER BY DATE_FORMAT(transaction_date, 'yyyyMM') DESC) AS month_rank
    FROM risk.dwd_bank_record_id_category_cr_df
    where grass_date = '${ds}'
    GROUP BY platform_user_id, DATE_FORMAT(transaction_date, 'yyyyMM') -- 小写yyyy
)

insert overwrite table ${SCHEMA}.ads_bank_record_id_monthly_txn_user_df partition(grass_date = '${ds}')
select  t1.platform_user_id
        ,apply_no
        ,acct_no
        ,bank_name
        ,currency
        ,source_file
        ,user_address
        ,user_name
        ,biz_type
        ,last6month	
        ,last5month	
        ,last4month	
        ,last3month	
        ,last2month	
        ,last1month	
        ,gmv_last6month	
        ,gmv_last5month	
        ,gmv_last4month	
        ,gmv_last3month	
        ,gmv_last2month	
        ,gmv_last1month	
from (
    select  platform_user_id
            ,apply_no
            ,acct_no
            ,bank_name
            ,currency
            ,source_file
            ,user_address
            ,user_name
            ,biz_type
    from risk.dwd_bank_record_id_category_df
    where  grass_date = '${ds}'
) t1 left join (
    SELECT  platform_user_id
            ,MAX(CASE WHEN month_rank = 6 THEN month END) AS last6month
            ,MAX(CASE WHEN month_rank = 5 THEN month END) AS last5month
            ,MAX(CASE WHEN month_rank = 4 THEN month END) AS last4month
            ,MAX(CASE WHEN month_rank = 3 THEN month END) AS last3month
            ,MAX(CASE WHEN month_rank = 2 THEN month END) AS last2month
            ,MAX(CASE WHEN month_rank = 1 THEN month END) AS last1month
            ,MAX(CASE WHEN month_rank = 6 THEN gmv END) AS gmv_last6month
            ,MAX(CASE WHEN month_rank = 5 THEN gmv END) AS gmv_last5month
            ,MAX(CASE WHEN month_rank = 4 THEN gmv END) AS gmv_last4month
            ,MAX(CASE WHEN month_rank = 3 THEN gmv END) AS gmv_last3month
            ,MAX(CASE WHEN month_rank = 2 THEN gmv END) AS gmv_last2month
            ,MAX(CASE WHEN month_rank = 1 THEN gmv END) AS gmv_last1month
    FROM monthly_gmv
    WHERE month_rank <= 6
    GROUP BY platform_user_id
) t2 on t1.platform_user_id = t2.platform_user_id