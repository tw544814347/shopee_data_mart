DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_id_uw_fdc_specific_loan_record_di;
CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_id_uw_fdc_specific_loan_record_di
(
    loan_id                      STRING
    ,ktp_inquiry_time            STRING
    ,platform_number             STRING
    ,borrower_type               STRING
    ,borrower_name               STRING
    ,ktp_number                  STRING
    ,npwp_number                 STRING
    ,agreement_date              STRING
    ,transfer_date               STRING
    ,total_amount                DECIMAL(30,10)
    ,latest_updated_date         STRING
    ,outstanding_balance         DECIMAL(30,10)
    ,due_date                    STRING
    ,loan_quality                STRING
    ,dpd                         BIGINT
    ,dpd_max                     BIGINT
    ,loan_status                 STRING
    ,loan_purpose                STRING
    ,loan_quality_description    STRING
    ,loan_status_description     STRING
)
PARTITIONED BY (
    data_source_name string comment 'data_source_name'
    ,grass_date string comment 'YYYY-MM-dd'
)
stored as orc tblproperties ("orc.compress"="zstd","orc.stripe.size"="2147483648")
LOCATION 'hdfs://R2/projects/risk/hdfs/prod/risk_mart/dwd/dwd_risk_uw_fdc_specific_loan_record_di/grass_region=ID';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_id_uw_fdc_specific_loan_record_di;
