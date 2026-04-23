DROP TABLE IF EXISTS risk.dwd_risk_slik_combine_base_info_di;
CREATE EXTERNAL TABLE IF NOT EXISTS risk.dwd_risk_slik_combine_base_info_di (
    trace_id STRING,
    credit_user_id BIGINT,          
    platform_user_id BIGINT,       
    flow_no STRING,
    ktp_no BIGINT,                 
    report_no STRING,
    status STRING,
    is_error STRING,
    report_update_time STRING,
    create_time STRING,
    name STRING,
    birth_date STRING,             
    birth_place STRING,
    identity_id BIGINT,            
    identity_number BIGINT,        
    npwp BIGINT,                   
    gender_id STRING,
    gender STRING,
    degree_id STRING,              
    degree STRING,
    job_id STRING,                 
    job STRING,
    work_place STRING,
    business_field_id STRING,
    business_field STRING,
    address STRING,
    country_id STRING,
    country STRING,
    city_id BIGINT,                
    city STRING,
    district STRING,
    village STRING,
    zipcode STRING,                
    report_update_date STRING,
    reporter_ljk_id STRING,        
    reporter STRING,
    report_create_date STRING,
    worst_quality STRING,
    worst_quality_date STRING,
    bank_reporter_cnt BIGINT,      
    bpr_reporter_cnt BIGINT,       
    financial_reporter_cnt BIGINT,  
    other_reporter_cnt BIGINT,     
    guarantee_os_amt DECIMAL(20,10),
    credit_os_amt DECIMAL(20,10),
    other_os_amt DECIMAL(20,10),
    lc_os_amt DECIMAL(20,10),
    securities_os_amt DECIMAL(20,10),
    guarantee_amt DECIMAL(20,10),
    credit_amt DECIMAL(20,10),
    other_amt DECIMAL(20,10),
    lc_amt DECIMAL(20,10),
    securities_amt DECIMAL(20,10),
    total_amt DECIMAL(20,10),
    total_os_amt DECIMAL(20,10)
)
PARTITIONED BY (
    data_source STRING COMMENT '数据来源: CBI/CLIK/SLIK',
    grass_date STRING COMMENT '分区日期 yyyy-MM-dd'
)
STORED AS ORC
TBLPROPERTIES (
    "orc.compress" = "SNAPPY",
    "orc.stripe.size" = "2147483648"
)
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_slik_combine_base_info_di_v2';


DROP TABLE IF EXISTS risk.dwd_risk_slik_combine_base_info_di_dist_clik;
CREATE EXTERNAL TABLE IF NOT EXISTS risk.dwd_risk_slik_combine_base_info_di_dist_clik (
    trace_id STRING,
    credit_user_id BIGINT,          
    platform_user_id BIGINT,       
    flow_no STRING,
    ktp_no BIGINT,                 
    report_no STRING,
    status STRING,
    is_error STRING,
    report_update_time STRING,
    create_time STRING,
    name STRING,
    birth_date STRING,             
    birth_place STRING,
    identity_id BIGINT,            
    identity_number BIGINT,        
    npwp BIGINT,                   
    gender_id STRING,
    gender STRING,
    degree_id STRING,              
    degree STRING,
    job_id STRING,                 
    job STRING,
    work_place STRING,
    business_field_id STRING,
    business_field STRING,
    address STRING,
    country_id STRING,
    country STRING,
    city_id BIGINT,                
    city STRING,
    district STRING,
    village STRING,
    zipcode STRING,                
    report_update_date STRING,
    reporter_ljk_id STRING,        
    reporter STRING,
    report_create_date STRING,
    worst_quality STRING,
    worst_quality_date STRING,
    bank_reporter_cnt BIGINT,      
    bpr_reporter_cnt BIGINT,       
    financial_reporter_cnt BIGINT,  
    other_reporter_cnt BIGINT,     
    guarantee_os_amt DECIMAL(20,10),
    credit_os_amt DECIMAL(20,10),
    other_os_amt DECIMAL(20,10),
    lc_os_amt DECIMAL(20,10),
    securities_os_amt DECIMAL(20,10),
    guarantee_amt DECIMAL(20,10),
    credit_amt DECIMAL(20,10),
    other_amt DECIMAL(20,10),
    lc_amt DECIMAL(20,10),
    securities_amt DECIMAL(20,10),
    total_amt DECIMAL(20,10),
    total_os_amt DECIMAL(20,10)
)
PARTITIONED BY (
    data_source STRING COMMENT '数据来源: CBI/CLIK/SLIK',
    grass_date STRING COMMENT '分区日期 yyyy-MM-dd'
)
STORED AS ORC
TBLPROPERTIES (
    "orc.compress" = "SNAPPY",
    "orc.stripe.size" = "2147483648"
)
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_slik_combine_base_info_di_v2/data_source=CLIK';


DROP TABLE IF EXISTS risk.dwd_risk_slik_combine_base_info_di_dist_slik;
CREATE EXTERNAL TABLE IF NOT EXISTS risk.dwd_risk_slik_combine_base_info_di_dist_slik (
    trace_id STRING,
    credit_user_id BIGINT,          
    platform_user_id BIGINT,       
    flow_no STRING,
    ktp_no BIGINT,                 
    report_no STRING,
    status STRING,
    is_error STRING,
    report_update_time STRING,
    create_time STRING,
    name STRING,
    birth_date STRING,             
    birth_place STRING,
    identity_id BIGINT,            
    identity_number BIGINT,        
    npwp BIGINT,                   
    gender_id STRING,
    gender STRING,
    degree_id STRING,              
    degree STRING,
    job_id STRING,                 
    job STRING,
    work_place STRING,
    business_field_id STRING,
    business_field STRING,
    address STRING,
    country_id STRING,
    country STRING,
    city_id BIGINT,                
    city STRING,
    district STRING,
    village STRING,
    zipcode STRING,                
    report_update_date STRING,
    reporter_ljk_id STRING,        
    reporter STRING,
    report_create_date STRING,
    worst_quality STRING,
    worst_quality_date STRING,
    bank_reporter_cnt BIGINT,      
    bpr_reporter_cnt BIGINT,       
    financial_reporter_cnt BIGINT,  
    other_reporter_cnt BIGINT,     
    guarantee_os_amt DECIMAL(20,10),
    credit_os_amt DECIMAL(20,10),
    other_os_amt DECIMAL(20,10),
    lc_os_amt DECIMAL(20,10),
    securities_os_amt DECIMAL(20,10),
    guarantee_amt DECIMAL(20,10),
    credit_amt DECIMAL(20,10),
    other_amt DECIMAL(20,10),
    lc_amt DECIMAL(20,10),
    securities_amt DECIMAL(20,10),
    total_amt DECIMAL(20,10),
    total_os_amt DECIMAL(20,10)
)
PARTITIONED BY (
    data_source STRING COMMENT '数据来源: CBI/CLIK/SLIK',
    grass_date STRING COMMENT '分区日期 yyyy-MM-dd'
)
STORED AS ORC
TBLPROPERTIES (
    "orc.compress" = "SNAPPY",
    "orc.stripe.size" = "2147483648"
)
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_slik_combine_base_info_di_v2/data_source=SLIK';




DROP TABLE IF EXISTS risk.dwd_risk_slik_combine_base_info_di_dist_cbi;
CREATE EXTERNAL TABLE IF NOT EXISTS risk.dwd_risk_slik_combine_base_info_di_dist_cbi (
    trace_id STRING,
    credit_user_id BIGINT,          
    platform_user_id BIGINT,       
    flow_no STRING,
    ktp_no BIGINT,                 
    report_no STRING,
    status STRING,
    is_error STRING,
    report_update_time STRING,
    create_time STRING,
    name STRING,
    birth_date STRING,             
    birth_place STRING,
    identity_id BIGINT,            
    identity_number BIGINT,        
    npwp BIGINT,                   
    gender_id STRING,
    gender STRING,
    degree_id STRING,              
    degree STRING,
    job_id STRING,                 
    job STRING,
    work_place STRING,
    business_field_id STRING,
    business_field STRING,
    address STRING,
    country_id STRING,
    country STRING,
    city_id BIGINT,                
    city STRING,
    district STRING,
    village STRING,
    zipcode STRING,                
    report_update_date STRING,
    reporter_ljk_id STRING,        
    reporter STRING,
    report_create_date STRING,
    worst_quality STRING,
    worst_quality_date STRING,
    bank_reporter_cnt BIGINT,      
    bpr_reporter_cnt BIGINT,       
    financial_reporter_cnt BIGINT,  
    other_reporter_cnt BIGINT,     
    guarantee_os_amt DECIMAL(20,10),
    credit_os_amt DECIMAL(20,10),
    other_os_amt DECIMAL(20,10),
    lc_os_amt DECIMAL(20,10),
    securities_os_amt DECIMAL(20,10),
    guarantee_amt DECIMAL(20,10),
    credit_amt DECIMAL(20,10),
    other_amt DECIMAL(20,10),
    lc_amt DECIMAL(20,10),
    securities_amt DECIMAL(20,10),
    total_amt DECIMAL(20,10),
    total_os_amt DECIMAL(20,10)
)
PARTITIONED BY (
    data_source STRING COMMENT '数据来源: CBI/CLIK/SLIK',
    grass_date STRING COMMENT '分区日期 yyyy-MM-dd'
)
STORED AS ORC
TBLPROPERTIES (
    "orc.compress" = "SNAPPY",
    "orc.stripe.size" = "2147483648"
)
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_slik_combine_base_info_di_v2/data_source=CBI';