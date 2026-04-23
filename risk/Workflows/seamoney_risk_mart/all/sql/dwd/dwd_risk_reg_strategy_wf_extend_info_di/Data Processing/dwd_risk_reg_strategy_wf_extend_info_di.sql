use risk;
--********************************************************************--
-- Author:              dongbo.yu@shopee.com
-- Created Time:        2025-09-12T14:00:00
-- Description:         
--                      app_id+scene_id
-- Data Granularity:    grass_date+grass_region
-- PRD                  https://docs.google.com/spreadsheets/d/15_k8buzAcFh4YlYbsuXi3JvoPH70Xx791oEiRvUYWJs/edit?gid=356353349#gid=356353349
-- Jira                 

--********************************************************************--
-- drop table if exists ${SCHEMA}.`dwd_risk_reg_strategy_wf_extend_info_di`;

create table if not exists ${SCHEMA}.`dwd_risk_reg_strategy_wf_extend_info_di` (
  app_id               STRING  COMMENT 'app_id, such as kyc/voi/fm',
   scene_id             BIGINT COMMENT 'scene_id, such as 10012/10013/40003',
   flow_no              STRING COMMENT 'flow_no',
   req_time             BIGINT COMMENT 'request send time',
   handle_begin_time    BIGINT COMMENT 'handle_begin_time',
   handle_end_time      BIGINT COMMENT 'handle_end_time',
   fm_check_info        STRING COMMENT 'Rsp.RiskInsight.fmCheckInfo',
   process_date         STRING COMMENT 'data process date'
) partitioned by (
    grass_region string comment 'Region of refreshed data',
    grass_date string comment 'Date of refreshed data'
) stored as orc tblproperties (
    "orc.compress" = "ZSTD"
) location '${HDFS_PATH}/dwd/dwd_risk_reg_strategy_wf_extend_info_di'
;

-- msck repair table ${SCHEMA}.dwd_risk_reg_strategy_wf_extend_info_di;
refresh table ${SCHEMA}.dwd_risk_reg_strategy_wf_extend_info_di;

