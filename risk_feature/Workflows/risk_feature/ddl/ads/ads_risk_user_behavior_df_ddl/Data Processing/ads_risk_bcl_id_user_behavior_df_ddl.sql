drop table if exists ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_behavior_df;

create external table if not exists ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_behavior_df 
(
    credit_user_id string comment 'Credit User ID'
    ,platform_user_id string comment 'Platform User ID'
    ,biz_type bigint comment 'Dimension, 1:BCL;2:SCL;3:SPL;4:FES;7:SPLX;8:CPL;11:TL;12:SVL;13:SCF'
    ,first_month_bill_date string comment 'First Monthly Bill Date'
    ,last_month_bill_date string comment 'Last Monthly Bill Date'
    ,first_month_due_date string comment 'First Monthly Due Date'
    ,last_month_due_date string comment 'Last Monthly Due Date'
    ,gross_floating_term_count bigint comment 'Gross Floating Term Count'
    ,net_floating_term_count bigint comment 'Net Floating Term Count'
    ,cleared_floating_term_count bigint comment 'Cleared Floating Term Count'
    ,principal_repayable decimal(30,10) comment 'Principal Repayable'
    ,total_amount_repayable decimal(30,10) comment 'Total Amount Repayable'
    ,principal_repaid decimal(30,10) comment 'Principal Repaid'
    ,total_amount_repaid decimal(30,10) comment 'Total Amount Repaid'
    ,principal_refund decimal(30,10) comment 'Principal Refund'
    ,total_amount_refund decimal(30,10) comment 'Total Amount Refund'
    ,principal_deduct decimal(30,10) comment 'Principal Deduct'
    ,total_amount_deduct decimal(30,10) comment 'Total Amount Deduct'
    ,gross_bill_count bigint comment 'Gross Bill Count'
    ,net_bill_count bigint comment 'Net Bill Count'
    ,cleared_bill_count bigint comment 'Cleared Bill Count'
    ,bill_principal_repayable decimal(30,10) comment 'Bill Principal Repayable'
    ,bill_total_amount_repayable decimal(30,10) comment 'Bill Total Amount Repayable'
    ,bill_principal_repaid decimal(30,10) comment 'Bill Principal Repaid'
    ,bill_total_amount_repaid decimal(30,10) comment 'Bill Total Amount Repaid'
    ,bill_principal_refund decimal(30,10) comment 'Bill Principal Refund'
    ,bill_total_amount_refund decimal(30,10) comment 'Bill Total Amount Refund'
    ,bill_principal_deduct decimal(30,10) comment 'Bill Principal Deduct'
    ,bill_total_amount_deduct decimal(30,10) comment 'Bill Total Amount Deduct'
    ,current_max_dpd_eod bigint comment 'Current Maximum DPD EOD'
    ,ever_max_dpd bigint comment 'Ever Maximum DPD'
    ,ever_max_dpd_eod bigint comment 'Ever Maximum DPD EOD'
    ,ever_max_dpd_12m_eod bigint comment 'Ever Maximum DPD 12M EOD'
    ,ever_max_dpd_6m_eod bigint comment 'Ever Maximum DPD 6M EOD'
    ,ever_max_dpd_3m_eod bigint comment 'Ever Maximum DPD 3M EOD'
    ,latest_floating_term_dpd_eod bigint comment 'Latest Floating Term DPD EOD'
    ,latest_floating_term_dpd_4m_eod bigint comment 'Latest Floating Term DPD 4M EOD'
    ,is_ever_disbursed bigint comment 'Is Ever Disbursed'
    ,is_ever_due bigint comment 'Is Ever Due'
)
partitioned by
(
    grass_date string comment 'Full Daily Partition'
) 
comment 'credit mart summary table'
stored as orc tblproperties ("orc.compress" = "SNAPPY", "orc.stripe.size" = "64000000") 
location '${HDFS_PATH}/ads/ads_risk_${table_product}_${table_region}_user_behavior_df/grass_region=${region}'
;
msck repair table ${SCHEMA}.ads_risk_${table_product}_${table_region}_user_behavior_df; 