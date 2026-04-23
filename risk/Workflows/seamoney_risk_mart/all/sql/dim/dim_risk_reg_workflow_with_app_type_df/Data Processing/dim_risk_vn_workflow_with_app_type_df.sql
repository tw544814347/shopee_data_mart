use risk;
--********************************************************************--
-- Author:              dongbo.yu@shopee.com
-- Created Time:        2025-09-12T14:00:00
-- Description:         
--                      app_id+scene_id
-- Data Granularity:    grass_date+grass_region
-- PRD                  https://docs.google.com/spreadsheets/d/15_k8buzAcFh4YlYbsuXi3JvoPH70Xx791oEiRvUYWJs/edit?gid=356353349#gid=356353349
-- Jira                 https://jira.shopee.io/browse/SPFDT-58639
-- add by dongbo.yu 2025-12-10   two columns (activation_risk_scene_tag+activation_risk_scene_tag_combined_limit)  修复宽表数据问题
-- add by dongbo.yu 2025-12-11   one columns (activation_risk_scene_tag_splx)  修复特殊业务形态
-- add by dongbo.yu 2026-01-14   six columns  (is_for_adjust_limit + adjust_limit_risk_scene_tag + is_for_checkout + checkout_risk_scene_tag + is_for_withdraw + withdraw_risk_scene_tag)  新增贷后相关字段
--********************************************************************--
-- drop table if exists ${SCHEMA}.`dim_risk_${region}_workflow_with_app_type_df`;

create table if not exists ${SCHEMA}.`dim_risk_${region}_workflow_with_app_type_df` (
  app_id               STRING  COMMENT 'app_id, such as kyc/voi/fm',
   scene_id             BIGINT COMMENT 'scene_id, such as 10012/10013/40003',
   event_code           STRING COMMENT 'event_code',
   sub_nodes            STRING COMMENT 'sub_nodes',
   app_type             STRING COMMENT 'app_type',
   risk_scene_wf_name   STRING COMMENT 'risk_scene_wf_name',
   is_for_activation    INT COMMENT 'is_for_activation',
   activation_risk_scene_tag String comment 'activation_risk_scene_tag',
   activation_risk_scene_tag_combined_limit String comment 'activation_risk_scene_tag_combined_limit',
   activation_risk_scene_tag_splx String comment 'activation_risk_scene_tag_splx',
   is_for_adjust_limit int  comment 'is_for_adjust_limit,0/1',
   adjust_limit_risk_scene_tag string comment 'adjust_limit_risk_scene_tag,credit_report_check/credit_af',
   is_for_checkout int comment 'is_for_checkout,0/1',
   checkout_risk_scene_tag string comment 'checkout_risk_scene_tag,credit_overdraft/credit_af',
   is_for_withdraw int comment 'is_for_withdraw,0/1',
   withdraw_risk_scene_tag string comment 'withdraw_risk_scene_tag,credit_af'
) comment 'credit mart dim app type table' 
partitioned by (
    grass_date string comment 'Date of refreshed data'
) stored as orc tblproperties (
    "orc.compress" = "ZSTD"
) location '${HDFS_PATH}/dim/dim_risk_reg_workflow_with_app_type_df/grass_region=${REGION}'
;

-- msck repair table ${SCHEMA}.dim_risk_${region}_workflow_with_app_type_df;
refresh table ${SCHEMA}.dim_risk_${region}_workflow_with_app_type_df;

ADD JAR hdfs://${IDC_NAMESPACE}/projects/credit/hdfs/udf/hive-udf.jar;
drop temporary function if exists format_time; 
create temporary function format_time as 'com.shopee.seamoney.udf.FromTimeStamp';


WITH
  -- 基础维度数据处理
  base_dim_data AS (
      SELECT
                '${REGION}' AS region,
                app_id,
                CAST(scene_id AS BIGINT) AS scene_id,
                event_code,
                sub_nodes,
                -- 应用类型分类逻辑
                CASE
                    -- 贷前 application
                    WHEN LOWER(app_id) IN ('kyc', 'voi')           THEN 'a_activation'
                    WHEN LOWER(event_code) LIKE '%activation%'         THEN 'a_activation'
                    WHEN LOWER(event_code) LIKE '%secondunderwriting%' THEN 'a_activation'  -- VN SPL/BCL 2次授信
                    -- MY TL 激活apply_no不会出现在调额流程
                    WHEN LOWER(event_code) LIKE '%report_check%'       THEN 'a_adjust_limit'
                    WHEN LOWER(event_code) LIKE '%limitadjustment%'    THEN 'a_adjust_limit'
                    WHEN LOWER(event_code) LIKE '%upgrade%' 
                      AND LOWER(event_code) NOT LIKE '%liteupgrade%'   THEN 'a_adjust_limit'  -- 升级为产品的XLTA
                    -- 特殊规则：PH地区的app_id='spr'属于激活
                    WHEN '${REGION}' = 'PH' AND app_id = 'spr'              THEN 'a_activation'
                    -- 贷中 behavior
                    WHEN (LOWER(event_code) LIKE '%cl_payment%' 
                      OR LOWER(event_code) LIKE '%withdraw%')          THEN 'b_withdraw'
                    WHEN LOWER(event_code) LIKE '%payment%'            THEN 'b_checkout'
                    ELSE 'other'
                END AS app_type,
                event_code AS risk_scene_wf_name,
                -- 风险场景标签1：通用激活标签
                CASE
                    WHEN LOWER(app_id) IN ('kyc', 'voi')               THEN 'credit_kyc'
                    WHEN LOWER(event_code) LIKE '%report_check%'       THEN 'credit_report_check'
                    WHEN LOWER(app_id) IN ('spr')                      THEN 'credit_spr'
                    WHEN LOWER(event_code) LIKE '%activation%'         THEN 'credit_af'  -- PH地区可能触发人审工单
                    WHEN LOWER(event_code) LIKE '%secondunderwriting%' THEN 'credit_af_2nd'  -- VN SPL/BCL 2次授信
                    ELSE NULL
                END AS activation_risk_scene_tag,
                -- 风险场景标签2：Combined Limit专用标签
                CASE
                    WHEN LOWER(app_id) IN ('kyc', 'voi')               THEN 'credit_kyc'
                    WHEN LOWER(event_code) LIKE '%report_check%'       THEN 'credit_report_check'
                    WHEN LOWER(app_id) IN ('spr')                      THEN 'credit_spr'
                    WHEN LOWER(event_code) LIKE '%activation%' 
                      AND app_id = 'kredit'                            THEN 'credit_af_spl'  -- combined limit(SPL&BCL)
                    WHEN LOWER(event_code) LIKE '%activation%' 
                      AND app_id = 'spj'                               THEN 'credit_af_bcl'  -- combined limit(SPL&BCL)
                    WHEN LOWER(event_code) LIKE '%activation%'         THEN 'credit_af'      -- PH地区可能触发人审工单
                    WHEN LOWER(event_code) LIKE '%secondunderwriting%' THEN 'credit_af_2nd'  -- VN SPL/BCL 2次授信
                    ELSE NULL
                END AS activation_risk_scene_tag_combined_limit,
                -- 风险场景标签3：SPLX专用标签
                CASE
                    WHEN LOWER(app_id) IN ('kyc', 'voi')               THEN 'credit_kyc'
                    WHEN LOWER(event_code) LIKE '%report_check%'       THEN 'credit_report_check'
                    WHEN LOWER(app_id) IN ('spr')                      THEN 'credit_spr'
                    WHEN LOWER(event_code) LIKE '%activation%' 
                      AND app_id = 'kredit'                            THEN 'credit_af_spl'  -- SPLX会调SPL AF刷新SPL额度
                    WHEN LOWER(event_code) LIKE '%activation%'         THEN 'credit_af'      -- PH地区可能触发人审工单
                    WHEN LOWER(event_code) LIKE '%secondunderwriting%' THEN 'credit_af_2nd'  -- VN SPL/BCL 2次授信
                    ELSE NULL
                END AS activation_risk_scene_tag_splx

        FROM      ${SCHEMA}.ods__credit_risk_control_${region}_db__risk_event_meta_data_tab__df
        WHERE     grass_date   = '${grass_date}'
  )

insert overwrite table ${SCHEMA}.dim_risk_${region}_workflow_with_app_type_df  partition(grass_date='${grass_date}')
SELECT
          app_id,                                                     -- 应用ID
          scene_id,                                                   -- 场景ID
          event_code,                                                 -- 事件编码
          sub_nodes,                                                  -- 子节点
          app_type,                                                   -- 应用类型
          risk_scene_wf_name,                                         -- 风险场景工作流名称
          ------------------- 抽象 贷前激活 activation 相关标签--------------------------------
          -- 是否为激活流程标识
          CASE 
              WHEN app_type = 'a_activation' 
                 OR LOWER(event_code) LIKE '%report_check%' 
              THEN 1 
              ELSE 0 
          END AS is_for_activation,                                   -- 是否用于激活标识
          activation_risk_scene_tag,                                  -- 通用激活风险场景标签
          activation_risk_scene_tag_combined_limit,                   -- Combined Limit风险场景标签
          activation_risk_scene_tag_splx,                             -- SPLX风险场景标签
          ------------------- 抽象 贷前调额 adjust_limit 相关标签--------------------------------
          IF(app_type = 'a_adjust_limit', 1, 0) AS is_for_adjust_limit,
          CASE
              WHEN app_type = 'a_adjust_limit' AND LOWER(event_code) LIKE '%report_check%' THEN 'credit_report_check'
              WHEN app_type = 'a_adjust_limit'                                             THEN 'credit_af'
              ELSE NULL
          END AS adjust_limit_risk_scene_tag,
          ------------------- 抽象 贷中支付 checkout 相关标签--------------------------------
          IF(app_type = 'b_checkout', 1, 0) AS is_for_checkout,
          CASE
              WHEN app_type = 'b_checkout' AND LOWER(event_code) LIKE '%overdraft%' THEN 'credit_overdraft'
              WHEN app_type = 'b_checkout' AND LOWER(event_code) LIKE '%payment%' THEN 'credit_af'
              ELSE NULL
          END AS checkout_risk_scene_tag,
          ------------------- 抽象 贷中提现 withdraw 相关标签--------------------------------
          IF(app_type = 'b_withdraw', 1, 0) AS is_for_withdraw,
          CASE
              WHEN app_type = 'b_withdraw' AND LOWER(event_code) LIKE '%cl_payment%' THEN 'credit_af'
              WHEN app_type = 'b_withdraw' AND LOWER(event_code) LIKE '%withdraw%' THEN 'credit_af'
              ELSE NULL
          END AS withdraw_risk_scene_tag
FROM      base_dim_data
ORDER BY  app_id,
          scene_id,
          event_code
;
-- show create table dev_risk.dim_risk_workflow_with_app_type;