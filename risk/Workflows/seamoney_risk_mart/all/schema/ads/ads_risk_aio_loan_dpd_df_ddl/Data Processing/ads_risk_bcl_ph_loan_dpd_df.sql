drop table if exists ${SCHEMA}.ads_risk_${product}_${region}_loan_dpd_df;
create external table if not exists ${SCHEMA}.ads_risk_${product}_${region}_loan_dpd_df
(
credit_user_id                     string                comment "Unique id of credit user 平台用户id"
,platform_user_id                  string                comment "Shopee platform user id credit系统用户ID"
,loan_id                           string                comment "Unique id of repay loancore生成唯一id"
,loan_disbursed_month              string                comment "time when instalment bill will be issued to user   出账日期"
,loan_disbursed_month_new          string                comment "first_instalment_due_time <= 15th each month → loan_disburse_month_new = month(first_instalment_due_time) - 1 else loan_disburse_month_new = month(first_instalment_due_time)"
,first_instalment_due_time         string                comment "Time when the bill will turn overdue 逾期日"
,max_dpd                           bigint                comment "History max number of days after bill due date 最大逾期天数" 
,max_dpd_eod                       bigint                comment "History max number of days after bill due date 最大逾期天数eod" 
,principal_repayable               decimal(30,10)        comment "Pincipal amount repayable 应还本金"
,loan_tenure                       int                   comment "loan_tenure" 
,principal_os_dpd9_minus           decimal(30,10)  comment 'principal_os_dpd9_minus'
,principal_os_dpd8_minus           decimal(30,10)  comment 'principal_os_dpd8_minus'
,principal_os_dpd7_minus           decimal(30,10)  comment 'principal_os_dpd7_minus'
,principal_os_dpd6_minus           decimal(30,10)  comment 'principal_os_dpd6_minus'
,principal_os_dpd5_minus           decimal(30,10)  comment 'principal_os_dpd5_minus'
,principal_os_dpd4_minus           decimal(30,10)  comment 'principal_os_dpd4_minus'
,principal_os_dpd3_minus           decimal(30,10)  comment 'principal_os_dpd3_minus'
,principal_os_dpd2_minus           decimal(30,10)  comment 'principal_os_dpd2_minus'
,principal_os_dpd1_minus           decimal(30,10)  comment 'principal_os_dpd1_minus'
,principal_os_dpd0                 decimal(30,10)  comment 'principal_os_dpd0'
,principal_os_dpd1                 decimal(30,10)  comment 'principal_os_dpd1'
,principal_os_dpd2                 decimal(30,10)  comment 'principal_os_dpd2'
,principal_os_dpd3                 decimal(30,10)  comment 'principal_os_dpd3'
,principal_os_dpd4                 decimal(30,10)  comment 'principal_os_dpd4'
,principal_os_dpd5                 decimal(30,10)  comment 'principal_os_dpd5'
,principal_os_dpd6                 decimal(30,10)  comment 'principal_os_dpd6'
,principal_os_dpd7                 decimal(30,10)  comment 'principal_os_dpd7'
,principal_os_dpd8                 decimal(30,10)  comment 'principal_os_dpd8'
,principal_os_dpd9                 decimal(30,10)  comment 'principal_os_dpd9'
,principal_os_dpd10                decimal(30,10)  comment 'principal_os_dpd10'
,principal_os_dpd11                decimal(30,10)  comment 'principal_os_dpd11'
,principal_os_dpd12                decimal(30,10)  comment 'principal_os_dpd12'
,principal_os_dpd13                decimal(30,10)  comment 'principal_os_dpd13'
,principal_os_dpd14                decimal(30,10)  comment 'principal_os_dpd14'
,principal_os_dpd15                decimal(30,10)  comment 'principal_os_dpd15'
,principal_os_dpd16                decimal(30,10)  comment 'principal_os_dpd16'
,principal_os_dpd17                decimal(30,10)  comment 'principal_os_dpd17'
,principal_os_dpd18                decimal(30,10)  comment 'principal_os_dpd18'
,principal_os_dpd19                decimal(30,10)  comment 'principal_os_dpd19'
,principal_os_dpd20                decimal(30,10)  comment 'principal_os_dpd20'
,principal_os_dpd21                decimal(30,10)  comment 'principal_os_dpd21'
,principal_os_dpd22                decimal(30,10)  comment 'principal_os_dpd22'
,principal_os_dpd23                decimal(30,10)  comment 'principal_os_dpd23'
,principal_os_dpd24                decimal(30,10)  comment 'principal_os_dpd24'
,principal_os_dpd25                decimal(30,10)  comment 'principal_os_dpd25'
,principal_os_dpd26                decimal(30,10)  comment 'principal_os_dpd26'
,principal_os_dpd27                decimal(30,10)  comment 'principal_os_dpd27'
,principal_os_dpd28                decimal(30,10)  comment 'principal_os_dpd28'
,principal_os_dpd29                decimal(30,10)  comment 'principal_os_dpd29'
,principal_os_dpd30                decimal(30,10)  comment 'principal_os_dpd30'
,principal_os_dpd31                decimal(30,10)  comment 'principal_os_dpd31'
,principal_os_dpd60                decimal(30,10)  comment 'principal_os_dpd60'
,principal_os_dpd90                decimal(30,10)  comment 'principal_os_dpd90'
,principal_os_dpd120               decimal(30,10)  comment 'principal_os_dpd120'
,principal_os_dpd150               decimal(30,10)  comment 'principal_os_dpd150'
,principal_os_dpd180               decimal(30,10)  comment 'principal_os_dpd180'
,first_loan_disbursed_month        string          comment 'First disburse time of the user'
,product_type                      string          comment 'SPL/SPL Xtra/BCL/BCL/BCL Xtra/SCL'
,loan_type                         string          comment 'SPL/Cicilan Handphone Loan/BCL/BCL/BCL Xtra/SCL'
,first_instalment_term             string          comment 'The term of the first instalment'
,principal_refund                  decimal(30,10)  comment 'principal_refund'
,principal_deduct                  decimal(30,10)  comment 'principal_deduct' 
,has_valid_loan                    int             comment 'total_amount_repayable - total_amount_refund - total_amount_deduct > 0'
,disbursement_term                 string          comment 'YYYYMM, first_instalment_due_time - 1 month'
${comment_out},is_vintage_exclusion              int             comment 'Whether the loan should be excluded from vintage analysis: 1 if first_instalment_due_time day not in (6,16) OR restructured_type=1 OR principal_repayable-principal_refund<=0, else 0'
)
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/ads/ads_aio_loan_dpd_df/garss_region=${upper_region}/product_id=${product_id}';

msck repair table ${SCHEMA}.ads_risk_${product}_${region}_loan_dpd_df;