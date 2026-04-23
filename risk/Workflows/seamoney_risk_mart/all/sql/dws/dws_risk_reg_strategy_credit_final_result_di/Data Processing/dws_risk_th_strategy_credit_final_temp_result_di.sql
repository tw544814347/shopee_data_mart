use risk;
--********************************************************************--
-- Author:              dongbo.yu@shopee.com
-- Created Time:        2025-10-09T14:00:00
-- Description:         
--                      flow_no as business key
-- Data Granularity:    flow_no+grass_date+grass_region
-- PRD                  
-- Jira                 https://jira.shopee.io/browse/SPFDT-56340
-- 
-- 1. apply_no 字段解析修改为 判断 _ 或者 | 分割之后的取第0个值,且应该为数字,否则为null
-- 2. channel_id为数字且<10000为合法,否则null
-- 3. checkout_id和loan_id均应为数字,否则null
-- 4. case when (trim(reqno) is null or trim(reqno)='') then 'Null' else 'Not Null' end as flag1,flow_no
--    因为flow_no验证过数据,在reqno空与非空之间不会发生漂移,所以拆成两部分逻辑来处理
--   part1-> 处理 notnull_final_result_tab , part2-> 处理 null_final_result_tab
--********************************************************************--

SET spark.sql.adaptive.enabled = true;
SET spark.sql.adaptive.skewJoin.enabled = true;
SET spark.sql.adaptive.skewJoin.skewedPartitionThresholdInBytes = 512MB;
SET spark.sql.shuffle.partitions = 1200;

-- drop table if exists ${SCHEMA}.`dws_risk_${region}_strategy_${product}_final_temp_result_di`;

create table if not exists ${SCHEMA}.`dws_risk_${region}_strategy_${product}_final_temp_result_di` (
    `id` BIGINT COMMENT 'id',
    `risk_version` BIGINT COMMENT 'risk_version',
    `app_id` STRING COMMENT 'app_id',
    `scene_id` BIGINT COMMENT 'scene_id',
    `flow_no` STRING COMMENT 'flow_no',
    `req_time` BIGINT COMMENT 'req_time',
    `req_ip` STRING COMMENT 'req_ip',
    `req_server` STRING COMMENT 'req_server',
    `req_memo` STRING COMMENT 'req_memo',
    `req_no` STRING COMMENT 'req_no',
    `apply_no` STRING COMMENT 'apply_no',
    `channel_id` STRING COMMENT 'channel_id',
    `checkout_id` STRING COMMENT 'checkout_id',
    `loan_id` STRING COMMENT 'loan_id',
    `workflow_scene_id` BIGINT COMMENT 'workflow_scene_id',
    `req_type` BIGINT COMMENT 'req_type',
    `req_async` BIGINT COMMENT 'req_async',
    `version` BIGINT COMMENT 'version',
    `seq_id` STRING COMMENT 'seq_id',
    `module` STRING COMMENT 'module',
    `cmd` STRING COMMENT 'cmd',
    `client_ip` STRING COMMENT 'client_ip',
    `device_type` BIGINT COMMENT 'device_type',
    `platform_type` BIGINT COMMENT 'platform_type',
    `platform_token` STRING COMMENT 'platform_token',
    `platform_user_id` STRING COMMENT 'platform_user_id',
    `credit_user_id` BIGINT COMMENT 'credit_user_id',
    `region` STRING COMMENT 'region',
    `device_brand` STRING COMMENT 'device_brand',
    `device_id` STRING COMMENT 'device_id',
    `system_type` STRING COMMENT 'system_type',
    `system_version` STRING COMMENT 'system_version',
    `app_version` STRING COMMENT 'app_version',
    `imei` STRING COMMENT 'imei',
    `device_fingerprint` STRING COMMENT 'device_fingerprint',
    `lang` STRING COMMENT 'lang',
    `from` STRING COMMENT 'from',
    `extension` STRING COMMENT 'extension',
    `handle_begin_time` BIGINT COMMENT 'handle_begin_time',
    `handle_end_time` BIGINT COMMENT 'handle_end_time',
    `strategy_id` BIGINT COMMENT 'strategy_id',
    `strategy_version` BIGINT COMMENT 'strategy_version',
    `final_result` BIGINT COMMENT 'final_result',
    `reasons` STRING COMMENT 'reasons',
    `mark` STRING COMMENT 'mark',
    `create_time` BIGINT COMMENT 'create_time',
    `event_result` BIGINT COMMENT 'event_result',
    `gps_status` BIGINT COMMENT 'gps_status',
    `gps_longitude` STRING COMMENT 'gps_longitude',
    `gps_latitude` STRING COMMENT 'gps_latitude',
    `device_model` STRING COMMENT 'device_model',
    `network_type` BIGINT COMMENT 'network_type',
    `cellular_type` STRING COMMENT 'cellular_type',
    `workflow_flow_no` STRING COMMENT 'workflow_flow_no',
    `email` STRING COMMENT 'email',
    `user_name` STRING COMMENT 'user_name',
    `phone` STRING COMMENT 'phone',
    `Phone_no` STRING COMMENT 'Phoneno',
    `emergency_contact_name1` STRING COMMENT 'emergency_contact_name1',
    `emergency_contact_name2` STRING COMMENT 'emergency_contact_name2',
    `emergency_contact_phone1` STRING COMMENT 'emergency_contact_phone1',
    `emergency_contact_phone2` STRING COMMENT 'emergency_contact_phone2',
    `user_name_by_user` STRING COMMENT 'user_name_by_user',
    `user_name_by_ocr` STRING COMMENT 'user_name_by_ocr',
    `id_card_no_by_ocr` STRING COMMENT 'id_card_no_by_ocr',
    `id_card_no` STRING COMMENT 'id_card_no',
    `event_code` STRING COMMENT 'event_code',
    `shopeepay_user_id` STRING COMMENT 'shopeepay_user_id',
    `app_type` STRING COMMENT 'app_type',
    `szdf_token` STRING COMMENT 'szdf_token',
    `check_result` STRING COMMENT 'check_result',
    `check_result_code` STRING COMMENT 'check_result_code',
    `additional_code` STRING COMMENT 'additional_code',
    `freeze_time` STRING COMMENT 'freeze_time',
    `encrypted_recipient_account` STRING COMMENT 'encrypted_recipient_account',
    `encrypted_bank_account_no` STRING COMMENT 'encrypted_bank_account_no',
    `topic_name` STRING COMMENT 'topic_name',
    `risk_scene_id` STRING COMMENT 'risk_scene_id',
    `process_date` STRING COMMENT 'process_date',
    `task_run_step` STRING COMMENT 'task_run_step',
    `x_notes` STRING COMMENT 'x_notes',
    `rspextension` STRING COMMENT 'rspextension',
    `rank_id_for_flow_no` INT NOT NULL COMMENT 'rank_id_for_flow_no',
    `rank_id_for_apply_no` INT COMMENT 'rank_id_for_apply_no',
    `rank_id_for_checkout_id_channel_id` INT COMMENT 'rank_id_for_checkout_id_channel_id',
    `rank_id_for_loan_id` INT COMMENT 'rank_id_for_loan_id',
    `szdf_device_id` STRING COMMENT 'szdf_device_id',
    `szdf_model` STRING COMMENT 'szdf_model',
    `bssid` STRING COMMENT 'bssid',
    `signature` STRING COMMENT 'signature',
    `sdk_version` STRING COMMENT 'sdk_version',
    `szdfp_risk_tags` STRING COMMENT 'szdfp_risk_tags',
    `location_status` STRING COMMENT 'location_status',
    `latitude` STRING COMMENT 'latitude',
    `longitude` STRING COMMENT 'longitude',
    `gps_hex5` STRING COMMENT 'gps_hex5',
    `gps_hex6` STRING COMMENT 'gps_hex6',
    `gps_hex7` STRING COMMENT 'gps_hex7',
    `gps_hex8` STRING COMMENT 'gps_hex8',
    `gps_hex9` STRING COMMENT 'gps_hex9',
    `gps_hex10` STRING COMMENT 'gps_hex10',
    `gps_hex11` STRING COMMENT 'gps_hex11',
    `gps_country` STRING COMMENT 'gps_country',
    `gps_province` STRING COMMENT 'gps_province',
    `gps_city` STRING COMMENT 'gps_city',
    `gps_district` STRING COMMENT 'gps_district',
    `gps_province_alt` STRING COMMENT 'gps_province_alt',
    `gps_city_alt` STRING COMMENT 'gps_city_alt',
    `gps_district_alt` STRING COMMENT 'gps_district_alt',
    `ip_city_name` STRING COMMENT 'ip_city_name',
    `ip_city_name_v2` STRING COMMENT 'ip_city_name_v2',
    `ip_region_name` STRING COMMENT 'ip_region_name',
    `system_call` STRING COMMENT 'system_call',
    `screen_captured` STRING COMMENT 'screen_captured',
    `audio_mode` STRING COMMENT 'audio_mode',
    `risk_device_info` STRING COMMENT 'risk_device_info',
    `phone_no_from_extension` STRING COMMENT 'phone_no_from_extension',
    `phone_from_extension` STRING COMMENT 'phone_from_extension',
    `kyc_phone` STRING COMMENT 'kyc_phone',
    `kyc_info_phone` STRING COMMENT 'kyc_info_phone',
    `id_card_no_from_extension` STRING COMMENT 'id_card_no_from_extension',
    `id_card_no_by_ocr_from_extension` STRING COMMENT 'id_card_no_by_ocr_from_extension',
    `user_name_from_extension` STRING COMMENT 'user_name_from_extension',
    `birthday_by_user` STRING COMMENT 'birthday_by_user',
    `birthday_by_ocr` STRING COMMENT 'birthday_by_ocr',
    `gender_by_user` STRING COMMENT 'gender_by_user',
    `address_by_user` STRING COMMENT 'address_by_user',
    `education_level` STRING COMMENT 'education_level',
    `province_by_user` STRING COMMENT 'province_by_user',
    `city_by_user` STRING COMMENT 'city_by_user',
    `district_by_user` STRING COMMENT 'district_by_user',
    `load_amount` STRING COMMENT 'load_amount',
    `credit_limit` STRING COMMENT 'credit_limit',
    `available_limit` STRING COMMENT 'available_limit',
    `used_limit` STRING COMMENT 'used_limit',
    `real_loan_amount` STRING COMMENT 'real_loan_amount',
    `bank_name` STRING COMMENT 'bank_name',
    `bank_account_add_time` STRING COMMENT 'bank_account_add_time',
    `transaction_sn` STRING COMMENT 'transaction_sn',
    `transaction_type` STRING COMMENT 'transaction_type',
    `ext_checkout_id` STRING COMMENT 'ext_checkout_id',
    `pay_id` STRING COMMENT 'pay_id',
    `ext_channel_id` STRING COMMENT 'ext_channel_id',
    `reference_id` STRING COMMENT 'reference_id',
    `ref_id` STRING COMMENT 'ref_id',
    `unique_merchant_id` STRING COMMENT 'unique_merchant_id',
    `unique_merchant_id_alt` STRING COMMENT 'unique_merchant_id_alt',
    `unique_merchant_id_string` STRING COMMENT 'unique_merchant_id_string',
    `is_onus` STRING COMMENT 'is_onus',
    `merchant_scope` STRING COMMENT 'merchant_scope',
    `order_info` STRING COMMENT 'order_info',
    `checkout_details` STRING COMMENT 'checkout_details',
    `checkout_detail` STRING COMMENT 'checkout_detail',
    `sub_biz_type` STRING COMMENT 'sub_biz_type',
    `biz_type` STRING COMMENT 'biz_type',
    `kyc_from` STRING COMMENT 'kyc_from',
    `kyc_info` STRING COMMENT 'kyc_info',
    `kyc_info_alt` STRING COMMENT 'kyc_info_alt',
    `is_allow_spp_kyc` STRING COMMENT 'is_allow_spp_kyc',
    `is_spl_activated` STRING COMMENT 'is_spl_activated',
    `is_cashloan_activated` STRING COMMENT 'is_cashloan_activated',
    `is_sellerloan_activated` STRING COMMENT 'is_sellerloan_activated',
    `activation_type` STRING COMMENT 'activation_type',
    `flow_no_from_extension` STRING COMMENT 'flow_no_from_extension',
    `id_type` STRING COMMENT 'id_type',
    `id_card_front_picture_url` STRING COMMENT 'id_card_front_picture_url',
    `id_card_back_picture_url` STRING COMMENT 'id_card_back_picture_url',
    `us_id_card_picture_url1` STRING COMMENT 'us_id_card_picture_url1',
    `us_id_card_picture_back_url` STRING COMMENT 'us_id_card_picture_back_url',
    `liveness_check_picture_url1` STRING COMMENT 'liveness_check_picture_url1',
    `liveness_check_picture_url2` STRING COMMENT 'liveness_check_picture_url2',
    `verify_liveness_check_picture_url1` STRING COMMENT 'verify_liveness_check_picture_url1',
    `verify_liveness_check_picture_url2` STRING COMMENT 'verify_liveness_check_picture_url2',
    `us_liveness_check_picture_url1` STRING COMMENT 'us_liveness_check_picture_url1',
    `us_liveness_check_picture_url2` STRING COMMENT 'us_liveness_check_picture_url2',
    `holding_lc_selfie` STRING COMMENT 'holding_lc_selfie',
    `uc_lc_picture` STRING COMMENT 'uc_lc_picture',
    `uc_lc_picture_2` STRING COMMENT 'uc_lc_picture_2',
    `liveness_check_result` STRING COMMENT 'liveness_check_result',
    `modular_lc_detail` STRING COMMENT 'modular_lc_detail',
    `lc_module_result` STRING COMMENT 'lc_module_result',
    `company_name` STRING COMMENT 'company_name',
    `industry_enum` STRING COMMENT 'industry_enum',
    `monthly_salary` STRING COMMENT 'monthly_salary',
    `mother_name` STRING COMMENT 'mother_name',
    `occupation` STRING COMMENT 'occupation',
    `occupation_enum` STRING COMMENT 'occupation_enum',
    `emergency_contact_info` STRING COMMENT 'emergency_contact_info',
    `pre_app_id_of_40003` STRING COMMENT 'pre_app_id_of_40003',
    `pre_scene_id_of_40003` STRING COMMENT 'pre_scene_id_of_40003',
    `pre_app_id_of` STRING COMMENT 'pre_app_id_of',
    `pre_scene_id` STRING COMMENT 'pre_scene_id',
    `pre_verify_method` STRING COMMENT 'pre_verify_method',
    `source` STRING COMMENT 'source',
    `application_id` STRING COMMENT 'application_id',
    `application_source` STRING COMMENT 'application_source',
    `birth_date_by_user` STRING COMMENT 'birth_date_by_user',
    `case_id` STRING COMMENT 'case_id',
    `ic_no_by_user` STRING COMMENT 'ic_no_by_user',
    `ic_type` STRING COMMENT 'ic_type',
    `kyc_level` STRING COMMENT 'kyc_level',
    `kyc_flow_type` STRING COMMENT 'kyc_flow_type',
    `kyc_tag_list` STRING COMMENT 'kyc_tag_list',
    `name_by_user` STRING COMMENT 'name_by_user',
    `place_of_birth_by_user` STRING COMMENT 'place_of_birth_by_user',
    `alc_return_flag` STRING COMMENT 'alc_return_flag',
    `task_id` STRING COMMENT 'task_id',
    `feature_latitude` STRING COMMENT 'feature_latitude',
    `feature_longitude` STRING COMMENT 'feature_longitude',
    `feature_phone` STRING COMMENT 'feature_phone',
    `shopeepay_phone_number` STRING COMMENT 'shopeepay_phone_number',
    `device_ext_info` STRING COMMENT 'device_ext_info'
) partitioned by (
    grass_date string comment 'Date of refreshed data, contains recent 190 days data',
    data_flag  string comment '0/1, 0 means reqno is null, 1 meas reqno is not null'
) stored as orc tblproperties (
    "orc.compress" = "ZSTD"
) location '${HDFS_PATH}/dwd/dws_risk_reg_strategy_${product}_final_temp_result_di/grass_region=${REGION}'
;


-- msck repair table ${SCHEMA}.dws_risk_${region}_strategy_${product}_final_temp_result_di;
refresh table ${SCHEMA}.dws_risk_${region}_strategy_${product}_final_temp_result_di;

ADD JAR hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


--------------------------------------------------这里是分割线,下面处理 notnull_final_result_tab------------------------------------------------------------------
-- cache table notnull_final_result_tab options ('storageLevel' 'DISK_ONLY')
WITH base AS (

    -- 解决数据倾斜,拆分热点数据和非热点数据处理
    SELECT 
    -- 基础表字段 (可以直接获取)
    id,
    risk_version,
    app_id,
    scene_id,
    flow_no,
    req_time,
    req_ip,
    req_server,
    req_memo,
    reqno as req_no,
    
    -- need add apply_no checkout_id  channel_id loan_id
    CASE WHEN regexp_extract(split(regexp_replace(reqno, '\\|', '_'), '_')[0], '^[0-9]+$', 0) != '' THEN regexp_extract(split(regexp_replace(reqno, '\\|', '_'), '_')[0], '^[0-9]+$', 0) ELSE NULL END AS apply_no,
    -- 贷中 支付
    CASE WHEN regexp_extract(SPLIT(reqno, '_')[1], '^[0-9]+$', 0) != '' AND cast(regexp_extract(SPLIT(reqno, '_')[1], '^[0-9]+$', 0) as bigint) < 10000 THEN regexp_extract(SPLIT(reqno, '_')[1], '^[0-9]+$', 0) ELSE NULL END AS channel_id,
    CASE WHEN regexp_extract(SPLIT(reqno, '_')[2], '^[0-9]+$', 0) != '' THEN regexp_extract(SPLIT(reqno, '_')[2], '^[0-9]+$', 0) ELSE NULL END AS checkout_id,
    -- 贷中 提现
    CASE WHEN regexp_extract(SPLIT(reqno, '_')[2], '^[0-9]+$', 0) != '' THEN regexp_extract(SPLIT(reqno, '_')[2], '^[0-9]+$', 0)  ELSE NULL END AS loan_id,
    workflowsceneid as workflow_scene_id,
    reqtype as req_type,
    reqasync as req_async,
    version,
    seq_id,
    module,
    cmd,
    client_ip,
    device_type,
    platform_type,
    platform_token,
    platform_user_id,
    credit_user_id,
    region,
    device_brand,
    device_id,
    system_type,
    system_version,
    app_version,
    imei,
    device_fingerprint,
    lang,
    `from`,
    extension,
    handle_begin_time,
    handle_end_time,
    strategy_id,
    strategy_version,
    final_result,
    reasons,
    mark,
    create_time,
    event_result,
    gps_status,
    gps_longitude,
    gps_latitude,
    device_model,
    network_type,
    cellular_type,
    workflow_flow_no,
    email,
    user_name,
    phone,
    Phoneno as phone_no,
    emergency_contact_name1,
    emergency_contact_name2,
    emergency_contact_phone1,
    emergency_contact_phone2,
    user_name_by_user,
    user_name_by_ocr,
    id_card_no_by_ocr,
    id_card_no,
    event_code,
    shopeepay_user_id,
    app_type,
    szdf_token,
    check_result,
    check_result_code,
    additional_code,
    freeze_time,
    encrypted_recipient_account,
    encrypted_bank_account_no,
    topic_name,
    risk_scene_id,
    grass_date,
    process_date,
    task_run_step,
    x_notes,
    rspextension,
    --  Step 1: 添加随机盐（0~9之间整数，用于打散大Key）
    CAST(RAND() * 10 AS INT) AS salt
    FROM risk.dwd_risk_${region}_strategy_final_result_merge_di
    WHERE grass_date >= cast(date('${grass_date}') - INTERVAL '${grass_cnt}' DAYS as string)
      AND grass_date <= '${grass_date}'
      AND not (trim(reqno) is null or trim(reqno)='')
),

-- =======================================================
-- Step 2: 先按 flow_no + salt 做 Row_Number
--         将相同 flow_no 的数据分散到 10 个不同 Executor
-- =======================================================
with_salt_rank AS (
    SELECT
        *
        ,ROW_NUMBER() OVER (
            PARTITION BY CONCAT(flow_no, '_', salt)
            ORDER BY process_date DESC, req_time DESC
        ) AS rank_id_for_flow_no_salted
    FROM base
),
-- =======================================================
-- Step 3: 先在盐分区内去重，再回聚到原 flow_no
-- =======================================================
deduped AS (
    SELECT * FROM with_salt_rank WHERE rank_id_for_flow_no_salted = 1   -- 先取每个 flow_no_salt 的最新记录
)
,flow_no_deduped AS (
select id,
    risk_version,
    app_id,
    scene_id,
    flow_no,
    req_time,
    req_ip,
    req_server,
    req_memo,
    req_no,
    
    apply_no,
    channel_id,
    checkout_id,
    loan_id,
    workflow_scene_id,
    req_type,
    req_async,
    `version`,
    seq_id,
    module,
    cmd,
    client_ip,
    device_type,
    platform_type,
    platform_token,
    platform_user_id,
    credit_user_id,
    region,
    device_brand,
    device_id,
    system_type,
    `system_version`,
    app_version,
    imei,
    device_fingerprint,
    lang,
    `from`,
    extension,
    handle_begin_time,
    handle_end_time,
    strategy_id,
    strategy_version,
    final_result,
    reasons,
    mark,
    create_time,
    event_result,
    gps_status,
    gps_longitude,
    gps_latitude,
    device_model,
    network_type,
    cellular_type,
    workflow_flow_no,
    email,
    user_name,
    phone,
    phone_no,
    emergency_contact_name1,
    emergency_contact_name2,
    emergency_contact_phone1,
    emergency_contact_phone2,
    user_name_by_user,
    user_name_by_ocr,
    id_card_no_by_ocr,
    id_card_no,
    event_code,
    shopeepay_user_id,
    app_type,
    szdf_token,
    check_result,
    check_result_code,
    additional_code,
    freeze_time,
    encrypted_recipient_account,
    encrypted_bank_account_no,
    topic_name,
    risk_scene_id,
    grass_date,
    process_date,
    task_run_step,
    x_notes,
    rspextension,
    rank_id_for_flow_no
from (
    SELECT
    id,
    risk_version,
    app_id,
    scene_id,
    flow_no,
    req_time,
    req_ip,
    req_server,
    req_memo,
    req_no,
    
    apply_no,
    channel_id,
    checkout_id,
    loan_id,
    workflow_scene_id,
    req_type,
    req_async,
    `version`,
    seq_id,
    module,
    cmd,
    client_ip,
    device_type,
    platform_type,
    platform_token,
    platform_user_id,
    credit_user_id,
    region,
    device_brand,
    device_id,
    system_type,
    `system_version`,
    app_version,
    imei,
    device_fingerprint,
    lang,
    `from`,
    extension,
    handle_begin_time,
    handle_end_time,
    strategy_id,
    strategy_version,
    final_result,
    reasons,
    mark,
    create_time,
    event_result,
    gps_status,
    gps_longitude,
    gps_latitude,
    device_model,
    network_type,
    cellular_type,
    workflow_flow_no,
    email,
    user_name,
    phone,
    phone_no,
    emergency_contact_name1,
    emergency_contact_name2,
    emergency_contact_phone1,
    emergency_contact_phone2,
    user_name_by_user,
    user_name_by_ocr,
    id_card_no_by_ocr,
    id_card_no,
    event_code,
    shopeepay_user_id,
    app_type,
    szdf_token,
    check_result,
    check_result_code,
    additional_code,
    freeze_time,
    encrypted_recipient_account,
    encrypted_bank_account_no,
    topic_name,
    risk_scene_id,
    grass_date,
    process_date,
    task_run_step,
    x_notes,
    rspextension,
    ROW_NUMBER() OVER (
            PARTITION BY flow_no
            ORDER BY process_date DESC, req_time DESC
    ) AS rank_id_for_flow_no
    from deduped
) t 
WHERE rank_id_for_flow_no = 1  --  最终只保留每个 flow_no 的最新一条记录
)
insert overwrite table ${SCHEMA}.dws_risk_${region}_strategy_${product}_final_temp_result_di  partition(grass_date,data_flag)
select id,
    risk_version,
    app_id,
    scene_id,
    flow_no,
    req_time,
    req_ip,
    req_server,
    req_memo,
    req_no,
    
    apply_no,
    channel_id,
    checkout_id,
    loan_id,
    workflow_scene_id,
    req_type,
    req_async,
    `version`,
    seq_id,
    module,
    cmd,
    client_ip,
    device_type,
    platform_type,
    platform_token,
    platform_user_id,
    credit_user_id,
    region,
    device_brand,
    device_id,
    system_type,
    `system_version`,
    app_version,
    imei,
    device_fingerprint,
    lang,
    `from`,
    extension,
    handle_begin_time,
    handle_end_time,
    strategy_id,
    strategy_version,
    final_result,
    reasons,
    mark,
    create_time,
    event_result,
    gps_status,
    gps_longitude,
    gps_latitude,
    device_model,
    network_type,
    cellular_type,
    workflow_flow_no,
    email,
    user_name,
    phone,
    phone_no,
    emergency_contact_name1,
    emergency_contact_name2,
    emergency_contact_phone1,
    emergency_contact_phone2,
    user_name_by_user,
    user_name_by_ocr,
    id_card_no_by_ocr,
    id_card_no,
    event_code,
    shopeepay_user_id,
    app_type,
    szdf_token,
    check_result,
    check_result_code,
    additional_code,
    freeze_time,
    encrypted_recipient_account,
    encrypted_bank_account_no,
    topic_name,
    risk_scene_id,
    process_date,
    task_run_step,
    x_notes,
    rspextension,
    rank_id_for_flow_no,
    ----- 把字段的顺序规整一下
    rank_id_for_apply_no,
    rank_id_for_checkout_id_channel_id,
    rank_id_for_loan_id,
    -- 从extension JSON中提取的字段 (需要JSON提取)
    -- 设备指纹相关
    get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.device_id') as szdf_device_id,
    get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.model') as szdf_model,
    get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.bssid') as bssid,
    get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.signature') as signature,
    get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.sdkversion') as sdk_version,
    -- cast(get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.risk_tags') as array<string>) as szdfp_risk_tags,
    cast(get_json_object(extension, '$.CommonHeader.extension_process_data.sz_dfp.risk_tags') as string) as szdfp_risk_tags,
    -- 位置信息
    get_json_object(extension, '$.CommonHeader.location.status') as location_status,
    get_json_object(extension, '$.CommonHeader.location.latitude') as latitude,
    get_json_object(extension, '$.CommonHeader.location.longitude') as longitude,
    get_json_object(extension, '$.CommonHeader.location.GpsHex5') as gps_hex5,
    get_json_object(extension, '$.CommonHeader.location.GpsHex6') as gps_hex6,
    get_json_object(extension, '$.CommonHeader.location.GpsHex7') as gps_hex7,
    get_json_object(extension, '$.CommonHeader.location.GpsHex8') as gps_hex8,
    get_json_object(extension, '$.CommonHeader.location.GpsHex9') as gps_hex9,
    get_json_object(extension, '$.CommonHeader.location.GpsHex10') as gps_hex10,
    get_json_object(extension, '$.CommonHeader.location.GpsHex11') as gps_hex11,
    get_json_object(extension, '$.CommonHeader.location.address.levelZero') as gps_country,
    get_json_object(extension, '$.CommonHeader.location.address.levelOne') as gps_province,
    get_json_object(extension, '$.CommonHeader.location.address.levelTwo') as gps_city,
    get_json_object(extension, '$.CommonHeader.location.address.levelThree') as gps_district,
    get_json_object(extension, '$.CommonHeader.location.address.province') as gps_province_alt,
    get_json_object(extension, '$.CommonHeader.location.address.city') as gps_city_alt,
    get_json_object(extension, '$.CommonHeader.location.address.district') as gps_district_alt,
    
    -- IP城市信息
    get_json_object(extension, '$.CommonHeader.extension_process_data.ip_city_info.ip_city_name') as ip_city_name,
    get_json_object(extension, '$.CommonHeader.extension_process_data.ip_city_info.ip_city_name_v2') as ip_city_name_v2,
    get_json_object(extension, '$.CommonHeader.extension_process_data.ip_city_info.ip_region_name') as ip_region_name,
    
    -- 风险相关字段
    get_json_object(extension, '$.CommonHeader.system_call') as system_call,
    get_json_object(extension, '$.CommonHeader.screen_captured') as screen_captured,
    get_json_object(extension, '$.CommonHeader.audio_mode') as audio_mode,
    get_json_object(extension, '$.CommonHeader.risk_device_info') as risk_device_info,
    
    -- 业务特定字段
    get_json_object(extension, '$.PhoneNo') as phone_no_from_extension,
    get_json_object(extension, '$.Phone') as phone_from_extension,
    get_json_object(extension, '$.KYCInfo.phone') as kyc_phone,
    get_json_object(extension, '$.kyc_info.phone') as kyc_info_phone,
    get_json_object(extension, '$.id_card_no') as id_card_no_from_extension,
    get_json_object(extension, '$.id_card_no_by_ocr') as id_card_no_by_ocr_from_extension,
    get_json_object(extension, '$.user_name') as user_name_from_extension,
    get_json_object(extension, '$.birthday_by_user') as birthday_by_user,
    get_json_object(extension, '$.birthday_by_ocr') as birthday_by_ocr,
    get_json_object(extension, '$.gender_by_user') as gender_by_user,
    get_json_object(extension, '$.address_by_user') as address_by_user,
    get_json_object(extension, '$.education_level') as education_level,
    get_json_object(extension, '$.province_by_user') as province_by_user,
    get_json_object(extension, '$.city_by_user') as city_by_user,
    get_json_object(extension, '$.district_by_user') as district_by_user,
    
    -- 贷款相关字段
    get_json_object(extension, '$.LoadAmount') as load_amount,
    get_json_object(extension, '$.CreditLimit') as credit_limit,
    get_json_object(extension, '$.AvailableLimit') as available_limit,
    get_json_object(extension, '$.UsedLimit') as used_limit,
    get_json_object(extension, '$.real_loan_amount') as real_loan_amount,
    get_json_object(extension, '$.BankName') as bank_name,
    get_json_object(extension, '$.BankAccountAddTime') as bank_account_add_time,
    
    -- 交易相关字段
    get_json_object(extension, '$.TransactionSN') as transaction_sn,
    get_json_object(extension, '$.TransactionType') as transaction_type,
    get_json_object(extension, '$.CheckOutId') as ext_checkout_id,
    get_json_object(extension, '$.PayId') as pay_id,
    get_json_object(extension, '$.channel_id') as ext_channel_id,
    get_json_object(extension, '$.ReferenceID') as reference_id,
    get_json_object(extension, '$.RefID') as ref_id,
    get_json_object(extension, '$.unique_merchant_id') as unique_merchant_id,
    get_json_object(extension, '$.UniqueMerchantID') as unique_merchant_id_alt,
    get_json_object(extension, '$.unique_merchant_id_string') as unique_merchant_id_string,
    get_json_object(extension, '$.IsOnUs') as is_onus,
    get_json_object(extension, '$.merchant_scope') as merchant_scope,
    
    -- 订单信息
    get_json_object(extension, '$.OrderInfo') as order_info,
    get_json_object(extension, '$.checkout_details') as checkout_details,
    get_json_object(extension, '$.CheckOutDetail') as checkout_detail,
    
    -- 子业务类型
    get_json_object(extension, '$.sub_biz_type') as sub_biz_type,
    get_json_object(extension, '$.biz_type') as biz_type,
    
    -- KYC相关字段
    get_json_object(extension, '$.kyc_from') as kyc_from,
    get_json_object(extension, '$.kyc_info') as kyc_info,
    get_json_object(extension, '$.KYCInfo') as kyc_info_alt,
    get_json_object(extension, '$.is_allow_spp_kyc') as is_allow_spp_kyc,
    get_json_object(extension, '$.is_spl_activated') as is_spl_activated,
    get_json_object(extension, '$.is_cashloan_activated') as is_cashloan_activated,
    get_json_object(extension, '$.is_sellerloan_activated') as is_sellerloan_activated,
    
    -- 激活相关字段
    get_json_object(extension, '$.activation_type') as activation_type,
    get_json_object(extension, '$.FlowNo') as flow_no_from_extension,
    
    -- 身份证相关字段
    get_json_object(extension, '$.id_type') as id_type,
    get_json_object(extension, '$.id_card_front_picture_url') as id_card_front_picture_url,
    get_json_object(extension, '$.id_card_back_picture_url') as id_card_back_picture_url,
    get_json_object(extension, '$.US_idCard_picture_url1') as us_id_card_picture_url1,
    get_json_object(extension, '$.US_idCard_picture_back_url') as us_id_card_picture_back_url,
    
    -- 活体检测相关字段
    get_json_object(extension, '$.liveness_check_picture_url1') as liveness_check_picture_url1,
    get_json_object(extension, '$.liveness_check_picture_url2') as liveness_check_picture_url2,
    get_json_object(extension, '$.verify_liveness_check_picture_url1') as verify_liveness_check_picture_url1,
    get_json_object(extension, '$.verify_liveness_check_picture_url2') as verify_liveness_check_picture_url2,
    get_json_object(extension, '$.US_liveness_check_picture_url1') as us_liveness_check_picture_url1,
    get_json_object(extension, '$.US_liveness_check_picture_url2') as us_liveness_check_picture_url2,
    get_json_object(extension, '$.holding_lc_selfie') as holding_lc_selfie,
    get_json_object(extension, '$.uc_lc_picture') as uc_lc_picture,
    get_json_object(extension, '$.uc_lc_picture_2') as uc_lc_picture_2,
    get_json_object(extension, '$.liveness_check_result') as liveness_check_result,
    get_json_object(extension, '$.modular_lc_detail') as modular_lc_detail,
    get_json_object(extension, '$.lc_module_result') as lc_module_result,
    
    -- 其他业务字段
    get_json_object(extension, '$.company_name') as company_name,
    get_json_object(extension, '$.industry_enum') as industry_enum,
    get_json_object(extension, '$.monthly_salary') as monthly_salary,
    get_json_object(extension, '$.mother_name') as mother_name,
    get_json_object(extension, '$.occupation') as occupation,
    get_json_object(extension, '$.occupation_enum') as occupation_enum,
    get_json_object(extension, '$.emergencyContactInfo') as emergency_contact_info,
    
    -- 预检查相关字段
    get_json_object(extension, '$.pre_app_id_of_40003') as pre_app_id_of_40003,
    get_json_object(extension, '$.pre_scene_id_of_40003') as pre_scene_id_of_40003,
    get_json_object(extension, '$.pre_app_id_of') as pre_app_id_of,
    get_json_object(extension, '$.pre_scene_id') as pre_scene_id,
    get_json_object(extension, '$.pre_verify_method') as pre_verify_method,
    get_json_object(extension, '$.source') as source,
    
    -- 应用相关字段
    get_json_object(extension, '$.application_id') as application_id,
    get_json_object(extension, '$.application_source') as application_source,
    get_json_object(extension, '$.birth_date_by_user') as birth_date_by_user,
    get_json_object(extension, '$.case_id') as case_id,
    get_json_object(extension, '$.ic_no_by_user') as ic_no_by_user,
    get_json_object(extension, '$.ic_type') as ic_type,
    get_json_object(extension, '$.kyc_level') as kyc_level,
    get_json_object(extension, '$.kyc_flow_type') as kyc_flow_type,
    get_json_object(extension, '$.kyc_tag_list') as kyc_tag_list,
    get_json_object(extension, '$.name_by_user') as name_by_user,
    get_json_object(extension, '$.place_of_birth_by_user') as place_of_birth_by_user,
    get_json_object(extension, '$.alc_return_flag') as alc_return_flag,
    
    
    -- 任务相关字段
    get_json_object(extension, '$.CommonHeader.task_id') as task_id,
    
    -- 特征属性
    get_json_object(extension, '$.CommonHeader.feature_property.latitude') as feature_latitude,
    get_json_object(extension, '$.CommonHeader.feature_property.longitude') as feature_longitude,
    get_json_object(extension, '$.CommonHeader.feature_property.phone') as feature_phone,
    
    -- SPP账户信息
    get_json_object(extension, '$.CommonHeader.extension_process_data.spp_account_info.shopeepay_phone_number') as shopeepay_phone_number,
    
    -- 设备扩展信息
    get_json_object(extension, '$.risk_device_info.deviceExtInfo') as device_ext_info,
    grass_date,
    '1' as data_flag
from (
select *
        ,ROW_NUMBER() OVER(
            PARTITION BY app_id, scene_id, apply_no
            ORDER BY process_date DESC, req_time DESC
        ) AS rank_id_for_apply_no,
        -- 针对 checkout_id 不为空进行row_number, 如果为null,会数据倾斜,则rank也为null
        ROW_NUMBER() OVER(
            PARTITION BY app_id, scene_id,channel_id,checkout_id
            ORDER BY process_date DESC, req_time DESC
        )  AS rank_id_for_checkout_id_channel_id,
        -- 针对 loan_id 不为空进行row_number, 如果为null,会数据倾斜,则rank也为null
        ROW_NUMBER() OVER(
            PARTITION BY app_id, scene_id,loan_id
            ORDER BY process_date DESC, req_time DESC
        ) AS rank_id_for_loan_id
    FROM flow_no_deduped
    where checkout_id is not null and apply_no is not null 
union all 
select *
        ,ROW_NUMBER() OVER(
            PARTITION BY app_id, scene_id, apply_no
            ORDER BY process_date DESC, req_time DESC
        ) AS rank_id_for_apply_no,
        -- 针对 checkout_id 不为空进行row_number, 如果为null,会数据倾斜,则rank也为null
        null  AS rank_id_for_checkout_id_channel_id,
        -- 针对 loan_id 不为空进行row_number, 如果为null,会数据倾斜,则rank也为null
        null AS rank_id_for_loan_id
    FROM flow_no_deduped
    where checkout_id is null and apply_no is not null 
union all 
select *
        ,null AS rank_id_for_apply_no,
        -- 针对 checkout_id 不为空进行row_number, 如果为null,会数据倾斜,则rank也为null
        ROW_NUMBER() OVER(
            PARTITION BY app_id, scene_id,channel_id,checkout_id
            ORDER BY process_date DESC, req_time DESC
        )  AS rank_id_for_checkout_id_channel_id,
        -- 针对 loan_id 不为空进行row_number, 如果为null,会数据倾斜,则rank也为null
        ROW_NUMBER() OVER(
            PARTITION BY app_id, scene_id,loan_id
            ORDER BY process_date DESC, req_time DESC
        ) AS rank_id_for_loan_id
    FROM flow_no_deduped
    where checkout_id is not null and apply_no is null 
union all 
select *,
    null AS rank_id_for_apply_no,
    -- 如果为null,会数据倾斜,则rank也为null
    null AS rank_id_for_checkout_id_channel_id,
    -- 如果为null,会数据倾斜,则rank也为null
    null AS rank_id_for_loan_id
    FROM flow_no_deduped
    where checkout_id is null and apply_no is null 
) t
;
