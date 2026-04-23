-- drop table if exists ${SCHEMA}.dws_risk_${product}_${region}_bill_repayment_zi;
-- create external table if not exists ${SCHEMA}.dws_risk_${product}_${region}_bill_repayment_zi
-- (
-- bill_id                 string              comment "Unique id of repay loancore生成唯一id"
-- ,credit_user_id         string              comment "Unique id of credit user 平台用户id"
-- ,platform_user_id       string              comment "Shopee platform user id credit系统用户ID"
-- ,bill_term              string              comment "Bill term in old version 账期"
-- ,month_bill_time        string              comment "time when instalment bill will be issued to user   出账日期"
-- ,month_due_time         string              comment "Time when the bill will turn overdue 逾期日"
-- ,principal_repayable    decimal(30,10)      comment "Pincipal amount repayable 应还本金"
-- ,principal_os           decimal(30,10)      comment "Pincipal amount outstanding 剩余本金"
-- ,principal_refund       decimal(30,10)      comment "Pincipal amount refund 退还本金"       
-- ,principal_deduct       decimal(30,10)      comment "Pincipal amount deduct 减免本金"
-- ,total_amount_repayable decimal(30,10)      comment "Total amount repayable 应还总费用"
-- ,total_amount_refund    decimal(30,10)      comment "Total amount refund 退还总费用"
-- ,total_amount_deduct    decimal(30,10)      comment "Total amount deduct减免总费用"
-- ,total_amount_os        decimal(30,10)      comment "Total amount outstanding 剩余总费用"
-- ,start_date             string              comment "start_date 剩余os开始时间"
-- ,end_date               string              comment "start_date 剩余os结束时间"
-- )
-- stored as orc tblproperties ("orc.compress"="zstd")
-- location '${HDFS_PATH}/risk_mart/dws/dws_aio_bill_repayment_zi/garss_region=${upper_region}/product_id=${product_id}';


-- drop table if exists ${SCHEMA}.dws_risk_${product}_${region}_bill_repayment_zi_his;
-- create external table if not exists ${SCHEMA}.dws_risk_${product}_${region}_bill_repayment_zi_his
-- (
-- bill_id                 string              comment "Unique id of repay loancore生成唯一id"
-- ,credit_user_id         string              comment "Unique id of credit user 平台用户id"
-- ,platform_user_id       string              comment "Shopee platform user id credit系统用户ID"
-- ,bill_term              string              comment "Bill term in old version 账期"
-- ,month_bill_time        string              comment "time when instalment bill will be issued to user   出账日期"
-- ,month_due_time         string              comment "Time when the bill will turn overdue 逾期日"
-- ,principal_repayable    decimal(30,10)      comment "Pincipal amount repayable 应还本金"
-- ,principal_os           decimal(30,10)      comment "Pincipal amount outstanding 剩余本金"
-- ,principal_refund       decimal(30,10)      comment "Pincipal amount refund 退还本金"       
-- ,principal_deduct       decimal(30,10)      comment "Pincipal amount deduct 减免本金"
-- ,total_amount_repayable decimal(30,10)      comment "Total amount repayable 应还总费用"
-- ,total_amount_refund    decimal(30,10)      comment "Total amount refund 退还总费用"
-- ,total_amount_deduct    decimal(30,10)      comment "Total amount deduct减免总费用"
-- ,total_amount_os        decimal(30,10)      comment "Total amount outstanding 剩余总费用"
-- ,start_date             string              comment "start_date 剩余os开始时间"
-- ,end_date               string              comment "start_date 剩余os结束时间"
-- )
-- stored as orc tblproperties ("orc.compress"="zstd")
-- location '${HDFS_PATH}/risk_mart/dws/dws_aio_bill_repayment_zi_his/garss_region=${upper_region}/product_id=${product_id}';


drop table if exists ${SCHEMA}.dws_risk_${product}_${region}_bill_repayment_zi;
create external table if not exists ${SCHEMA}.dws_risk_${product}_${region}_bill_repayment_zi
(
bill_id                 string              comment "Unique id of repay loancore生成唯一id"
,credit_user_id         string              comment "Unique id of credit user 平台用户id"
,platform_user_id       string              comment "Shopee platform user id credit系统用户ID"
,bill_term              string              comment "Bill term in old version 账期"
,month_bill_time        string              comment "time when instalment bill will be issued to user   出账日期"
,month_due_time         string              comment "Time when the bill will turn overdue 逾期日"
,principal_repayable    decimal(30,10)      comment "Pincipal amount repayable 应还本金"
,principal_os           decimal(30,10)      comment "Pincipal amount outstanding 剩余本金"
,principal_refund       decimal(30,10)      comment "Pincipal amount refund 退还本金"       
,principal_deduct       decimal(30,10)      comment "Pincipal amount deduct 减免本金"
,total_amount_repayable decimal(30,10)      comment "Total amount repayable 应还总费用"
,total_amount_refund    decimal(30,10)      comment "Total amount refund 退还总费用"
,total_amount_deduct    decimal(30,10)      comment "Total amount deduct减免总费用"
,total_amount_os        decimal(30,10)      comment "Total amount outstanding 剩余总费用"
,start_date             string              comment "start_date 剩余os开始时间"
) partitioned by (
 end_date               string              comment "start_date 剩余os结束时间"
)
stored as orc tblproperties ("orc.compress"="zstd")
comment 'Tag:risk summary table'
location '${HDFS_PATH}/risk_mart/dws/dws_aio_bill_repayment_zi_v2/garss_region=${upper_region}/product_id=${product_id}';

msck repair table ${SCHEMA}.dws_risk_${product}_${region}_bill_repayment_zi;
