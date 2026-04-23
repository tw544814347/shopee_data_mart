--********************************************************************--
-- Author:              huangyue@shopee.com
-- Created Time:        2025-10-09
-- Theme Domain：       key metrics mart loan base info dimension table
-- Description:         loan base info dimension table
-- Data Granularity:    loan_id
-- Jira: https://jira.shopee.io/browse/SPFDT-54775
-- Confluence: https://docs.google.com/document/d/18phpogzubeMqoo9vLuUE3q7GJulp9KfJr4VBiUZ2z9U/edit?tab=t.0
-- Examples: https://docs.google.com/spreadsheets/d/1ff9h1uplpQHsLQxV6wiqG0O-PZrS7XbTfbMgQ-a7H1Y/edit?gid=0#gid=0
-- history: 2025-10-09  huangyue    initialize
--          2025-12-25  lisheng     add product_code, dsiburese_term, source tb changed to dws_${product}_aio_${region}_loan_repayment_df
--********************************************************************--

drop table if exists ${SCHEMA}.dim_risk_${product}_${region}_loan_base_info_df;
create external table if not exists ${SCHEMA}.dim_risk_${product}_${region}_loan_base_info_df
(
    loan_id                     string   comment "Loan ID"
    ,credit_user_id             string   comment "Credit User ID"
    ,platform_user_id           string   comment "Platform User ID (Due to the DFS project, it will be offline in the future. At that time, the upstream table will switch to shopee_user_id and shopeepay_user_id)"
    ,platform_type              string   comment "platform type (Due to the DFS project, it will be offline in the future). 1: Shopee, 2: Shopeepay, 3: Merchant"
    ,loan_tenure                int      comment "Loan Tenure"
    ,channel_id                 int      comment "1:MP/SPM(Marketplace) 2:APM / ShopeePay(Apm) 3:DP/SPM(Direct Purchase) 4:CsB / ShopeePay/APM 5:BsC / ShopeePay/APM 6:Shopee Food(food) 7:Jump APP(jump app) 8:Cicilan Handphone Loan via SPM(手机分期) 9:Insurance(保险) 10:Account linking(账户绑定) 11:VA(虚拟账户) 12:SPL Card 13:QR P2P Payment(扫码转账) 14:Cash Advance(现金预支) 1004:ShopeePay App 1005:ShopeePay App 1007:ShopeePay App"
    ,product_type               string   comment "Product Type: SPL/SPLX/BCL/BCLX/SCL/TL"
    ,first_instalment_due_time  string   comment "First Instalment Due Time"
    ,due_time                   string   comment "Due Time (equal first_instalment_due_time)"
    ,due_week                   string   comment "The week number of the month (first_instalment_due_time) , in the format: YYYY-MM WN (e.g., 2025-10 W1 indicates the 1st to 7th day of the first week of October, and W2 indicates the 8th to 14th day of the second week)"
    ,due_month                  string   comment "The Month of the first_instalment_due_time"
    ,disburse_time              string   comment "Disburse Time"
    ,disburse_week              string   comment "The week number of the month (disburse_time) , in the format: YYYY-MM WN (e.g., 2025-10 W1 indicates the 1st to 7th day of the first week of October, and W2 indicates the 8th to 14th day of the second week)"
    ,disburse_month             string   comment "Disburse Month (Use first_instalment_due_time minus 1 month as the disburse month)"
    ,product_code               string   comment "product code"
    ,disburse_term              string   comment "Disburse Term (Use first_instalment_due_time minus 1 month as the disburse term)"    
    ${comment_out},confirm_time      string   comment 'Confirm time from '   
    ${comment_out},restructured_type bigint  comment '1 → bnpl to installment, 2 → post due, 3 → bnpl conversion, 4 → bill install' 
)   
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dim/dim_risk_aio_loan_base_info_df/garss_region=${REGION}/product_id=${product_id}';

msck repair table ${SCHEMA}.dim_risk_${product}_${region}_loan_base_info_df;

insert overwrite ${SCHEMA}.dim_risk_${product}_${region}_loan_base_info_df partition(grass_date)
select
    loan_id
    ,credit_user_id
    ,platform_user_id
    ,platform_type
    ,loan_tenure
    ,${channel_id}                                                                                                                              as channel_id
    ,case when '${product}' = 'spl' and ${product_type_column} = 3   then 'SPL'
          when '${product}' = 'spl' and ${product_type_column} = 7   then 'SPL Xtra'
          when '${product}' = 'bcl' and ${product_type_column} = 102 then 'BCL Xtra'
          when '${product}' = 'bcl' then 'BCL'
          when '${product}' = 'scl' then 'SCL'
          when '${product}' = 'tl' then 'TL'
          else null
     end                                                                                                                                        as product_type
    ,first_instalment_due_time
    ,first_instalment_due_time                                                                                                                  as due_time
    ,concat(substr(first_instalment_due_time, 1, 7), ' W', cast(ceiling(cast(substr(first_instalment_due_time, 9, 2) as int) / 7.0) as string)) as due_week
    ,substr(first_instalment_due_time, 1, 7)                                                                                                    as due_month
    ,disburse_time
    ,concat(substr(disburse_time, 1, 7), ' W', cast(ceiling(cast(substr(disburse_time, 9, 2) as int) / 7.0) as string))                         as disburse_week
    ,substr(add_months(first_instalment_due_time, -1), 1, 7)                                                                                    as disburse_month
    ,product_code   
    ,date_format(date_sub(add_months(to_date(first_instalment_due_time), -1), 1), 'yyyyMM')                                                     as disburse_term
    ${comment_out} ,confirm_time                                                                                                                as confirm_time
    ${comment_out} ,restructured_type                                                                                                            as restructured_type
    ,'${ds}'                                                                                                                                    as grass_date
from credit_mart.dws_${product}_aio_${region}_loan_repayment_df
where grass_date = '${ds}';