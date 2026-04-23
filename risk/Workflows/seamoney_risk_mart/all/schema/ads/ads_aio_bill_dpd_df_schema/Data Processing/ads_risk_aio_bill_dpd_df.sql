drop table if exists ${SCHEMA}.ads_risk_aio_bill_dpd_df;
create external table if not exists ${SCHEMA}.ads_risk_aio_bill_dpd_df
(
credit_user_id                     string                comment "Unique id of credit user 平台用户id"
,platform_user_id                  string                comment "Shopee platform user id credit系统用户ID"
,bill_id                           string                comment "Unique id of repay loancore生成唯一id"
,bill_term                         string                comment "Bill term in old version 账期"
,bill_term_new                     string                comment "due_date <= 15th each month → bill_term_new = month(month_dued_time) - 1 else bill_term_new = month(month_dued_time)"
,bill_date                         string                comment "time when instalment bill will be issued to user   出账日期"
,due_date                          string                comment "Time when the bill will turn overdue 逾期日"
,has_new_bill                      int                   comment "total_amount_repayable - total_amount_refund - total_amount_deduct > 0 then 1 else 0"
,max_dpd                           bigint                comment "History max number of days after bill due date 最大逾期天数" 
,max_dpd_eod                       bigint                comment "History max number of days after bill due date 最大逾期天数eod" 
,is_rollover                       int                   comment "On billing term level, if there are unclear bills before the current term or the clear time of the current term is after the due date, the bill is rollover.是否存在未清账单"
,principal_repayable               decimal(30,10)        comment "Pincipal amount repayable 应还本金"
,principal_refund                  decimal(30,10)        comment "Pincipal amount refund 退还本金"       
,principal_deduct                  decimal(30,10)        comment "Pincipal amount deduct 减免本金"
,total_amount_repayable            decimal(30,10)        comment "Total amount repayable 应还总费用"
,total_amount_refund               decimal(30,10)        comment "Total amount refund 退还总费用"
,total_amount_deduct               decimal(30,10)        comment "Total amount deduct 减免总费用"
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
,total_amount_os_dpd1              decimal(30,10)  comment 'total_amount_os_dpd1'
,total_amount_os_dpd2              decimal(30,10)  comment 'total_amount_os_dpd2'
,total_amount_os_dpd3              decimal(30,10)  comment 'total_amount_os_dpd3'
,total_amount_os_dpd4              decimal(30,10)  comment 'total_amount_os_dpd4'
,total_amount_os_dpd5              decimal(30,10)  comment 'total_amount_os_dpd5'
,total_amount_os_dpd6              decimal(30,10)  comment 'total_amount_os_dpd6'
,total_amount_os_dpd7              decimal(30,10)  comment 'total_amount_os_dpd7'
,total_amount_os_dpd8              decimal(30,10)  comment 'total_amount_os_dpd8'
,total_amount_os_dpd9              decimal(30,10)  comment 'total_amount_os_dpd9'
,total_amount_os_dpd10             decimal(30,10)  comment 'total_amount_os_dpd10'
,total_amount_os_dpd11             decimal(30,10)  comment 'total_amount_os_dpd11'
,total_amount_os_dpd12             decimal(30,10)  comment 'total_amount_os_dpd12'
,total_amount_os_dpd13             decimal(30,10)  comment 'total_amount_os_dpd13'
,total_amount_os_dpd14             decimal(30,10)  comment 'total_amount_os_dpd14'
,total_amount_os_dpd15             decimal(30,10)  comment 'total_amount_os_dpd15'
,total_amount_os_dpd16             decimal(30,10)  comment 'total_amount_os_dpd16'
,total_amount_os_dpd17             decimal(30,10)  comment 'total_amount_os_dpd17'
,total_amount_os_dpd18             decimal(30,10)  comment 'total_amount_os_dpd18'
,total_amount_os_dpd19             decimal(30,10)  comment 'total_amount_os_dpd19'
,total_amount_os_dpd20             decimal(30,10)  comment 'total_amount_os_dpd20'
,total_amount_os_dpd21             decimal(30,10)  comment 'total_amount_os_dpd21'
,total_amount_os_dpd22             decimal(30,10)  comment 'total_amount_os_dpd22'
,total_amount_os_dpd23             decimal(30,10)  comment 'total_amount_os_dpd23'
,total_amount_os_dpd24             decimal(30,10)  comment 'total_amount_os_dpd24'
,total_amount_os_dpd25             decimal(30,10)  comment 'total_amount_os_dpd25'
,total_amount_os_dpd26             decimal(30,10)  comment 'total_amount_os_dpd26'
,total_amount_os_dpd27             decimal(30,10)  comment 'total_amount_os_dpd27'
,total_amount_os_dpd28             decimal(30,10)  comment 'total_amount_os_dpd28'
,total_amount_os_dpd29             decimal(30,10)  comment 'total_amount_os_dpd29'
,total_amount_os_dpd30             decimal(30,10)  comment 'total_amount_os_dpd30'
,total_amount_os_dpd31             decimal(30,10)  comment 'total_amount_os_dpd31'
,total_amount_os_dpd61             decimal(30,10)  comment 'total_amount_os_dpd61'
,total_amount_os_dpd91             decimal(30,10)  comment 'total_amount_os_dpd91'
,total_amount_os_dpd121            decimal(30,10)  comment 'total_amount_os_dpd121'
,total_amount_os_dpd151            decimal(30,10)  comment 'total_amount_os_dpd151'
,total_amount_os_dpd181            decimal(30,10)  comment 'total_amount_os_dpd181'
)
partitioned by
(
    garss_region   string   comment 'region'
    ,product_id     bigint   comment 'prod'
    ,grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/ads/ads_aio_bill_dpd_df';

msck repair table ${SCHEMA}.ads_risk_aio_bill_dpd_df;