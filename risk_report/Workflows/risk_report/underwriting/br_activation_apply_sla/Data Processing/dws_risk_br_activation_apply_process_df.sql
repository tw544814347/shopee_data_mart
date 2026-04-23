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

drop table if exists risk_report.dws_risk_${region}_activation_apply_process_df;
create external table if not exists risk_report.dws_risk_${region}_activation_apply_process_df
(
    apply_no string comment '申请编号，激活申请的唯一标识'
    ,main_apply_no string comment '主申请编号(用于BR/MX合并额度场景)'
    ,sub_apply_no string comment '子申请编号(用于BR/MX合并额度场景)'
    ,credit_kyc_apply_no string comment 'Credit KYC关联的申请编号'
    ,credit_af_spl_apply_no string comment 'Credit AF SPL关联的申请编号'
    ,credit_af_bcl_apply_no string comment 'Credit AF BCL关联的申请编号'
    ,product_id int comment '产品ID: 3=SPL, 7=SPLX, 12=2W, 16=2W_MY, 1=BCL'
    ,platform_type bigint comment '平台类型标识'
    ,platform_user_id string comment 'shopee_user_id'
    ,credit_user_id string comment 'credit_user_id'
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
    ,consent_share bigint comment 'User consent to share information'
    ,is_instore_user tinyint comment '是否为门店用户(线下): 1=是, 0=否'
    ,from_type bigint comment '来源类型: 2=SPLX调额来源'
    ,header_from string comment 'UC请求header_from'
    ,flow_trace_id string comment 'flow_trace_id，用于uc和risk_spp日志关联'
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
msck repair table risk_report.dws_risk_${region}_activation_apply_process_df;

create or replace temporary view uc_apply_unified as 
select
    product_id,
    apply_no,
    coalesce(cast(main_apply_no as string), '') as main_apply_no,
    if(coalesce(cast(main_apply_no as string), '') in ('', '0'), 1, 0) as is_main_apply_no,
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

create or replace temporary view user_action_step_summary as 
select
    grass_region
    ,product_id
    ,apply_no
    ,max(is_old_shopee_id) as is_old_shopee_id
    ,max(is_old_user_id) as is_old_user_id
    ,min(
        case
            when step_name = 'spp_kyc_check' then step_time_start
        end
    ) as risk_spp_kyc_check_step_start_time
    ,max(
        case
            when step_name = 'spp_kyc_check' then step_time_end
        end
    ) as risk_spp_kyc_check_step_end_time
from credit_uc.dws_uc_reg_apply_user_action_step_df
where
    grass_region = '${grass_region}'
    and grass_date = '${grass_date}'
group by 1, 2, 3
;

insert overwrite risk_report.dws_risk_${region}_activation_apply_process_df PARTITION (grass_date = '${grass_date}')
select
    t1.apply_no,
    t2.apply_no as main_apply_no,
    t3.apply_no AS sub_apply_no,
    -- credit kyc
    CASE
    WHEN t1.grass_region = 'MX'                       THEN t2.apply_no  -- MX都用的主单apply_no
    WHEN t1.grass_region = 'BR' AND t2.product_id = 3 THEN t2.apply_no  -- 主单是SPL,就传SPL的apply_no
    WHEN t1.grass_region = 'BR' AND t2.product_id = 1 THEN t3.apply_no  -- 主单是BCL,就传BCL的子单SPL的apply_no
    ELSE t1.apply_no  -- 其他地区,就传步骤表的apply_no
    END AS credit_kyc_apply_no,
    -- credit af spl
    CASE
    WHEN t1.grass_region = 'MX'                       THEN t2.apply_no  -- MX都用的主单apply_no
    WHEN t1.grass_region = 'BR' AND t2.product_id = 3 THEN t2.apply_no  -- 主单是SPL,就传SPL的apply_no
    WHEN t1.grass_region = 'BR' AND t2.product_id = 1 THEN t3.apply_no  -- 主单是BCL,就传BCL的子单SPL的apply_no
    ELSE t1.apply_no  -- 其他地区,就传步骤表的apply_no
    END AS credit_af_spl_apply_no,
    -- credit af bcl
    CASE
    WHEN t1.grass_region = 'MX'                       THEN t2.apply_no  -- MX都用的主单apply_no
    WHEN t1.grass_region = 'BR' AND t2.product_id = 3 THEN t3.apply_no  -- 主单是SPL,就子单BCL的apply_no
    WHEN t1.grass_region = 'BR' AND t2.product_id = 1 THEN t2.apply_no  -- 主单是BCL,就传主单apply_no
    ELSE t1.apply_no  -- 其他地区,就传步骤表主单的apply_no
    END AS credit_af_bcl_apply_no,
    t2.product_id,
    t2.platform_type,
    t2.platform_user_id,
    t2.credit_user_id,
    t2.apply_status,
    t2.is_submit,
    t2.screen_status,
    t2.activate_create_time,
    t2.activate_start_time,
    t2.activate_submit_time,
    t2.activate_result_time_for_create_account,
    t2.activate_result_time_for_screen,
    t2.credit_screen_platform,
    t2.uc_screen_start_time,
    t2.operator,
    t2.operator_start_time,
    t2.operator_end_time,
    t2.uc_screen_end_time,
    t1.is_old_shopee_id,
    t1.is_old_user_id,
    cast(t2.consent_share as bigint),
    t2.is_instore_user,
    t2.from_type,
    t2.header_from,
    t2.flow_trace_id,
    t1.risk_spp_kyc_check_step_start_time,
    t1.risk_spp_kyc_check_step_end_time,
    case
        when t1.product_id = 3 and get_json_object(t2.header, '$.from') like '%offline%' then 'offline'
        when t1.product_id = 3 then 'online'
        when t1.product_id = 7 and t2.is_instore_user = 1 then 'offline'
        when t1.product_id = 7 then 'online'
        when t1.product_id = 12 and t2.header like '%offline_qr_scan%' then 'offline'
        when t1.product_id = 12 then 'online'
    end as channel_type,
    case
        when t1.product_id = 3 and t2.from_type = 2 then '7_SPLX_SPL'
        when t1.product_id = 3 then '3_SPL'
        when t1.product_id = 12 then '12_2W'
        when t1.product_id = 16 then '16_SPLX'
    end as product_name,
    case
        when t2.apply_status in (0,1) then '11-user pending'
        when t2.apply_status in (4) then '21-pass'
        when t2.apply_status in (5) then '22-reject'
        else '9-other'
    end as activation_result
from user_action_step_summary t1
left join uc_apply_unified t2 on t1.apply_no = t2.apply_no and t2.is_main_apply_no = 1
left join uc_apply_unified t3 on t1.apply_no = t3.main_apply_no
where (
    t2.activate_start_time >= date_sub('${current_grass_date}', 190)
    or t2.activate_submit_time >= date_sub('${current_grass_date}', 190)
)
;