-- ====================================================================
-- Author:              lisheng@shopee.com
-- Created Time:        2025-12-04
-- Theme Domain：       SMS Info Snapshot
-- Description:         解密app data采集的SMS信息快照表
-- Data Granularity:    task_id
-- History
-- ====================================================================


-- DDL
-- DROP TABLE IF EXISTS ${SCHEMA}.dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_sms_info_snapshot_df;

CREATE EXTERNAL TABLE IF NOT EXISTS ${SCHEMA}.dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_sms_info_snapshot_df (
    task_id                 STRING          COMMENT 'Task ID',
    event_timestamp         STRING          COMMENT 'Event timestamp',
    log_timestamp           STRING          COMMENT 'Log timestamp',
    id                      STRING          COMMENT 'SMS ID',
    address                 STRING          COMMENT 'SMS address/phone number',
    body                    STRING          COMMENT 'SMS body content',
    date                    STRING          COMMENT 'SMS date',
    date_sent               STRING          COMMENT 'SMS date sent',
    type                    STRING          COMMENT 'SMS type',
    read                    STRING          COMMENT 'SMS read status',
    seen                    STRING          COMMENT 'SMS seen status',
    thread_id               STRING          COMMENT 'SMS thread ID',
    subject                 STRING          COMMENT 'SMS subject'
)
COMMENT 'risk mart summary table'
PARTITIONED BY (grass_date STRING COMMENT "YYYY-MM-DD")
STORED AS ORC 
TBLPROPERTIES ("orc.compress"="zstd")
LOCATION '${HDFS_PATH}/risk_mart/dwd/dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_sms_info_snapshot_df';

MSCK REPAIR TABLE ${SCHEMA}.dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_sms_info_snapshot_df;

-- DML
INSERT OVERWRITE TABLE ${SCHEMA}.dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_sms_info_snapshot_df
PARTITION (grass_date = '${grass_date}')
SELECT
    task_id
    , event_timestamp
    , log_timestamp
    , get_json_object(sms_info, '$.id') AS id
    , get_json_object(sms_info, '$.address') AS address
    , get_json_object(sms_info, '$.body') AS body
    , get_json_object(sms_info, '$.date') AS date
    , get_json_object(sms_info, '$.date_sent') AS date_sent
    , get_json_object(sms_info, '$.type') AS type
    , get_json_object(sms_info, '$.read') AS read
    , get_json_object(sms_info, '$.seen') AS seen
    , get_json_object(sms_info, '$.thread_id') AS thread_id
    , get_json_object(sms_info, '$.subject') AS subject
FROM risk.dwd_risk_mx_user_biz_manage_data_inhouse__data_point_taskid_comms_snapshot_df
LATERAL VIEW explode(from_json(get_json_object(tracking.dps_decrypt_comms(comms), '$.sms_info'), 'array<string>')) sms_tab AS sms_info
WHERE grass_date = '${grass_date}';