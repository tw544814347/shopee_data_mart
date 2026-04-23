-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-09-01
-- Theme Domain:        Activation AF Workflow
-- Data Granularity:    af_source + app_id + apply_no + flow_trace_id
-- Description:         Activation AF Workflow Summary Table
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-09-01 - chengguo.liu - 初始化
-- =============================================================================


drop table if exists risk_report.dws_risk_${region}_activation_af_workflow_df;
create external table if not exists risk_report.dws_risk_${region}_activation_af_workflow_df
(
    af_source string comment 'AF来源: credit_af=信贷AF, spp_af=SPP AF'
    ,product_id bigint comment '产品ID: 3=SPL, 7=SPLX, 12=2W, 16=2W_MY, 1=BCL'
    ,activation_risk_scene_tag string comment '激活风控场景标签: credit_kyc/credit_af/credit_report_check/credit_spr/credit_af_2nd'
    ,activation_risk_scene_tag_splx string comment 'SPLX专用场景标签: credit_af/credit_af_spl'
    ,activation_risk_scene_tag_combined_limit string comment '合并额度场景标签: credit_kyc/credit_af/credit_af_spl/credit_af_bcl等'
    ,platform_user_id string comment '平台用户ID'
    ,apply_no string comment '申请编号'
    ,risk_af_workflow_flow_no string comment 'AF工作流流水号'
    ,risk_af_app_id string comment 'AF应用ID: kredit/chp/motorloan/spj/splx/shopeepay'
    ,risk_af_scene_id bigint comment 'AF场景ID: 10001=激活, 11001=用户分群, 70048=SPP激活'
    ,risk_af_workflow_run_step string comment '工作流当前运行步骤'
    ,risk_af_workflow_create_time string comment '工作流创建时间'
    ,risk_af_workflow_update_time string comment '工作流最后更新时间'
    ,flow_trace_id string comment 'flow_trace_id，用于关联SPP KYC流程'
    ,risk_af_cnt_uw_pending bigint comment 'UW pending次数'
    ,risk_af_pending_duration bigint comment 'UW pending总时长(秒)'
    ,risk_af_pending_sla_second bigint comment 'UW pending SLA时长(秒)'
    ,risk_af_uw_user_segment_name string comment 'UW用户分群名称: SPLX in store activation/SA QR Scan SPL Activation等'
    ,is_uw_processed int comment '是否经过UW处理: 1=是, 0=否'
    ,risk_af_ticket_start_time string comment '关联工单开始时间'
    ,risk_af_ticket_end_time string comment '关联工单结束时间'
    ,risk_af_ticket_sla_second bigint comment '关联工单SLA时长(秒)'
    ,risk_af_ticket_result string comment '关联工单结果'
    ,risk_af_ticket_maker_start_time string comment '工单审核人开始处理时间'
    ,risk_af_ticket_maker_end_time string comment '工单审核人结束处理时间'
    ,is_finish_risk_af_ticket int comment '是否已完成工单审核: 1=是, 0=否'
    ,risk_af_ticket_maker_email string comment '工单审核人邮箱'
    ,risk_af_ticket_maker_map_no string comment '工单审核人MAP工号'
)
COMMENT 'Tag:risk report summary table'
partitioned by (grass_date string comment "YYYY-MM-DD 日期分区")
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/dws/dws_risk_reg_activation_af_workflow_df/grass_region=${grass_region}'
;
msck repair table risk_report.dws_risk_${region}_activation_af_workflow_df;


create or replace temporary view credit_af_workflow as
select
    t1.app_id
    ,t1.scene_id
    ,t1.activation_risk_scene_tag
    ,t1.activation_risk_scene_tag_splx
    ,t1.activation_risk_scene_tag_combined_limit
    ,t2.af_source
    ,t2.product_id
    ,t2.platform_user_id
    ,t2.apply_no
    ,t2.flow_no
    ,t2.run_step
    ,t2.workflow_create_time
    ,t2.workflow_update_time
    ,t2.flow_trace_id
from
(
    select
        app_id
        ,scene_id
        ,activation_risk_scene_tag
        ,activation_risk_scene_tag_splx
        ,activation_risk_scene_tag_combined_limit
    from risk.dim_risk_reg_workflow_with_app_type_df
    where
        grass_region = '${grass_region}'
        and grass_date = '${grass_date}'
        and is_for_activation = 1
) t1
left join
(
    select
        'credit_af' as af_source
        ,product_id
        ,platform_user_id
        ,apply_no
        ,flow_no
        ,app_id
        ,scene_id
        ,run_step
        ,workflow_create_time
        ,workflow_update_time
        ,null as flow_trace_id
    from credit_app.ads_credit_reg_uc_activation_order_risk_workflow_di
    where
        grass_region = '${grass_region}'
        and grass_date >= date_sub ('${current_grass_date}', 190)
        and app_id not in ('kyc', 'voi')
    union all
    --kyc/voi 老户重新激活apply_no不变，可能有重复数据
    select
        'credit_af' as af_source
        ,product_id
        ,platform_user_id
        ,apply_no
        ,flow_no
        ,app_id
        ,scene_id
        ,run_step
        ,workflow_create_time
        ,workflow_update_time
        ,null as flow_trace_id
    from
        (
            select
                product_id
                ,platform_user_id
                ,apply_no
                ,flow_no
                ,app_id
                ,scene_id
                ,run_step
                ,workflow_create_time
                ,workflow_update_time
                ,row_number() over (partition by apply_no order by workflow_update_time desc) as rn
            from credit_app.ads_credit_reg_uc_activation_order_risk_workflow_di
            where
                grass_region = '${grass_region}'
                and grass_date >= date_sub ('${current_grass_date}', 190)
                and app_id in ('kyc', 'voi')
        )
    where rn = 1
) t2
on t1.app_id = t2.app_id
and t1.scene_id = t2.scene_id
;

create or replace temporary view spp_af_workflow as 
select
    'spp_af' as af_source,
    platform_user_id,
    REGEXP_EXTRACT(req_no, '([0-9]+)') as apply_no,
    flow_no as workflow_flow_no,
    'shopeepay' as app_id,
    70048 as scene_id,
    run_step,
    create_time,
    update_time,
    get_json_object(
        cast(unbase64(get_json_object(input, '$.Params')) as string),
        '$.flow_trace_id'
    ) as flow_trace_id
from risk.dwd_risk_${shopeepay_workflow_region}_af_shopeepay_workflow_di
where
  1 = ${has_shopeepay_workflow_region}
  and grass_date >= date_sub('${current_grass_date}', 190)
  and date(create_time) >= current_date - interval '190' day
  and scene_id = 70048
  and trim(get_json_object(
        cast(unbase64(get_json_object(input, '$.Params')) as string),
        '$.flow_trace_id'
    )) <> ''
;

create or replace temporary view unified_af_workflow as
select
    af_source,
    product_id,
    activation_risk_scene_tag,
    activation_risk_scene_tag_splx,
    activation_risk_scene_tag_combined_limit,
    platform_user_id,
    apply_no,
    flow_no as workflow_flow_no,
    app_id,
    scene_id,
    run_step,
    workflow_create_time as create_time,
    workflow_update_time as update_time,
    flow_trace_id
from credit_af_workflow
union all
select
    af_source
    ,null as product_id
    ,null as activation_risk_scene_tag
    ,null as activation_risk_scene_tag_splx
    ,null as activation_risk_scene_tag_combined_limit
    ,platform_user_id
    ,apply_no
    ,workflow_flow_no
    ,app_id
    ,scene_id
    ,run_step
    ,create_time
    ,update_time
    ,flow_trace_id
from
    (
        select
            *
            ,row_number() over (
                partition by flow_trace_id
                order by create_time desc
            ) as rank_id
        from spp_af_workflow
    ) ranked_spp
where rank_id = 1
;

create or replace temporary view uw_pending_summary as 
select
    flow_no as workflow_flow_no,
    count(1) as cnt_uw_pending,
    sum(
        unix_timestamp(pending_finish_time, 'yyyy-MM-dd HH:mm:ss') - 
        unix_timestamp(pending_start_time, 'yyyy-MM-dd HH:mm:ss')
    ) as pending_duration,
    sum(
        unix_timestamp(pending_finish_time, 'yyyy-MM-dd HH:mm:ss') - 
        unix_timestamp(pending_start_time, 'yyyy-MM-dd HH:mm:ss')
    ) as pending_sla_second
from risk.dwd_risk_${invoke_policy_region}_underwriting_invoke_policy_result_history_df
where
    1 = ${has_invoke_policy_region}
    and grass_date = '${grass_date}'
    and scene_id in (10001, 11001)
group by flow_no
;

create or replace temporary view uw_user_segment as 
select
    request_id as workflow_flow_no,
    max(get_json_object(rsp, '$.DAJSONDocument.MAPPING_OUTPUT.UserSegmentName.value')) as user_segment_name
from risk.dwd_risk_${region}_uw_spl_process_di
where
    grass_date >= date_sub('${current_grass_date}', 190)
    and policy_scene_id in ('10001', '11001')
    and coalesce(
        get_json_object(rsp, '$.DAJSONDocument.OUTPUT.underwriting_decisions.value'),
        get_json_object(rsp, '$.DAJSONDocument.OUTPUT.underwriting_decisions_temp.value')
    ) in ('Approve', 'Reject')
    and alias like 'IAOA%'
    and policy_status <> 3
group by request_id
;


insert overwrite risk_report.dws_risk_${region}_activation_af_workflow_df PARTITION (grass_date = '${grass_date}')
select
    af.af_source,
    af.product_id,
    af.activation_risk_scene_tag,
    af.activation_risk_scene_tag_splx,
    af.activation_risk_scene_tag_combined_limit,
    af.platform_user_id,
    af.apply_no,
    af.workflow_flow_no as risk_af_workflow_flow_no,
    af.app_id as risk_af_app_id,
    af.scene_id as risk_af_scene_id,
    af.run_step as risk_af_workflow_run_step,
    af.create_time as risk_af_workflow_create_time,
    af.update_time as risk_af_workflow_update_time,
    af.flow_trace_id,
    coalesce(uw.cnt_uw_pending, 0) as risk_af_cnt_uw_pending,
    coalesce(uw.pending_duration, 0) as risk_af_pending_duration,
    coalesce(uw.pending_sla_second, 0) as risk_af_pending_sla_second,
    us.user_segment_name as risk_af_uw_user_segment_name,
    case when uw.cnt_uw_pending > 0 then 1 else 0 end as is_uw_processed,
    t.ticket_start_time as risk_af_ticket_start_time,
    t.ticket_update_time as risk_af_ticket_end_time,
    t.ticket_sla_second as risk_af_ticket_sla_second,
    t.ticket_result as risk_af_ticket_result,
    t.ticket_maker_start_time as risk_af_ticket_maker_start_time,
    t.ticket_maker_end_time as risk_af_ticket_maker_end_time,
    case when t.workflow_flow_no is not null then 1 else 0 end as is_finish_risk_af_ticket,
    t.maker_email as risk_af_ticket_maker_email,
    t.maker_map_no as risk_af_ticket_maker_map_no
from unified_af_workflow af
left join uw_pending_summary uw on af.workflow_flow_no = uw.workflow_flow_no
left join uw_user_segment us on af.workflow_flow_no = us.workflow_flow_no
left join
(
select
    workflow_flow_no
    ,ticket_start_time
    ,ticket_update_time
    ,ticket_sla_second
    ,ticket_result
    ,ticket_maker_start_time
    ,ticket_maker_end_time
    ,maker_email
    ,maker_map_no
from risk_report.dws_risk_${region}_activation_ticket_df
where grass_date = '${grass_date}'
) t on af.workflow_flow_no = t.workflow_flow_no
;