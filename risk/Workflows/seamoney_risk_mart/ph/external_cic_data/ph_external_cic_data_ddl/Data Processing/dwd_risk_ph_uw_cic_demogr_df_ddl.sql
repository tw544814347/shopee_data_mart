DROP VIEW IF EXISTS dwd_risk_ph_uw_cic_demogr_df;

CREATE TABLE dwd_risk_ph_uw_cic_demogr_df (
    -- 基础字段
    -- grass_date                  STRING COMMENT '数据分区日期',
    trace_id                    STRING COMMENT '请求唯一追踪ID',
    credit_user_id              STRING COMMENT '信贷用户ID',
    platform_user_id            STRING COMMENT '平台用户ID',
    flow_no                     STRING COMMENT '流水号',
    request_date                STRING   COMMENT 'CRIF请求日期',
    request_date_time           STRING COMMENT 'CRIF请求时间戳',
    
    -- 主体匹配信息
    cic_demogr_cb_subject_code  STRING COMMENT 'CRIF主体代码',
    cic_demogr_matched_flag     STRING COMMENT '匹配标识',
    
    -- 姓名信息
    cic_demogr_first_name       STRING COMMENT '名字',
    cic_demogr_former_last_name STRING COMMENT '曾用姓氏',
    cic_demogr_last_name        STRING COMMENT '姓氏',
    cic_demogr_middle_name      STRING COMMENT '中间名',
    cic_demogr_nickname         STRING COMMENT '昵称',
    cic_demogr_suffix           STRING COMMENT '姓名后缀',
    
    -- 家庭成员信息
    cic_demogr_father_first_name STRING COMMENT '父亲名字',
    cic_demogr_father_last_name  STRING COMMENT '父亲姓氏',
    cic_demogr_father_middle_name STRING COMMENT '父亲中间名',
    cic_demogr_father_suffix      STRING COMMENT '父亲姓名后缀',
    cic_demogr_mother_first_name  STRING COMMENT '母亲婚前名',
    cic_demogr_mother_last_name   STRING COMMENT '母亲婚前姓',
    cic_demogr_mother_middle_name STRING COMMENT '母亲婚前中间名',
    cic_demogr_spouse_first_name  STRING COMMENT '配偶名字',
    cic_demogr_spouse_last_name   STRING COMMENT '配偶姓氏',
    cic_demogr_spouse_middle_name STRING COMMENT '配偶中间名',
    
    -- 人口统计信息
    cic_demogr_cars_owned_no    BIGINT COMMENT '拥有汽车数量',
    cic_demogr_civil_status     STRING COMMENT '婚姻状态代码',
    cic_demogr_civil_status_desc STRING COMMENT '婚姻状态描述',
    cic_demogr_dependants_no    BIGINT COMMENT '抚养人数',
    cic_demogr_gender           STRING COMMENT '性别代码',
    cic_demogr_gender_desc      STRING COMMENT '性别描述',
    cic_demogr_nationality      STRING COMMENT '国籍代码',
    cic_demogr_nationality_desc STRING COMMENT '国籍描述',
    cic_demogr_resident         STRING COMMENT '居住状态代码',
    cic_demogr_resident_desc    STRING COMMENT '居住状态描述',
    cic_demogr_title            STRING COMMENT '头衔代码',
    cic_demogr_title_desc       STRING COMMENT '头衔描述',
    
    -- 出生信息
    cic_demogr_birth_country    STRING COMMENT '出生国家代码',
    cic_demogr_birth_country_desc STRING COMMENT '出生国家描述',
    cic_demogr_birth_place      STRING COMMENT '出生地',
    cic_demogr_birth_date       STRING COMMENT '出生日期',
    
    -- 职业信息
    cic_demogr_employ_text      STRING COMMENT '职业文本描述',
    cic_demogr_employ_last_update_date STRING COMMENT '职业信息最后更新日期',
    cic_demogr_employ_annual_monthly_indicator STRING COMMENT '收入周期标识',
    cic_demogr_employ_annual_monthly_indicator_desc STRING COMMENT '收入周期描述',
    cic_demogr_employ_currency  STRING COMMENT '收入货币代码',
    cic_demogr_employ_currency_desc STRING COMMENT '收入货币描述',
    cic_demogr_employ_date_hired_from STRING COMMENT '雇佣开始日期',
    cic_demogr_employ_date_hired_to STRING COMMENT '雇佣结束日期',
    cic_demogr_employ_gross_income DECIMAL(30,10) COMMENT '总收入金额',
    cic_demogr_employ_occupation STRING COMMENT '职业代码',
    cic_demogr_employ_occupation_desc STRING COMMENT '职业描述',
    cic_demogr_employ_occupation_status STRING COMMENT '职业状态代码',
    cic_demogr_employ_occupation_status_desc STRING COMMENT '职业状态描述',
    cic_demogr_employ_phone_number STRING COMMENT '工作联系电话',
    
    -- 历史信息
    cic_demogr_address_history STRING COMMENT '历史地址记录',
    cic_demogr_contact_history  STRING COMMENT '联系方式历史',
    cic_demogr_id_code_history  STRING COMMENT '身份代码历史',
    cic_demogr_id_history       STRING COMMENT '身份证明历史',
    cic_demogr_sole_trader_data STRING COMMENT '个体经营者数据'
)

PARTITIONED BY (grass_date STRING COMMENT '分区日期')

stored as orc tblproperties ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_ph_uw_cic_demogr_df_v0';
MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_ph_uw_cic_demogr_df;