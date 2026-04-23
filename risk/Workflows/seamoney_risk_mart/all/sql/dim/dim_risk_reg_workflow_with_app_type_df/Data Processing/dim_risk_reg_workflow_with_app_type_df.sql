use risk;
--********************************************************************--
-- Author:              dongbo.yu@shopee.com
-- Created Time:        2025-09-12T14:00:00
-- Description:         
--                      app_id+scene_id
-- Data Granularity:    grass_date+grass_region
-- PRD                  https://docs.google.com/spreadsheets/d/15_k8buzAcFh4YlYbsuXi3JvoPH70Xx791oEiRvUYWJs/edit?gid=356353349#gid=356353349
-- Jira                 
-- 
--********************************************************************--
drop table if exists ${SCHEMA}.`dim_risk_reg_workflow_with_app_type_df`;

create table if not exists ${SCHEMA}.`dim_risk_reg_workflow_with_app_type_df` (
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
    grass_region string comment 'grass_region',
    grass_date string comment 'Date of refreshed data'
) stored as orc tblproperties (
    "orc.compress" = "ZSTD"
) location '${HDFS_PATH}/dim/dim_risk_reg_workflow_with_app_type_df'
;

msck repair table ${SCHEMA}.dim_risk_reg_workflow_with_app_type_df;
refresh table ${SCHEMA}.dim_risk_reg_workflow_with_app_type_df;

