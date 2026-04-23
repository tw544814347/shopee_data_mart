drop table if exists ${SCHEMA}.dws_risk_${product}_${region}_loan_repayment_zi_his;
create external table if not exists ${SCHEMA}.dws_risk_${product}_${region}_loan_repayment_zi_his
(
platform_user_id                 string              comment "Shopee platform user id credit系统用户ID"
,credit_user_id                  string              comment "Unique id of credit user 平台用户id"
,loan_id                         string              comment "loan_id"
,loan_disbursed_month            string              comment "the first bill term of the loan.if the loan hasn't been confirmed, the value is null. 首期借据，如果借据还未确认，则该值为null"
,first_instalment_due_time       string              comment "time of the first instalment due 分期付款首期逾期时间"
,bill_due_day                    int                 comment "day(date(first_instalment_due_time))"
,new_repeat_user                 string              comment "is_first_bill_loan=1 then new else repeat"
,loan_tenure                     int                 comment "loan_tenure 总期数"
,months_on_book                  bigint              comment "Months after bill due date 逾期日相差月份"
,months_after_due                bigint              comment "number of months after bill due date, regardless of clear_status 当前与首期逾期日相差月数"
,clear_status                    bigint              comment "1:uncleared 2:partial cleared 3:cleared"
,dpd_eod                         bigint              comment "dpd_eod"
,principal_repayable             decimal(30,10)      comment "Pincipal amount repayable 应还本金"
,principal_os                    decimal(30,10)      comment "Pincipal amount outstanding 剩余本金"
,start_date                      string              comment "start_date 剩余os开始时间"
,end_date                        string              comment "end_date 剩余os结束时间"
) 
partitioned by(
    grass_date                        string              comment "备份时间"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/dws/dws_aio_loan_repayment_zi_his/garss_region=${upper_region}/product_id=${product_id}';
;

