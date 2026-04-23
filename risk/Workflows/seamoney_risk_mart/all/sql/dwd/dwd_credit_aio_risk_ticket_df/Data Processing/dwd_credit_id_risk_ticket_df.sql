--********************************************************************--
-- Author:              zongyi.lu@shopee.com
-- Created Time:        2024-01-23
-- Theme Domain：       ticket_id相关的数据
-- Description:         ticket_id相关的数据,ID由于有LDN/CF拆分,现在需要直接读取ldn&cf ods表
-- Data Granularity:    ticket_id 
-- 变更历史：
--  2024-01-23 zongyi.lu ID由于有LDN/CF拆分,现在需要直接读取ldn&cf ods表
--  2025-03-31 wei.tao https://jira.shopee.io/browse/SPFDT-50409
--  2025-11-24 chengguo.liu 新增业务冗余字段和映射，与通用地区脚本保持一致, https://jira.shopee.io/browse/SPFDT-57710
--********************************************************************--


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


create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

create or replace temporary view tmp_id_ticket_tab_merge as
select 
 id                                                                                                   as id
,ticket_id                                                                                            as ticket_id
,ticket_category                                                                                      as ticket_category
,ticket_subtype                                                                                       as ticket_subtype
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,ops                                                                                                  as ops
,assignee                                                                                             as assignee
,status                                                                                               as status
,result                                                                                               as result
,reject_reason                                                                                        as reject_reason
,ticket_info                                                                                          as ticket_info
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,credit_user_id                                                                                       as credit_user_id
,id_card_no                                                                                           as id_card_no
,user_name                                                                                            as user_name
,return_codes                                                                                         as return_codes
,adapter_id                                                                                           as adapter_id
,code_return_nums                                                                                     as code_return_nums
,product_code                                                                                         as product_code
,credit_corp_id                                                                                       as credit_corp_id
,notes                                                                                                as notes
,priority                                                                                             as priority
,assign_time                                                                                          as assign_time
,order_field                                                                                          as order_field
,skip_operator_notes                                                                                  as skip_operator_notes
,skip_time                                                                                            as skip_time
,skip_reason                                                                                          as skip_reason
,skip_operator                                                                                        as skip_operator
,remark                                                                                               as remark
,_event
 from(
    select 
 id                                                                                                   as id
,ticket_id                                                                                            as ticket_id
,ticket_category                                                                                      as ticket_category
,ticket_subtype                                                                                       as ticket_subtype
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,ops                                                                                                  as ops
,assignee                                                                                             as assignee
,status                                                                                               as status
,result                                                                                               as result
,reject_reason                                                                                        as reject_reason
,ticket_info                                                                                          as ticket_info
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,credit_user_id                                                                                       as credit_user_id
,id_card_no                                                                                           as id_card_no
,user_name                                                                                            as user_name
,return_codes                                                                                         as return_codes
,adapter_id                                                                                           as adapter_id
,code_return_nums                                                                                     as code_return_nums
,product_code                                                                                         as product_code
,credit_corp_id                                                                                       as credit_corp_id
,notes                                                                                                as notes
,priority                                                                                             as priority
,assign_time                                                                                          as assign_time
,order_field                                                                                          as order_field
,skip_operator_notes                                                                                  as skip_operator_notes
,skip_time                                                                                            as skip_time
,skip_reason                                                                                          as skip_reason
,skip_operator                                                                                        as skip_operator
,remark                                                                                               as remark
 ,_event
,row_number() over(partition by ticket_id order by update_time desc) as rn
    from (
        select 
 id                                                                                                   as id
,ticket_id                                                                                            as ticket_id
,ticket_category                                                                                      as ticket_category
,ticket_subtype                                                                                       as ticket_subtype
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,ops                                                                                                  as ops
,assignee                                                                                             as assignee
,status                                                                                               as status
,result                                                                                               as result
,reject_reason                                                                                        as reject_reason
,ticket_info                                                                                          as ticket_info
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,credit_user_id                                                                                       as credit_user_id
,id_card_no                                                                                           as id_card_no
,user_name                                                                                            as user_name
,return_codes                                                                                         as return_codes
,adapter_id                                                                                           as adapter_id
,code_return_nums                                                                                     as code_return_nums
,product_code                                                                                         as product_code
,credit_corp_id                                                                                       as credit_corp_id
,notes                                                                                                as notes
,priority                                                                                             as priority
,assign_time                                                                                          as assign_time
,order_field                                                                                          as order_field
,skip_operator_notes                                                                                  as skip_operator_notes
,skip_time                                                                                            as skip_time
,skip_reason                                                                                          as skip_reason
,skip_operator                                                                                        as skip_operator
,remark                                                                                               as remark
 ,concat(nvl(ticket_id,''))                                                                            as on_keys_conds

,_event
        from risk.ods__credit_risk_control_id_cf_db__ticket_tab__df__private fs
        where grass_date = '${grass_date}'


        union all
        select 
 id                                                                                                   as id
,ticket_id                                                                                            as ticket_id
,ticket_category                                                                                      as ticket_category
,ticket_subtype                                                                                       as ticket_subtype
,app_id                                                                                               as app_id
,scene_id                                                                                             as scene_id
,platform_user_id                                                                                     as platform_user_id
,ops                                                                                                  as ops
,assignee                                                                                             as assignee
,status                                                                                               as status
,result                                                                                               as result
,reject_reason                                                                                        as reject_reason
,ticket_info                                                                                          as ticket_info
,version                                                                                              as version
,create_time                                                                                          as create_time
,update_time                                                                                          as update_time
,credit_user_id                                                                                       as credit_user_id
,id_card_no                                                                                           as id_card_no
,user_name                                                                                            as user_name
,return_codes                                                                                         as return_codes
,adapter_id                                                                                           as adapter_id
,code_return_nums                                                                                     as code_return_nums
,product_code                                                                                         as product_code
,credit_corp_id                                                                                       as credit_corp_id
,notes                                                                                                as notes
,priority                                                                                             as priority
,assign_time                                                                                          as assign_time
,order_field                                                                                          as order_field
,skip_operator_notes                                                                                  as skip_operator_notes
,skip_time                                                                                            as skip_time
,skip_reason                                                                                          as skip_reason
,skip_operator                                                                                        as skip_operator
,remark                                                                                               as remark
 ,concat(nvl(ticket_id,''))                                                                            as on_keys_conds

,_event
        from risk.ods__credit_risk_control_id_ldn_db__ticket_tab__df__private fs
        where grass_date = '${grass_date}'
        
    ) a
   ) where  rn = 1 and 1=1
;

insert overwrite ${SCHEMA}.dwd_credit_id_risk_ticket_df PARTITION (grass_date = '${bizdate}')
select
      id                                as sys_id
      ,ticket_id                        as ticket_id
      ,ticket_id                        as workflow_flow_no
      ,ticket_info                      as ticket_info
      ,app_id                           as app_id
      ,scene_id                         as scene_id
      ,product_code                     as product_code
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
      ,credit_user_id                   as credit_user_id
      ,credit_corp_id                   as credit_corp_id
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
      ,return_codes                     as return_codes
      ,code_return_nums                 as code_return_nums
      ,assignee                         as assignee
      ,assignee                         as maker_email
      ,notes                            as maker_map_no
      ,skip_operator                    as skip_operator
      ,skip_operator_notes              as skip_operator_notes
      ,skip_reason                      as skip_reason
      ,adapter_id                       as adapter_id
      ,priority                         as priority
      ,ops                              as ops
      ,order_field                      as order_field
      ,remark                           as remark
      ,create_time                      as ticket_start_time_timestamp
      ,assign_time                      as maker_start_time_timestamp
      ,update_time                      as maker_submit_time_timestamp
      ,update_time                      as ticket_end_time_timestamp
      ,skip_time                        as skip_time_timestamp
      ,format_time(create_time, 'ID')   as af_screen_start_time
      ,format_time(create_time, 'ID')   as ticket_start_time
      ,format_time(update_time, 'ID')   as af_screen_update_time
      ,format_time(update_time, 'ID')   as ticket_end_time
      ,format_time(assign_time, 'ID')   as maker_start_time
      ,format_time(skip_time, 'ID')     as skip_time
      ,update_time - create_time        as af_screen_sla_second
      ,(update_time - create_time)      as ticket_sla_seconds
      ,(update_time - assign_time)      as maker_sla_seconds
from tmp_id_ticket_tab_merge
where ticket_category not in (100)
  and status <> 4
;
