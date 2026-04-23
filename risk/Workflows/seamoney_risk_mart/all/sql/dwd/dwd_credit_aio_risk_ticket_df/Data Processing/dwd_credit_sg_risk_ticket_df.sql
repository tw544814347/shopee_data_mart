-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2023-05-17
-- Theme Domain:        
-- Data Granularity:    ticket_id
-- Description:         
-- Documents:           
-- =============================================================================
--  Version History:
--  2023-05-17 - 初始化
--  2025-03-31 - wei.tao - https://jira.shopee.io/browse/SPFDT-50409
--  2025-11-24 - chengguo.liu - 新增业务冗余字段和映射, https://jira.shopee.io/browse/SPFDT-57710
--                              SG工单表无数据，空表
-- =============================================================================


--drop table if exists ${SCHEMA}.dwd_credit_${region}_risk_ticket_df;
create table if not exists ${SCHEMA}.dwd_credit_${region}_risk_ticket_df
(
    sys_id string comment '主键：sys db id'
    ,ticket_id string comment '主键：ticket_id'
    ,workflow_flow_no string comment '工单id，flow no (映射为工作流流水号)'
    ,ticket_info string comment '工单详情信息'
    ,app_id string comment '应用ID'
    ,scene_id string comment '场景ID'
    ,product_code string comment '产品类型'
    ,ticket_category int comment '工单类型：0-Undefined, 1-Liveness Check, 2-KYC Risk, 3-IVR, 4-Listing, 5-Common, 6-Transaction, 7-Duplicate, 8-Upgrade, 100-invokepolicy not real ticket'
    ,ticket_category_name string comment '工单类型名称'
    ,ticket_subtype int comment '同category工单下，分子类型'
    ,platform_user_id string comment '平台用户ID'
    ,credit_user_id string comment '信贷用户ID'
    ,credit_corp_id string comment '信贷企业ID'
    ,id_card_no string comment '身份证号'
    ,user_name string comment '用户姓名'
    ,status int comment '工单状态：0-Unassigned, 1-MakerReview, 2-Done, 3-FieldCompleting, 4-MakerSkip, 5-MakerReviewFromSkip'
    ,status_name string comment '工单状态名称'
    ,af_screen_result int comment '审核结果（保留原字段名）：0-Unreviewed, 1-Approved, 2-Rejected'
    ,result int comment '审核结果：0-Unreviewed, 1-Approved, 2-Rejected'
    ,result_name string comment '审核结果名称'
    ,reject_reason string comment '拒绝原因'
    ,return_codes string comment '返回码'
    ,code_return_nums bigint comment '代码返回数'
    ,assignee string comment '审单 ops 邮箱'
    ,maker_email string comment '审单 ops 邮箱 (重命名映射)'
    ,maker_map_no string comment '审单 ops notes（ID地区有值）'
    ,skip_operator string comment 'skip 操作人'
    ,skip_operator_notes string comment 'skip 操作人notes（ID地区有值）'
    ,skip_reason string comment 'skip 原因'
    ,adapter_id bigint comment '工单模版id'
    ,priority bigint comment '优先级'
    ,ops string comment '已废弃'
    ,order_field string comment '排序字段'
    ,remark string comment 'ops 的备注'
    ,ticket_start_time_timestamp bigint comment '单的创建时间（原始时间戳）'
    ,maker_start_time_timestamp bigint comment '派单给 ops 的时间（原始时间戳）'
    ,maker_submit_time_timestamp bigint comment '单更新（状态变更）时间（原始时间戳）'
    ,ticket_end_time_timestamp bigint comment '单更新（状态变更）时间（原始时间戳）'
    ,skip_time_timestamp bigint comment 'skip 时间（原始时间戳）'
    ,af_screen_start_time string comment '单的创建时间（保留原字段名，转换为业务时区字符串）'
    ,ticket_start_time string comment '单的创建时间（新字段名，转换为业务时区字符串）'
    ,af_screen_update_time string comment '单更新时间（保留原字段名，转换为业务时区字符串）'
    ,ticket_end_time string comment '单更新时间（新字段名，转换为业务时区字符串）'
    ,maker_start_time string comment '派单给 ops 的时间（转换为业务时区字符串）'
    ,skip_time string comment 'skip 时间（转换为业务时区字符串）'
    ,af_screen_sla_second bigint comment '总耗时（保留原字段名）：update_time - create_time'
    ,ticket_sla_seconds bigint comment '总耗时：update_time - create_time'
    ,maker_sla_seconds bigint comment '派单给 ops 的耗时：update_time - assign_time'
) 
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as parquet
tblproperties ("parquet.compress" = "zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_af_risk_screen_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dwd_credit_${region}_risk_ticket_df;
