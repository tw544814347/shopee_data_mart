drop table if exists ${SCHEMA}.ads_bank_record_indiv_cr_df;
create external table ${SCHEMA}.ads_bank_record_indiv_cr_df
(          
    folder	            string
    ,source_file_name	string
    ,txn_month	        string
    ,txn_type	        string
    ,comp_or_indiv	    string
    ,sender	            string
    ,txn_times_cr_m	    bigint
    ,txn_amount_cr_m	bigint
    ,ratio_amt_within_type_m	double 
    ,ratio_amt_comp_m	        double
    ,ratio_times_within_type_m	double
    ,ratio_times_comp_m	        double
    ,ratio_amt_overall_m	    double
    ,ratio_times_overall_m	    double
    
) partitioned by(
    grass_region        string
    ,bank	            string
    ,cr_db	            string
    ,grass_date         string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION '${HDFS_PATH}/ads/ads_bank_record_indiv_cr_df/'
;
