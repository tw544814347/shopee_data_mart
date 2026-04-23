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

-- drop table if exists ${SCHEMA}.`dws_risk_${region}_strategy_${product}_final_result_di`;

create table if not exists ${SCHEMA}.`dws_risk_${region}_strategy_${product}_final_result_di` (
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
    `from_source` STRING COMMENT 'from_source',
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
) 
-- comment 'credit mart summary table' 
partitioned by (
    grass_date string comment 'Date of refreshed data, contains recent 190 days data'
) stored as orc tblproperties (
    "orc.compress" = "ZSTD"
) location '${HDFS_PATH}/dwd/dws_risk_reg_strategy_${product}_final_result_di/grass_region=${REGION}'
;


-- msck repair table ${SCHEMA}.dws_risk_${region}_strategy_${product}_final_result_di;
refresh table ${SCHEMA}.dws_risk_${region}_strategy_${product}_final_result_di;

ADD JAR hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


insert overwrite table ${SCHEMA}.dws_risk_${region}_strategy_${product}_final_result_di  partition(grass_date)
select
    id
    ,risk_version
    ,app_id
    ,scene_id
    ,flow_no
    ,req_time
    ,req_ip
    ,req_server
    ,req_memo
    ,req_no
    ,apply_no
    ,channel_id
    ,checkout_id
    ,loan_id
    ,workflow_scene_id
    ,req_type
    ,req_async
    ,version
    ,seq_id
    ,module
    ,cmd
    ,client_ip
    ,device_type
    ,platform_type
    ,platform_token
    ,platform_user_id
    ,credit_user_id
    ,region
    ,device_brand
    ,device_id
    ,system_type
    ,system_version
    ,app_version
    ,imei
    ,device_fingerprint
    ,lang
    ,`from` as from_source
    ,extension
    ,handle_begin_time
    ,handle_end_time
    ,strategy_id
    ,strategy_version
    ,final_result
    ,reasons
    ,mark
    ,create_time
    ,event_result
    ,gps_status
    ,gps_longitude
    ,gps_latitude
    ,device_model
    ,network_type
    ,cellular_type
    ,workflow_flow_no
    ,email
    ,user_name
    ,phone
    ,phone_no
    ,emergency_contact_name1
    ,emergency_contact_name2
    ,emergency_contact_phone1
    ,emergency_contact_phone2
    ,user_name_by_user
    ,user_name_by_ocr
    ,id_card_no_by_ocr
    ,id_card_no
    ,event_code
    ,shopeepay_user_id
    ,app_type
    ,szdf_token
    ,check_result
    ,check_result_code
    ,additional_code
    ,freeze_time
    ,encrypted_recipient_account
    ,encrypted_bank_account_no
    ,topic_name
    ,risk_scene_id
    ,process_date
    ,task_run_step
    ,x_notes
    ,rspextension
    ,rank_id_for_flow_no
    ,rank_id_for_apply_no
    ,rank_id_for_checkout_id_channel_id
    ,rank_id_for_loan_id
    ,szdf_device_id
    ,szdf_model
    ,bssid
    ,signature
    ,sdk_version
    ,szdfp_risk_tags
    ,location_status
    ,latitude
    ,longitude
    ,gps_hex5
    ,gps_hex6
    ,gps_hex7
    ,gps_hex8
    ,gps_hex9
    ,gps_hex10
    ,gps_hex11
    ,gps_country
    ,gps_province
    ,gps_city
    ,gps_district
    ,gps_province_alt
    ,gps_city_alt
    ,gps_district_alt
    ,ip_city_name
    ,ip_city_name_v2
    ,ip_region_name
    ,system_call
    ,screen_captured
    ,audio_mode
    ,risk_device_info
    ,phone_no_from_extension
    ,phone_from_extension
    ,kyc_phone
    ,kyc_info_phone
    ,id_card_no_from_extension
    ,id_card_no_by_ocr_from_extension
    ,user_name_from_extension
    ,birthday_by_user
    ,birthday_by_ocr
    ,gender_by_user
    ,address_by_user
    ,education_level
    ,province_by_user
    ,city_by_user
    ,district_by_user
    ,load_amount
    ,credit_limit
    ,available_limit
    ,used_limit
    ,real_loan_amount
    ,bank_name
    ,bank_account_add_time
    ,transaction_sn
    ,transaction_type
    ,ext_checkout_id
    ,pay_id
    ,ext_channel_id
    ,reference_id
    ,ref_id
    ,unique_merchant_id
    ,unique_merchant_id_alt
    ,unique_merchant_id_string
    ,is_onus
    ,merchant_scope
    ,order_info
    ,checkout_details
    ,checkout_detail
    ,sub_biz_type
    ,biz_type
    ,kyc_from
    ,kyc_info
    ,kyc_info_alt
    ,is_allow_spp_kyc
    ,is_spl_activated
    ,is_cashloan_activated
    ,is_sellerloan_activated
    ,activation_type
    ,flow_no_from_extension
    ,id_type
    ,id_card_front_picture_url
    ,id_card_back_picture_url
    ,us_id_card_picture_url1
    ,us_id_card_picture_back_url
    ,liveness_check_picture_url1
    ,liveness_check_picture_url2
    ,verify_liveness_check_picture_url1
    ,verify_liveness_check_picture_url2
    ,us_liveness_check_picture_url1
    ,us_liveness_check_picture_url2
    ,holding_lc_selfie
    ,uc_lc_picture
    ,uc_lc_picture_2
    ,liveness_check_result
    ,modular_lc_detail
    ,lc_module_result
    ,company_name
    ,industry_enum
    ,monthly_salary
    ,mother_name
    ,occupation
    ,occupation_enum
    ,emergency_contact_info
    ,pre_app_id_of_40003
    ,pre_scene_id_of_40003
    ,pre_app_id_of
    ,pre_scene_id
    ,pre_verify_method
    ,source
    ,application_id
    ,application_source
    ,birth_date_by_user
    ,case_id
    ,ic_no_by_user
    ,ic_type
    ,kyc_level
    ,kyc_flow_type
    ,kyc_tag_list
    ,name_by_user
    ,place_of_birth_by_user
    ,alc_return_flag
    ,task_id
    ,feature_latitude
    ,feature_longitude
    ,feature_phone
    ,shopeepay_phone_number
    ,device_ext_info
    ,grass_date
from risk.dws_risk_${region}_strategy_${product}_final_temp_result_di
WHERE grass_date >= cast(date('${grass_date}') - INTERVAL '${grass_cnt}' DAYS as string)
AND grass_date <= '${grass_date}'
-- 因为业务数据当中基本不怎么关注这块的数据,统一放置other或者pre_check表中,所以只取req_no合理的数据
AND data_flag='1'
;
