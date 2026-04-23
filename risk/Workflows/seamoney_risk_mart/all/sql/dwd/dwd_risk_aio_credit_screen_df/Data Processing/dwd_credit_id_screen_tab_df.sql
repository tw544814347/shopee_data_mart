-- =========================================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-11-25
-- Theme Domain:        
-- Data Granularity:    screen_id
-- Description:         UC 工单明细表，记录工单审核流程和结果（ID地区特殊版本，合并 id_ldn 和 id_cf 两张表）
-- Documents:           
-- =========================================================================================
--  Version History:
--  2025-11-25 - chengguo.liu - 初始化，ID地区从2张表merge，jira: https://jira.shopee.io/browse/SPFDT-57710
-- =========================================================================================


--drop table if exists ${SCHEMA}.dwd_credit_id_screen_tab_df;
create table if not exists ${SCHEMA}.dwd_credit_id_screen_tab_df
(
    screen_id string comment '主键：工单ID'
    ,workflow_flow_no string comment '工单ID（映射为工作流流水号）'
    ,req_no string comment '请求编号'
    ,product_code string comment '产品类型'
    ,screen_type string comment '工单类型；枚举：RiskAuto(自动审核的单)|Pre|Post'
    ,screen_type_name string comment '工单类型名称'
    ,screen_source string comment '工单来源'
    ,apply_type string comment '申请类型；枚举：uc_migrate|uc|risk'
    ,category int comment '工单类型（该表仅UC KYC工单固定为9）'
    ,category_name string comment '工单类型名称'
    ,app_id string comment '应用ID'
    ,scene_id string comment '场景ID'
    ,platform_user_id string comment '平台用户ID'
    ,platform_type string comment '平台类型'
    ,credit_user_id string comment '信贷用户ID'
    ,credit_corp_id string comment '信贷企业ID'
    ,user_name string comment '用户姓名'
    ,id_card_no string comment '身份证号'
    ,id_card_type int comment "身份证类型"
    ,id_card_type_name string comment '身份证类型名称'
    ,screen_status int comment '工单状态；枚举：WaitingData=1、WaitingMaker=2、MakerReview=3、WaitingChecker=4、CheckerReview=5、Done=6、Revoked=7、MakerSkip=21、MakerReviewFromSkip=22、CheckerSkip=41、CheckerReviewFromSkip=42'
    ,screen_status_name string comment '工单状态名称'
    ,task_result int comment '任务处理结果；枚举：NotNeedTask=1、WaitTaskExec=2、TaskPass=3、TaskReject=4、OverRetryTime=5'
    ,task_result_name string comment '任务处理结果名称'
    ,screen_result int comment '工单审核结果；枚举：Unreviewed=0、Approved=1、Rejected=2'
    ,screen_result_name string comment '工单审核结果名称'
    ,reject_code string comment '拒绝码'
    ,maker_result int comment 'Maker审核结果；枚举：Unreviewed=0、Approved=1、Rejected=2'
    ,maker_result_name string comment 'Maker审核结果名称'
    ,maker_email string comment 'Maker邮箱'
    ,maker_map_no string comment 'Maker备注'
    ,checker_result int comment 'Checker审核结果；枚举：Unreviewed=0、Approved=1、Rejected=2'
    ,checker_result_name string comment 'Checker审核结果名称'
    ,checker_email string comment 'Checker邮箱'
    ,checker_map_no string comment 'Checker备注'
    ,is_skip int comment '是否跳过审核；枚举：UnSkipped=1、Skipped=2'
    ,is_skip_name string comment '是否跳过审核名称'
    ,maker_checker_attr int comment '工单审核流程类型；枚举：Normal=1（仅需Maker）、Maker-Checker=2（需Maker+Checker）、Checker=3（仅需Checker）'
    ,maker_checker_attr_name string comment '工单审核流程类型名称'
    ,skip_reason string comment '跳过原因'
    ,skip_operator string comment '跳过操作人'
    ,skip_operator_map_no string comment '跳过操作人备注'
    ,screen_info string comment '工单详情信息'
    ,screen_tpl_uuid string comment '工单模板UUID'
    ,shop_id string comment '店铺ID'
    ,assignee string comment '审核负责人'
    ,notes string comment '通用备注信息'
    ,risk_result_type int comment '前一个Risk节点处理结果；枚举：Pass=1、Reject=2'
    ,risk_result_type_name string comment '前一个Risk节点处理结果名称'
    ,from_source string comment '关联分配工单的来源'
    ,order_field string comment '排序字段'
    ,archive_batch_no string comment '归档批次号'
    ,create_time_timestamp bigint comment '记录创建时间（原始时间戳）'
    ,maker_start_time_timestamp bigint comment 'Maker开始审核的时间（原始时间戳）'
    ,maker_submit_time_timestamp bigint comment 'Maker提交结果的时间（原始时间戳）'
    ,checker_start_time_timestamp bigint comment 'Checker开始审核的时间（原始时间戳）'
    ,checker_submit_time_timestamp bigint comment 'Checker提交结果的时间（原始时间戳）'
    ,update_time_timestamp bigint comment '记录更新时间（原始时间戳）'
    ,first_order_time_timestamp bigint comment '首次订单时间（原始时间戳）'
    ,skip_time_timestamp bigint comment '跳过时间（原始时间戳）'
    ,screen_start_time string comment '记录创建时间（转换为业务时区字符串）'
    ,maker_start_time string comment 'Maker开始审核的时间（转换为业务时区字符串）'
    ,maker_submit_time string comment 'Maker提交结果的时间（转换为业务时区字符串）'
    ,checker_start_time string comment 'Checker开始审核的时间（转换为业务时区字符串）'
    ,checker_submit_time string comment 'Checker提交结果的时间（转换为业务时区字符串）'
    ,update_time string comment '记录更新时间（转换为业务时区字符串）'
    ,first_order_time string comment '首次订单时间（转换为业务时区字符串）'
    ,skip_time string comment '跳过时间（转换为业务时区字符串）'
    ,ops_type int comment '操作类型；0=system(RiskAuto), 1=maker, 2=maker+checker, 3=checker'
    ,ops_cnt int comment '操作人数；0=system, 1=单人, 2=双人'
    ,screen_sla_seconds bigint comment '工单总耗时（秒）：最后提交时间 - 创建时间'
    ,ops_sla_seconds bigint comment 'Ops审核耗时（秒）：Maker和Checker审核时长之和'
    ,screen_pending_sla_seconds bigint comment '工单等待耗时（秒）：总耗时 - Ops审核耗时'
) 
partitioned by
(
    grass_date string comment 'grass_date, partition key'
)
stored as parquet
tblproperties ("parquet.compress" = "zstd")
location '${HDFS_PATH}/risk_mart/dwd/dwd_credit_id_screen_tab_df/grass_region=${grass_region}';
--msck repair table ${SCHEMA}.dwd_credit_id_screen_tab_df;


create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

insert overwrite ${SCHEMA}.dwd_credit_id_screen_tab_df PARTITION (grass_date = '${grass_date}')
select
      screen_id                                                         as screen_id
      ,screen_id                                                        as workflow_flow_no
      ,req_no                                                           as req_no
      ,product_code                                                     as product_code
      ,screen_type                                                      as screen_type
      ,CASE
          WHEN screen_type = 'RiskAuto' THEN '自动审核的单'
          WHEN screen_type = 'Pre'      THEN 'Pre'
          WHEN screen_type = 'Post'     THEN 'Post'
          ELSE 'Other'
       END                                                              as screen_type_name
      ,screen_source                                                    as screen_source
      ,apply_type                                                       as apply_type
      ,category                                                         as category
      ,CASE
          WHEN category = 9 THEN 'UC KYC'
          ELSE 'Other'
       END                                                              as category_name
      ,app_id                                                           as app_id
      ,scene_id                                                         as scene_id
      ,platform_user_id                                                 as platform_user_id
      ,platform_type                                                    as platform_type
      ,credit_user_id                                                   as credit_user_id
      ,credit_corp_id                                                   as credit_corp_id
      ,user_name                                                        as user_name
      ,id_card_no                                                       as id_card_no
      ,id_card_type                                                     as id_card_type
      ,CASE
          WHEN id_card_type = 0  THEN 'Unknown'
          WHEN id_card_type = 1  THEN 'ID Card'
          WHEN id_card_type = 2  THEN 'Passport'
          WHEN id_card_type = 3  THEN 'Driver''s License'
          WHEN id_card_type = 4  THEN 'UMID'
          WHEN id_card_type = 5  THEN 'SSS Card'
          WHEN id_card_type = 6  THEN 'PRC ID'
          WHEN id_card_type = 7  THEN 'Headlth ID'
          WHEN id_card_type = 8  THEN 'Postal ID'
          WHEN id_card_type = 15 THEN 'TIN ID'
          WHEN id_card_type = 16 THEN 'ACR'
          WHEN id_card_type = 17 THEN 'PhilID'
          WHEN id_card_type = 21 THEN 'ePhilID'
          WHEN id_card_type = 24 THEN 'GSIS ID'
          ELSE 'Other'
       END                                                              as id_card_type_name
      ,screen_status                                                    as screen_status
      ,CASE
          WHEN screen_status = 1  THEN 'WaitingData'
          WHEN screen_status = 2  THEN 'WaitingMaker'
          WHEN screen_status = 3  THEN 'MakerReview'
          WHEN screen_status = 4  THEN 'WaitingChecker'
          WHEN screen_status = 5  THEN 'CheckerReview'
          WHEN screen_status = 6  THEN 'Done'
          WHEN screen_status = 7  THEN 'Revoked'
          WHEN screen_status = 21 THEN 'MakerSkip'
          WHEN screen_status = 22 THEN 'MakerReviewFromSkip'
          WHEN screen_status = 41 THEN 'CheckerSkip'
          WHEN screen_status = 42 THEN 'CheckerReviewFromSkip'
          ELSE 'Other'
       END                                                              as screen_status_name
      ,task_result                                                      as task_result
      ,CASE
          WHEN task_result = 1 THEN 'NotNeedTask'
          WHEN task_result = 2 THEN 'WaitTaskExec'
          WHEN task_result = 3 THEN 'TaskPass'
          WHEN task_result = 4 THEN 'TaskReject'
          WHEN task_result = 5 THEN 'OverRetryTime'
          ELSE 'Other'
       END                                                              as task_result_name
      ,screen_result                                                    as screen_result
      ,CASE
          WHEN screen_result = 0 THEN 'Unreviewed'
          WHEN screen_result = 1 THEN 'Approved'
          WHEN screen_result = 2 THEN 'Rejected'
          ELSE 'Other'
       END                                                              as screen_result_name
      ,reject_code                                                      as reject_code
      ,maker_result                                                     as maker_result
      ,CASE
          WHEN maker_result = 0 THEN 'Unreviewed'
          WHEN maker_result = 1 THEN 'Approved'
          WHEN maker_result = 2 THEN 'Rejected'
          ELSE 'Other'
       END                                                              as maker_result_name
      ,maker                                                            as maker_email
      ,maker_map_no                                                     as maker_map_no
      ,checker_result                                                   as checker_result
      ,CASE
          WHEN checker_result = 0 THEN 'Unreviewed'
          WHEN checker_result = 1 THEN 'Approved'
          WHEN checker_result = 2 THEN 'Rejected'
          ELSE 'Other'
       END                                                              as checker_result_name
      ,checker                                                          as checker_email
      ,checker_map_no                                                   as checker_map_no
      ,is_skip                                                          as is_skip
      ,CASE
          WHEN is_skip = 1 THEN 'UnSkipped'
          WHEN is_skip = 2 THEN 'Skipped'
          ELSE 'Other'
       END                                                              as is_skip_name
      ,maker_checker_attr                                               as maker_checker_attr
      ,CASE
          WHEN maker_checker_attr = 1 THEN 'Normal'
          WHEN maker_checker_attr = 2 THEN 'Maker-Checker'
          WHEN maker_checker_attr = 3 THEN 'Checker'
          ELSE 'Other'
       END                                                              as maker_checker_attr_name
      ,skip_reason                                                      as skip_reason
      ,skip_operator                                                    as skip_operator
      ,skip_operator_map_no                                             as skip_operator_map_no
      ,screen_info                                                      as screen_info
      ,screen_tpl_uuid                                                  as screen_tpl_uuid
      ,shop_id                                                          as shop_id
      ,assignee                                                         as assignee
      ,notes                                                            as notes
      ,risk_result_type                                                 as risk_result_type
      ,CASE
          WHEN risk_result_type = 1 THEN 'Pass'
          WHEN risk_result_type = 2 THEN 'Reject'
          ELSE 'Other'
       END                                                              as risk_result_type_name
      ,from_source                                                      as from_source
      ,order_field                                                      as order_field
      ,archive_batch_no                                                 as archive_batch_no
      ,create_time                                                      as create_time_timestamp
      ,maker_start_time                                                 as maker_start_time_timestamp
      ,maker_submit_time                                                as maker_submit_time_timestamp
      ,checker_start_time                                               as checker_start_time_timestamp
      ,checker_submit_time                                              as checker_submit_time_timestamp
      ,update_time                                                      as update_time_timestamp
      ,first_order_time                                                 as first_order_time_timestamp
      ,skip_time                                                        as skip_time_timestamp
      ,format_time(create_time, '${grass_region}')                      as screen_start_time
      ,format_time(maker_start_time, '${grass_region}')                 as maker_start_time
      ,format_time(maker_submit_time, '${grass_region}')                as maker_submit_time
      ,format_time(checker_start_time, '${grass_region}')               as checker_start_time
      ,format_time(checker_submit_time, '${grass_region}')              as checker_submit_time
      ,format_time(update_time, '${grass_region}')                      as update_time
      ,format_time(first_order_time, '${grass_region}')                 as first_order_time
      ,format_time(skip_time, '${grass_region}')                        as skip_time
      ,CASE
          WHEN screen_type = 'RiskAuto' THEN 0
          ELSE maker_checker_attr
       END                                                              as ops_type
      ,CASE
          WHEN screen_type = 'RiskAuto'        THEN 0
          WHEN maker_checker_attr IN (1, 3)    THEN 1
          WHEN maker_checker_attr = 2          THEN 2
          ELSE -1
       END                                                              as ops_cnt
      ,CASE
          WHEN screen_type = 'RiskAuto' THEN 0
          ELSE GREATEST(maker_submit_time, checker_submit_time) - create_time
       END                                                              as screen_sla_seconds
      ,CASE
          WHEN screen_type = 'RiskAuto'    THEN 0
          WHEN maker_checker_attr = 1      THEN GREATEST((maker_submit_time - maker_start_time), 0)
          WHEN maker_checker_attr = 3      THEN GREATEST((checker_submit_time - checker_start_time), 0)
          WHEN maker_checker_attr = 2      THEN GREATEST((maker_submit_time - maker_start_time), 0)
                                              + GREATEST((checker_submit_time - checker_start_time), 0)
          ELSE 0
       END                                                              as ops_sla_seconds
      ,CASE
          WHEN screen_type = 'RiskAuto' THEN 0
          ELSE GREATEST(maker_submit_time, checker_submit_time) - create_time
       END
       - CASE
          WHEN screen_type = 'RiskAuto'    THEN 0
          WHEN maker_checker_attr = 1      THEN GREATEST((maker_submit_time - maker_start_time), 0)
          WHEN maker_checker_attr = 3      THEN GREATEST((checker_submit_time - checker_start_time), 0)
          WHEN maker_checker_attr = 2      THEN GREATEST((maker_submit_time - maker_start_time), 0)
                                              + GREATEST((checker_submit_time - checker_start_time), 0)
          ELSE 0
       END                                                              as screen_pending_sla_seconds
from 
(
    select * from risk.ods__credit_risk_control_id_ldn_db__screen_tab__df
    where grass_date = '${grass_date}'
    union all
    select * from risk.ods__credit_risk_control_id_cf_db__screen_tab__df
    where grass_date = '${grass_date}'
) t
;



