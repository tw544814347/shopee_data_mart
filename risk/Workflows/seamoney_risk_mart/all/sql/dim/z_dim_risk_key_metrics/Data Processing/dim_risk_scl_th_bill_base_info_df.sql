--********************************************************************--
-- Author:              huangyue@shopee.com
-- Created Time:        2025-10-09
-- Theme Domain：       key metrics mart loan base info dimension table
-- Description:         bill base info dimension table
-- Data Granularity:    bill_id
-- Jira: https://jira.shopee.io/browse/SPFDT-54775
-- Confluence: https://docs.google.com/document/d/18phpogzubeMqoo9vLuUE3q7GJulp9KfJr4VBiUZ2z9U/edit?tab=t.0
-- Examples: https://docs.google.com/spreadsheets/d/1ff9h1uplpQHsLQxV6wiqG0O-PZrS7XbTfbMgQ-a7H1Y/edit?gid=0#gid=0
--********************************************************************--

-- drop table if exists ${SCHEMA}.dim_risk_${product}_${region}_bill_base_info_df;
create external table if not exists ${SCHEMA}.dim_risk_${product}_${region}_bill_base_info_df
(
    bill_id                     string   comment "Bill ID"
    ,credit_user_id             string   comment "Credit User ID"
    ,platform_user_id           string   comment "Platform User ID (Due to the DFS project, it will be offline in the future. At that time, the upstream table will switch to shopee_user_id and shopeepay_user_id)"
    ,platform_type              string   comment "platform type (Due to the DFS project, it will be offline in the future). 1: Shopee, 2: Shopeepay, 3: Merchant"
    ,product_type               string   comment "Product Type: SPL/SPLX/BCL/BCLX/SCL/TL"
    ,due_time                   string   comment "Due Time (equal month_due_time)"
    ,due_week                   string   comment "The week number of the month (month_due_time) , in the format: YYYY-MM WN (e.g., 2025-10 W1 indicates the 1st to 7th day of the first week of October, and W2 indicates the 8th to 14th day of the second week)"
    ,due_month                  string   comment "The Month of the month_due_time"
    ,month_bill_time            string   comment "The time when the bill was issued (billing date)"
)
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dim/dim_risk_aio_bill_base_info_df/garss_region=${REGION}/product_id=${product_id}';

msck repair table ${SCHEMA}.dim_risk_${product}_${region}_bill_base_info_df;

insert overwrite ${SCHEMA}.dim_risk_${product}_${region}_bill_base_info_df partition(grass_date)
select  bill_id
        ,credit_user_id
        ,platform_user_id 
        ,platform_type
        ,case when '${product}' = 'spl' and ${product_type_column} = 3   then 'SPL'
              when '${product}' = 'spl' and ${product_type_column} = 7   then 'SPL Xtra'
              when '${product}' = 'bcl' and ${product_type_column} = 102 then 'BCL Xtra'
              when '${product}' = 'bcl' then  'BCL'
              when '${product}' = 'scl' then  'SCL'
              when '${product}' = 'tl' then   'TL'
              else null  
         end as product_type  
        ,month_due_time as due_time 
        ,concat(substr(month_due_time, 1, 7), ' W', cast(ceiling(cast(substr(month_due_time, 9, 2) as int) / 7.0) as string)) as due_week
        ,substr(month_due_time, 1, 7) as due_month
        ,month_bill_time as month_bill_time
        ,'${ds}' as grass_date
from credit_mart.dws_${product}_${region}_bill_repayment_df
where grass_date = '${ds}';
;