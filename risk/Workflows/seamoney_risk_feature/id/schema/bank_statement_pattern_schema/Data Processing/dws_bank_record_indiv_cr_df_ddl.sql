drop table if exists ${SCHEMA}.dws_bank_record_indiv_cr_df;
create external table ${SCHEMA}.dws_bank_record_indiv_cr_df
(          
    folder	            string
    ,source_file_name	string
    ,txn_date	        string
    ,txn_type	        string
    ,comp_or_indiv	    string
    ,sender	            string
    ,txn_amount_cr_d	bigint
    ,txn_times_cr_d	    bigint
) partitioned by(
    grass_region        string
    ,bank	            string
    ,cr_db	            string
    ,grass_date         string
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="268435456")
LOCATION '${HDFS_PATH}/dws/dws_bank_record_indiv_cr_df/'
;
