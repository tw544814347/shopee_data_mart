--********************************************************************--
-- Author:             li.lill@shopee.com
-- Created Time:       2026-03-20
-- Description:        [TH/VN/BR]新增mirror的af数据,final result表
-- PRD:                https://jira.shopee.io/browse/SPFDT-61697                  
--********************************************************************--

-- drop table if exists risk.dwd_risk_${region}_af_final_result_mirror_di;
CREATE TABLE if not exists risk.dwd_risk_${region}_af_final_result_mirror_di (
   id                   BIGINT COMMENT '<comment><description>Primary key identifier, fixed value 0</description><calculationLogic>0</calculationLogic><enum>No enum</enum></comment>',
   risk_version         BIGINT COMMENT '<comment><description>Risk version from source table</description><calculationLogic>cast(risk_version as bigint) from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   app_id               STRING COMMENT '<comment><description>App identifier</description><calculationLogic>app_id from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   scene_id             BIGINT COMMENT '<comment><description>Scene identifier</description><calculationLogic>cast(scene_id as bigint) from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   flow_no              STRING COMMENT '<comment><description>Workflow flow number</description><calculationLogic>flow_no from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   req_time             BIGINT COMMENT '<comment><description>Request timestamp</description><calculationLogic>req_time from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   req_ip               STRING COMMENT '<comment><description>Request IP address</description><calculationLogic>req_ip from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   req_server           STRING COMMENT '<comment><description>Request server</description><calculationLogic>req_server from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   req_memo             STRING COMMENT '<comment><description>Request memo</description><calculationLogic>req_memo from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   reqno                STRING COMMENT '<comment><description>Request number</description><calculationLogic>req_no from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   workflowsceneid      BIGINT COMMENT '<comment><description>Workflow scene identifier</description><calculationLogic>cast(workflow_sceneid as bigint) from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   reqtype              BIGINT COMMENT '<comment><description>Request type</description><calculationLogic>cast(req_type as bigint) from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   reqasync             BIGINT COMMENT '<comment><description>Request async flag</description><calculationLogic>cast(req_async as bigint) from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   version              BIGINT COMMENT '<comment><description>Version</description><calculationLogic>cast(version as bigint) from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   seq_id               STRING COMMENT '<comment><description>Sequence identifier</description><calculationLogic>seq_id from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   module               STRING COMMENT '<comment><description>Module name</description><calculationLogic>module from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   cmd                  STRING COMMENT '<comment><description>Command</description><calculationLogic>cmd from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   client_ip            STRING COMMENT '<comment><description>Client IP address</description><calculationLogic>client_ip from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   device_type          BIGINT COMMENT '<comment><description>Device type</description><calculationLogic>cast(device_type as bigint) from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   platform_type        BIGINT COMMENT '<comment><description>Platform type identifier</description><calculationLogic>cast(platform_type as bigint) from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>1-Shopee, 5-ShopeePay</enum></comment>',
   platform_token       STRING COMMENT '<comment><description>Platform token</description><calculationLogic>platform_token from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   platform_user_id     STRING COMMENT '<comment><description>Platform user identifier</description><calculationLogic>platform_user_id from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   credit_user_id       BIGINT COMMENT '<comment><description>Credit user identifier</description><calculationLogic>cast(credit_user_id as bigint) from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   region               STRING COMMENT '<comment><description>Region code</description><calculationLogic>region from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   device_brand         STRING COMMENT '<comment><description>Device brand</description><calculationLogic>device_brand from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   device_id            STRING COMMENT '<comment><description>Device identifier</description><calculationLogic>device_id from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   sz_dfp_device_id STRING COMMENT '<comment><description>shenzhen device fingerprint</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.extension_process_data.sz_dfp.device_id")</calculationLogic><enum>No enum</enum></comment>',
   system_type          STRING COMMENT '<comment><description>System type</description><calculationLogic>system_type from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   system_version       STRING COMMENT '<comment><description>System version</description><calculationLogic>system_version from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   app_version          STRING COMMENT '<comment><description>App version</description><calculationLogic>app_version from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   imei                 STRING COMMENT '<comment><description>IMEI</description><calculationLogic>imei from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   device_fingerprint   STRING COMMENT '<comment><description>Device fingerprint</description><calculationLogic>device_fingerprint from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   lang                 STRING COMMENT '<comment><description>Language code</description><calculationLogic>lang from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   `from`               STRING COMMENT '<comment><description>Request source</description><calculationLogic>from_source from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   extension            STRING COMMENT '<comment><description>Full ReqParams JSON as extension</description><calculationLogic>extension from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   handle_begin_time    BIGINT COMMENT '<comment><description>Handle begin timestamp</description><calculationLogic>handle_begin_time from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   handle_end_time      BIGINT COMMENT '<comment><description>Handle end timestamp</description><calculationLogic>handle_end_time from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   strategy_id          BIGINT COMMENT '<comment><description>Strategy identifier</description><calculationLogic>cast(strategy_id as bigint) from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   strategy_version     BIGINT COMMENT '<comment><description>Strategy version, fixed value 0</description><calculationLogic>0</calculationLogic><enum>No enum</enum></comment>',
   final_result         BIGINT COMMENT '<comment><description>Final check result</description><calculationLogic>cast(final_result as bigint) from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   reasons              STRING COMMENT '<comment><description>Reasons</description><calculationLogic>reasons from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   mark                 STRING COMMENT '<comment><description>Mark</description><calculationLogic>mark from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   create_time          BIGINT COMMENT '<comment><description>Creation timestamp</description><calculationLogic>create_time from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   event_result         BIGINT COMMENT '<comment><description>Event result, fixed value -1</description><calculationLogic>-1</calculationLogic><enum>No enum</enum></comment>',
   gps_status           BIGINT COMMENT '<comment><description>GPS status</description><calculationLogic>cast(gps_status as bigint) from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   gps_longitude        STRING COMMENT '<comment><description>GPS longitude</description><calculationLogic>gps_longitude from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   gps_latitude         STRING COMMENT '<comment><description>GPS latitude</description><calculationLogic>gps_latitude from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   device_model         STRING COMMENT '<comment><description>Device model</description><calculationLogic>device_model from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   network_type         BIGINT COMMENT '<comment><description>Network type</description><calculationLogic>cast(network_type as bigint) from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   cellular_type        STRING COMMENT '<comment><description>Cellular type</description><calculationLogic>cellular_type from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   workflow_flow_no     STRING COMMENT '<comment><description>Workflow flow number</description><calculationLogic>workflow_flow_no from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   email                STRING COMMENT '<comment><description>User email address</description><calculationLogic>email from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   user_name            STRING COMMENT '<comment><description>User name</description><calculationLogic>user_name from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   phone                STRING COMMENT '<comment><description>Phone number</description><calculationLogic>phone from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   PhoneNo              STRING COMMENT '<comment><description>Phone number (alternate field)</description><calculationLogic>PhoneNo from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   emergency_contact_name1         STRING COMMENT '<comment><description>Emergency contact name 1</description><calculationLogic>emergency_contact_name1 from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   emergency_contact_name2         STRING COMMENT '<comment><description>Emergency contact name 2</description><calculationLogic>emergency_contact_name2 from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   emergency_contact_phone1        STRING COMMENT '<comment><description>Emergency contact phone 1</description><calculationLogic>emergency_contact_phone1 from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   emergency_contact_phone2        STRING COMMENT '<comment><description>Emergency contact phone 2</description><calculationLogic>emergency_contact_phone2 from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   user_name_by_user               STRING COMMENT '<comment><description>User name provided by user</description><calculationLogic>user_name_by_user from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   user_name_by_ocr                STRING COMMENT '<comment><description>User name extracted by OCR</description><calculationLogic>user_name_by_ocr from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   id_card_no_by_ocr               STRING COMMENT '<comment><description>ID card number extracted by OCR</description><calculationLogic>id_card_no_by_ocr from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   id_card_no                      STRING COMMENT '<comment><description>ID card number</description><calculationLogic>id_card_no from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   event_code                      STRING COMMENT '<comment><description>Event code</description><calculationLogic>event_code from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   shopeepay_user_id               STRING COMMENT '<comment><description>ShopeePay user identifier</description><calculationLogic>shopeepay_user_id from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   app_type                        STRING COMMENT '<comment><description>App type</description><calculationLogic>app_type from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   szdf_token                      STRING COMMENT '<comment><description>SZDF token</description><calculationLogic>szdf_token from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   check_result                    STRING COMMENT '<comment><description>Check result</description><calculationLogic>check_result from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   check_result_code               STRING COMMENT '<comment><description>Check result code</description><calculationLogic>check_result_code from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   additional_code                 STRING COMMENT '<comment><description>Additional code</description><calculationLogic>additional_code from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   freeze_time                     STRING COMMENT '<comment><description>Freeze time</description><calculationLogic>freeze_time from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   encrypted_recipient_account     STRING COMMENT '<comment><description>Encrypted recipient account</description><calculationLogic>encrypted_recipient_account from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   encrypted_bank_account_no       STRING COMMENT '<comment><description>Encrypted bank account number</description><calculationLogic>encrypted_bank_account_no from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   risk_scene_id                   STRING COMMENT '<comment><description>Risk scene identifier from scene config</description><calculationLogic>scene_id_from_scene_config from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   task_run_step                   STRING COMMENT '<comment><description>Task run step path</description><calculationLogic>task_run_step from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   x_notes                         STRING COMMENT '<comment><description>X notes from response</description><calculationLogic>x_notes from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   RspExtension                    STRING COMMENT '<comment><description>Response extension JSON</description><calculationLogic>rspextension from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   source_platform_type            STRING COMMENT '<comment><description>Original platform type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.original_platform_type")</calculationLogic><enum>No enum</enum></comment>',
   source_platform_user_id         STRING COMMENT '<comment><description>Original platform user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.original_platform_user_id")</calculationLogic><enum>No enum</enum></comment>',
   traffic_platform_type           STRING COMMENT '<comment><description>Traffic platform type from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.traffic_platform_type")</calculationLogic><enum>No enum</enum></comment>',
   traffic_platform_user_id        STRING COMMENT '<comment><description>Traffic platform user ID from CommonHeader</description><calculationLogic>get_json_object(value, "$.ReqParams.CommonHeader.traffic_platform_user_id")</calculationLogic><enum>No enum</enum></comment>'
   )
PARTITIONED BY (
   topic_name STRING COMMENT '<comment><description>Kafka topic name from scene config</description><calculationLogic>topic_name_from_scene_config from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   grass_date STRING COMMENT '<comment><description>Biz Local Date</description><calculationLogic>grass_date from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>',
   process_date STRING COMMENT '<comment><description>Data processing date</description><calculationLogic>dt from dwd_risk_live_kafka_gateway_aio_log_di</calculationLogic><enum>No enum</enum></comment>'
)
stored as orc tblproperties ("orc.compress"="ZSTD","orc.stripe.size"="2147483648")
LOCATION '${HDFS_PATH}/risk_kafka/dwd/dwd_risk_reg_af_final_result_mirror_di/grass_region=${upper_region}'
COMMENT 'Data warehouse detail table for credit risk strategy final result, merged from Kafka gateway AIO log data'
;

-- msck repair table risk.dwd_risk_${region}_af_final_result_mirror_di;

insert overwrite table risk.dwd_risk_${region}_af_final_result_mirror_di partition (topic_name, grass_date, process_date)
select  
    0                          as id
    ,cast(risk_version as bigint)             as risk_version
    ,app_id                    as app_id
    ,cast(scene_id as bigint)                 as scene_id
    ,flow_no                   as flow_no
    ,req_time                  as req_time
    ,req_ip                    as req_ip
    ,req_server                as req_server
    ,req_memo                  as req_memo
    ,req_no                     as reqno
    ,cast(workflow_sceneid as bigint)   as workflowsceneid
    ,cast(req_type as bigint)                   as reqtype
    ,cast(req_async as bigint)                 as reqasync
    ,cast(version  as bigint)                  as version
    ,seq_id                    as seq_id
    ,module                    as module
    ,cmd                       as cmd
    ,client_ip                 as client_ip
    ,cast(device_type  as bigint)              as device_type
    ,cast(platform_type  as bigint)             as platform_type
    ,platform_token            as platform_token
    ,platform_user_id          as platform_user_id
    ,cast(credit_user_id  as bigint)         as credit_user_id
    ,region                    as region
    ,device_brand              as device_brand
    ,device_id           as device_id
    ,sz_dfp_device_id    as sz_dfp_device_id
    ,system_type         as system_type
    ,system_version      as system_version
    ,app_version         as app_version
    ,imei                as imei
    ,device_fingerprint  as device_fingerprint
    ,lang                as lang
    ,from_source         as from_source
    ,extension                     as extension
    ,handle_begin_time             as handle_begin_time
    ,handle_end_time               as handle_end_time
    ,cast(strategy_id  as bigint)                   as strategy_id
    ,0                             as strategy_version
    ,cast(final_result  as bigint)                  as final_result
    ,reasons                       as reasons
    ,mark                          as mark
    ,create_time                   as create_time
    ,-1                            as event_result
    ,cast(gps_status  as bigint)                    as gps_status
    ,gps_longitude                 as gps_longitude
    ,gps_latitude                  as gps_latitude
    ,device_model                  as device_model
    ,cast(network_type  as bigint)                  as network_type
    ,cellular_type                 as cellular_type
    ,workflow_flow_no              as workflow_flow_no
    ,email                         as email
    ,user_name                     as user_name
    ,phone                         as phone
    ,PhoneNo                       as PhoneNo
    ,emergency_contact_name1       as emergency_contact_name1
    ,emergency_contact_name2       as emergency_contact_name2
    ,emergency_contact_phone1      as emergency_contact_phone1
    ,emergency_contact_phone2      as emergency_contact_phone2
    ,user_name_by_user  as user_name_by_user
    ,user_name_by_ocr as user_name_by_ocr
    ,id_card_no_by_ocr as id_card_no_by_ocr
     ,id_card_no                   as id_card_no
    ,event_code                    as event_code
    ,shopeepay_user_id             as shopeepay_user_id
    ,app_type                      as app_type
    ,szdf_token                    as szdf_token
    ,check_result                  as check_result
    ,check_result_code             as check_result_code
    ,additional_code               as additional_code
    ,freeze_time                   as freeze_time
    ,encrypted_recipient_account   as encrypted_recipient_account
    ,encrypted_bank_account_no     as encrypted_bank_account_no
    ,scene_id                      as risk_scene_id
    ,task_run_step                 as task_run_step
    ,x_notes                       as x_notes
    ,rspextension                  as rspextension
    ,source_platform_type
    ,source_platform_user_id
    ,traffic_platform_type
    ,traffic_platform_user_id
    ,concat('${region}_live_credit_risk_gateway_req_rsp_', app_id)  as topic_name
    ,grass_date as grass_date
    ,dt                            as process_date
from  risk.dwd_risk_${region}_live_kafka_gateway_aio_log_mirror_di
where dt >= cast(date_sub('${grass_date}', 0) as string)
and   dt <= cast(date_add('${grass_date}', 1) as string);

