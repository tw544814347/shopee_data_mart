use risk;
--********************************************************************--
-- Author:              dongbo.yu@shopee.com
-- Created Time:        2025-10-09T14:00:00
-- Description:         
--                      app_id+scene_id
-- Data Granularity:    grass_date+grass_region
-- PRD                  https://jira.shopee.io/browse/SPFDT-56340
-- Jira                 
-- 
--********************************************************************--
drop table if exists ${SCHEMA}.`dws_risk_reg_af_biz_workflow_di`;

create table if not exists ${SCHEMA}.`dws_risk_reg_af_biz_workflow_di` (
    `platform_user_id` STRING COMMENT 'platform_user_id',
    `app_id` STRING COMMENT 'app_id',
    `scene_id` BIGINT COMMENT 'scene_id',
    `req_no` STRING COMMENT 'req_no',
    `apply_no` STRING COMMENT 'apply_no',
    `channel_id` STRING COMMENT 'channel_id',
    `checkout_id` STRING COMMENT 'checkout_id',
    `loan_id` STRING COMMENT 'loan_id',
    `flow_no` STRING COMMENT 'flow_no',
    `run_step` STRING COMMENT 'run_step',
    `workflow_create_time` STRING COMMENT 'workflow_create_time',
    `workflow_update_time` STRING COMMENT 'workflow_update_time',
    `create_date` STRING COMMENT 'create_time, YYYY-MM-dd',
    `rank_id_for_flow_no` INT COMMENT 'rank_id_for_flow_no',
    `rank_id_for_apply_no` INT COMMENT 'rank_id_for_apply_no',
    `rank_id_for_checkout_id_channel_id` INT COMMENT 'rank_id_for_checkout_id_channel_id',
    `rank_id_for_loan_id` INT COMMENT 'rank_id_for_loan_id',
    `flow_trace_id`       STRING COMMENT 'flow_trace_id, this flow_trace_id for spp,migrated to the extend info table'
) partitioned by (
    biz_name     string comment 'biz name, credit/shopeepay',
    grass_region string comment 'grass region',
    grass_date   string comment 'Date of refreshed data, contains recent 190 days data'
) stored as orc tblproperties (
    "orc.compress" = "ZSTD"
) location '${HDFS_PATH}/dwd/dws_risk_reg_af_biz_workflow_di'
;


msck repair table ${SCHEMA}.dws_risk_reg_af_biz_workflow_di;
refresh table ${SCHEMA}.dws_risk_reg_af_biz_workflow_di;
