-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-08-25
-- Theme Domain:        Anti-Fraud 
-- Data Granularity:    ticket_id
-- Description:         risk_ticket dwd表
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-08-21 - chengguo.liu - 初始化
--  2025-11-24 - chengguo.liu - 新增业务冗余字段和映射, https://jira.shopee.io/browse/SPFDT-57710
-- =============================================================================

--drop table if exists ${SCHEMA}.dwd_spp_${region}_risk_ticket_df;
create table if not exists ${SCHEMA}.dwd_spp_${region}_risk_ticket_df
(
    sys_id bigint comment '主键：sys db id'
    ,ticket_id string comment '主键：ticket_id'
    ,workflow_flow_no string comment '工单id，flow no (映射为工作流流水号)'
    ,ticket_info string comment '工单详情信息'
    ,app_id string comment '应用ID'
    ,scene_id bigint comment '场景ID'
    ,ticket_category bigint comment '工单类型：0-Undefined, 1-Liveness Check, 2-KYC Risk, 3-IVR, 4-Listing, 5-Common, 6-Transaction, 7-Duplicate, 8-Upgrade, 100-invokepolicy not real ticket'
    ,ticket_category_name string comment '工单类型名称'
    ,ticket_subtype bigint comment '同category工单下，分子类型'
    ,platform_user_id string comment '平台用户ID'
    ,shopeepay_user_id string comment 'ShopeePay用户ID'
    ,case_id string comment 'case ID'
    ,application_source bigint comment '申请来源'
    ,id_card_no string comment '身份证号'
    ,user_name string comment '用户姓名'
    ,status bigint comment '工单状态：0-Unassigned, 1-MakerReview, 2-Done, 3-FieldCompleting, 4-MakerSkip, 5-MakerReviewFromSkip'
    ,status_name string comment '工单状态名称'
    ,af_screen_result bigint comment '审核结果（保留原字段名）：0-Unreviewed, 1-Approved, 2-Rejected'
    ,result bigint comment '审核结果：0-Unreviewed, 1-Approved, 2-Rejected'
    ,result_name string comment '审核结果名称'
    ,reject_reason string comment '拒绝原因'
    ,assignee string comment '审单 ops 邮箱'
    ,maker_email string comment '审单 ops 邮箱 (重命名映射)'
    ,notes string comment '审单 ops notes'
    ,maker_map_no string comment '审单 ops notes（重命名映射）'
    ,kyc_tag_list string comment 'KYC标签列表'
    ,ic_type bigint comment 'IC类型'
    ,application_id string comment '申请ID'
    ,kyc_level bigint comment 'KYC等级'
    ,user_name_encrypt string comment '用户姓名（加密）'
    ,ticket_info_encrypt string comment '工单信息（加密）'
    ,id_card_no_encrypt string comment '身份证号（加密）'
    ,ticket_start_time_timestamp bigint comment '单的创建时间（原始时间戳）'
    ,maker_submit_time_timestamp bigint comment '单更新（状态变更）时间（原始时间戳）'
    ,ticket_end_time_timestamp bigint comment '单更新（状态变更）时间（原始时间戳）'
    ,skip_time_timestamp bigint comment 'skip 时间（原始时间戳）'
    ,af_screen_start_time string comment '单的创建时间（保留原字段名，转换为业务时区字符串）'
    ,ticket_start_time string comment '单的创建时间（新字段名，转换为业务时区字符串）'
    ,af_screen_update_time string comment '单更新时间（保留原字段名，转换为业务时区字符串）'
    ,ticket_end_time string comment '单更新时间（新字段名，转换为业务时区字符串）'
    ,skip_time string comment 'skip 时间（转换为业务时区字符串）'
    ,af_screen_sla_second bigint comment '总耗时（保留原字段名）：update_time - create_time'
    ,ticket_sla_seconds bigint comment '总耗时：update_time - create_time'
) 
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as orc
tblproperties
(
    "orc.compress" = "zstd"
)
location '${HDFS_PATH}/risk_mart/dwd/dwd_spp_aio_risk_ticket_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dwd_spp_${region}_risk_ticket_df;


create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

insert overwrite ${SCHEMA}.dwd_spp_${region}_risk_ticket_df PARTITION (grass_date = '${bizdate}')
select
      id                                as sys_id
      ,ticket_id                        as ticket_id
      ,ticket_id                        as workflow_flow_no
      ,ticket_info                      as ticket_info
      ,app_id                           as app_id
      ,scene_id                         as scene_id
      ,ticket_category                  as ticket_category
      ,CASE
          WHEN ticket_category = 2 THEN 'KYC Risk'
          WHEN ticket_category = 4 THEN 'Listing'
          WHEN ticket_category = 5 THEN 'Common'
          WHEN ticket_category = 6 THEN 'Transaction'
          WHEN ticket_category = 7 THEN 'Duplicate'
          WHEN ticket_category = 8 THEN 'Upgrade'
          ELSE 'Undefined'
       END                              as ticket_category_name
      ,ticket_subtype                   as ticket_subtype
      ,platform_user_id                 as platform_user_id
      ,shopeepay_user_id                as shopeepay_user_id
      ,case_id                          as case_id
      ,application_source               as application_source
      ,id_card_no                       as id_card_no
      ,user_name                        as user_name
      ,status                           as status
      ,CASE
          WHEN status = 0 THEN 'Unassigned'
          WHEN status = 1 THEN 'MakerReview'
          WHEN status = 2 THEN 'Done'
          WHEN status = 3 THEN 'FieldCompleting'
          WHEN status = 4 THEN 'MakerSkip'
          WHEN status = 5 THEN 'MakerReviewFromSkip'
          ELSE 'Other'
       END                              as status_name
      ,result                           as af_screen_result
      ,result                           as result
      ,CASE
          WHEN result = 0 THEN 'Unreviewed'
          WHEN result = 1 THEN 'Approved'
          WHEN result = 2 THEN 'Rejected'
          ELSE 'Other'
       END                              as result_name
      ,reject_reason                    as reject_reason
      ,assignee                         as assignee
      ,assignee                         as maker_email
      ,notes                            as notes
      ,notes                            as maker_map_no
      ,kyc_tag_list                     as kyc_tag_list
      ,ic_type                          as ic_type
      ,application_id                   as application_id
      ,kyc_level                        as kyc_level
      ,user_name_encrypt                as user_name_encrypt
      ,ticket_info_encrypt              as ticket_info_encrypt
      ,id_card_no_encrypt               as id_card_no_encrypt
      ,create_time                      as ticket_start_time_timestamp
      ,update_time                      as maker_submit_time_timestamp
      ,update_time                      as ticket_end_time_timestamp
      ,skip_time                        as skip_time_timestamp
      ,format_time(create_time, '${grass_region}')   as af_screen_start_time
      ,format_time(create_time, '${grass_region}')   as ticket_start_time
      ,format_time(update_time, '${grass_region}')   as af_screen_update_time
      ,format_time(update_time, '${grass_region}')   as ticket_end_time
      ,format_time(skip_time, '${grass_region}')     as skip_time
      ,update_time - create_time        as af_screen_sla_second
      ,(update_time - create_time)      as ticket_sla_seconds
from risk.ods__shopeepay_risk_control_${region}_db__spp_ticket_tab__df
where ticket_category not in (100)
  and grass_date = '${bizdate}'
;

