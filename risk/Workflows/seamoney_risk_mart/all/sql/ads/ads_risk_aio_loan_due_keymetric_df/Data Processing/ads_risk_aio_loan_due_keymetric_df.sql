--DROP TABLE IF EXISTS ${SCHEMA}.ads_risk_aio_loan_due_keymetric_df;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.ads_risk_aio_loan_due_keymetric_df
(
        new_repeat_user string COMMENT '<comment><description>is_first_bill_loan=1 then new else repeat</description><calculationLogic>new_repeat_user</calculationLogic><enum>No enum</enum></comment>',
        loan_tenure bigint COMMENT '<comment><description>Total loan tenure periods</description><calculationLogic>loan_tenure</calculationLogic><enum>No enum</enum></comment>',
        dpd_filter bigint COMMENT '<comment><description>DPD bucket filter based on days past due at end of day</description><calculationLogic>case when dpd_eod > 0 and dpd_eod <= 30 then 1 when dpd_eod > 30 and dpd_eod <= 60 then 30 when dpd_eod > 60 and dpd_eod <= 90 then 60 when dpd_eod > 90 and dpd_eod <= 120 then 90 when dpd_eod > 120 and dpd_eod <= 180 then 120 when dpd_eod > 180 then 180 end</calculationLogic><enum>1-1to30, 30-31to60, 60-61to90, 90-91to120, 120-121to180, 180-over180</enum></comment>',
        loan_disbursed_month string COMMENT '<comment><description>The first bill term of the loan. If the loan hasn&apos;t been confirmed, the value is null.</description><calculationLogic>loan_disbursed_month</calculationLogic><enum>No enum</enum></comment>',
        loan_due_amt decimal(30,10) COMMENT '<comment><description>Total principal amount outstanding</description><calculationLogic>sum(principal_os)</calculationLogic><enum>No enum</enum></comment>',
        loan_repay_amt decimal(30,10) COMMENT '<comment><description>Total principal amount repayable</description><calculationLogic>sum(principal_repayable)</calculationLogic><enum>No enum</enum></comment>',
        loan_due_rate decimal(30,10) COMMENT '<comment><description>Ratio of outstanding principal to repayable principal</description><calculationLogic>sum(principal_os) / sum(principal_repayable)</calculationLogic><enum>No enum</enum></comment>'
        )
partitioned by(
    grass_region string COMMENT '<comment><description>Grass region,Biz Local Market</description><calculationLogic>grass_region</calculationLogic><enum></enum></comment>',
    product_id int COMMENT '<comment><description>Product ID,1=BCL,3=SPL</description><calculationLogic>product_id</calculationLogic><enum>1=BCL,3=SPL</enum></comment>',
    grass_date string COMMENT '<comment><description>Biz Local Date,YYYY-MM-dd</description><calculationLogic>Get Local Date From Biz Data</calculationLogic><enum>No enum</enum></comment>'
)
stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/ads/ads_risk_aio_loan_due_keymetric_df'
COMMENT 'Application data service table for risk information.'
;
MSCK REPAIR TABLE ${SCHEMA}.ads_risk_aio_loan_due_keymetric_df;