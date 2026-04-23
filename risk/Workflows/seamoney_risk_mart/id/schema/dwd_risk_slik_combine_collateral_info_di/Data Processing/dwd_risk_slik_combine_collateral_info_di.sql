DROP TABLE IF EXISTS risk.dwd_risk_slik_combine_collateral_info_di;
CREATE EXTERNAL TABLE IF NOT EXISTS risk.dwd_risk_slik_combine_collateral_info_di (
    trace_id STRING COMMENT '追踪ID',
    credit_user_id BIGINT COMMENT '信用用户ID',  
    platform_user_id BIGINT COMMENT '平台用户ID',  
    flow_no STRING COMMENT '流程编号',
    ktp_no BIGINT COMMENT 'KTP号码',  
    report_no STRING COMMENT '报告编号',
    status STRING COMMENT '状态',
    is_error STRING COMMENT '是否错误',
    create_time STRING COMMENT '创建时间',
    report_update_time STRING COMMENT '报告更新时间',    
    initial_contract_no STRING COMMENT '初始合同号',
    collateral_address STRING COMMENT '抵押物地址',
    register_code STRING COMMENT '登记代码',
    collateral_type STRING COMMENT '抵押物类型',
    collateral_rating STRING COMMENT '抵押物评级',
    rating_agency_code STRING COMMENT '评级机构代码',
    rating_agency STRING COMMENT '评级机构',
    binding_type_code STRING COMMENT '绑定类型代码',  --string
    binding_type STRING COMMENT '绑定类型',
    binding_date STRING COMMENT '绑定日期',
    name_of_the_collateral_owner STRING COMMENT '抵押物所有者名称',
    proof_of_owner_ship STRING COMMENT '所有权证明',
    district_city_code STRING COMMENT '地区城市代码',  --string
    district_city STRING COMMENT '地区城市',
    collateral_value_NJOP DECIMAL(20,10) COMMENT '抵押物NJOP价值',  
    reporting_evaluation_date STRING COMMENT '报告评估日期',
    collateral_value_by_independent_appraiser DECIMAL(20,10) COMMENT '独立评估价值',  
    collateral_value_by_LJK DECIMAL(20,10) COMMENT 'LJK评估价值',  
    name_of_independent_appraiser STRING COMMENT '独立评估机构名称',
    date_of_independent_appraisal_assessment STRING COMMENT '独立评估日期',
    percentage_of_paripasu DECIMAL(20,10) COMMENT '共同抵押百分比',  
    insured STRING COMMENT '是否投保',  
    description STRING COMMENT '描述',
    update_timestamp STRING COMMENT '更新时间',
    reporter_rating_date STRING COMMENT '报告人评级日期'
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
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_slik_combine_collateral_info_di_v2';

DROP TABLE IF EXISTS risk.dwd_risk_slik_combine_collateral_info_di_dist_clik;
CREATE EXTERNAL TABLE IF NOT EXISTS risk.dwd_risk_slik_combine_collateral_info_di_dist_clik (
    trace_id STRING COMMENT '追踪ID',
    credit_user_id BIGINT COMMENT '信用用户ID',  
    platform_user_id BIGINT COMMENT '平台用户ID',  
    flow_no STRING COMMENT '流程编号',
    ktp_no BIGINT COMMENT 'KTP号码',  
    report_no STRING COMMENT '报告编号',
    status STRING COMMENT '状态',
    is_error STRING COMMENT '是否错误',
    create_time STRING COMMENT '创建时间',
    report_update_time STRING COMMENT '报告更新时间',    
    initial_contract_no STRING COMMENT '初始合同号',
    collateral_address STRING COMMENT '抵押物地址',
    register_code STRING COMMENT '登记代码',
    collateral_type STRING COMMENT '抵押物类型',
    collateral_rating STRING COMMENT '抵押物评级',
    rating_agency_code STRING COMMENT '评级机构代码',
    rating_agency STRING COMMENT '评级机构',
    binding_type_code STRING COMMENT '绑定类型代码',  
    binding_type STRING COMMENT '绑定类型',
    binding_date STRING COMMENT '绑定日期',
    name_of_the_collateral_owner STRING COMMENT '抵押物所有者名称',
    proof_of_owner_ship STRING COMMENT '所有权证明',
    district_city_code STRING COMMENT '地区城市代码',  
    district_city STRING COMMENT '地区城市',
    collateral_value_NJOP DECIMAL(20,10) COMMENT '抵押物NJOP价值',  
    reporting_evaluation_date STRING COMMENT '报告评估日期',
    collateral_value_by_independent_appraiser DECIMAL(20,10) COMMENT '独立评估价值',  
    collateral_value_by_LJK DECIMAL(20,10) COMMENT 'LJK评估价值',  
    name_of_independent_appraiser STRING COMMENT '独立评估机构名称',
    date_of_independent_appraisal_assessment STRING COMMENT '独立评估日期',
    percentage_of_paripasu DECIMAL(20,10) COMMENT '共同抵押百分比',  
    insured STRING COMMENT '是否投保',  
    description STRING COMMENT '描述',
    update_timestamp STRING COMMENT '更新时间',
    reporter_rating_date STRING COMMENT '报告人评级日期'
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
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_slik_combine_collateral_info_di_v2/data_source=CLIK';


DROP TABLE IF EXISTS risk.dwd_risk_slik_combine_collateral_info_di_dist_slik;
CREATE EXTERNAL TABLE IF NOT EXISTS risk.dwd_risk_slik_combine_collateral_info_di_dist_slik (
    trace_id STRING COMMENT '追踪ID',
    credit_user_id BIGINT COMMENT '信用用户ID',  
    platform_user_id BIGINT COMMENT '平台用户ID',  
    flow_no STRING COMMENT '流程编号',
    ktp_no BIGINT COMMENT 'KTP号码',  
    report_no STRING COMMENT '报告编号',
    status STRING COMMENT '状态',
    is_error STRING COMMENT '是否错误',
    create_time STRING COMMENT '创建时间',
    report_update_time STRING COMMENT '报告更新时间',    
    initial_contract_no STRING COMMENT '初始合同号',
    collateral_address STRING COMMENT '抵押物地址',
    register_code STRING COMMENT '登记代码',
    collateral_type STRING COMMENT '抵押物类型',
    collateral_rating STRING COMMENT '抵押物评级',
    rating_agency_code STRING COMMENT '评级机构代码',
    rating_agency STRING COMMENT '评级机构',
    binding_type_code STRING COMMENT '绑定类型代码',  
    binding_type STRING COMMENT '绑定类型',
    binding_date STRING COMMENT '绑定日期',
    name_of_the_collateral_owner STRING COMMENT '抵押物所有者名称',
    proof_of_owner_ship STRING COMMENT '所有权证明',
    district_city_code STRING COMMENT '地区城市代码',  
    district_city STRING COMMENT '地区城市',
    collateral_value_NJOP DECIMAL(20,10) COMMENT '抵押物NJOP价值',  
    reporting_evaluation_date STRING COMMENT '报告评估日期',
    collateral_value_by_independent_appraiser DECIMAL(20,10) COMMENT '独立评估价值',  
    collateral_value_by_LJK DECIMAL(20,10) COMMENT 'LJK评估价值',  
    name_of_independent_appraiser STRING COMMENT '独立评估机构名称',
    date_of_independent_appraisal_assessment STRING COMMENT '独立评估日期',
    percentage_of_paripasu DECIMAL(20,10) COMMENT '共同抵押百分比',  
    insured STRING COMMENT '是否投保',  
    description STRING COMMENT '描述',
    update_timestamp STRING COMMENT '更新时间',
    reporter_rating_date STRING COMMENT '报告人评级日期'
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
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_slik_combine_collateral_info_di_v2/data_source=SLIK';


DROP TABLE IF EXISTS risk.dwd_risk_slik_combine_collateral_info_di_dist_cbi;
CREATE EXTERNAL TABLE IF NOT EXISTS risk.dwd_risk_slik_combine_collateral_info_di_dist_cbi (
    trace_id STRING COMMENT '追踪ID',
    credit_user_id BIGINT COMMENT '信用用户ID',  
    platform_user_id BIGINT COMMENT '平台用户ID',  
    flow_no STRING COMMENT '流程编号',
    ktp_no BIGINT COMMENT 'KTP号码',  
    report_no STRING COMMENT '报告编号',
    status STRING COMMENT '状态',
    is_error STRING COMMENT '是否错误',
    create_time STRING COMMENT '创建时间',
    report_update_time STRING COMMENT '报告更新时间',    
    initial_contract_no STRING COMMENT '初始合同号',
    collateral_address STRING COMMENT '抵押物地址',
    register_code STRING COMMENT '登记代码',
    collateral_type STRING COMMENT '抵押物类型',
    collateral_rating STRING COMMENT '抵押物评级',
    rating_agency_code STRING COMMENT '评级机构代码',
    rating_agency STRING COMMENT '评级机构',
    binding_type_code STRING COMMENT '绑定类型代码',  
    binding_type STRING COMMENT '绑定类型',
    binding_date STRING COMMENT '绑定日期',
    name_of_the_collateral_owner STRING COMMENT '抵押物所有者名称',
    proof_of_owner_ship STRING COMMENT '所有权证明',
    district_city_code STRING COMMENT '地区城市代码',  
    district_city STRING COMMENT '地区城市',
    collateral_value_NJOP DECIMAL(20,10) COMMENT '抵押物NJOP价值',  
    reporting_evaluation_date STRING COMMENT '报告评估日期',
    collateral_value_by_independent_appraiser DECIMAL(20,10) COMMENT '独立评估价值',  
    collateral_value_by_LJK DECIMAL(20,10) COMMENT 'LJK评估价值',  
    name_of_independent_appraiser STRING COMMENT '独立评估机构名称',
    date_of_independent_appraisal_assessment STRING COMMENT '独立评估日期',
    percentage_of_paripasu DECIMAL(20,10) COMMENT '共同抵押百分比',  
    insured STRING COMMENT '是否投保',  
    description STRING COMMENT '描述',
    update_timestamp STRING COMMENT '更新时间',
    reporter_rating_date STRING COMMENT '报告人评级日期'
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
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_slik_combine_collateral_info_di_v2/data_source=CBI';

