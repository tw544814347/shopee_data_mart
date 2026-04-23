drop table if exists ${SCHEMA}.ads_risk_${product}_${region}_loan_mob_dpd_df;
create external table if not exists ${SCHEMA}.ads_risk_${product}_${region}_loan_mob_dpd_df
(
platform_user_id       string               comment  "Shopee platform user id credit系统用户ID"
,credit_user_id        string               comment "Unique id of credit user 平台用户id"
,loan_disburse_month   string               comment "the first bill term of the loan.if the loan hasn't been confirmed, the value is null"
,loan_id               string               comment "loan id 票据ID"
,bill_due_day          int                  comment "The bill due day of the loan day(date(first_instalment_due_time))"
,new_repeat_user       string               comment "If the loan is the first loan of the user"
,tenure                string               comment "Only applicable by Tenure level"
,product_type          string               comment "Only application to ID SPL ID SPL normal/mini/lite"
,loan_type             string               comment "Only application to ID SPL ID SPL/ Cicilan Handphone Loan"
,dpd_filter            string               comment "Choose the DPD value which the performance is based on (DPD 0,7,15,30,60,90)"
,month_on_book         string               comment "The nth bill cycle which the loan is undergoing(mob1-25)"
,mob_date              string               comment "The specific date for this MOB based on month_on_book and dpd_filter"
,dpd_amt               decimal(30,10)       comment "The nominator of vintage in amt level,principal_os"
,loan_amt_usd          decimal(30,10)       comment "The denominator of vintage in amt level,principal_repayable usd"
,loan_amt              decimal(30,10)       comment "The denominator of vintage in amt level,principal_repayable"
,disbursement_term     string               comment "YYYYMM, first_instalment_due_time - 1 month"
,disburse_date         string               comment "actual disburse date"
,interest_rate         decimal(30,10)       comment "The interest rate of this loan"
,principal_accu        decimal(30,10)       comment "Accumulated principal from disburse date to due date of MOB, considering actual repayment behavior"
,principal_accu_usd    decimal(30,10)       comment "Accumulated principal in USD from disburse date to due date of MOB"
,principal_accu_no_early_repay decimal(30,10) comment "Theoretical accumulated principal assuming no early repayment and on-time payment"
,bill_install_loan_id  string               comment "If bill is re-installed, use this id to connect to re-install loan id"
,is_behaved            boolean              comment "Whether this loan is behaved for conditioned mob and dpd days"
,loan_from_restructure bigint   
${comment_out} ,loan_date             string               comment 'user view disburse date'
-- ${comment_out},is_vintage_exclusion  bigint               comment"Is Vintage Exclusion? 1:yes, 0:no"
)
comment 'Tag:risk mart summary table'
partitioned by
(
    grass_date     string   comment "YYYY-MM-DD"
)
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/risk_mart/ads/ads_aio_loan_mob_dpd_df/garss_region=${upper_region}/product_id=${product_id}';

msck repair table ${SCHEMA}.ads_risk_${product}_${region}_loan_mob_dpd_df;