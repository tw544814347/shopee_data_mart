drop table if exists ${SCHEMA}.dwd_bank_record_category_df;
create external table if not exists ${SCHEMA}.dwd_bank_record_category_df
(          
        acct_no	string
        ,apply_no	string
        ,bank_name	string
        ,bs_index	string
        ,currency	string
        ,amount	 string      
        ,description	string
        ,extra_infos	string
        ,page_index	string
        ,period_end_date	string
        ,period_start_date	string
        ,platform_user_id	string
        ,remaining_balance	string
        ,row_index	string
        ,source_file	string
        ,total_balance	string
        ,total_credit_amt	string
        ,total_credit_cnt	string
        ,total_debit_amt	string
        ,total_debit_cnt	string
        ,transaction_date	string
        ,transaction_type	string
        ,user_address	string
        ,user_name	string
        ,biz_type	string
        ,txn_type	string
        ,comp_or_indiv	string
        ,other_party_name    string 
        ,company_type	string
        ,ecommerce_platform	string
) partitioned by(
    cr_db	            string
    ,grass_region        string
    ,bank	            string
    ,grass_date         string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION '${HDFS_PATH}/dwd/dwd_bank_record_category_df/'
;

