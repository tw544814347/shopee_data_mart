-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-09-01
-- Theme Domain:        Activation Ticket
-- Data Granularity:    ticket_id
-- Description:         Activation Ticket Operations Summary Table
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-09-01 - chengguo.liu - 初始化
-- =============================================================================

drop table if exists risk_report.dws_risk_${region}_activation_ticket_df;
create external table risk_report.dws_risk_${region}_activation_ticket_df
(
    ticket_source string comment '工单来源: spp_kyc=SPP KYC工单, credit_kyc=Credit KYC工单'
    ,ticket_id string comment '工单ID，工单唯一标识'
    ,workflow_flow_no string comment '关联的工作流流水号'
    ,app_id string comment '应用ID: kyc/voi/spr/reportcheck等'
    ,scene_id bigint comment '场景ID'
    ,ticket_result int comment '工单结果码: 1=通过, 2=拒绝'
    ,ticket_status bigint comment '工单状态: 2=已完成'
    ,ticket_start_time string comment '工单创建/开始时间'
    ,ticket_update_time string comment '工单更新/结束时间'
    ,ticket_sla_second bigint comment '工单SLA时长(秒)，从创建到结束'
    ,ticket_maker_start_time string comment '审核人开始处理时间'
    ,ticket_maker_end_time string comment '审核人结束处理时间'
    ,ticket_handle_duration_seconds bigint comment '审核人实际处理时长(秒)'
    ,ticket_result_name string comment '工单结果名称: Manual Approve/Manual Reject'
    ,is_spp_ticket int comment '是否为SPP工单: 1=是, 0=否'
    ,is_credit_ticket int comment '是否为Credit工单: 1=是, 0=否'
    ,maker_email string comment '审核人邮箱'
    ,maker_map_no string comment '审核人MAP工号'
)
COMMENT 'Tag:risk report summary table'
partitioned by (grass_date string comment "YYYY-MM-DD 日期分区")
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/dws/dws_risk_reg_activation_ticket_df/grass_region=${grass_region}'
;
msck repair table risk_report.dws_risk_${region}_activation_ticket_df;

create or replace temporary view spp_ticket_info as 
select
    'spp_kyc' as ticket_source,
    workflow_flow_no as ticket_id,
    workflow_flow_no,
    app_id,
    scene_id,
    status as ticket_status,
    ticket_start_time as ticket_start_time,
    ticket_end_time as ticket_update_time,  --待改回别名
    ticket_sla_seconds as ticket_sla_second,  --待改回别名
    result as ticket_result,
    maker_start_time as ticket_maker_start_time,
    case when maker_start_time <> '' then maker_end_time else null end as ticket_maker_end_time,
    maker_email,
    maker_map_no
from risk.dws_spp_reg_risk_ticket_df
where grass_region = '${grass_region}'
    and grass_date = '${grass_date}'
    and status = 2
;

create or replace temporary view credit_ticket_info as 
select
    'credit_kyc' as ticket_source,
    workflow_flow_no as ticket_id,
    workflow_flow_no,
    app_id,
    scene_id,
    status as ticket_status,
    ticket_start_time as ticket_start_time,
    ticket_end_time as ticket_update_time,  --待改回别名
    ticket_sla_seconds as ticket_sla_second,  --待改回别名
    result as ticket_result,
    maker_start_time as ticket_maker_start_time,
    case when maker_start_time <> '' then maker_end_time else null end as ticket_maker_end_time,
    maker_email,
    maker_map_no
from risk.dws_credit_reg_risk_ticket_df
where grass_region = '${grass_region}'
    and grass_date = '${grass_date}'
    --and app_id in ('kyc', 'voi', 'spr', 'reportcheck')
    and status = 2
;

insert overwrite risk_report.dws_risk_${region}_activation_ticket_df PARTITION (grass_date = '${grass_date}')
select
    t.ticket_source,
    t.ticket_id,
    t.workflow_flow_no,
    t.app_id,
    cast(t.scene_id as bigint) as scene_id,
    t.ticket_result,
    t.ticket_status,
    t.ticket_start_time,
    t.ticket_update_time,
    t.ticket_sla_second,
    t.ticket_maker_start_time,
    t.ticket_maker_end_time,
    case 
        when t.ticket_maker_start_time is not null and t.ticket_maker_end_time is not null
        then unix_timestamp(t.ticket_maker_end_time, 'yyyy-MM-dd HH:mm:ss') - 
             unix_timestamp(t.ticket_maker_start_time, 'yyyy-MM-dd HH:mm:ss')
        else 0
     end as ticket_handle_duration_seconds,
    case when t.ticket_result = 1 then 'Manual Approve'
         when t.ticket_result = 2 then 'Manual Reject' end as ticket_result_name,
    case when t.ticket_source = 'spp_kyc' then 1 else 0 end as is_spp_ticket,
    case when t.ticket_source = 'credit_kyc' then 1 else 0 end as is_credit_ticket
    ,t.maker_email
    ,t.maker_map_no
from
(
    select * from spp_ticket_info
    union all
    select * from credit_ticket_info
) t
;
