-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-09-01
-- Theme Domain:        Underwriting Activation
-- Data Granularity:    
-- Description:         Underwriting Activation SLA Report Table
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-09-01 - chengguo.liu - 初始化
-- =============================================================================

--drop table if exists risk_report.ads_risk_${region}_activation_apply_sla_df;
create external table if not exists risk_report.ads_risk_${region}_activation_apply_sla_df (
    -- ==================== 基础申请信息 ====================
    product_id int comment '产品ID: 3=SPL, 7=SPLX, 12=2W, 16=2W_MY'
    ,platform_type bigint comment '平台类型标识'
    ,platform_user_id string comment 'shopee_user_id'
    ,credit_user_id string comment 'credit_user_id'
    ,is_old_shopee_id bigint comment '是否为老Shopee用户: 1=是, 0=否'
    ,is_old_user_id bigint comment '是否为老Credit用户: 1=是, 0=否'
    ,apply_no string comment '申请编号，激活申请的唯一标识'
    ,main_apply_no string comment '主申请编号(预留字段)'
    ,sub_apply_no string comment '子申请编号(预留字段)'
    ,apply_status bigint comment '申请状态: 0,1=用户pending, 4=通过, 5=拒绝'
    -- ==================== 业务标签 ====================
    ,tag_offline_or_online string comment '渠道标签: online=线上, offline=线下'
    ,tag_new_or_existing_credit_user string comment '信贷用户标签: new_credit_user=新用户, existing_credit_user=老用户'
    ,tag_new_or_existing_spp_user string comment 'SPP用户标签: new_spp_user=新用户, existing_spp_user=老用户'
    ,prod_name string comment '产品名称: 3_SPL/7_SPLX_SPL/12_2W/16_SPLX'
    ,activation_result string comment '激活结果: 11-user pending/21-pass/22-reject/9-other'
    ,is_offline_in_store_by_uw int comment '是否为线下门店激活(UW判定): 1=是, 0=否'
    ,is_enter_risk_spp_kyc_manual_screen int comment '是否进入SPP KYC人工审核: 1=是, 0=否'
    ,is_enter_risk_credit_kyc_manual_screen int comment '是否进入Credit KYC人工审核: 1=是, 0=否'
    ,is_enter_risk_credit_af_workflow int comment '是否进入Credit AF工作流: 1=是, 0=否'
    ,is_enter_risk_credit_af_uw_pending int comment '是否进入Credit AF UW pending: 1=是, 0=否'
    -- ==================== 申请来源信息 ====================
    ,consent_share bigint comment 'User consent to share information'
    ,is_instore_user tinyint comment '是否为门店用户: 1=是, 0=否'
    ,from_type bigint comment '来源类型: 2=SPLX调额来源'
    ,header_from string comment 'UC请求header_from'
    ,flow_trace_id string comment 'flow_trace_id，用于uc和risk_spp日志关联'
    -- ==================== 激活时间节点 ====================
    ,activate_create_time string comment '激活申请创建时间'
    ,activate_start_time string comment '激活流程开始时间'
    -- ==================== SPP KYC流程信息 ====================
    ,risk_spp_kyc_flow_trace_id string comment 'SPP KYC流程追踪ID'
    ,risk_spp_kyc_workflow_flow_no string comment 'SPP KYC工作流流水号'
    ,risk_spp_kyc_sp_user_id string comment 'SPP KYC平台用户ID'
    ,risk_spp_kyc_workflow_run_step string comment 'SPP KYC工作流当前步骤'
    ,risk_spp_kyc_workflow_create_time string comment 'SPP KYC工作流创建时间'
    ,risk_spp_kyc_workflow_update_time string comment 'SPP KYC工作流更新时间'
    ,risk_spp_kyc_workflow_step_flow_no string comment 'SPP KYC策略步骤流水号'
    ,risk_spp_kyc_shopeepay_user_id string comment 'SPP KYC ShopeePay用户ID'
    ,risk_spp_kyc_biz_id string comment 'SPP KYC业务ID'
    ,risk_spp_kyc_check_result_name string comment 'SPP KYC检查结果: Auto Approve/Auto Reject/Screening/Waiting For Third Data/Others'
    ,risk_spp_kyc_req_time string comment 'SPP KYC请求时间'
    ,risk_spp_kyc_handle_end_time string comment 'SPP KYC处理结束时间'
    ,risk_spp_kyc_screening_result_name string comment 'SPP KYC人审结果: Manual Approve/Manual Reject'
    ,risk_spp_kyc_ticket_status bigint comment 'SPP KYC工单状态'
    ,risk_spp_kyc_ticket_start_time string comment 'SPP KYC工单开始时间'
    ,risk_spp_kyc_ticket_update_time string comment 'SPP KYC工单更新时间'
    ,risk_spp_kyc_ticket_maker_start_time string comment 'SPP KYC工单审核人开始时间'
    ,risk_spp_kyc_ticket_maker_end_time string comment 'SPP KYC工单审核人结束时间'
    ,risk_spp_kyc_ticket_maker_email string comment 'SPP KYC工单审核人邮箱'
    ,risk_spp_kyc_ticket_maker_map_no string comment 'SPP KYC工单审核人MAP工号'
    ,risk_spp_kyc_status_name string comment 'SPP KYC最终状态: Approved/Rejected/Pending/Others'
    ,risk_spp_kyc_screening_type string comment 'SPP KYC审核类型: Auto Decision/Manual Decision/Unknown'
    ,is_finish_risk_spp_kyc_ticket int comment '是否完成SPP KYC工单: 1=是, 0=否'
    -- ==================== 激活提交信息 ====================
    ,activate_submit_time string comment '激活申请提交时间'
    ,is_submit bigint comment '是否已提交: 1=是, 0=否'
    ,risk_spp_kyc_check_step_start_time string comment 'SPP KYC检查步骤开始时间(UC侧)'
    ,risk_spp_kyc_check_step_end_time string comment 'SPP KYC检查步骤结束时间(UC侧)'
    -- ==================== Credit KYC流程信息 ====================
    ,risk_credit_kyc_app_id string comment 'Credit KYC应用ID'
    ,risk_credit_kyc_scene_id bigint comment 'Credit KYC场景ID'
    ,risk_credit_kyc_workflow_flow_no string comment 'Credit KYC工作流流水号'
    ,risk_credit_kyc_workflow_run_step string comment 'Credit KYC工作流当前步骤'
    ,risk_credit_kyc_workflow_create_time string comment 'Credit KYC工作流创建时间'
    ,risk_credit_kyc_workflow_update_time string comment 'Credit KYC工作流更新时间'
    ,risk_credit_kyc_ticket_start_time string comment 'Credit KYC工单开始时间'
    ,risk_credit_kyc_ticket_end_time string comment 'Credit KYC工单结束时间'
    ,risk_credit_kyc_ticket_sla_second bigint comment 'Credit KYC工单SLA时长(秒)'
    ,risk_credit_kyc_ticket_result string comment 'Credit KYC工单结果'
    ,risk_credit_kyc_ticket_maker_start_time string comment 'Credit KYC工单审核人开始时间'
    ,risk_credit_kyc_ticket_maker_end_time string comment 'Credit KYC工单审核人结束时间'
    ,risk_credit_kyc_ticket_maker_email string comment 'Credit KYC工单审核人邮箱'
    ,risk_credit_kyc_ticket_maker_map_no string comment 'Credit KYC工单审核人MAP工号'
    ,is_finish_risk_credit_kyc_ticket int comment '是否完成Credit KYC工单: 1=是, 0=否'
    -- ==================== Credit Report Check流程信息 ====================
    ,risk_credit_report_check_app_id string comment 'Credit报告检查应用ID'
    ,risk_credit_report_check_scene_id bigint comment 'Credit报告检查场景ID'
    ,risk_credit_report_check_workflow_flow_no string comment 'Credit报告检查工作流流水号'
    ,risk_credit_report_check_workflow_run_step string comment 'Credit报告检查工作流当前步骤'
    ,risk_credit_report_check_workflow_create_time string comment 'Credit报告检查工作流创建时间'
    ,risk_credit_report_check_workflow_update_time string comment 'Credit报告检查工作流更新时间'
    ,risk_credit_report_check_ticket_start_time string comment 'Credit报告检查工单开始时间'
    ,risk_credit_report_check_ticket_end_time string comment 'Credit报告检查工单结束时间'
    ,risk_credit_report_check_ticket_sla_second bigint comment 'Credit报告检查工单SLA时长(秒)'
    ,risk_credit_report_check_ticket_result string comment 'Credit报告检查工单结果'
    ,risk_credit_report_check_ticket_maker_email string comment 'Credit报告检查工单审核人邮箱'
    ,risk_credit_report_check_ticket_maker_map_no string comment 'Credit报告检查工单审核人MAP工号'
    ,risk_credit_report_check_ticket_maker_start_time string comment 'Credit报告检查工单审核人开始时间'
    ,risk_credit_report_check_ticket_maker_end_time string comment 'Credit报告检查工单审核人结束时间'
    ,is_finish_risk_credit_report_check_ticket int comment '是否完成Credit报告检查工单: 1=是, 0=否'
    -- ==================== Credit SPR(PH特有)流程信息 ====================
    ,risk_credit_spr_workflow_flow_no string comment 'Credit SPR工作流流水号'
    ,risk_credit_spr_workflow_run_step string comment 'Credit SPR工作流当前步骤'
    ,risk_credit_spr_workflow_create_time string comment 'Credit SPR工作流创建时间'
    ,risk_credit_spr_workflow_update_time string comment 'Credit SPR工作流更新时间'
    ,risk_credit_spr_ticket_start_time string comment 'Credit SPR工单开始时间'
    ,risk_credit_spr_ticket_end_time string comment 'Credit SPR工单结束时间'
    ,risk_credit_spr_ticket_sla_second bigint comment 'Credit SPR工单SLA时长(秒)'
    ,risk_credit_spr_ticket_result string comment 'Credit SPR工单结果'
    ,risk_credit_spr_ticket_maker_email string comment 'Credit SPR工单审核人邮箱'
    ,risk_credit_spr_ticket_maker_map_no string comment 'Credit SPR工单审核人MAP工号'
    ,risk_credit_spr_ticket_maker_start_time string comment 'Credit SPR工单审核人开始时间'
    ,risk_credit_spr_ticket_maker_end_time string comment 'Credit SPR工单审核人结束时间'
    ,is_finish_risk_credit_spr_ticket int comment '是否完成Credit SPR工单: 1=是, 0=否'
    -- ==================== Credit AF主流程信息 ====================
    ,risk_credit_af_workflow_flow_no string comment 'Credit AF工作流流水号'
    ,risk_credit_af_app_id string comment 'Credit AF应用ID'
    ,risk_credit_af_scene_id bigint comment 'Credit AF场景ID'
    ,risk_credit_af_workflow_run_step string comment 'Credit AF工作流当前步骤'
    ,risk_credit_af_workflow_create_time string comment 'Credit AF工作流创建时间'
    ,risk_credit_af_workflow_update_time string comment 'Credit AF工作流更新时间'
    ,risk_credit_af_ticket_start_time string comment 'Credit AF工单开始时间'
    ,risk_credit_af_ticket_end_time string comment 'Credit AF工单结束时间'
    ,risk_credit_af_ticket_sla_second string comment 'Credit AF工单SLA时长(秒)'
    ,risk_credit_af_ticket_result string comment 'Credit AF工单结果'
    ,risk_credit_af_ticket_maker_email string comment 'Credit AF工单审核人邮箱'
    ,risk_credit_af_ticket_maker_map_no string comment 'Credit AF工单审核人MAP工号'
    ,risk_credit_af_ticket_maker_start_time string comment 'Credit AF工单审核人开始时间'
    ,risk_credit_af_ticket_maker_end_time string comment 'Credit AF工单审核人结束时间'
    ,is_finish_risk_credit_af_ticket int comment '是否完成Credit AF工单: 1=是, 0=否'
    ,risk_credit_af_cnt_uw_pending bigint comment 'Credit AF UW pending次数'
    ,risk_credit_af_uw_pending_sla_second bigint comment 'Credit AF UW pending SLA时长(秒)'
    ,risk_credit_af_uw_user_segment_name string comment 'Credit AF UW用户分群名称'
    -- ==================== Credit Screen审核信息 ====================
    ,credit_screen_status bigint comment 'Credit人审状态码'
    ,credit_screen_platform bigint comment 'Credit人审平台标识'
    ,credit_screen_start_time string comment 'Credit人审开始时间'
    ,credit_screen_end_time string comment 'Credit人审结束时间'
    ,credit_screen_operator string comment 'Credit人审操作人'
    ,credit_screen_operator_start_time string comment 'Credit人审操作人开始时间'
    ,credit_screen_operator_end_time string comment 'Credit人审操作人结束时间'
    ,activate_result_time_for_credit_screen string comment 'Credit人审激活结果时间(取各环节最大值)'
    -- ==================== Credit AF SPL(SPLX调额专用)流程信息 ====================
    ,risk_credit_af_spl_workflow_flow_no string comment 'Credit AF SPL工作流流水号(SPLX调额SPL反欺诈)'
    ,risk_credit_af_spl_app_id string comment 'Credit AF SPL应用ID'
    ,risk_credit_af_spl_scene_id bigint comment 'Credit AF SPL场景ID'
    ,risk_credit_af_spl_workflow_run_step string comment 'Credit AF SPL工作流当前步骤'
    ,risk_credit_af_spl_workflow_create_time string comment 'Credit AF SPL工作流创建时间'
    ,risk_credit_af_spl_workflow_update_time string comment 'Credit AF SPL工作流更新时间'
    ,risk_credit_af_spl_cnt_uw_pending bigint comment 'Credit AF SPL UW pending次数'
    ,risk_credit_af_spl_uw_pending_sla_second bigint comment 'Credit AF SPL UW pending SLA时长(秒)'
    -- ==================== Credit AF BCL(预留)流程信息 ====================
    ,risk_credit_af_bcl_workflow_flow_no string comment 'Credit AF BCL工作流流水号(预留字段)'
    ,risk_credit_af_bcl_app_id string comment 'Credit AF BCL应用ID(预留字段)'
    ,risk_credit_af_bcl_scene_id bigint comment 'Credit AF BCL场景ID(预留字段)'
    ,risk_credit_af_bcl_workflow_run_step string comment 'Credit AF BCL工作流当前步骤(预留字段)'
    ,risk_credit_af_bcl_workflow_create_time string comment 'Credit AF BCL工作流创建时间(预留字段)'
    ,risk_credit_af_bcl_workflow_update_time string comment 'Credit AF BCL工作流更新时间(预留字段)'
    ,risk_credit_af_bcl_cnt_uw_pending bigint comment 'Credit AF BCL UW pending次数(预留字段)'
    ,risk_credit_af_bcl_uw_pending_sla_second bigint comment 'Credit AF BCL UW pending SLA时长(预留字段)'
    -- ==================== Credit AF 2nd(VN二次授信)流程信息 ====================
    ,risk_credit_af_2nd_workflow_flow_no string comment 'Credit AF二次授信工作流流水号(VN)'
    ,risk_credit_af_2nd_app_id string comment 'Credit AF二次授信应用ID'
    ,risk_credit_af_2nd_scene_id bigint comment 'Credit AF二次授信场景ID'
    ,risk_credit_af_2nd_workflow_run_step string comment 'Credit AF二次授信工作流当前步骤'
    ,risk_credit_af_2nd_workflow_create_time string comment 'Credit AF二次授信工作流创建时间'
    ,risk_credit_af_2nd_workflow_update_time string comment 'Credit AF二次授信工作流更新时间'
)
COMMENT 'Tag:risk report summary table'
partitioned by
    (grass_date string comment "YYYY-MM-DD 日期分区") stored as orc tblproperties ("orc.compress" = "zstd") location '${HDFS_PATH}/ads/ads_risk_reg_activation_apply_sla_df/grass_region=${grass_region}'
;
--msck repair table risk_report.ads_risk_${region}_activation_apply_sla_df;


create or replace temporary view uc_apply_combined as
select
    -- 基础UC申请数据
    product_id
    ,apply_no
    ,platform_type
    ,platform_user_id
    ,credit_user_id
    ,apply_status
    ,is_submit
    ,screen_status
    ,activate_create_time
    ,activate_start_time
    ,activate_submit_time
    ,activate_result_time_for_create_account
    ,credit_screen_platform
    ,uc_screen_start_time
    ,operator
    ,operator_start_time
    ,operator_end_time
    ,uc_screen_end_time
    ,activate_result_time_for_screen
    ,header_from
    ,flow_trace_id
    ,from_type
    ,is_instore_user
    -- 用户行为步骤数据
    ,is_old_shopee_id
    ,is_old_user_id
    ,risk_spp_kyc_check_step_start_time
    ,risk_spp_kyc_check_step_end_time
    -- 申请人信息
    ,consent_share
from risk_report.dws_risk_${region}_activation_apply_process_df
where grass_date = '${grass_date}'
;

create or replace temporary view credit_screen as
select
    apply_no
    ,product_id
    ,risk_screen_start_time
    ,risk_screen_end_time
    ,risk_screen_operator
    ,risk_screen_operator_start_time
    ,risk_screen_operator_end_time
from
(
    select
        apply_no
        ,product_id
        ,submission_time as risk_screen_start_time
        ,screen_completed_time as risk_screen_end_time
        ,operator as risk_screen_operator
        ,operator_start_time as risk_screen_operator_start_time
        ,operator_end_time as risk_screen_operator_end_time
        ,ROW_NUMBER() OVER( PARTITION BY apply_no ORDER BY operator_start_time DESC ) AS rank_id
    from risk.dwd_credit_${screen_region}_risk_screen_df
    where
        1 = ${has_risk_screen}
        and grass_date = '${grass_date}'
        and apply_type = 1
        and screen_type <> 'RiskAuto'
        and maker_operator <> 'System_Revoked'
        and operator_start_time <> ''
        and operator_end_time > operator_start_time
)
where rank_id = 1
;

create or replace temporary view credit_kyc as
select
    apply_no
    ,risk_af_app_id as risk_credit_kyc_app_id
    ,risk_af_scene_id as risk_credit_kyc_scene_id
    ,risk_af_workflow_flow_no as risk_credit_kyc_workflow_flow_no
    ,risk_af_workflow_run_step as risk_credit_kyc_workflow_run_step
    ,risk_af_workflow_create_time as risk_credit_kyc_workflow_create_time
    ,risk_af_workflow_update_time as risk_credit_kyc_workflow_update_time
    ,risk_af_ticket_start_time as risk_credit_kyc_ticket_start_time
    ,risk_af_ticket_end_time as risk_credit_kyc_ticket_end_time
    ,risk_af_ticket_sla_second as risk_credit_kyc_ticket_sla_second
    ,risk_af_ticket_result as risk_credit_kyc_ticket_result
    ,risk_af_ticket_maker_start_time as risk_credit_kyc_ticket_maker_start_time
    ,risk_af_ticket_maker_end_time as risk_credit_kyc_ticket_maker_end_time
    ,is_finish_risk_af_ticket as is_finish_risk_credit_kyc_ticket
    ,risk_af_ticket_maker_email as risk_credit_kyc_ticket_maker_email
    ,risk_af_ticket_maker_map_no as risk_credit_kyc_ticket_maker_map_no
from risk_report.dws_risk_${region}_activation_af_workflow_df
where grass_date = '${grass_date}'
and af_source = 'credit_af'
and activation_risk_scene_tag = 'credit_kyc'
;

create or replace temporary view credit_report_check as
select
    apply_no
    ,risk_af_app_id as risk_credit_report_check_app_id
    ,risk_af_scene_id as risk_credit_report_check_scene_id
    ,risk_af_workflow_flow_no as risk_credit_report_check_workflow_flow_no
    ,risk_af_workflow_run_step as risk_credit_report_check_workflow_run_step
    ,risk_af_workflow_create_time as risk_credit_report_check_workflow_create_time
    ,risk_af_workflow_update_time as risk_credit_report_check_workflow_update_time
    ,risk_af_ticket_start_time as risk_credit_report_check_ticket_start_time
    ,risk_af_ticket_end_time as risk_credit_report_check_ticket_end_time
    ,risk_af_ticket_sla_second as risk_credit_report_check_ticket_sla_second
    ,risk_af_ticket_result as risk_credit_report_check_ticket_result
    ,risk_af_ticket_maker_start_time as risk_credit_report_check_ticket_maker_start_time
    ,risk_af_ticket_maker_end_time as risk_credit_report_check_ticket_maker_end_time
    ,is_finish_risk_af_ticket as is_finish_risk_credit_report_check_ticket
    ,risk_af_ticket_maker_email as risk_credit_report_check_ticket_maker_email
    ,risk_af_ticket_maker_map_no as risk_credit_report_check_ticket_maker_map_no
from risk_report.dws_risk_${region}_activation_af_workflow_df
where grass_date = '${grass_date}'
and af_source = 'credit_af'
and activation_risk_scene_tag = 'credit_report_check'
;

--credit workflow total
create or replace temporary view credit_af as
select
    af_source
    ,apply_no
    ,risk_af_workflow_flow_no as risk_credit_af_workflow_flow_no
    ,risk_af_app_id as risk_credit_af_app_id
    ,risk_af_scene_id as risk_credit_af_scene_id
    ,risk_af_workflow_run_step as risk_credit_af_workflow_run_step
    ,risk_af_workflow_create_time as risk_credit_af_workflow_create_time
    ,risk_af_workflow_update_time as risk_credit_af_workflow_update_time
    ,risk_af_ticket_start_time as risk_credit_af_ticket_start_time
    ,risk_af_ticket_end_time as risk_credit_af_ticket_end_time
    ,risk_af_ticket_sla_second as risk_credit_af_ticket_sla_second
    ,risk_af_ticket_result as risk_credit_af_ticket_result
    ,risk_af_ticket_maker_start_time as risk_credit_af_ticket_maker_start_time
    ,risk_af_ticket_maker_end_time as risk_credit_af_ticket_maker_end_time
    ,is_finish_risk_af_ticket as is_finish_risk_credit_af_ticket
    ,risk_af_ticket_maker_email as risk_credit_af_ticket_maker_email
    ,risk_af_ticket_maker_map_no as risk_credit_af_ticket_maker_map_no
    ,risk_af_cnt_uw_pending as risk_credit_af_cnt_uw_pending
    ,risk_af_pending_sla_second as risk_credit_af_pending_sla_second
    ,risk_af_uw_user_segment_name as user_segment_name
from risk_report.dws_risk_${region}_activation_af_workflow_df
where
    grass_date = '${grass_date}'
    and (
        (
            product_id = 7
            and activation_risk_scene_tag_splx = 'credit_af'
        )
        or (
            product_id <> 7
            and activation_risk_scene_tag = 'credit_af'
        )
    )
;

--credit workflow splx, 调额有1个相同的apply_no，但是不同的flow_no, 调spl的反欺诈流程
create or replace temporary view credit_af_splx_include_spl as
select
    af_source
    ,apply_no
    ,risk_af_workflow_flow_no as risk_credit_af_spl_workflow_flow_no
    ,risk_af_app_id as risk_credit_af_spl_app_id
    ,risk_af_scene_id as risk_credit_af_spl_scene_id
    ,risk_af_workflow_run_step as risk_credit_af_spl_workflow_run_step
    ,risk_af_workflow_create_time as risk_credit_af_spl_workflow_create_time
    ,risk_af_workflow_update_time as risk_credit_af_spl_workflow_update_time
    ,risk_af_cnt_uw_pending as risk_credit_af_spl_cnt_uw_pending
    ,risk_af_pending_sla_second as risk_credit_af_spl_uw_pending_sla_second
from risk_report.dws_risk_${region}_activation_af_workflow_df
where grass_date = '${grass_date}'
and product_id = 7
and activation_risk_scene_tag_splx = 'credit_af_spl'
;

--PH SPR
create or replace temporary view credit_spr as
select
    apply_no
    ,risk_af_app_id as risk_credit_spr_app_id
    ,risk_af_scene_id as risk_credit_spr_scene_id
    ,risk_af_workflow_flow_no as risk_credit_spr_workflow_flow_no
    ,risk_af_workflow_run_step as risk_credit_spr_workflow_run_step
    ,risk_af_workflow_create_time as risk_credit_spr_workflow_create_time
    ,risk_af_workflow_update_time as risk_credit_spr_workflow_update_time
    ,risk_af_ticket_start_time as risk_credit_spr_ticket_start_time
    ,risk_af_ticket_end_time as risk_credit_spr_ticket_end_time
    ,risk_af_ticket_sla_second as risk_credit_spr_ticket_sla_second
    ,risk_af_ticket_result as risk_credit_spr_ticket_result
    ,risk_af_ticket_maker_start_time as risk_credit_spr_ticket_maker_start_time
    ,risk_af_ticket_maker_end_time as risk_credit_spr_ticket_maker_end_time
    ,is_finish_risk_af_ticket as is_finish_risk_credit_spr_ticket
    ,risk_af_ticket_maker_email as risk_credit_spr_ticket_maker_email
    ,risk_af_ticket_maker_map_no as risk_credit_spr_ticket_maker_map_no
from risk_report.dws_risk_${region}_activation_af_workflow_df
where grass_date = '${grass_date}'
and af_source = 'credit_af'
and activation_risk_scene_tag = 'credit_spr'
;

--VN 二次授信
create or replace temporary view credit_2nd as
select
    af_source
    ,apply_no
    ,risk_af_workflow_flow_no as risk_credit_af_2nd_workflow_flow_no
    ,risk_af_app_id as risk_credit_af_2nd_app_id
    ,risk_af_scene_id as risk_credit_af_2nd_scene_id
    ,risk_af_workflow_run_step as risk_credit_af_2nd_workflow_run_step
    ,risk_af_workflow_create_time as risk_credit_af_2nd_workflow_create_time
    ,risk_af_workflow_update_time as risk_credit_af_2nd_workflow_update_time
from risk_report.dws_risk_${region}_activation_af_workflow_df
where grass_date = '${grass_date}'
and af_source = 'credit_af'
and activation_risk_scene_tag = 'credit_af_2nd'
;

create or replace temporary view spp_af_strategy as
select 
    t1.workflow_flow_no
    ,t1.platform_user_id
    ,t1.flow_trace_id
    ,t1.risk_af_workflow_run_step
    ,t1.risk_af_workflow_create_time
    ,t1.risk_af_workflow_update_time
    ,t2.flow_no
    ,t2.shopeepay_user_id
    ,t2.biz_id
    ,t2.check_result_name
    ,t2.req_time
    ,t2.handle_end_time
    ,t2.req_date
    ,t2.handle_end_date
    ,t3.ticket_result
    ,t3.ticket_status
    ,t3.ticket_result_name
    ,t3.ticket_start_time
    ,t3.ticket_update_time
    ,t3.ticket_maker_start_time
    ,t3.ticket_maker_end_time
    ,t3.is_finish_risk_spp_kyc_ticket
    ,t3.risk_spp_kyc_ticket_maker_email
    ,t3.risk_spp_kyc_ticket_maker_map_no
from
(
    select
        risk_af_workflow_flow_no as workflow_flow_no
        ,platform_user_id
        ,flow_trace_id
        ,risk_af_workflow_run_step
        ,risk_af_workflow_create_time
        ,risk_af_workflow_update_time
    from risk_report.dws_risk_${region}_activation_af_workflow_df
    where grass_date = '${grass_date}'
    and af_source = 'spp_af'
) t1
left join
(
    select
        flow_trace_id,
        workflow_flow_no,
        flow_no,
        shopeepay_user_id,
        biz_id,
        check_result_name,
        req_time,
        handle_end_time,
        req_date,
        handle_end_date
    from risk_report.dws_risk_${region}_activation_af_strategy_df
    where grass_date = '${grass_date}'
) t2 on t1.workflow_flow_no = t2.workflow_flow_no
left join
(
    select
        workflow_flow_no
        ,ticket_result
        ,ticket_result_name
        ,ticket_status
        ,ticket_start_time
        ,ticket_update_time
        ,ticket_maker_start_time
        ,ticket_maker_end_time
        ,is_spp_ticket as is_finish_risk_spp_kyc_ticket
        ,maker_email as risk_spp_kyc_ticket_maker_email
        ,maker_map_no as risk_spp_kyc_ticket_maker_map_no
    from
        risk_report.dws_risk_${region}_activation_ticket_df 
    where
        grass_date = '${grass_date}'
        and is_spp_ticket = 1
) t3 on t2.workflow_flow_no = t3.workflow_flow_no
;


insert overwrite
    risk_report.ads_risk_${region}_activation_apply_sla_df partition (grass_date = '${grass_date}')
select
    t1.product_id
    ,t1.platform_type
    ,t1.platform_user_id
    ,t1.credit_user_id
    ,t1.is_old_shopee_id
    ,t1.is_old_user_id
    ,t1.apply_no
    ,null as main_apply_no
    ,null as sub_apply_no
    ,t1.apply_status
    ,case
    -- SPL
        when t1.product_id = 3 and t1.header_from like '%offline%' then 'offline'
        when t1.product_id = 3 then 'online'
        -- SPLX
        when t1.product_id = 7 and t1.is_instore_user = 1 then 'offline'
        when t1.product_id = 7 then 'online'
        -- 2W
        when t1.product_id = 12 and t1.header_from like '%offline_qr_scan%' then 'offline'
        when t1.product_id = 12 then 'online'
        -- 2W MY 特殊逻辑
        when t1.product_id = 16 and t1.header_from = 'seller_me_page' then 'offline'
        when t1.product_id = 16 then 'online'        
    end as tag_offline_or_online
    ,if (
        t1.is_old_user_id = 0
        ,'new_credit_user'
        ,'existing_credit_user'
    ) as tag_new_or_existing_credit_user
    ,if (t1.consent_share = 1, 'existing_spp_user', 'new_spp_user') as tag_new_or_existing_spp_user
    ,case
        when t1.product_id = 3 and t1.from_type = 2 then '7_SPLX_SPL'
        when t1.product_id = 3 then '3_SPL'
        when t1.product_id = 12 then '12_2W'
        when t1.product_id = 16 then '16_SPLX'
    end as prod_name
    ,case
        when t1.apply_status in (0, 1) then '11-user pending'
        when t1.apply_status in (4) then '21-pass'
        when t1.apply_status in (5) then '22-reject'
        else '9-other'
    end as activation_result
    ,if (
        t6.user_segment_name in ('SPLX in store activation', 'SA QR Scan SPL Activation')
        ,1
        ,0
    ) as is_offline_in_store_by_uw
    ,coalesce(t9.is_finish_risk_spp_kyc_ticket, 0) as is_enter_risk_spp_kyc_manual_screen
    ,coalesce(t5.is_finish_risk_credit_kyc_ticket, 0) as is_enter_risk_credit_kyc_manual_screen
    ,if (
        coalesce(t6.risk_credit_af_workflow_create_time, '') <> ''
        ,1
        ,0
    ) as is_enter_risk_credit_af_workflow
    ,if (t6.risk_credit_af_cnt_uw_pending > 0, 1, 0) as is_enter_risk_credit_af_uw_pending
    ,t1.consent_share
    ,t1.is_instore_user
    ,t1.from_type
    ,t1.header_from
    ,t1.flow_trace_id
    ,t1.activate_create_time
    ,t1.activate_start_time
    ,t9.flow_trace_id as risk_spp_kyc_flow_trace_id
    ,t9.workflow_flow_no as risk_spp_kyc_workflow_flow_no
    ,t9.platform_user_id as risk_spp_kyc_sp_user_id
    ,t9.risk_af_workflow_run_step as risk_spp_kyc_workflow_run_step
    ,t9.risk_af_workflow_create_time as risk_spp_kyc_workflow_create_time
    ,t9.risk_af_workflow_update_time as risk_spp_kyc_workflow_update_time
    ,t9.flow_no as risk_spp_kyc_workflow_step_flow_no
    ,t9.shopeepay_user_id as risk_spp_kyc_shopeepay_user_id
    ,t9.biz_id as risk_spp_kyc_biz_id
    ,t9.check_result_name as risk_spp_kyc_check_result_name
    ,t9.req_date as risk_spp_kyc_req_time
    ,t9.handle_end_date as risk_spp_kyc_handle_end_time
    ,t9.ticket_result_name as risk_spp_kyc_screening_result_name
    ,t9.ticket_status as risk_spp_kyc_ticket_status
    ,t9.ticket_start_time as risk_spp_kyc_ticket_start_time
    ,t9.ticket_update_time as risk_spp_kyc_ticket_update_time
    ,t9.ticket_maker_start_time as risk_spp_kyc_ticket_maker_start_time
    ,t9.ticket_maker_end_time as risk_spp_kyc_ticket_maker_end_time
    ,t9.risk_spp_kyc_ticket_maker_email
    ,t9.risk_spp_kyc_ticket_maker_map_no
    ,case
        when t9.check_result_name = 'Auto Approve' or t9.ticket_result_name = 'Manual Approve' then 'Approved'
        when t9.check_result_name in ('Auto Reject', 'Waiting For Third Data') or t9.ticket_result_name = 'Manual Reject' then 'Rejected'
        when t9.check_result_name = 'Screening' and t9.ticket_result_name is null then 'Pending'
        else 'Others'
    end as risk_spp_kyc_status_name
    ,case
        when t9.check_result_name in ('Auto Approve', 'Auto Reject', 'Waiting For Third Data') then 'Auto Decision'
        when t9.check_result_name = 'Screening' THEN 'Manual Decision'
        else 'Unknown'
    end as risk_spp_kyc_screening_type
    ,coalesce(t9.is_finish_risk_spp_kyc_ticket, 0) as is_finish_risk_spp_kyc_ticket
    ,t1.activate_submit_time
    ,t1.is_submit
    ,t1.risk_spp_kyc_check_step_start_time
    ,t1.risk_spp_kyc_check_step_end_time
    ,t5.risk_credit_kyc_app_id
    ,t5.risk_credit_kyc_scene_id
    ,t5.risk_credit_kyc_workflow_flow_no
    ,t5.risk_credit_kyc_workflow_run_step
    ,t5.risk_credit_kyc_workflow_create_time
    ,t5.risk_credit_kyc_workflow_update_time
    ,t5.risk_credit_kyc_ticket_start_time
    ,t5.risk_credit_kyc_ticket_end_time
    ,t5.risk_credit_kyc_ticket_sla_second
    ,t5.risk_credit_kyc_ticket_result
    ,t5.risk_credit_kyc_ticket_maker_start_time
    ,t5.risk_credit_kyc_ticket_maker_end_time
    ,t5.risk_credit_kyc_ticket_maker_email
    ,t5.risk_credit_kyc_ticket_maker_map_no
    ,coalesce(t5.is_finish_risk_credit_kyc_ticket, 0) as is_finish_risk_credit_kyc_ticket
    ,t10.risk_credit_report_check_app_id
    ,t10.risk_credit_report_check_scene_id
    ,t10.risk_credit_report_check_workflow_flow_no
    ,t10.risk_credit_report_check_workflow_run_step
    ,t10.risk_credit_report_check_workflow_create_time
    ,t10.risk_credit_report_check_workflow_update_time
    ,t10.risk_credit_report_check_ticket_start_time
    ,t10.risk_credit_report_check_ticket_end_time
    ,t10.risk_credit_report_check_ticket_sla_second
    ,t10.risk_credit_report_check_ticket_result
    ,t10.risk_credit_report_check_ticket_maker_email
    ,t10.risk_credit_report_check_ticket_maker_map_no
    ,t10.risk_credit_report_check_ticket_maker_start_time
    ,t10.risk_credit_report_check_ticket_maker_end_time
    ,coalesce(t10.is_finish_risk_credit_report_check_ticket, 0) as is_finish_risk_credit_report_check_ticket
    ,t8.risk_credit_spr_workflow_flow_no
    ,t8.risk_credit_spr_workflow_run_step
    ,t8.risk_credit_spr_workflow_create_time
    ,t8.risk_credit_spr_workflow_update_time
    ,t8.risk_credit_spr_ticket_start_time
    ,t8.risk_credit_spr_ticket_end_time
    ,t8.risk_credit_spr_ticket_sla_second
    ,t8.risk_credit_spr_ticket_result
    ,t8.risk_credit_spr_ticket_maker_email
    ,t8.risk_credit_spr_ticket_maker_map_no
    ,t8.risk_credit_spr_ticket_maker_start_time
    ,t8.risk_credit_spr_ticket_maker_end_time
    ,coalesce(t8.is_finish_risk_credit_spr_ticket, 0) as is_finish_risk_credit_spr_ticket
    ,t6.risk_credit_af_workflow_flow_no
    ,t6.risk_credit_af_app_id
    ,t6.risk_credit_af_scene_id
    ,t6.risk_credit_af_workflow_run_step
    ,t6.risk_credit_af_workflow_create_time
    ,t6.risk_credit_af_workflow_update_time
    ,t6.risk_credit_af_ticket_start_time
    ,t6.risk_credit_af_ticket_end_time
    ,t6.risk_credit_af_ticket_sla_second
    ,t6.risk_credit_af_ticket_result
    ,t6.risk_credit_af_ticket_maker_email
    ,t6.risk_credit_af_ticket_maker_map_no
    ,t6.risk_credit_af_ticket_maker_start_time
    ,t6.risk_credit_af_ticket_maker_end_time
    ,coalesce(t6.is_finish_risk_credit_af_ticket, 0) as is_finish_risk_credit_af_ticket
    ,t6.risk_credit_af_cnt_uw_pending
    ,t6.risk_credit_af_pending_sla_second as risk_credit_af_uw_pending_sla_second
    ,t6.user_segment_name as risk_credit_af_uw_user_segment_name
    ,t1.screen_status as credit_screen_status
    ,t1.credit_screen_platform
    ,coalesce(t4.risk_screen_start_time, t1.uc_screen_start_time) as credit_screen_start_time
    ,coalesce(t4.risk_screen_end_time, t1.uc_screen_end_time) as credit_screen_end_time
    ,coalesce(t4.risk_screen_operator, t1.operator) as credit_screen_operator
    ,coalesce(
        t4.risk_screen_operator_start_time
        ,t1.operator_start_time
    ) as credit_screen_operator_start_time
    ,coalesce(
        t4.risk_screen_operator_end_time
        ,t1.operator_end_time
    ) as credit_screen_operator_end_time
    ,greatest (
        coalesce(t4.risk_screen_end_time, t1.uc_screen_end_time)
        ,coalesce(t4.risk_screen_operator_end_time, t1.operator_end_time)
        ,t1.activate_result_time_for_screen
        ,t1.activate_result_time_for_create_account
    ) as activate_result_time_for_credit_screen
    -- risk_credit_af_spl 相关字段
    ,t11.risk_credit_af_spl_workflow_flow_no
    ,t11.risk_credit_af_spl_app_id
    ,t11.risk_credit_af_spl_scene_id
    ,t11.risk_credit_af_spl_workflow_run_step
    ,t11.risk_credit_af_spl_workflow_create_time
    ,t11.risk_credit_af_spl_workflow_update_time
    ,t11.risk_credit_af_spl_cnt_uw_pending
    ,t11.risk_credit_af_spl_uw_pending_sla_second
    -- risk_credit_af_bcl 相关字段
    ,null as risk_credit_af_bcl_workflow_flow_no
    ,null as risk_credit_af_bcl_app_id
    ,null as risk_credit_af_bcl_scene_id
    ,null as risk_credit_af_bcl_workflow_run_step
    ,null as risk_credit_af_bcl_workflow_create_time
    ,null as risk_credit_af_bcl_workflow_update_time
    ,null as risk_credit_af_bcl_cnt_uw_pending
    ,null as risk_credit_af_bcl_uw_pending_sla_second
    -- risk_credit_af_2nd 相关字段
    ,t12.risk_credit_af_2nd_workflow_flow_no
    ,t12.risk_credit_af_2nd_app_id
    ,t12.risk_credit_af_2nd_scene_id
    ,t12.risk_credit_af_2nd_workflow_run_step
    ,t12.risk_credit_af_2nd_workflow_create_time
    ,t12.risk_credit_af_2nd_workflow_update_time
from
    uc_apply_combined as t1
    left join credit_screen as t4 on t1.apply_no = t4.apply_no
    left join credit_kyc as t5 on t1.apply_no = t5.apply_no
    left join credit_spr as t8 on t1.apply_no = t8.apply_no
    left join credit_af as t6 on t1.apply_no = t6.apply_no
    left join spp_af_strategy as t9 on t1.flow_trace_id = t9.flow_trace_id
    left join credit_report_check as t10 on t1.apply_no = t10.apply_no
    left join credit_af_splx_include_spl as t11 on t1.apply_no = t11.apply_no
    left join credit_2nd as t12 on t1.apply_no = t12.apply_no
;