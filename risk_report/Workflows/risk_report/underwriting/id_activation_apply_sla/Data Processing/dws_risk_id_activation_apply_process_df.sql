-- =============================================================================
-- Author:              chengguo.liu@shopee.com
-- Created Time:        2025-09-01
-- Theme Domain:        Activation Apply Process
-- Data Granularity:    apply_no
-- Description:         Activation Apply Process Summary Table
-- Documents:           
-- =============================================================================
--  Version History:
--  2025-09-01 - chengguo.liu - 初始化
-- =============================================================================

create or replace temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';

--drop table if exists risk_report.dws_risk_${region}_activation_apply_process_df;
create external table if not exists risk_report.dws_risk_${region}_activation_apply_process_df
(
    apply_no string comment '申请编号，激活申请的唯一标识'
    ,product_id int comment '产品ID: 3=SPL, 7=SPLX, 12=2W, 16=2W_MY'
    ,platform_type bigint comment '平台类型标识'
    ,platform_user_id string comment '平台用户ID，如Shopee用户ID'
    ,credit_user_id string comment '信贷用户ID，Credit系统内部用户标识'
    ,apply_status bigint comment '申请状态: 0,1=用户pending, 4=通过, 5=拒绝'
    ,is_submit bigint comment '是否已提交申请: 1=已提交, 0=未提交'
    ,screen_status bigint comment '审核状态码'
    ,activate_create_time string comment '激活申请创建时间'
    ,activate_start_time string comment '激活流程开始时间'
    ,activate_submit_time string comment '激活申请提交时间'
    ,activate_result_time_for_create_account string comment '创建账户结果时间'
    ,activate_result_time_for_screen string comment '审核结果时间'
    ,credit_screen_platform bigint comment '信贷审核平台标识'
    ,uc_screen_start_time string comment 'UC审核开始时间'
    ,operator string comment '审核操作人'
    ,operator_start_time string comment '操作人开始处理时间'
    ,operator_end_time string comment '操作人结束处理时间'
    ,uc_screen_end_time string comment 'UC审核结束时间'
    ,is_old_shopee_id bigint comment '是否为老Shopee用户: 1=是, 0=否'
    ,is_old_user_id bigint comment '是否为老Credit用户: 1=是, 0=否'
    ,consent_share bigint comment '是否同意数据共享(已有SPP用户): 1=同意, 0=不同意'
    ,is_instore_user tinyint comment '是否为门店用户(线下): 1=是, 0=否'
    ,from_type bigint comment '来源类型: 2=SPLX调额来源'
    ,header_from string comment '请求来源header标识'
    ,flow_trace_id string comment '流程追踪ID，用于关联SPP KYC流程'
    ,risk_spp_kyc_check_step_start_time string comment 'SPP KYC检查步骤开始时间'
    ,risk_spp_kyc_check_step_end_time string comment 'SPP KYC检查步骤结束时间'
    ,channel_type string comment '渠道类型: online=线上, offline=线下'
    ,product_name string comment '产品名称: 3_SPL, 7_SPLX_SPL, 12_2W, 16_SPLX'
    ,activation_result string comment '激活结果: 11-user pending, 21-pass, 22-reject, 9-other'
)
COMMENT 'Tag:risk report summary table'
partitioned by (grass_date string comment "YYYY-MM-DD 日期分区")
stored as orc tblproperties ("orc.compress"="zstd")
location '${HDFS_PATH}/dws/dws_risk_reg_activation_apply_process_df/grass_region=${grass_region}'
;
--msck repair table risk_report.dws_risk_${region}_activation_apply_process_df;

create or replace temporary view uc_apply_unified as 
select
    product_id,
    apply_no,
    platform_type,
    platform_user_id,
    credit_user_id,
    apply_status,
    is_submit,
    screen_status,
    create_time as activate_create_time,
    activate_start_time,
    activate_submit_time,
    activate_result_time_v2 as activate_result_time_for_create_account,
    screen_platform as credit_screen_platform,
    uc_screen_start_time,
    operator,
    operator_start_time,
    operator_end_time,
    uc_screen_end_time,
    activate_result_time as activate_result_time_for_screen,
    header,
    header_from,
    flow_trace_id,
    from_type,
    is_instore_user,
    consent_share
from credit_uc.dwd_all_prod_${region}_uc_apply_df
where
    grass_date = '${grass_date}'
    and apply_type = 1
;

create or replace temporary view user_action_step_with_window as 
select
    apply_no,
    is_old_shopee_id,
    is_old_user_id,
    action,
    step_no,
    create_time,
    update_time,
    lag(update_time, 1, create_time) over (
        partition by apply_no 
        order by step_no asc
    ) as prev_update_time,
    dense_rank() over (partition by apply_no order by create_time desc) as rank_id
from credit_uc.dwd_all_prod_${region}_uc_apply_user_action_step_df
where date(grass_date) = '${grass_date}'
;

create or replace temporary view user_action_step_summary as 
select
    apply_no,
    max(is_old_shopee_id) as is_old_shopee_id,
    max(is_old_user_id) as is_old_user_id,
    max(case 
        when action = 'spp_kyc_check' 
        then prev_update_time
    end) as risk_spp_kyc_check_step_start_time,
    max(case 
        when action = 'spp_kyc_check' 
        then update_time 
    end) as risk_spp_kyc_check_step_end_time
from user_action_step_with_window
where rank_id = 1
group by apply_no;

insert overwrite risk_report.dws_risk_${region}_activation_apply_process_df PARTITION (grass_date = '${grass_date}')
select
    u.apply_no,
    u.product_id,
    u.platform_type,
    u.platform_user_id,
    u.credit_user_id,
    u.apply_status,
    u.is_submit,
    u.screen_status,
    u.activate_create_time,
    u.activate_start_time,
    u.activate_submit_time,
    u.activate_result_time_for_create_account,
    u.activate_result_time_for_screen,
    u.credit_screen_platform,
    u.uc_screen_start_time,
    u.operator,
    u.operator_start_time,
    u.operator_end_time,
    u.uc_screen_end_time,
    s.is_old_shopee_id,
    s.is_old_user_id,
    cast(u.consent_share as bigint),
    u.is_instore_user,
    u.from_type,
    u.header_from,
    u.flow_trace_id,
    s.risk_spp_kyc_check_step_start_time,
    s.risk_spp_kyc_check_step_end_time,
    case
        when u.product_id = 3 and get_json_object(u.header, '$.from') like '%offline%' then 'offline'
        when u.product_id = 3 then 'online'
        when u.product_id = 7 and u.is_instore_user = 1 then 'offline'
        when u.product_id = 7 then 'online'
        when u.product_id = 12 and u.header like '%offline_qr_scan%' then 'offline'
        when u.product_id = 12 then 'online'
    end as channel_type,
    case
        when u.product_id = 3 and u.from_type = 2 then '7_SPLX_SPL'
        when u.product_id = 3 then '3_SPL'
        when u.product_id = 12 then '12_2W'
        when u.product_id = 16 then '16_SPLX'
    end as product_name,
    case
        when u.apply_status in (0,1) then '11-user pending'
        when u.apply_status in (4) then '21-pass'
        when u.apply_status in (5) then '22-reject'
        else '9-other'
    end as activation_result

from uc_apply_unified u
left join user_action_step_summary s on u.apply_no = s.apply_no
where (
    u.activate_start_time >= date_sub('${current_grass_date}', 190)
    or u.activate_submit_time >= date_sub('${current_grass_date}', 190)
);
